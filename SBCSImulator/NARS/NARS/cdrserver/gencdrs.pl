#!/usr/local/bin/perl

# generate a bunch of CDR/CDT files just like the iserver does
# Usage: gencdrs.pl [-n <calls> -e <calls>] <-f master cdr file> | <-c config file> [cdr_dir [num_lines_in_cdr]]
#     -n x = create a normal call with duration zero for every x calls
#     -e x = create an error call with duration > zero for every x calls
#     -g gzip the files when rolling over to the next file
#     -m create cdrs with the maximum creation rate possible (no sleeps)
#     default cdr_dir = .
#     default num_lines_in_cdr = 1000
#     default cdr file creation = 3600 secs (one an hour)

use strict;

use Getopt::Std;
use File::Copy;
use Time::HiRes;
use Fcntl;
use Time::Local;
use POSIX qw(strftime);


my $DEBUG = 0;

my $MSWNAME = 'mswname';

my $DEFAULT_OUTPUT_DIR = '.';     # default directory where cdr files are created
my $DEFAULT_LINES_IN_CDR = 3600;  # default number of lines in a cdr file
my $DEFAULT_CREATE_TIME = 3600;   # default number of seconds in which a cdr file is created

my $DEFAULT_MIN_DURATION = 5;   # default minimum number of seconds for the duration of the call
my $DEFAULT_MAX_DURATION = 3600; # default maximum number of seconds for the duration of the call

my $DEFAULT_BUSY_PERCENT = .10;        # percentage of calls that are busy
my $DEFAULT_ABANDONED_PERCENT = 0.05;  # percentage of calls that are abandoned
my $DEFAULT_NOROUTE_PERCENT = 0.10;    # percentage of calls that did not have a route
my $VARIANCE = 0.10;   # 10% variance for error call percentages

my $SRC_PACKETS_LOSS_PERCENT = 0.02;   # percentage of packet loss on the src leg
my $DST_PACKETS_LOSS_PERCENT = 0.01;   # percentage of packet loss on the dst leg
my $PACKET_LOSS_VARIANCE = 0.05;       # 5% variance on packet loss

my $SRC_RFACTOR = 90;        # R factor on the src leg
my $DST_RFACTOR = 90;        # R factor on the dst leg
my $RFACTOR_VARIANCE = 0.05; # 5% variance on R factor

my $CODEC_SAMPLE_RATE = 20;  # 20msec sample rate

my $srcPacketLossPerLow = $SRC_PACKETS_LOSS_PERCENT - ($SRC_PACKETS_LOSS_PERCENT*$PACKET_LOSS_VARIANCE);
my $srcPacketLossPerHigh = $SRC_PACKETS_LOSS_PERCENT + ($SRC_PACKETS_LOSS_PERCENT*$PACKET_LOSS_VARIANCE);
my $dstPacketLossPerLow = $DST_PACKETS_LOSS_PERCENT - ($DST_PACKETS_LOSS_PERCENT*$PACKET_LOSS_VARIANCE);
my $dstPacketLossPerHigh = $DST_PACKETS_LOSS_PERCENT + ($DST_PACKETS_LOSS_PERCENT*$PACKET_LOSS_VARIANCE);
my $srcRfacLow = $SRC_RFACTOR - ($SRC_RFACTOR*$RFACTOR_VARIANCE);
my $srcRfacHigh = $SRC_RFACTOR + ($SRC_RFACTOR*$RFACTOR_VARIANCE);
my $dstRfacLow = $DST_RFACTOR - ($DST_RFACTOR*$RFACTOR_VARIANCE);
my $dstRfacHigh = $DST_RFACTOR + ($DST_RFACTOR*$RFACTOR_VARIANCE);

# indexes of stored data per gw<->gw tuple
my $BUSY_LIMIT = 0;
my $ABAN_LIMIT = 1;
my $NORO_LIMIT = 2;
my $NUM_BUSY = 3;
my $NUM_ABAN = 4;
my $NUM_NORO = 5;
my $NUM_GOOD = 6;
my $BUSY_DIR = 7;
my $ABAN_DIR = 8;
my $NORO_DIR = 9;
my $SRC_LOSS_PER = 10;
my $SRC_LOSS_DIR = 14;
my $DST_LOSS_PER = 10;
my $DST_LOSS_DIR = 15;
my $SRC_RFAC = 16;
my $SRC_RFAC_DIR = 18;
my $DST_RFAC = 17;
my $DST_RFAC_DIR = 19;



