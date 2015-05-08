#!/usr/local/narsagent/perl
# file cdrserver.pl

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

#use DBI;
use Net::INET6Glue::INET_is_INET6;
use Digest::Perl::MD5;
use Config::Simple;
use Fcntl ':flock'; # import LOCK_* constants
use File::Tail;
use POSIX qw(strftime);
use File::Basename;
use IO::File;

use NexTone::Logger; # nextone logger module
use NexTone::Cdrposter; # has the rating/database code
use NexTone::LM;  # has the license check code
use NexTone::validate; # validate cdr files
use NexTone::version; # get program version
use NexTone::Cdrstreamer; # stream cdr contents to other databases
use NexTone::Cdrfilter; # filter cdr entries based on configured criteria
use NexTone::Trapposter;# nextone snmp trap

# some constants
my $SELECTTIME  = 3;               # number of seconds to wait for select to timeout
my $LICENSE_GRACE = 3;             # number of times we will check for the license before exiting
my $RATEUNRATED = 600;             # number of seconds between each try of rating existing unrated cdrs
my $NORMALCALLDURATION = 0;        # if duration greater than this, set disc_code to 'N'
my $ERRORCALLDURATION = -1;        # if duration smaller than this, set disc_code to 'E'
my $FILE_PREFIX="nars";
my $FILE_PREFIX_NARS="nars";
my $FILE_PREFIX_STRM="cstm";
my $trap = NexTone::Trapposter->new();
#error code
my $IOFailure_CDR = "005";
my $IOFailure_CFG = "006";
my $Wrong_CFG = "007";
#state code of cdr server ---0 running, 1 error
my $state_failure = "1";



my $keepRunning = 1;
my $cdrposter = undef;
my $instance = 1;				# By default we are the first instance
my $isTimeSizeCdr = undef;
my $noOfTimeSizeEntry=undef;
# if we are only asking for version...
if (defined($ARGV[0]))
{
    if ($ARGV[0] eq "-v" || $ARGV[0] eq "-version" || $ARGV[0] eq "-V")
    {
        print STDOUT "GENBAND RSM Agent:cdrserver, $NexTone::version::Version\n";
        exit 0;
    }
	elsif (($ARGV[0] eq "-i") && defined($ARGV[1]))
	{
		$instance = $ARGV[1] + 1;
		$FILE_PREFIX .= (($instance > 1) ? ($instance-1) : "");
		$FILE_PREFIX_NARS .= (($instance > 1) ? ($instance-1) : "");
		$FILE_PREFIX_STRM .= (($instance > 1) ? ($instance-1) : "");
	}
	else
	{
    	print STDERR "Usage: <$0> [-v] [-i instance_num]\n";
    	exit 1;
	}
}

# The files
my $PIDFILE     = $FILE_PREFIX.".pid";      # contains the pid of the nars daemon
my $CONFFILE    = $FILE_PREFIX.".cfg";      # contains nars app config
my $LOGCONFFILE = $FILE_PREFIX."log.cfg";   # contains nars logging config
my $LOGFILE     = $FILE_PREFIX.".log";      # contains the logged info
my $LASTSEEN_NARS    = $FILE_PREFIX_NARS.".lastseen"; # contains last processed cdr file info
my $LASTSEEN_STRM    = $FILE_PREFIX_STRM.".lastseen"; # contains last processed cdr file info

# find the directory where this perl script is located at
my $mydir = dirname($0);

# first thing is to daemonize
my $pid;
if ($ENV{NODAEMONIZE} == 0)
{
    $pid = fork;
    exit if $pid;
    die "Could not fork: $!\n" unless defined($pid);
    POSIX::setsid() or die "Can't start a new session: $!\n";
}
$pid = POSIX::getpid();  # my pid

# open the pidfile and acquire lock
sysopen(PIDFILE, "$mydir/$PIDFILE", O_WRONLY|O_APPEND|O_CREAT) or die "Could not open PID file: $!\n";
unless (flock(PIDFILE, LOCK_EX|LOCK_NB))
{
    die "Unable to get a lock on PID file (another instance running?): $!\n";
}

# create the pid file
sysseek(PIDFILE, 0, 0);
truncate(PIDFILE, 0);
syswrite(PIDFILE, $pid);


# set output buffers to auto-flush
$| = 1;


# install signal handlers
$SIG{ABRT} = $SIG{BREAK} = $SIG{TERM} = $SIG{INT} = $SIG{KILL} = \&doExit;
$SIG{HUP} = $SIG{PIPE} = $SIG{USR1} = $SIG{USR2} = 'IGNORE';

