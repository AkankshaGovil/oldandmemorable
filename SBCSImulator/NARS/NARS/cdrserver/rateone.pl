#!/usr/local/narsagent/perl
# file rateone.pl

use strict;

BEGIN
{
    if ($ENV{BASE})
    {
        push(@INC, "$ENV{BASE}/lib/perl5/site_perl");
    }

    my $CurrentVersion = sprintf "%vd", $^V;
    if ($CurrentVersion lt "5.6")
    {
        push(@INC, "/usr/local/narsagent/lib/perl5/site_perl/5.005");
    }
    else
    {
        push(@INC, "/usr/local/narsagent/lib/perl5/site_perl");
    }
}

use Getopt::Std;
use DBI;
use Config::Simple;
use POSIX qw(strftime);
use Fcntl ':flock'; # import LOCK_* constants
use File::Basename;

use NexTone::Logger; # nextone logger module
use NexTone::Cdrrater; # has the rating/database code
use NexTone::LM;  # has the license check code
use NexTone::Sqlstatements;
use NexTone::version; # has the program version

# some constants
my $CONFFILE    = "nars.cfg";      # contains nars app config
my $LICENSE_GRACE = 3;             # number of times we will check for the license before exiting

die "Usage: $0 [-v] [-r <recordnum>] [-s <SQL where condition>]" unless @ARGV;

our ($opt_v, $opt_r, $opt_s);
getopts('vr:s:') or die "Usage: $0 [-v] [-r <recordnum>] [-s <SQL where condition>]";
# if we are only asking for version...
if ($opt_v)
{
    print STDOUT "GENBAND RSM Agent rateunone version $NexTone::version::Version\n";
    exit 0;
}

my $recordNum = 0;
my $whereStmt = "";
if ($opt_r)
{
    $recordNum = $opt_r;
}
else
{
    $whereStmt = $opt_s;
}

# find the directory where this perl script is located at
my $mydir = dirname($0);

# set output buffers to auto-flush
$| = 1;

# install signal handlers
$SIG{TERM} = $SIG{INT} = $SIG{KILL} = \&doExit;
$SIG{HUP} = $SIG{PIPE} = $SIG{USR1} = $SIG{USR2} = 'IGNORE';

# set up the logger
my $Logger = NexTone::Logger->new("/tmp/narsone.log", $NexTone::Logger::DEBUG3, {maxSize => 1048576});
if (! defined($Logger))
{
    doExit("Cannot instantiate logger: $NexTone::Logger::errstr");
}
$Logger->info("rateone running from $mydir");

# read the nars config file
my $config;
if (-f "$mydir/$CONFFILE" && -T "$mydir/$CONFFILE")
{
    $config = new Config::Simple(filename=>"$CONFFILE", mode=>O_RDONLY);
} else {
    doExit("Cannot read config file $mydir/$CONFFILE");
}
my %cfghash = $config->param_hash();
# if the password is just a '.', it means password is empty
if ($cfghash{'default.dbpass'} eq '.')
{
    $cfghash{'default.dbpass'} = "";
}
my $rateUnratedPeriod = defined($cfghash{'default.rateUnratedPeriod'})?$cfghash{'default.rateUnratedPeriod'}:30;
my $rateCalledNumber = defined($cfghash{'default.rateCalledNumber'})?$NexTone::Cdrrater::callNumberTypes{$cfghash{'default.rateCalledNumber'}}:$NexTone::Cdrrater::callNumberTypes{'ATDEST'};
$Logger->info("ratecalledNumber = " . $rateCalledNumber);