# cdr error codes
#         error type  =>  error desc,    isdn code
my %errorCodes = ( '3' => ['invalid-phone', '28'],
                   '7' => ['user-blocked', '21'],
                   '12' => ['network-error', '38'],
                   '13' => ['no-route', '3'],
                   '14' => ['no-ports', '42'],
                   '15' => ['general-error', '31'],
                   '1001' => ['resource-unavailable', '47'],
                   '1002' => ['dest-unreach', '20'],
                   '1003' => ['undefined', '31'],
                   '1004' => ['no-bandwidth', '34'],
                   '1005' => ['h245-error', ''],
                   '1006' => ['incomp-addr', '88'],
                   '1007' => ['local-disconnect'],
                   '1008' => ['h323-internal', ''],
                   '1009' => ['h323-proto', ''],
                   '1010' => ['no-call-handle', ''],
                   '1011' => ['gw-resource-unavailable', '42'],
                   '1012' => ['fce-error-setup', ''],
                   '1013' => ['fce-error', ''],
                   '1014' => ['no-vports', ''],
                   '1015' => ['hairpin', ''],
                   '1016' => ['shutdown', ''],
                   '1017' => ['disconnect-unreach', '3'],
                   '1018' => ['temporarily-unavailable', '41'],
                   '1019' => ['switchover', ''],
                   '1020' => ['dest-relcomp', '26'],
                   '1021' => ['fce-no-vports', ''],
                   '5300' => ['sip-redirect', ''],
                   '5401' => ['401 authorization required', '57'],
                   '5403' => ['403 forbidden', ''],
                   '5407' => ['407 proxy authorization required', '57'],
                   '5500' => ['500 internal error', ''],
                   '5501' => ['501 not implemented', '97'],
                   '5503' => ['503 service unavailable', '63'],
                   );

my %busyCodes = ( '1' => ['busy', '17'],
                  );
my %abandonedCodes = ( '2' => ['abandoned', '19'],
                       );


# output auto-flush
$| = 1;

die "Usage: $0 [-n <calls> -e <calls>] [ -g | -m ] [ -s <starttime> -i <interarrivaltime> -t <endtime>] <-c | -f> <filename> [cdr_dir [num_lines_in_cdr]]" unless @ARGV;

our ($opt_n, $opt_e, $opt_s, $opt_i, $opt_t, $opt_f, $opt_c, $opt_g, $opt_m);
getopts('n:e:gms:i:t:f:c:') or die "Usage: $0 [-n <calls> -e <calls>] [ -g | -m ] [ -s <starttime> -i <interarrivaltime> -t <endtime> ] <-c | -f> <filename> [cdr_dir [num_lines_in_cdr]]";

my $master_file = $opt_c || $opt_f;

$opt_e = -1 unless $opt_e;
$opt_n = -1 unless $opt_n;
$opt_s = -1 unless $opt_s;
$opt_i = -1 unless $opt_i;
$opt_t = -1 unless $opt_t;


# the directory to create the new CDR/CDT files
my $cdr_dir = defined($ARGV[0])?$ARGV[0]:$DEFAULT_OUTPUT_DIR;

# the number of entries in each new CDR files
my $line_count = defined($ARGV[1])?$ARGV[1]:$DEFAULT_LINES_IN_CDR;

print "Using \"" . $master_file . "\" to create " . $line_count . " line cdr files in \"" . $cdr_dir . "\"\n";
if ($opt_c)
{
    if ($opt_n != -1)
    {
        print "Will produce a normal call with duration = 0 for every $opt_n calls\n";
    }
    if ($opt_e != -1)
    {
        print "Will produce an error call with duration > 0 for every $opt_e calls\n";
    }
}
my $startTime = time;
my $interarrivaltime = $DEFAULT_CREATE_TIME * (1000000/$line_count);
if ($opt_s != -1)
{
	my ($yyyy, $mm, $dd, $hh, $mn, $ss) = ($opt_s =~ /(\d+)-(\d+)-(\d+)-(\d+)-(\d+)-(\d+)/);
	$startTime = timelocal($ss, $mn, $hh, $dd, $mm, $yyyy);
	my $strftStartTime = strftime("%Y-%m-%d %H:%M:%S", localtime($startTime)); 
	print "Will produce calls starting at ".$strftStartTime."\n";
}