# set up the logger
my $Logger;
if (-f "$mydir/$LOGCONFFILE")
{
    $Logger = NexTone::Logger->new("$mydir/$LOGCONFFILE");
} else {
    # set up some default logger
    $Logger = NexTone::Logger->new("/tmp/narsagent.log", $NexTone::Logger::INFO, {maxSize => 1048576});
}
if (! defined($Logger))
{
    exitProgram("Cannot instantiate logger: $NexTone::Logger::errstr");
}
$Logger->info("cdrserver instance $instance running from $mydir");


# read the nars config file and store the params
my $config;
if (-f "$mydir/$CONFFILE" && -T "$mydir/$CONFFILE")
{
    $config = new Config::Simple(filename=>"$mydir/$CONFFILE", mode=>O_RDONLY);
} else {
    $trap->sendAndLogTrap($state_failure, $IOFailure_CFG);
    exitProgram("Cannot read config file $mydir/$CONFFILE");
}
my %cfghash = $config->param_hash();
my $streamsOnly = (defined($cfghash{'default.streamsOnly'}) && $cfghash{'default.streamsOnly'} eq 'TRUE')?1:0;
$Logger->debug1("streamsOnly = $streamsOnly");
if (!$streamsOnly) {
    my $host=$cfghash{'default.host'};
    if (!defined($host)) {
       $Logger->error("host = $host");
       $trap->sendAndLogTrap($state_failure, $Wrong_CFG);
    } else {
        my $tmpHost="";
        if (is_ipv6($host)) {
            $tmpHost=`ping6 "$host" -c 3`;
        } else {
            $tmpHost=`ping "$host" -c 3`;
        }
        if( index($tmpHost, "packet loss") < 0 || index($tmpHost, "100% packet loss") >= 0 )
        {
             $Logger->error("host is not pingable");
             $trap->sendAndLogTrap($state_failure, $Wrong_CFG);

        }
    }
     my $user=$cfghash{'default.user'};
     if ((!defined($user)) || $user ne "narsagent" ) {
             $Logger->error("user is not correct");
             $trap->sendAndLogTrap($state_failure, $Wrong_CFG);
     }
     my $pass=$cfghash{'default.pass'};
     if ((!defined($pass)) || $pass ne "narsagent" ) {
             $Logger->error("pass is not correct");
             $trap->sendAndLogTrap($state_failure, $Wrong_CFG);
     }
}

my $tmpMaxInst=$cfghash{'default.maxInst'};
if ((!defined($tmpMaxInst))|| ($tmpMaxInst ne 1)){
    $Logger->warn("maxInst is $tmpMaxInst,one RSM agent installation can only launch one instance.");
}

exitProgram("Attempt to start instance $instance failed, max is $cfghash{'default.maxInst'}")
if (($instance > 1) &&
	!(defined($cfghash{'default.maxInst'}) && ($instance <= $cfghash{'default.maxInst'})));
my $cdr_dir = $cfghash{'default.cdrpath'};

if(!defined($cdr_dir)) {
    $trap->sendAndLogTrap($state_failure, $IOFailure_CDR);
    exitProgram("Cannot read CDR storage path from $mydir/$CONFFILE");
}
$Logger->debug1("CDRs stored at $cdr_dir");
# if the password is just a '.', it means password is empty
if ($cfghash{'default.dbpass'} eq '.')
{
    $cfghash{'default.dbpass'} = "";
}

if ($cfghash{'default.pass'} eq '.')
{
    $cfghash{'default.pass'} = "";
}
my $makeCallidUnique = (defined($cfghash{'default.makeCallidUnique'}) && $cfghash{'default.makeCallidUnique'} eq 'TRUE')?1:0;
my $allowEmptyLastSeen = (defined($cfghash{'default.allowEmptyLastSeen'}) && $cfghash{'default.allowEmptyLastSeen'} eq 'FALSE')?0:1;
my $comparatorLastSeen = (defined($cfghash{'default.comparatorLastSeen'}))?$cfghash{'default.comparatorLastSeen'}:'maxima';

$Logger->debug1("makeCallidUnique = $makeCallidUnique");
my $rateCdrs = (defined($cfghash{'default.rateCdrs'}) && $cfghash{'default.rateCdrs'} eq 'TRUE')?1:0;
$Logger->debug1("rateCdrs = $rateCdrs");
my $rateUnratedPeriod = defined($cfghash{'default.rateUnratedPeriod'})?int($cfghash{'default.rateUnratedPeriod'}):$RATEUNRATED;
$Logger->debug1("rateUnratedPeriod = $rateUnratedPeriod");
my $lastRateUnratedTime = 0;
my $normalCallDuration = defined($cfghash{'default.normalCallDuration'})?int($cfghash{'default.normalCallDuration'}):$NORMALCALLDURATION;
$Logger->debug1("normalCallDuration = $normalCallDuration");
my $errorCallDuration = defined($cfghash{'default.errorCallDuration'})?int($cfghash{'default.errorCallDuration'}):$ERRORCALLDURATION;
$Logger->debug1("errorCallDuration = $errorCallDuration");

