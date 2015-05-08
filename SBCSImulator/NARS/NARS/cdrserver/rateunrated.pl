#!/usr/local/narsagent/perl
# file rateunrated.pl

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
my $PIDFILE     = "narsbatch.pid"; # contains the pid of the narsbatch daemon
my $CONFFILE    = "nars.cfg";      # contains nars app config
my $LOGCONFFILE = "narslog.cfg";   # contains nars logging config
my $LICENSE_GRACE = 3;             # number of times we will check for the license before exiting
my $RATEUNRATED = 600;             # number of seconds between each try of rating existing unrated cdrs

# if we are only asking for version...
if (defined($ARGV[0]))
{
    if ($ARGV[0] eq "-v" || $ARGV[0] eq "-version" || $ARGV[0] eq "-V")
    {
        print STDOUT "GENBAND RSM Agent rateunrated version $NexTone::version::Version\n";
        exit 0;
    }

    print STDERR "Usage: <$0> [-v]\n";
    exit 1;
}


# find the directory where this perl script is located at
my $mydir = dirname($0);
#my $mydir = "/home/santosh/NARS/cdrserver";
#print "mydir = $mydir\n";

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
$SIG{TERM} = $SIG{INT} = $SIG{KILL} = \&doExit;
$SIG{HUP} = $SIG{PIPE} = $SIG{USR1} = $SIG{USR2} = 'IGNORE';

# set up the logger
my $Logger;
if (-f "$mydir/$LOGCONFFILE")
{
    $Logger = NexTone::Logger->new("$mydir/$LOGCONFFILE");
} else {
    $Logger = NexTone::Logger->new("/tmp/narsbatch.log", $NexTone::Logger::INFO, {maxSize => 1048576});
}
if (! defined($Logger))
{
    doExit("Cannot instantiate logger: $NexTone::Logger::errstr");
}
$Logger->info("rateunrated running from $mydir");

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
my $rateUnratedPeriod = defined($cfghash{'default.rateUnratedPeriod'})?$cfghash{'default.rateUnratedPeriod'}:$RATEUNRATED;
my $rateCalledNumber = defined($cfghash{'default.rateCalledNumber'})?$NexTone::Cdrrater::callNumberTypes{$cfghash{'default.rateCalledNumber'}}:$NexTone::Cdrrater::callNumberTypes{'ATDEST'};
if (!defined($rateCalledNumber))
{
    $rateCalledNumber = $NexTone::Cdrrater::callNumberTypes{'ATDEST'};
}

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
while (1)
{
    my $cdrCount = $cdrrater->rateUnrated();

    # check if the license has expired
    doExit("License check failed: $NexTone::LM::errstr") if (licenseNotOk());

    if (!defined($cdrCount)  || $cdrCount < $NexTone::Sqlstatements::UNRATED_CDR_LIMIT)
    {
        # sleep only if we processed less number of entries than we intended to
        # i.e., not enough unrated entries available to process
        sleep($rateUnratedPeriod);
    }
}


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

    # remove the pid file
#    flock(PIDFILE, LOCK_UN);
    close(PIDFILE);
    unlink("$mydir/$PIDFILE") or warn "Unable to delete pid file: $!\n";

    # close the logger;
    my $msg = defined($arg[0])?$arg[0]:"Caught signal";
    $Logger->error($msg);
    $Logger->info("rateunrated exited [$pid]");

    exit 0;
}


1;