my $endTime = $startTime + 10; #added constant to force endTime to be greater than startTime
if ($opt_t != -1)
{

	my ($yyyy, $mm, $dd, $hh, $mn, $ss) = ($opt_t =~ /(\d+)-(\d+)-(\d+)-(\d+)-(\d+)-(\d+)/);
	$endTime = timelocal($ss, $mn, $hh, $dd, $mm, $yyyy);
	my $strftEndTime = strftime("%Y-%m-%d %H:%M:%S", localtime($endTime)); 
	print "Will stop producing calls at ".$strftEndTime."\n";


}
if($opt_i != -1)
{
	print "Will produce calls with ".$opt_i." microseconds inter arrival time \n";
	$interarrivaltime = $opt_i;
}
my $cdr_count = 0;
my $filename;
    # try to make one cdr file approximately every 20 seconds
my $sleeptime = $DEFAULT_CREATE_TIME * (1000000/$line_count);
my $keepWorking = 1;

# install signal handler
$SIG{TERM} = $SIG{INT} = $SIG{KILL} = \&exit;
$SIG{HUP} = $SIG{PIPE} = $SIG{USR1} = $SIG{USR2} = 'IGNORE';

if ($opt_c)
{
    workFromConfig();
}
else
{
    workFromFile();
}


# create the CDR entries from a master cdr file
sub workFromFile
{
    # open the master file
    open(MASTER, "< $master_file") or die "Cannot open \"" . $master_file . "\": $!\n";

    # loop through the entire master file
    while ($keepWorking && (my $line = <MASTER>) && ($startTime < $endTime))
    {
        createCDR($line);
    }

    close(CDRFILE);
    close(MASTER);
}


my @gateways;        # list of gateways from the config
my @ports;           # corresponding port numbers
my @ips;             # corresponding ip addresses
my @realms;          # corresponding realms
my $prefixes = {};   # contains a list of phone number prefixes hashed by gateway
my $exts = {};       # contains a list of extension lengths hashed by gateway
my $allowedGws = {}; # contains a list of gateways hashed by gateway
my $errors = {};     # contains a list of error limits and error counts hashed by src and dst gws