my $postPeriod = defined($cfghash{'default.postPeriod'})?int($cfghash{'default.postPeriod'}):$SELECTTIME;
$Logger->debug1("postPeriod = $postPeriod");
if($postPeriod < $SELECTTIME)
{
  $SELECTTIME= $postPeriod;
}
$Logger->debug1("SELECTTIME = $SELECTTIME");

my $cdrfilter = NexTone::Cdrfilter->new(\$Logger, $cfghash{'default.excludeEP'}, $cfghash{'default.excludeFilter'}, $cfghash{'default.includeFilter'});
if(!defined($cdrfilter)) {
    $trap->sendAndLogTrap($state_failure, $IOFailure_CFG);  
    exitProgram("Unable to process the filter criteria");
}

my @cdrStreamers = ();
my @cdrStreamStrict = ();
if (defined($cfghash{'default.addStream'}))
{
    if ($cfghash{'default.addStream'} ne '.')
    {
        my $addStream = $cfghash{'default.addStream'};
        my @streams = undef;
        my $stream = '';
        if (ref($addStream) eq 'ARRAY'){
            @streams = @$addStream;
        } else {
            @streams = ($addStream);
        }
        foreach $stream (@streams)
        {
            my ($file, $flag) = split(/;/, $stream);
            $flag = 'strict' unless $flag;
            my $cstr = NexTone::Cdrstreamer->new($file, $Logger);
            unless ($cstr)
            {
                $trap->sendAndLogTrap($state_failure, $Wrong_CFG);
                $Logger->error("Cannot process additional cdr stream: $NexTone::Cdrstreamer::errstr");
                if ($flag eq 'strict')
                {
                    $trap->sendAndLogTrap($state_failure, $Wrong_CFG);
                    exitProgram("Unable to process a strict cdr stream");
                }
                next;
            }
            $Logger->info("Adding $cstr->{id} to process list");
            push(@cdrStreamers, $cstr);
            push(@cdrStreamStrict, $flag);
        }
    }
}

my $rateCalledNumber = defined($cfghash{'default.rateCalledNumber'})?$NexTone::Cdrposter::callNumberTypes{$cfghash{'default.rateCalledNumber'}}:$NexTone::Cdrposter::callNumberTypes{'ATDEST'};
if (!defined($rateCalledNumber))
{
    $rateCalledNumber = $NexTone::Cdrposter::callNumberTypes{'ATDEST'};
}
$Logger->debug1("rateCalledNumber = $rateCalledNumber");

# get the host id we are running on
my $mswId = defined($cfghash{'default.mswId'})?$cfghash{'default.mswId'}:`/usr/bin/hostid`;
chomp($mswId);
$Logger->debug1("mswId = $mswId");

# check for the license
my $lastLicenseCheckTime = 0;  # secs since epoch when we last checked for license
my $licenseCheckTimes = 0;     # number of times we have checked for the license
while ($keepRunning && licenseNotOk())
{
	$Logger->error("License check failed: $NexTone::LM::errstr");
	sleep(10);
}
if (!$keepRunning)
{
	exitProgram("stopping normally");
}