my $xEP=[];
if (defined($cfghash{'default.excludeEP'})) {
	my @EPList = split(',',$cfghash{'default.excludeEP'});
	foreach my $EP (@EPList) {
		my $h = {};
		($h->{'regid'}, $h->{'port'}) = split(':', $EP);
		push(@$xEP, $h);	
	}
}	
my $logmsg = "Excluded end points - \n";
foreach my $i (0..$#$xEP) { $logmsg .= "regid = $xEP->[$i]{regid} , port = $xEP->[$i]{port} \n"; }
$Logger->debug1($logmsg);

my $excludeFilter = $cfghash{'default.excludeFilter'};
$Logger->debug1("excludeFilter = $excludeFilter");

# check for the license
my $lastLicenseCheckTime = 0;  # secs since epoch when we last checked for license
my $licenseCheckTimes = 0;     # number of times we have checked for the license
doExit("License check failed: $NexTone::LM::errstr") if (licenseNotOk());

# create rater object (this will initialize connection with the database)
my $cdrrater = NexTone::Cdrrater->new($cfghash{'default.dburl'},
                                      $cfghash{'default.dbuser'},
                                      $cfghash{'default.dbpass'},
                                      {PrintError => 1,
                                       RaiseError => 1,
                                       AutoCommit => 1},
                                      $Logger,
                                      $rateCalledNumber,
                                      $xEP,
                                      $excludeFilter
                                      );
doExit("Cannot initiate cdrrater: $NexTone::Cdrrater::errstr") unless $cdrrater;
$Logger->debug1("successfully created cdrrater");
# set the cache reload interval if it is in the cfg file
{
    my $reloadInterval = $cfghash{'default.cacheReloadInterval'};
    if (defined($reloadInterval) && $reloadInterval > 5)
    {
        $cdrrater::cacheReloadInterval = $reloadInterval;
    }
    $reloadInterval = $cdrrater::cacheReloadInterval; # to avoid a stupid compiler warning
}

# only do this every configured amount of time
$Logger->info("Attempting to rate record " . $recordNum);

my $dbh = DBI->connect($cfghash{'default.dburl'}, $cfghash{'default.dbuser'}, $cfghash{'default.dbpass'},
                       {PrintError => 1,
                        RaiseError => 1,
                        AutoCommit => 1});
doExit("Cannot connect to database: $DBI::errstr") unless $dbh;
my $colname = $NexTone::Sqlstatements::calledNumberColumnNames[$rateCalledNumber];
$Logger->info("Called number used for rating: " . $colname);
my $stmt = "SELECT RecordNum, Date_Time, Date_Time_Int, Orig_GW, Orig_Port, Orig_IP, Term_GW, Term_Port, Term_IP, $colname, Duration, Hold_Time, Disc_Code, Call_ID, Src_File, Src_Line, Call_Type, Status FROM cdrs WHERE ";
if ($recordNum)
{
    $stmt .= "RecordNum = $recordNum";
}
else
{
    $stmt .= $whereStmt;
}
$Logger->info($stmt);
my $sth = $dbh->prepare($stmt);
doExit("Cannot prepare statement: $DBI::errstr") unless $sth;

eval {$sth->execute()};
if ($@)
{
    doExit("Unable to get cdr: $DBI::errstr");
}

my $count = 0;
while (my ($rec_num, $date_time, $date_time_int, $orig_gw, $orig_port, $orig_ip, $term_gw, $term_port, $term_ip, $calledNumber, $duration, $pdd, $disc_code, $uniqueid, $src_file, $src_line, $calltype, $status) = $sth->fetchrow_array)
{
    $Logger->debug3((++$count) . ": $rec_num, $date_time, $date_time_int, $orig_gw, $orig_port, $orig_ip, $term_gw, $term_port, $term_ip, $calledNumber, $duration, $pdd, $disc_code, $uniqueid, $src_file, $src_line, $calltype, $status");
    $cdrrater->_rateCdr($date_time, $date_time_int, $orig_gw, $orig_port, $orig_ip, $term_gw, $term_port, $term_ip, $calledNumber, $duration, $pdd, $disc_code, $uniqueid, $src_file, $src_line, $calltype);

    # check if the license has expired
    doExit("License check failed: $NexTone::LM::errstr") if (licenseNotOk());
}

doExit("Done");

#################################
# check if we have license to run
#################################
sub licenseNotOk
{
    # only check for the license every 24 hours
    if ((time - $lastLicenseCheckTime) > (24*60*60))
    {
        unless (NexTone::LM::Agent_Licensed("$mydir/$CONFFILE", "RAM"))
        {
            if ($lastLicenseCheckTime > 0)
            {
                # if the license was ok when we started up, try once an hour up to
                # 'LICENSE_GRACE' times before giving up
                if ($licenseCheckTimes++ <= $LICENSE_GRACE)
                {
                    # set this guy to check the license after an hour
                    $lastLicenseCheckTime = (time - (23*60*60));

                    $Logger->warn("License check failed: $NexTone::LM::errstr\nWill try " . ($LICENSE_GRACE - $licenseCheckTimes) . " more time(s) before giving up");

                    return 0;  # some problem, but we will try again an hour later
                }
            }
            return 1;  # some problem with the license
        }

        $lastLicenseCheckTime = time;
        $licenseCheckTimes = 0;
    }

    return 0;  # license is ok
}

#############################
# do all the cleanup and exit
#############################
sub doExit
{
    my @arg = @_;

    # delete db handle
    $sth->finish if $sth;
    $dbh->disconnect if $dbh;

    my $msg = defined($arg[0])?$arg[0]:"Caught signal";
    $Logger->error($msg);
    $Logger->info("rateone exited");

    exit 0;
}


1;