# create random cdr entries from the given configuration
sub workFromConfig
{
    readConfigFile();

    die "Need atleast 2 gateways to generate cdrs" unless (@gateways > 1);

    my $cdrSeqNum = int(rand(1000000000));
    my $needOptN = 0;
    my $needOptE = 0;

    while ($keepWorking && ($startTime < $endTime))
    {
        # choose the source and destination gateway
        my ($srcGw, $srcPort, $srcIp, $srcRealm, $srcNum) = chooseRandomGw();
        my ($dstGw, $dstPort, $dstIp, $dstRealm, $dstNum) = chooseRandomGw($srcGw, $srcPort, $srcIp, $srcRealm);

        # call duration (inited to error call duration)
        my $duration = int(rand(26)) + 5;

        # get the reference to current error counts
        my $numGood = \$errors->{$srcGw}{$dstGw}[$NUM_GOOD];
        my $numBusy = \$errors->{$srcGw}{$dstGw}[$NUM_BUSY];
        my $numAbandoned = \$errors->{$srcGw}{$dstGw}[$NUM_ABAN];
        my $numNoRoute = \$errors->{$srcGw}{$dstGw}[$NUM_NORO];

        # get the error limits
        my $busyLimit = $errors->{$srcGw}{$dstGw}[$BUSY_LIMIT];
        my $abanLimit = $errors->{$srcGw}{$dstGw}[$ABAN_LIMIT];
        my $noroLimit = $errors->{$srcGw}{$dstGw}[$NORO_LIMIT];

        # get the asr variance direction
        my $busyDir = \$errors->{$srcGw}{$dstGw}[$BUSY_DIR];
        my $abanDir = \$errors->{$srcGw}{$dstGw}[$ABAN_DIR];
        my $noroDir = \$errors->{$srcGw}{$dstGw}[$NORO_DIR];

        # determine what kind of cdr (good, busy, abandoned, no route) we are going to generate
        my $total = $$numGood + $$numBusy + $$numAbandoned + $$numNoRoute;

        my $isdnCode = '16';  # normal clearing
        my $discCode = 'N';
        my $errString = '';
        my $errType = '0';
        if ($total > 0)
        {
            my $busyPer = $$numBusy/$total;
            my $busyPerLow = $busyLimit - ($busyLimit*$VARIANCE);
            my $busyPerHigh = $busyLimit + ($busyLimit*$VARIANCE);
            if ($$busyDir == 0 && $busyPer <= $busyPerLow) {
                $$busyDir = 1;
            } elsif ($$busyDir == 1 && $busyPer >= $busyPerHigh) {
                $$busyDir = 0;
            }

            my $abanPer = $$numAbandoned/$total;
            my $abanPerLow = $abanLimit - ($abanLimit*$VARIANCE);
            my $abanPerHigh = $abanLimit + ($abanLimit*$VARIANCE);
            if ($$abanDir == 0 && $abanPer <= $abanPerLow) {
                $$abanDir = 1;
            } elsif ($$abanDir == 1 && $abanPer >= $abanPerHigh) {
                $$abanDir = 0;
            }

            my $noroPer = $$numNoRoute/$total;
            my $noroPerLow = $noroLimit - ($noroLimit*$VARIANCE);
            my $noroPerHigh = $noroLimit + ($noroLimit*$VARIANCE);
            if ($$noroDir == 0 && $noroPer <= $noroPerLow) {
                $$noroDir = 1;
            } elsif ($$noroDir == 1 && $noroPer >= $noroPerHigh) {
                $$noroDir = 0;
            }

            if (int(rand(2)) && $$busyDir == 1)
            {
                # generate a busy cdr
                $$numBusy++;
                $discCode = 'B';
                ($errType, $errString, $isdnCode) = getRandomFromHash(\%busyCodes);
            }
            elsif (int(rand(2)) && $$abanDir == 1)
            {
                # generate an abandoned cdr
                $$numAbandoned++;
                $discCode = 'A';
                ($errType, $errString, $isdnCode) = getRandomFromHash(\%abandonedCodes);
            }
            elsif (int(rand(2)) && $$noroDir == 1)
            {
                # generate a no route error cdr
                $$numNoRoute++;
                $discCode = 'E';
                ($errType, $errString, $isdnCode) = getRandomFromHash(\%errorCodes);
                if ($errType eq '13')
                {
                    # if it is our no route error
                    $dstIp = '0.0.0.0';
                    $dstPort = 0;
                    $dstGw = '';
                    $duration = 0;
                }
            }
        }

        # generate a good cdr
        if ($discCode eq 'N')
        {
            $$numGood++;
            $duration = int(rand($DEFAULT_MAX_DURATION-$DEFAULT_MIN_DURATION+1)) + $DEFAULT_MIN_DURATION;
        }

        # for every $opt_n number of calls, produce a normal CDR with duration = 0
        if ($opt_n != -1 && $total && $total%$opt_n == 0)
        {
            $needOptN = 1;
        }
        if ($needOptN && $discCode eq 'N')
        {
            $duration = 0;
            $needOptN = 0;
        }

        # for every $opt_e number of calls produce an error CDR with duration > 0
        if ($opt_e != -1 && $total && $total%$opt_e == 0)
        {
            $needOptE = 1;
        }
        if ($needOptE && $discCode ne 'N')
        {
            $duration = int(rand($DEFAULT_MAX_DURATION-$DEFAULT_MIN_DURATION+1)) + $DEFAULT_MIN_DURATION;
            $needOptE = 0;
        }

	if ($opt_s == -1)
	{
	        $startTime = time - $duration;
		if ($opt_t == -1)
		{
			$endTime = $startTime + 10; #force endtime to be greater than starttime if no endtime specified
		}
	}

        my $protocol = ($cdrSeqNum++%2 == 0)?'sip':'h323';
        my $peerProtocol = (int(rand(2)) == 1)?'sip':'h323';

        my $ddur = '0.0';
        if ($duration > 0)
        {
            my $msec = int(rand(1000));
            if ($msec < 500)
            {
                $ddur = $duration . '.' . $msec;
            }
            else
            {
                $ddur = ($duration-1) . '.' . $msec;
            }
        }

        my $dntype = int(rand(8));
        $dntype = 0 if ($dntype == 6);

        my $cntype = int(rand(8));
        $cntype = 0 if ($cntype == 6);

        # get the packet loss and Rfactor storage areas
        my $srcLossPer = \$errors->{$srcGw}{$dstGw}[$SRC_LOSS_PER];
        my $srcLossDir = \$errors->{$srcGw}{$dstGw}[$SRC_LOSS_DIR];
        my $dstLossPer = \$errors->{$srcGw}{$dstGw}[$DST_LOSS_PER];
        my $dstLossDir = \$errors->{$srcGw}{$dstGw}[$DST_LOSS_DIR];
        my $srcRfactor = \$errors->{$srcGw}{$dstGw}[$SRC_RFAC];
        my $srcRfacDir = \$errors->{$srcGw}{$dstGw}[$SRC_RFAC_DIR];
        my $dstRfactor = \$errors->{$srcGw}{$dstGw}[$DST_RFAC];
        my $dstRfacDir = \$errors->{$srcGw}{$dstGw}[$DST_RFAC_DIR];

        # calculate packets and packet loss

        # number of packets is based on G711 codec (64Kbits/sec) and 20msec sample rate
        my $numPackets = $duration*(1000/$CODEC_SAMPLE_RATE);

        # calculate source packets
        $$srcLossPer = $SRC_PACKETS_LOSS_PERCENT if ($$srcLossPer == 0);
        if ($$srcLossDir == 0) {
            my $variance = rand($PACKET_LOSS_VARIANCE*100)/100;
            $$srcLossPer = $$srcLossPer - ($$srcLossPer*$variance);
            $$srcLossDir = 1 if ($$srcLossPer <= $srcPacketLossPerLow);
        } elsif ($$srcLossDir == 1) {
            my $variance = rand($PACKET_LOSS_VARIANCE*100)/100;
            $$srcLossPer = $$srcLossPer + ($$srcLossPer*$variance);
            $$srcLossDir = 0 if ($$srcLossPer >= $srcPacketLossPerHigh);
        }
        my $srcPacketsLost = int($numPackets*$$srcLossPer);

        # calculate destination packets
        $$dstLossPer = $DST_PACKETS_LOSS_PERCENT if ($$dstLossPer == 0);
        if ($$dstLossDir == 0) {
            my $variance = rand($PACKET_LOSS_VARIANCE*100)/100;
            $$dstLossPer = $$dstLossPer - ($$dstLossPer*$variance);
            $$dstLossDir = 1 if ($$dstLossPer <= $dstPacketLossPerLow);
        } elsif ($$dstLossDir == 1) {
            my $variance = rand($PACKET_LOSS_VARIANCE*100)/100;
            $$dstLossPer = $$dstLossPer + ($$dstLossPer*$variance);
            $$dstLossDir = 0 if ($$dstLossPer >= $dstPacketLossPerHigh);
        }
        my $dstPacketsLost = int($numPackets*$$dstLossPer);

        # calculate source R-factor
        $$srcRfactor = $SRC_RFACTOR if ($$srcRfactor == 0);
        if ($$srcRfacDir == 0) {
            my $variance = rand($RFACTOR_VARIANCE*100)/100;
            $$srcRfactor = $$srcRfactor - int($$srcRfactor*$variance);
            $$srcRfacDir = 1 if ($$srcRfactor <= $srcRfacLow);
        } elsif ($$srcRfacDir == 1) {
            my $variance = rand($RFACTOR_VARIANCE*100)/100;
            $$srcRfactor = $$srcRfactor + int($$srcRfactor*$variance);
            $$srcRfacDir = 0 if ($$srcRfactor >= $srcRfacHigh);
        }

        # calculate destination R-factor
        $$dstRfactor = $DST_RFACTOR if ($$dstRfactor == 0);
        if ($$dstRfacDir == 0) {
            my $variance = rand($RFACTOR_VARIANCE*100)/100;
            $$dstRfactor = $$dstRfactor - int($$dstRfactor*$variance);
            $$dstRfacDir = 1 if ($$dstRfactor <= $dstRfacLow);
        } elsif ($$dstRfacDir == 1) {
            my $variance = rand($RFACTOR_VARIANCE*100)/100;
            $$dstRfactor = $$dstRfactor + int($$dstRfactor*$variance);
            $$dstRfacDir = 0 if ($$dstRfactor >= $dstRfacHigh);
        }

        my $cdr = strftime("%Y-%m-%d %H:%M:%S", localtime($startTime)) . ';' .
# start-time
            $startTime . ';' .
# call-duration
            toTimeString($duration) . ';' .
# call-source
            $srcIp . ';' .
# call-source-q931sig-port
            (30000 + int(rand(25000))) . ';' .
# call-dest
            $dstIp . ';' .
            ';' .
# call-source-custid
            ';' .
# called-party-on-dest
            $dstNum . ';' .
# called-party-from-src
            $dstNum . ';' .
# call-type
            'IV' . ';' .
            '01' . ';' .
# disconnect-error-type
            $discCode . ';' .
# call-error
            $errType . ';' . 
# call-error
            $errString . ';' .
            ';' .
            ';' .
# ani
            $srcNum . ';' .
            ';' .
            ';' .
            ';' .
# cdr-seq-no
            $cdrSeqNum . ';' .
            ';' .
# callid
            time . $srcNum . $dstNum . $duration . ';' .
# call-hold-time
            '000:00:0' . int(rand(6)) . ';' .
# call-source-regid
            $srcGw . ';' .
# call-source-uport
            $srcPort . ';' .
# call-dest-regid
            $dstGw . ';' .
# call-dest-uport
            $dstPort . ';' .
# isdn-cause-code
            $isdnCode . ';' .
# called-party-after-src-calling-plan
            $dstNum . ';' .
# call-error-dest
            ';' .
# call-error-dest
            ';' .
# call-error-event-str
            ';' .
# new-ani
            $srcNum . ';' .
# call-duration
            $duration . ';' .
# incoming-leg-callid
            ';' .
# protocol
            $protocol . ';' .
# cdr-type
            'end1' . ';' .
# hunting-attempts
            '1' . ';' .
# caller-trunk-group
            ';' .
# call-pdd
            (int(rand(850))+50) . ';' .
# h323-dest-ras-error
            ';' .
# h323-dest-h225-error
            ';' .
# sip-dest-respcode
            ';' .
# destination-trunk-group
            ';' .
# duration in sec.msec format
            $ddur . ';' .
# local time zone
            strftime("%Z", localtime($startTime)) . ';' .
# MSW name
            $MSWNAME . ';' . 
# called-party-number-after-transitRoute
            $dstNum . ';' .
# destination-number-type
            $dntype . ';' .
# called-number-type
            $cntype . ';' .
# src realm
            $srcRealm . ';' .
# dest realm
            $dstRealm . ';' .
# route name
            'routename' . ';' .
# dest custid
            'destcustid' . ';' .
# call zone
            'callzone' . ';' .
# called-party-on-dest-num-type
            $dntype . ';' .
# called-party-on-src-num-type
            $cntype . ';' .
# original-isdn
            $isdnCode . ';' .
# packets-received-on-src-leg
            $numPackets . ';' .
# packets-lost-on-src-leg
            $srcPacketsLost . ';' .
# packets-discarded-on-src-leg
            '0' . ';' .
# pdv-on-src-leg
            '10' . ';' .
# codec-on-src-leg
            'G711' . ';' .
# latency-on-src-leg
            '10' . ';' .
# rfactor-on-src-leg
            $$srcRfactor . ';' .
# packets-received-on-dest-leg
            $numPackets . ';' .
# packets-lost-on-dest-leg
            $dstPacketsLost . ';' .
# packets-discarded-on-dest-leg
            '0' . ';' .
# pdv-on-dest-leg
            '10' . ';' .
# codec-on-dest-leg
            'G711' . ';' .
# latency-on-dest-leg
            '10' . ';' .
# rfactor-on-dest-leg
            $$dstRfactor . ';' .
# source sip response code
            '' . ';' .
# peer protocol
            $peerProtocol . ';' .
# source private IP
            '10.0.0.1' . ';' .
# destination private IP
            '10.0.0.2' . ';' .
# source igroup name
            'srcigrp' . ';' .
# destination igroup name
            'dstigrp' . ';' .
# diversion info
            'diversioninfo' . ';' .
# custom contact tag
            'customcontact' .

            "\n";

        createCDR($cdr);
    }

    close(CDRFILE);

    if ($DEBUG == 0)
    {
        File::Copy::move("$cdr_dir/$filename.CDT", "$cdr_dir/$filename.CDR") or warn "move failed for \"" . $filename . ".CDT\": $!\n";
        if ($opt_g)
        {
            system("gzip $cdr_dir/$filename.CDR") == 0 or warn "gzip failed for \"" . $filename . ".CDT\": $?\n";
        }
    }
}