# create rater object (this will initialize connection with the database)
# and read the last place we left off at
# if the last place we left off is .CDT, then look for .CDT and then .CDR
my ($lastfileseen, $lastlineseen, $last_strm_fileseen, $last_strm_lineseen, $lastfileseenHandle, $numlinesinlastfileseen);
my $fileToSkip = '';   # file where we may have to skip some lines
my $line_strm="";
if ((defined($cfghash{'default.addStream'}) && ($cfghash{'default.addStream'} ne '.'))) 
{
	if((! -f "$mydir/$LASTSEEN_STRM"))
	{
    	$Logger->info("unable to read $mydir/$LASTSEEN_STRM, will process from the beginning");
	} else { 
    		if (((stat "$mydir/$LASTSEEN_STRM")[7]))
    		{
        		open(FILE_STRM, "< $mydir/$LASTSEEN_STRM") or exitProgram("unable to read $mydir/$LASTSEEN_STRM: $!");
        		chomp($line_strm = <FILE_STRM>);
        		($last_strm_fileseen, $last_strm_lineseen) = split(":", $line_strm);
        		($lastfileseen, $lastlineseen) = split(":", $line_strm);
        		if (! defined($last_strm_fileseen) || ! defined($last_strm_lineseen))
        		{
            			exitProgram("unable to parse $mydir/$LASTSEEN_STRM");
        		}
        		close(FILE_STRM);
    		}
	}
sysopen(FILE, "$mydir/$LASTSEEN_STRM", O_WRONLY|O_APPEND|O_CREAT) or exitProgram("unable to write to $mydir/$LASTSEEN_STRM: $!");
}
my $line_nars="";
if ((!$streamsOnly))
{
	if(! -f "$mydir/$LASTSEEN_NARS")
	{
    		$Logger->info("unable to read $mydir/$LASTSEEN_NARS, will process from the begining");
	} else {
    		if (((stat "$mydir/$LASTSEEN_NARS")[7]))
    		{
        		unless(open(FILE_NARS, "< $mydir/$LASTSEEN_NARS")) {
        		    $trap->sendAndLogTrap($state_failure, $IOFailure_CFG);  
        		    exitProgram("unable to read $mydir/$LASTSEEN_NARS: $!");
        		}
        		chomp($line_nars = <FILE_NARS>);
        		($lastfileseen, $lastlineseen) = split(":", $line_nars);
        		if (! defined($lastfileseen) || ! defined($lastlineseen))
        		{
        		        $trap->sendAndLogTrap($state_failure, $IOFailure_CFG);  
            			exitProgram("unable to parse $mydir/$LASTSEEN_NARS");
        		}
        		close(FILE_NARS);
    		}
	}
}

if ((!$streamsOnly) && ($cfghash{'default.addStream'} ne '.'))
{

	if($line_nars gt $line_strm)
	{
            ($lastfileseen, $lastlineseen) = split(":", $line_strm);
	}

        $Logger->info("last processed file: $lastfileseen, line $lastlineseen");
}

while($keepRunning && !defined($lastfileseen) && !$allowEmptyLastSeen)
{

     $Logger->warn("Empty value for last seen not allowed, not streaming cdrs");
     sleep(10);
}
if(!$keepRunning)
{
    exitProgram("exit signal received");
}


# narsAgentMode and localAddress values added 
if (!$streamsOnly) {
        do
        {
            $cdrposter = NexTone::Cdrposter->new($mydir, 
					       $cfghash{'default.host'},
                                               $cfghash{'default.user'},
                                               $cfghash{'default.pass'},
                                               \$Logger,
                                               $cfghash{'default.postThresh'},
					       $cfghash{'default.postPeriod'},
						$cfghash{'default.narsAgentMode'},
						$cfghash{'default.localAddress'},
					       1,
						$instance,
						$lastfileseen,
						$lastlineseen
					       );
     $Logger->warn("Cannot initiate cdrposter: $NexTone::Cdrposter::errstr, will try again in 10 seconds") unless $cdrposter;
            sleep(10);
        } while ($keepRunning && !$cdrposter);

        if (!$keepRunning)
        {
            exitProgram("exit signal received");
        }

	$Logger->debug2("successfully created cdrposter");

	# set the cache reload interval if it is in the cfg file
}
        # read the last file to make sure we can read it
        unless (open(LFILE, "< $lastfileseen"))
        {
            $Logger->warn("unable to read last file seen \"$lastfileseen\": $!");
            if ($lastfileseen =~ /(\.CDT$)|(DATA.CDR$)/)
            {
                $lastfileseen =~ s/\.CDT$/\.CDR/;
                $Logger->info("will try reading \"$lastfileseen\" instead");
                if (open(LFILE, "< $lastfileseen"))
                {
                    $fileToSkip = $lastfileseen;
                    $numlinesinlastfileseen = 0;
                    $numlinesinlastfileseen++ while (<LFILE>);
                    close(LFILE);
                } else {
                    undef $lastfileseen;
                    undef $lastlineseen;
                    $Logger->warn("unable to read last file seen, will process from the beginning")
                }
            } else {
                undef $lastfileseen;
                undef $lastlineseen;
                $Logger->warn("unable to read last file seen, will process from the beginning")
            }
        } else {
            $fileToSkip = $lastfileseen;
            $numlinesinlastfileseen = 0;
            $numlinesinlastfileseen++ while (<LFILE>);
            close(LFILE);
        }

# create a file handle to store the last file seen
$lastfileseenHandle = *FILE;

my $totalcount = 0;
my $cdtfile;
my $cdtfileFound = '';

