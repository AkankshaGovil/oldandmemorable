#!/usr/local/narsagent/perl
# file cdrcatchup.pl

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
use Digest::Perl::MD5;
use Config::Simple;
use Fcntl ':flock'; # import LOCK_* constants
use File::Tail;
use POSIX qw(strftime);
use File::Basename;
use IO::File;
use Getopt::Std;

use NexTone::Logger; # nextone logger module
use NexTone::Cdrposter; # has the cdrposter code
use NexTone::LM;  # has the license check code
use NexTone::validate; # validate cdr files
use NexTone::version; # get program version
use NexTone::Cdrstreamer; # stream cdr contents to other databases
use NexTone::Cdrfilter; # filter cdr entries based on configured criteria

# some constants
my $LICENSE_GRACE = 3;             # number of times we will check for the license before exiting
my $NORMALCALLDURATION = 0;        # if duration greater than this, set disc_code to 'N'
my $ERRORCALLDURATION = -1;        # if duration smaller than this, set disc_code to 'E'

my $keepRunning = 1;
my $cdrposter = undef;

# find the directory where this perl script is located at
my $mydir = dirname($0);

my %opt;
getopts('c:s:e:d:hHvV', \%opt) or print "Usage: $0 [-c config_file] <-s start_file[:line]> [-e end_file[:line]] [-d debuglevel] [-vh]\n" and exit;

if ($opt{v} || $opt{V})
{
    # if we are only asking for version...
    print STDOUT "GENBAND RSM Agent cdrcatchup version $NexTone::version::Version\n";
    exit 0;
}
if ($opt{h} || $opt{H})
{
    print STDERR "Usage: <$0> $0 [-c config_file] <-s start_file[:line]> [-e end_file[:line]] [-d debuglevel] [-vh]\n";
    exit 1;
}

# The files
my $CONFFILE    = "nars.cfg";      # contains nars app config
if ($opt{c})
{
    $CONFFILE = $opt{c};
}
else
{
    $CONFFILE = "$mydir/$CONFFILE";
}

my ($startFile, $startLine, $endFile, $endLine) = (undef, undef, undef, undef);
if ($opt{s})
{
    ($startFile, $startLine) =  split(/:/, $opt{s});
	unless ($startFile =~ /CDT$/ || $startFile =~ /CDR$/)
	{
		print STDERR "The CDR files to catch up should have .CDR or .CDT extensions ($startFile)\n";
		exit 1;
	}
}
else
{
    print STDERR "Usage: <$0> $0 [-c config_file] <-s start_file[:line]> [-e end_file[:line]] [-d debuglevel] [-vh]\n";
    exit 1;
}

if ($opt{e})
{
    ($endFile, $endLine) = split(/:/, $opt{e});
	unless ($endFile =~ /CDT$/ || $endFile =~ /CDR$/)
	{
		print STDERR "The CDR files to catch up should have .CDR or .CDT extensions ($endFile)\n";
		exit 1;
	}
	if (($startFile =~ /CDR$/ && $endFile =~ /CDT$/) ||
		($startFile =~ /CDT$/ && $endFile =~ /CDR$/))
	{
		print STDERR "The start and end files should be both .CDR or .CDT\n";
		exit 1;
	}
}


# set output buffers to auto-flush
$| = 1;


# install signal handlers
$SIG{ABRT} = $SIG{BREAK} = $SIG{TERM} = $SIG{INT} = $SIG{KILL} = \&doExit;
$SIG{HUP} = $SIG{PIPE} = $SIG{USR1} = $SIG{USR2} = 'IGNORE';

my $loglevel = ($opt{d})?$opt{d}:$NexTone::Logger::DEBUG2;

# set up the logger
my $Logger = NexTone::Logger->new("/tmp/cdrcatchup.log", $loglevel, {maxSize => 1048576}, 'FILE');
if (! defined($Logger))
{
    exitProgram("Cannot instantiate logger: $NexTone::Logger::errstr");
}
$Logger->info("cdrcatchup running from $mydir: configfile=$CONFFILE start=$startFile:$startLine end=$endFile:$endLine loglevel = $loglevel");


# read the nars config file and store the params
my $config;
if (-f "$CONFFILE" && -T "$CONFFILE")
{
    $config = new Config::Simple(filename=>"$CONFFILE", mode=>O_RDONLY);
} else {
    exitProgram("Cannot read config file $CONFFILE");
}
my %cfghash = $config->param_hash();
my $cdr_dir = $cfghash{'default.cdrpath'};
my $cdrdir = dirname($startFile);
if ($cdrdir ne '.')
{
  $cdr_dir = $cdrdir;
}