# append the given cdr line to the right cdr/cdt file
sub createCDR
{
    my $entry = $_[0];

    if ($DEBUG)
    {
        print $entry;
	if ($opt_s != -1) 
	{
		#$startTime = $startTime*(1000000) + $interarrivaltime;
		#$startTime = $startTime/1000000;
	} else
	{
            if (!$opt_m)
            {
        	Time::HiRes::usleep($sleeptime);
            }
	}
        return 1;
    }

    my $curTime = time;

    # for every batch of entries, create a new .CDT file
    if (($cdr_count % $line_count == 0) || (($curTime - $filename) >= $DEFAULT_CREATE_TIME))
    {
        # close the previous CDT file and rename it to CDR        
        if ($cdr_count != 0)
        {
            close(CDRFILE);
            File::Copy::move("$cdr_dir/$filename.CDT", "$cdr_dir/$filename.CDR") or warn "move failed for \"" . $filename . ".CDT\": $!\n";
            if ($opt_g)
            {
                system("gzip $cdr_dir/$filename.CDR") == 0 or warn "gzip failed for \"" . $filename . ".CDT\": $?\n";
            }
        }
	if ($opt_s != -1)
	{
	        $filename = $startTime;
	} else
	{
		$filename = $curTime;
	}
        sysopen(CDRFILE, "$cdr_dir/$filename.CDT", O_WRONLY|O_CREAT|O_TRUNC) or die "Cannot open \"" . $filename . ".CDT\": $!\n";
        print "creating new CDT file: $cdr_dir/$filename.CDT...\n";
    }

    syswrite(CDRFILE, $entry);

    $cdr_count++;

    if (($cdr_count % $line_count == 0) || (($curTime - $filename) >= $DEFAULT_CREATE_TIME))
    {
        # before file roles over, sleep for a random time
        sleep(int(rand(10)) + 1);
    }
    else
    {
        # sleep time between cdr lines
	if ($opt_s != -1)
	{
		$startTime = $startTime*1000000 + $interarrivaltime;
		$startTime = $startTime/1000000;
		if ($opt_t == -1)
		{
			$endTime = $startTime + 10;
		}
	}else
	{
            if (!$opt_m)
            {
	        Time::HiRes::usleep($sleeptime);
            }
	}
    }

    return 1;
}