if ($lastfileseen =~ /(\.CDT$)|(DATA.CDR$)/)
{
    # start processing the CDT file we left off
    $cdtfile = $lastfileseen;
} else {

    my $sleepCnt = 0;
    while ($keepRunning)
    {
        # process the .CDR files until there are no more
        my @cdrlist = createCDRList();
        foreach my $file (@cdrlist)
        {
            if ($fileToSkip =~ /$file$/ && $numlinesinlastfileseen >= $lastlineseen)
            {
                # skip lines that are already seen
                processCDR($file, $lastlineseen);
            } else {
                processCDR($file);
            }

            if (!$keepRunning)
            {
                last;
            }
        }

        # find the .CDT file to process, it is oldest .CDT file in the dir
        $cdtfile = getOldestCDTFile();

        if (defined($cdtfile))
        {
            if ($cdtfile eq $cdtfileFound)
            {
                last;  # for the last 2 tries we got the same guy, proceed
            }
            else
            {
                $cdtfileFound = $cdtfile;
                next;
            }
        }
        else
        {
	    if(($sleepCnt % 30) == 0) {
	            $Logger->warn("Cannot find any .CDT files in $cdr_dir");
		    $sleepCnt = 0;
	    }

            # check if the license has expired
            exitProgram("License check failed: $NexTone::LM::errstr") if (licenseNotOk());

            # rate some of the unrated cdrs
            # rateUnrated(); // commented by vdham not needed for Blue Neon
	    if(!$streamsOnly)
	    {
	            $cdrposter->postCDRdata();
	    }

            sleep(10); # try again after 10 seconds
	    $sleepCnt++;

            if (!$keepRunning)
            {
                last;
            }
        }
    }
} 

if (!$keepRunning)
{
    exitProgram("exiting while processing older cdr files");
}

$Logger->debug1("Starting to tail file \"$cdtfile\"");