exitProgram("Cannot read CDR storage path from $CONFFILE") unless $cdr_dir;
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
$Logger->debug1("makeCallidUnique = $makeCallidUnique");
my $rateCdrs = (defined($cfghash{'default.rateCdrs'}) && $cfghash{'default.rateCdrs'} eq 'TRUE')?1:0;
$Logger->debug1("rateCdrs = $rateCdrs");
my $normalCallDuration = defined($cfghash{'default.normalCallDuration'})?int($cfghash{'default.normalCallDuration'}):$NORMALCALLDURATION;
$Logger->debug1("normalCallDuration = $normalCallDuration");
my $errorCallDuration = defined($cfghash{'default.errorCallDuration'})?int($cfghash{'default.errorCallDuration'}):$ERRORCALLDURATION;
$Logger->debug1("errorCallDuration = $errorCallDuration");

my $cdrfilter = NexTone::Cdrfilter->new(\$Logger, $cfghash{'default.excludeEP'}, $cfghash{'default.excludeFilter'}, $cfghash{'default.includeFilter'});
exitProgram("Unable to process the filter criteria") unless ($cdrfilter);

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
                $Logger->error("Cannot process additional cdr stream: $NexTone::Cdrstreamer::errstr");
                if ($flag eq 'strict')
                {
                    exitProgram("Unable to process a strict cdr stream");
                }
                next;
            }
            $Logger->debug1("Adding $cstr->{id} to process list");
            push(@cdrStreamers, $cstr);
            push(@cdrStreamStrict, $flag);
        }
    }
}
my $streamsOnly = (defined($cfghash{'default.streamsOnly'}) && $cfghash{'default.streamsOnly'} eq 'TRUE')?1:0;
$Logger->debug1("streamsOnly = $streamsOnly");
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
exitProgram("License check failed: $NexTone::LM::errstr") if (licenseNotOk());

# create rater object (this will initialize connection with the database)
# narsAgentMode and localAddress values added 
if (!$streamsOnly) {
	$cdrposter = NexTone::Cdrposter->new($mydir,
                                      $cfghash{'default.host'},
                                      $cfghash{'default.user'},
                                      $cfghash{'default.pass'},
                                      \$Logger,
                                      $cfghash{'default.postThresh'},
                                      $cfghash{'default.postPeriod'},
					    $cfghash{'default.narsAgentMode'},
					    $cfghash{'default.localAddress'}, 
				      2,
                                             1,
                                             $startFile,
                                             $startLine
                                      );
	exitProgram("Cannot initiate cdrposter: $NexTone::Cdrposter::errstr") unless $cdrposter;
	$Logger->debug2("successfully created cdrposter");
}

# read the last place we left off at
# if the last place we left off is .CDT, then look for .CDT and then .CDR
my ($lastfileseen, $lastlineseen, $numlinesinlastfileseen) = ($startFile, 0, 0);
exitProgram("Unable to read start file: $startFile") unless (open(LFILE, "< $startFile"));
$numlinesinlastfileseen++ while (<LFILE>);
close(LFILE);
if (defined($startLine))
{
    $lastlineseen = ($startLine > 0)?($startLine - 1):0;
}

my $totalcount = 0;
my $fileext = ($startFile =~ /.CDR$/)?'.CDR':'.CDT';