sub readConfigFile
{
    # open the config file
    open(MASTER, "< $master_file") or die "Cannot open \"" . $master_file . "\": $!\n";

    print "Allowed Traffic Flows:\n";

    # loop through the entire master file
    while ($keepWorking && (my $line = <MASTER>) && ($startTime < $endTime))
    {
        # exclude the comment lines
        if ($line =~ /^#/)
        {
            next;
        }
        $line =~ s/\s//;
        if ($line eq '')
        {
            next;
        }

        my ($gw, $port, $ip, $range, $allowed) = split(/;/, $line);
        push(@gateways, $gw);
        push(@ports, $port);
	my $realm = '';
        my ($ip, $realm) = split(/,/, $ip);
        push(@ips, $ip);
        push(@realms, $realm);

        # create the allowed destination gateways for each source gateway
        @{$allowedGws->{$gw}} = ();
        if (defined($allowed))
        {
            if ($allowed eq '')
            {
                # no gws configured, i.e., this gw cannot source any calls
                push(@{$allowedGws->{$gw}}, '<none>');
            }
            else
            {
                my @agws = split(/,/, $allowed);
                foreach my $agw (@agws)
                {
                    my ($gatew, $bus, $aban, $norout) = split(/%/, $agw);
                    chomp($gatew);
                    push(@{$allowedGws->{$gw}}, $gatew);
                    if ($bus)
                    {
                        $bus /= 100;
                        $aban /= 100;
                        $norout /= 100;
                    }
                    else
                    {
                        $bus = $DEFAULT_BUSY_PERCENT;
                        $aban = $DEFAULT_ABANDONED_PERCENT;
                        $norout = $DEFAULT_NOROUTE_PERCENT;
                    }
                    $errors->{$gw}{$gatew} = [$bus, $aban, $norout, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                }
            }
        }
        else
        {
            # no gws configured, but calls can be destined to any other available gw
        }

        if (@{$allowedGws->{$gw}} > 0)
        {
            foreach my $tg (@{$allowedGws->{$gw}})
            {
                if ($tg ne '<none>')
                {
                    print "$gw ---> $tg\n";
                }
            }
        }
        else
        {
            print "$gw ---> <ANY GATEWAY>\n";
        }

        # create the range of phones
        if ($range =~ /^</)
        {
            # read the dial codes from a separate file
            my ($file, $len) = split(/-/, $range);
            $file = substr($file, 1, -1);
            chomp($len);
            open(CODEFILE, "< $file") or die "Unable to open dial code file \"$file\": $!"; 
            while (my $prefix = <CODEFILE>)
            {
                chomp($prefix);
                push(@{$prefixes->{$gw}}, $prefix);
                push(@{$exts->{$gw}}, $len-length($prefix));
            }
            close(CODEFILE);
        }
        else
        {
            # read the dial codes right from the config string
            my @phones = split(/,/, $range);
            foreach my $phone (@phones)
            {
                my ($prefix, $digits) = split(/-/, $phone);
                chomp($digits);
                push(@{$prefixes->{$gw}}, $prefix);
                push(@{$exts->{$gw}}, length($digits));
            }
        }
    }

    close(MASTER);    
}


sub chooseRandomGw
{
    # exclude this gateway if passed in
    my ($excludeGw, $excludePort, $excludeIp, $excludeRealm) = @_;

    my ($gw, $port, $ip, $realm) = ($excludeGw, $excludePort, $excludeIp, $excludeRealm);

    my @includeGws = ();
    if (defined($excludeGw))
    {
        @includeGws = @{$allowedGws->{$excludeGw}};
    }

    my $tries = 0;
    while ($gw eq $excludeGw || ($ip eq $excludeIp && $realm eq $excludeRealm))
    {
#        if ($tries++ > (5*@gateways))
#        {
#            # unable to find a gateway, something must be wrong in the config
#            die "unable to find an appropriate gw: check the config file ($excludeGw)";
#        }

        # choose a random gateway index
        my $index = int(rand(@gateways));

        # make sure the destination we choose is in one of the allowed gateway list
        my $found = 0;
        if (@includeGws > 0)
        {
            foreach my $igw (@includeGws)
            {
                if ($gateways[$index] eq $igw)
                {
                    $found = 1;
                    last;
                }
            }
        }
        else
        {
            # don't choose a gateway that does not have any destination gateways allowed
            if (!defined($allowedGws->{$gateways[$index]}[0]) || $allowedGws->{$gateways[$index]}[0] ne '<none>')
            {
                $found = 1;
            }
        }

        # if everything was fine, choose that gateway
        if ($found)
        {
            $gw = $gateways[$index];
            $port = $ports[$index];
            $ip = $ips[$index];
            $realm = $realms[$index];
        }
    }

    # now choose a random phone
    my $index = int(rand(@{$prefixes->{$gw}}));
    my $numDigits = $exts->{$gw}[$index];
    my $max = '';
    for (my $i = 0; $i < $numDigits; $i++)
    {
        $max .= 9;
    }
    my $format = '%' . $numDigits . '.' . $numDigits . 'u';

    # return the result
    return ($gw, $port, $ip, $realm, $prefixes->{$gw}[$index] . sprintf($format, int(rand($max))));
}


sub toTimeString
{
    my ($time) = @_;

    my $hour = $time/3600;
    my $left = $time%3600;
    my $min = $left/60;
    $left %= 60;

    return sprintf("%3.3d:%2.2d:%2.2d", $hour, $min, $left);
}


sub getRandomFromHash
{
    my ($hash) = @_;

    my @hashkeys = keys %$hash;
    my $rand = int(rand(@hashkeys));
    my $index = $hashkeys[$rand];

    return ($index, $hash->{$index}[0], $hash->{$index}[1]);
}


sub exit
{
    $keepWorking = 0;
}

1;