# the buffer size used depends on the number of cdr files currently in the cdr dir
# (more files mean that we may spend a long time sorting through them, which means more
#  chances of a backlog in the current tail)
my @allCDRs = <$cdr_dir/*.CDR>;
my $maxbufSize = ($#allCDRs > 1000)?327680:163840;
$Logger->debug1("Using bufsize $maxbufSize for tail buffer size");

# now tail the .CDT file
my $tailer = File::Tail->new(name => $cdtfile,
                            maxinterval => 2,
                             interval => 1,
                             reset_tail => 0,
                             maxbuf => $maxbufSize,
                             tail => -1);
my $line;
my $count = 0;
my $canCheckCDT = 0;
$cdtfileFound = '';
while ($keepRunning)
{
    my $nfound = 0;
    eval{$nfound = File::Tail::select(undef, undef, undef, $SELECTTIME, $tailer)};
    if ($@)
    {
        $nfound = 0;
	if(!$streamsOnly)
	{        
		my $status = $cdrposter->postCDRdata();
	}
    }
    if (!$keepRunning)
    {
        next;
    }

    if ($nfound)
    {
        my $line = $tailer->read;
        $count++;

        # skip the entries we have already read
        if ($fileToSkip =~ /$cdtfile$/ && $count <= $lastlineseen)
        {
            next;
        }

        $totalcount++;
        processCDREntry($line, $cdtfile, $count);

        # check if the license has expired
        exitProgram("License check failed: $NexTone::LM::errstr") if (licenseNotOk());

        # rate some of the unrated cdrs
        # rateUnrated(); // commented by vdham not needed for Blue Neon
    } else {
        # select timed out, look for the next .CDT file
        sleep(10);
        $Logger->debug1("select timed out, will look for a new .CDT file");
	if(!$streamsOnly)
	{
	        $cdrposter->postCDRdata();
	}

        # check if the license has expired
        exitProgram("License check failed: $NexTone::LM::errstr") if (licenseNotOk());

        # rate some of the unrated cdrs, 
        # rateUnrated(); // commented by vdham not needed for Blue Neon

        # maybe we also need to check for newer cdr files
        # only do this check every other timeout
        if ($canCheckCDT && !$cdtfileFound) {
            # last time around cdt was checked, don't check it this time
            $canCheckCDT = 0;

            $Logger->debug1("checking if there are any newer '.CDR' files");
            my $cdrCheckStartTime = time;
            my $oldestFile = $cdtfile;
            while ($keepRunning && (my @cdrlist = getFilesOlderThan($oldestFile, '.CDR', 0)))
            {
                foreach my $file (@cdrlist)
                {
                    $Logger->debug2("processing cdr file during cdt timeout: " . $file);
                    processCDR($file);
                    $oldestFile = "$cdr_dir/$file";

                    if (!$keepRunning)
                    {
                        last;
                    }
                }
            }
            my $cdrCheckEndTime = time;
            my $cdrCheckDiffTime = ($cdrCheckEndTime - $cdrCheckStartTime);
            $Logger->debug1("checking for newer '.CDR' files took $cdrCheckDiffTime seconds");
        }
        else
        {
            $canCheckCDT = 1;
        }

        # if we went of checking for .CDR files, then do not look for .CDT file
        # here, we may end up skipping some CDR lines that were collected in the meantime
        if ($canCheckCDT) {
            $Logger->debug1("checking if there are any newer '.CDT' files");
            # no (more) cdr files, process the oldest cdt file
            my $startTime = time;
            my $file = $cdtfileFound?$cdtfileFound:getOldestCDTFile();
            my $endTime = time;
            my $diffTime = ($endTime - $startTime);
            $Logger->debug1("checking for newer '.CDT' files took $diffTime seconds");
            if (defined($file) && $file ne $cdtfile)
            {
                if ($file eq $cdtfileFound)
                {
                    $cdtfileFound = '';
                    $cdtfile = $file;
                    $Logger->debug1("Starting to tail CDT file \"$cdtfile\"");
                    @allCDRs = <$cdr_dir/*.CDR>;
                    $maxbufSize = ($#allCDRs > 1000)?327680:163840;
                    $tailer = File::Tail->new(name => $cdtfile,
                                              interval => 1,
                                              maxinterval => 2,
                                              reset_tail => 0,
                                              maxbuf => $maxbufSize,
                                              tail => -1);
                    $count = 0;
                }
                else
                {
                    $cdtfileFound = $file;
                    $Logger->debug1("found a new CDT file ($file), will do one last check of current file being read ($cdtfile)");
                }
            }
        }
    }
}

exitProgram("exiting while processing CDT file");


#####################################
# get the oldest .CDT file in the dir
#####################################
sub getOldestCDTFile
{
    if (!$keepRunning)
    {
        return undef;
    }

    unless(opendir(CDR_DIR, $cdr_dir)){
        $trap->sendAndLogTrap($state_failure, $IOFailure_CDR);
        exitProgram("Cannot opendir $cdr_dir: $!");
    }
    my @files = grep { /(\.CDT$)|(^DATA.CDR$)/ } readdir(CDR_DIR);
    my %files;
    $Logger->debug4(".CDT files in dir: " . commify_array(@files));
    my $emptyAllowed=1;
    foreach my $file (@files)
    {
        if (NexTone::validate::validFile("$cdr_dir/$file",$emptyAllowed) == 0)
        {
            $Logger->debug2((caller(0))[3] . ": won't consider invalid .CDT file ($cdr_dir/$file): $NexTone::validate::errstr");
            next;
        }
        $files{(stat "$cdr_dir/$file")[9]} = $file;
    }
    my @cdrlist = ();
    foreach (sort { $b <=> $a } keys %files)
    {
        push(@cdrlist, $files{$_});
        last;
    }

    if (@cdrlist == 0)
    {
        $Logger->debug2((caller(0))[3] . ": no .CDT files found");
        return undef;
    }

    $Logger->debug4(".CDT files to be processed: " . commify_array(@cdrlist));

    $Logger->debug3((caller(0))[3] . ": returning CDT file $cdr_dir/$cdrlist[0]");

    return "$cdr_dir/$cdrlist[0]";
}


##############################################
# process a single CDR entry until it succeeds
##############################################
sub processCDREntry
{
    my ($entry, $file, $line) = @_;

    chomp($entry);
    if ($entry eq '')
    {
        #ignore empty lines
        $Logger->warn("CDR entry $file:$line is empty");
        return;
    }
    
    ##--Handling for time-size type cdr--##
    ## In time-size type cdrs header information and checksum are filtered out
    if($isTimeSizeCdr && ($line ==1 || $line ==$noOfTimeSizeEntry)) 
    {
    	$cdrfilter->{_timeSize} = 1;
    }
    ##----##	

    # check if this cdr needs to be filtered out
    my ($filtered, @filterCriteria) = $cdrfilter->filterEntry($entry);
    if ($filtered)
    {
        $Logger->debug3("cdr entry filtered [$file:$line]: @filterCriteria");
        updateLastFileSeen($file, $line) if ($#cdrStreamers > 0 || ($cdrfilter->{_timeSize} == 1));
        $cdrfilter->{_timeSize}=0 if($cdrfilter->{_timeSize}==1);
        return;
    }

    # give him a unique callid if necessary
    my @suffixlist = ('.CDR', '.CDT', '.CTR', '.CTT');
    my ($filename, $path, $suffix) = fileparse($file, @suffixlist);
    my $uniqueExt = $makeCallidUnique?Digest::Perl::MD5::md5_hex($filename . $line . $mswId):0;

    # keep processing the entry until it succeeds
    while ($keepRunning)
    {
        my $status = 1;
        if (!$streamsOnly)
        {
            $status = $cdrposter->processCDREntry($entry, $file, $line, $mswId);
        }

        if ($status)
        {
            $Logger->debug4("inserted cdr entry ($file:$line) into Cdrposter");

            my $updateFile = 1;
            my $index = 0;
            foreach my $cstr (@cdrStreamers)
            {
                $updateFile = 0;
              keepInnerLoop:
                while ($keepRunning)
                {
		    $Logger->debug4("Inserting cdr entry to streamer $cstr->{id}: $uniqueExt");
                    my $st = $cstr->processCDREntry($entry, $uniqueExt, $file, $line, $mswId);
                    if ($st)
                    {
                        $updateFile = 1;
                        last keepInnerLoop;
                    }
                    else
                    {
                        $Logger->warn("unable to insert cdr entry ($file:$line) to $cstr->{id}: $cstr->{errstr}");
                        if ($cdrStreamStrict[$index] eq 'nostrict')
                        {
                            $updateFile = 1;
                            last keepInnerLoop;
                        }
                        else
                        {
                            sleep(10);  # try again after 10 seconds
                            # reconnect if the server has gone down
                            if (index($cstr->{errstr}, "MySQL server has gone away") >= 0)
                            {
                                $Logger->info("Reinitializing DB connection for $cstr->{id}");
                                $Logger->warn("Unable to reinitialize DB connection: $cstr->{errstr}") unless $cstr->_DBInit();
                            }
                        }
                    }
                }
                $index++;
            }

            if ($updateFile)
            {
                updateLastFileSeen($file, $line);
            }
            last;  # get out of keepRunning loop
        }
        else
        {
            $Logger->warn("unable to insert cdr entry ($file:$line): $NexTone::Cdrposter::errstr");
            sleep(10);  # try again after 10 seconds
        }
    }
}


#####################################
# process the CDR entries in the file
#####################################
sub processCDR
{
    my @arg = @_;
    my $file = "$cdr_dir/$arg[0]";
    my $line = defined($arg[1])?$arg[1]:0;  # line number to start processing from

    $Logger->debug2((caller(0))[3] . ": begin processing CDR file $file");

    unless (open(CDRFILE, "< $file"))
    {
        $trap->sendAndLogTrap($state_failure, $IOFailure_CDR);
        $Logger->error("Unable to open CDR file \"$file\": $!");
        return;
    }
    my $count = 0;
    
    ##--Handling for time-size type cdr--##
    #Checks whether its a time-size cdr type or not. The time-size type is checked if the no. of elements in filename are >= 6
    my @fileDetails = split(/\./,$arg[0]);
    if(@fileDetails>=6)
    {
    	$isTimeSizeCdr=1;
    	$noOfTimeSizeEntry=$fileDetails[$#fileDetails-1]+2;
    }
    ##----##	 
    
    while ($keepRunning && (my $entry = <CDRFILE>))
    {
        if (++$count <= $line)
        {
            next;
        }

        $totalcount++;
        processCDREntry($entry, $file, $count);
    }
    close(CDRFILE);

    $numlinesinlastfileseen = $count;
    $isTimeSizeCdr=undef;
   	$noOfTimeSizeEntry=undef;

    $Logger->debug2((caller(0))[3] . ": end processing CDR file $file, $count lines processed");
}


############################################################
# sort the given hash according to the key and return a list
############################################################
sub sortFiles
{
    my ($files) = @_;
    my @list = ();

#    foreach (sort { $a <=> $b } keys %$files)
#    {
#        push(@list, $files->{$_});
#    }
	@list = sort { $files->{$a} cmp $files->{$b} } keys %$files;

    $Logger->debug2("Number of CDR files to be processed: " . @list);
    $Logger->debug2("Files to be processed: " . commify_array(@list));

    return @list;
}


###########################################################################
# create list of files ending with 'ext' that are older than the given file
###########################################################################
sub getFilesOlderThan
{
    # referenceFile is the complete path name of the file
    # if referenceFile is undefined, list all files in the directory
    # ext is the file extension '.CDT' or '.CDR'
    # chooseRefFile is 1 if the reference file should also be included in the final list
    my ($referenceFile, $ext, $chooseRefFile) = @_;

    # open the cdr directory
    unless(opendir(CDR_DIR, $cdr_dir)){
        $trap->sendAndLogTrap($state_failure, $IOFailure_CDR);
        exitProgram("Cannot opendir $cdr_dir: $!");  
    } 

    my %files;  # contains file names hashed by modification times

    my $mtime = 0;
    if (defined($referenceFile))
    {
        # reference file could have moved from CDT to CDR
        if (! -f $referenceFile)
        {
            $Logger->debug2("changing from CDT to CDR for $referenceFile");
            $referenceFile =~ s/\.CDT$/\.CDR/;
        }
        $mtime = (stat "$referenceFile")[9];
    }

    my @files = grep { /$ext$/ } readdir(CDR_DIR);

    $Logger->debug2("creating " . $ext . " file list older than " . $referenceFile);

    foreach my $file (@files)
    {
        if (NexTone::validate::validFile("$cdr_dir/$file") == 0)
        {
            $Logger->debug2((caller(0))[3] . ": won't consider invalid $ext file ($cdr_dir/$file): $NexTone::validate::errstr");
            next;
        }
		next if ($file =~ /^DATA.CDR$/);

        my $mt = (stat "$cdr_dir/$file")[9];
        if ((stat _)[7] && # skip the zero byte files
            ($mt > $mtime || ($chooseRefFile && $referenceFile =~ /$file$/)))
        {
            if ($mt > $mtime)
            {
                $Logger->debug2("choosing $file because $mt > $mtime");
            }
            else
            {
                $Logger->debug2("choosing $file because $referenceFile matches");
            }
            #$files{$mt} = $file;
            $files{$file} = $mt;
        }
    }

    closedir(CDR_DIR);

    return sortFiles(\%files);
}


########################################################
# create a list of all the .CDR files we need to process
########################################################
sub createCDRList
{
    my @cdrlist;

    if (defined $lastfileseen)
    {
        # only consider files since the last file
        $Logger->debug1("listing only files changed since $lastfileseen, $numlinesinlastfileseen > $lastlineseen");
        @cdrlist = getFilesOlderThan($lastfileseen, '.CDR', ($numlinesinlastfileseen > $lastlineseen));
    }
    else
    {
        # consider all the .CDR files in the dir
        $Logger->debug1("listing all files in the dir $cdr_dir");
        @cdrlist = getFilesOlderThan(undef, '.CDR', 0);
    }

    return @cdrlist;
}


###########################
# update the last file seen
###########################
sub updateLastFileSeen
{
    my @arg = @_;
    $lastfileseen = $arg[0];
    $lastlineseen = $arg[1];

    sysseek($lastfileseenHandle, 0, 0);

    # erase the previous content
    truncate($lastfileseenHandle, 0);

    syswrite($lastfileseenHandle, "$lastfileseen" . ':' . "$lastlineseen");

    return 1;
}


#
# exit signal received
#
sub doExit
{
    my ($signal) = @_;
    $keepRunning = 0;  # setting this to 0 will cause the program to exit

    $Logger->info("Received signal: $signal");
}


#############################
# do all the cleanup and exit
#############################
sub exitProgram
{
    my @arg = @_;
    if (defined $lastfileseenHandle)
    {
        close($lastfileseenHandle);
    }

    $cdrposter->endPosting() if (defined($cdrposter));

    # remove the pid file
#    flock(PIDFILE, LOCK_UN);
    close(PIDFILE);
    unlink("$mydir/$PIDFILE") or warn "Unable to delete pid file: $!\n";

    # close the logger;
    if ($Logger)
    {
        $Logger->info("Processed $totalcount total CDR entries");
        $Logger->error($arg[0]);
        $Logger->info("cdrserver exiting gracefully [$pid]");
    }
    else
    {
        print "$arg[0]\n";
    }

    exit 0;
}


###################################################
# rate some of the unrated cdrs, every once a while
###################################################


#################################
# check if we have license to run
#################################
sub licenseNotOk
{
    # only check for the license every 24 hours
    if ($keepRunning && (time - $lastLicenseCheckTime) > (24*60*60))
    {
        unless (NexTone::LM::Agent_Licensed("$mydir/$CONFFILE", \$Logger, "RAM"))
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


##########################
# return a printable array
##########################
sub commify_array
{
    (@_ == 0) ? '' :
    (@_ == 1) ? $_[0] :
    (@_ == 2) ? join(" and ", @_) :
                join(", ", @_[0 .. ($#_-1)], "and $_[-1]");
}

sub is_ipv6 
{ 
  my($ipv6) = @_; 

  return $ipv6 =~ /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/; 
} 


sub END
{
    if ($Logger)
    {
        $Logger->info("cdrserver exited");
    }
    else
    {
# for some reason this block gets executed at the beginning of the program!
# maybe some interaction with daemonizing??
#        print "cdrserver exited\n";
    }
}


1;