while ($keepRunning)
{
    # process the .CDR files until there are no more
    $Logger->debug2("listing file changed since $lastfileseen");
    my @cdrlist = getFilesOlderThan($lastfileseen, $endFile, $fileext, ($numlinesinlastfileseen > $lastlineseen));

    exitProgram("No more CDR files to process") if ($#cdrlist < 0);

    foreach my $file (@cdrlist)
    {
		# if file is start file, start at lastlineseen (else start at line zero)
		# if file is end file, end at end line (else process whole file)
		processCDR($file, ($startFile =~ /$file$/)?$lastlineseen:0, (defined($endFile) && $endFile =~ /$file$/)?$endLine:0x7fffffff);

        if (!$keepRunning)
        {
            last;
        }
    }

    # check if the license has expired
    exitProgram("License check failed: $NexTone::LM::errstr") if (licenseNotOk());
} 

exitProgram("exiting while processing CDR files");  # only when TERM or INT is received

sub postCDREntry
{
   my ($entry, $file, $line) = @_;

   chomp($entry);

	my $status = 1;
	while ($keepRunning)
	{
	if (!$streamsOnly)
	{
		$status = $cdrposter->processCDREntry($entry, $file, $line, $mswId);
	}
	if($status)
	{
		last;
	}
        else
        {
            $Logger->warn("unable to insert cdr entry ($file:$line): $NexTone::Cdrposter::errstr");
        #    sleep(2);  # try again after 10 seconds
        }
	}
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

    # check if this cdr needs to be filtered out
    my ($filtered, @filterCriteria) = $cdrfilter->filterEntry($entry);
    if ($filtered)
    {
        $Logger->debug3("cdr entry filtered [$file:$line]: @filterCriteria");
        updateLastFileSeen($file, $line) if ($#cdrStreamers > 0);
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
                        }
                    }
                }
                $index++;
            }

            if ($updateFile)
            {
                $lastfileseen = $file;
                $lastlineseen = $line;
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
    my $endLine = defined($arg[2])?$arg[2]:0x7fffffff;  # line number to stop processing

    $Logger->debug2((caller(0))[3] . ": begin processing CDR file $file");

    unless (open(CDRFILE, "< $file"))
    {
        $Logger->error("Unable to open CDR file \"$file\": $!");
        return;
    }
    my $count = 0;
    my $cdrs = "";
    my @lines = <CDRFILE>;
    my $entry;
    my $status;	
    foreach $entry (@lines) 
    {
	chomp ($entry);
        $count++;
        if ($count > $endLine)
        {
            last;
        }
	if ($count < $line)
	{
	    next;
	}
        elsif ($count <= $endLine)
        {
	    processCDREntry($entry, $file, $count);
            $totalcount++;
	    printProgress() if ($totalcount%500 == 0);
            next;
        }

    }
	if($totalcount%500 != 0) {
		$status =  $cdrposter->postCDRdata();
	}
	
    close(CDRFILE);

    printProgress();

    $lastfileseen = $file;
    $lastlineseen = $count;
    $numlinesinlastfileseen = $count;

    $Logger->debug2((caller(0))[3] . ": end processing CDR file $file, $count lines processed");
}


############################################################
# sort the given hash according to the key and return a list
############################################################
sub sortFiles
{
    my ($files) = @_;
    my @list = ();

    foreach (sort { $a <=> $b } keys %$files)
    {
        push(@list, $files->{$_});
    }

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
    my ($referenceFile, $refEndFile, $ext, $chooseRefFile) = @_;

    # open the cdr directory
    opendir(CDR_DIR, $cdr_dir) or exitProgram("Cannot opendir $cdr_dir: $!");

    my %files;  # contains file names hashed by modification times

    my $mtime = 0;
    if (defined($referenceFile))
    {
        $mtime = (stat "$referenceFile")[9];
    }

    my $smtime = -1;
    if (defined($refEndFile))
    {
        $smtime = (stat "$refEndFile")[9];
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
        my $mt = (stat "$cdr_dir/$file")[9];
        if ((stat _)[7] && # skip the zero byte files
            ($mt > $mtime || ($chooseRefFile && $referenceFile =~ /$file$/)) &&
            ($mt <= $smtime))
        {
            if ($mt > $mtime)
            {
                $Logger->debug2("choosing $file because $mt > $mtime");
            }
            else
            {
                $Logger->debug2("choosing $file because $referenceFile matches");
            }
            $files{$mt} = $file;
        }
    }

    closedir(CDR_DIR);

    return sortFiles(\%files);
}


#
# exit signal received
#
sub doExit
{
    my ($signal) = @_;
    $keepRunning = 0;
    $Logger->info("Received signal: $signal");
}


sub printProgress
{
    print STDOUT "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";
    print STDOUT "Processed $totalcount entries";
}


#############################
# do all the cleanup and exit
#############################
sub exitProgram
{
    my @arg = @_;

    printProgress();

    print "\nLastseen: $lastfileseen:$lastlineseen\n";
    $cdrposter->endPosting() if (defined($cdrposter));


    # close the logger;
    if ($Logger)
    {
        $Logger->info("Processed $totalcount total CDR entries");
        $Logger->info("Lastseen: $lastfileseen:$lastlineseen");
        $Logger->error($arg[0]);
    }
    else
    {
        print "$arg[0]\n";
    }

    exit 0;
}


#################################
# check if we have license to run
#################################
sub licenseNotOk
{
    # only check for the license every 24 hours
    if ($keepRunning && (time - $lastLicenseCheckTime) > (24*60*60))
    {
        unless (NexTone::LM::Agent_Licensed("$CONFFILE", \$Logger, "RAM"))
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

sub END
{
    if ($Logger)
    {
        $Logger->info("cdrcatchup exited");
    }
    else
    {
# for some reason this block gets executed at the beginning of the program!
# maybe some interaction with daemonizing??
#        print "cdrserver exited\n";
    }
}


1;

