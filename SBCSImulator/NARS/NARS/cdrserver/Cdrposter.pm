package NexTone::Cdrposter;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
use LWP::UserAgent;
$VERSION = 1.00;
@ISA = qw(Exporter);

use Carp;
use POSIX qw(strftime);
use IO::File;
use NexTone::Trapposter; # nextone snmp trap


## Import LWP::Protocol::http for attaching simulated IP to the POST request
use LWP::Protocol::http;


# some global variables
our $errstr = "";
our %callNumberTypes = ( 'FROMSRC' => 0,
                         'AFTERSRCCP' => 1,
                         'ATDEST' => 2,
    );

# module private variables

###################################################################
# create and return a new cdrposter object
###################################################################
sub new
{
    my $class = shift;

    ## Simulator variables added - $narsAgentMode, $localAddress
    my ($mydir, $host, $user, $pass, $loggerref, $cdrPostThresh, $cdrPostPeriod , $narsAgentMode, $localAddress, $updateFileCode, $inst, $lastfileseen, $lastlineseen) = @_;

    $class = ref($class) || $class;

    my $self = {
        _postData => undef,
        _cdrCNT => 0,
        _lastPostTime => time,
        _ua => undef,
        _req => undef,
        _lastfileseenHandle => undef,
        _curFile => $lastfileseen,
        _curLine => $lastlineseen,
        _logger => $$loggerref,
        _cdrPostThresh => $cdrPostThresh,
        _cdrPostPeriod => $cdrPostPeriod,
	
    };

    ## Logger added to print values of $narsAgentMode, $localAddress
    if ($narsAgentMode == 1){
	 $self->{_logger}->info("\n**********narsAgentMode****************  = Simulator");
        $self->{_logger}->info("\n**********localAddress****************  = $localAddress");
	 }

    my $instPrefix = (($inst > 1) ? ($inst-1) : "");
    my $filename = undef;
    if ($updateFileCode == 1) {
        $filename = "$mydir/nars$instPrefix.lastseen";
    } elsif ($updateFileCode == 2) {
        $filename = "$mydir/cdrc$instPrefix.lastseen";
    } else {
        $errstr = "Invalid file update code: $updateFileCode";
        return undef;
    }

    unless (sysopen(FILE, "$filename", O_WRONLY|O_APPEND|O_CREAT)) {
        $errstr = "Unable to open lastseen file: $!";
        return undef;
    }
    $self->{_lastfileseenHandle} = *FILE;

    ## Code added to attach the simulated IP to the POST request    
    if ($narsAgentMode == 1)
	{
	$self->{_logger}->info("\nAttaching the simulated IP to the POST request");
	@LWP::Protocol::http::EXTRA_SOCK_OPTS = (LocalAddr => $localAddress);
	}

    
    $self->{_ua} = LWP::UserAgent->new(keep_alive => 1000, timeout => 5000);
    $self->{_ua}->agent("CdrPoster/0.1 ");

    my $url = $NexTone::Constants::RATER_URL_PREFIX . $host . $NexTone::Constants::RATER_URL_SUFFIX;
    if (is_ipv6($host)) {
        $url = $NexTone::Constants::RATER_URL_PREFIX . "[" . $host . "]" . $NexTone::Constants::RATER_URL_SUFFIX;
    }

    $self->{_req} = HTTP::Request->new(POST =>$url);
    $self->{_req}->push_header(Connection => 'Keep-Alive');
    $self->{_req}->content_type('application/x-www-form-urlencoded');
    $self->{_req}->authorization_basic($user,$pass);

    $self->{_logger}->debug1("url = $url");
    $self->{_logger}->debug1("user = $user");
    $self->{_logger}->debug1("pass = $pass");
    $self->{_logger}->debug1("cdrPostThresh = $cdrPostThresh");
    $self->{_logger}->debug1("cdrPostPeriod = $cdrPostPeriod");
    $self->{_logger}->info("will update last seen file: $filename");

    _updateLastFileSeen($self) if (defined($self->{_curFile}));

    bless $self => $class;

    return $self;
}


#########################################################################
# process an individual CDR entry
#
# if it is time (postPeriod) or the buffer is full, post the cdr
# else store it in the buffer
#
# return undef if the CDR entry could not be inserted, 1 otherwise
#########################################################################
sub processCDREntry
{
    my $self = shift;

    # arguments passed are (cdr entry, cdr file, cdr line number, unique callid extension, rate cdr flag, normal call duration, error call duration)
    my ($cdrEntry, $cdrFile, $cdrLine, $mswId) = @_;

    # post the cdr to the server
    if (($self->{_cdrCNT} > 0) && (($self->{_curFile} ne $cdrFile) || ($self->{_cdrCNT} >= $self->{_cdrPostThresh}) ))
    {
	# limit reached, we cannot process any more until we flush our buffers
        # OR
        # a new cdr file started, flush the current buffer entries
	_printDebug($self, "" . (caller(0))[3] . "buffer limit reached (or a new file started), will have to wait until buffer is free", $NexTone::Logger::DEBUG2);
	postCDRdata($self);
	return undef;  # make caller retry the current entry again
    }
    else
    {
        my $postCdr=$mswId.";".$cdrFile.";".$cdrLine.";".$cdrEntry;

        $self->{_curFile} = $cdrFile;
        $self->{_curLine} = $cdrLine;

#    	_printDebug($self, "buffering...", $NexTone::Logger::DEBUG4);
	if ($self->{_postData})
	{
    	    $self->{_postData} .= "\n".$postCdr;
	}
	else
	{
	    $self->{_postData} = $postCdr;
	}
    	$self->{_cdrCNT}++;
    	if (($self->{_cdrCNT} >= $self->{_cdrPostThresh}) || ((time - $self->{_lastPostTime}) >= $self->{_cdrPostPeriod} ))   
    	{
    		_printDebug($self, "Posting buffered data $self->{_cdrCNT}", $NexTone::Logger::DEBUG4);
      		postCDRdata($self);
    	}
    }
    return 1;
}

sub postCDRdata
{
    my $self = shift;
    if (!defined($self->{_postData}))
    {
        _printDebug($self, "attempt to post empty data", $NexTone::Logger::DEBUG3);
        return 1;
    }

    _printDebug($self, "Posting Batch to the URL: " . $self->{_postData}, $NexTone::Logger::DEBUG4);
    $self->{_req}->content($self->{_postData});
    my $res = $self->{_ua}->request($self->{_req});
    if ($res->is_success && $res->content eq "ok") {
        _printDebug($self, "successfully posted $self->{_cdrCNT} cdrs to the URL: " . $res->status_line . '/' . $res->content, $NexTone::Logger::DEBUG4);
        $self->{_postData} = undef;
        $self->{_cdrCNT} = 0;
        $self->{_lastPostTime} = time;
        _updateLastFileSeen($self);
    } else {
    	## may be RSM occued a internal error, and response str include string "RSM Error Page"
    	if(index($res->content, "RSM Error Page") >= 0 || index($res->content, "ackerror") >= 0){
    		##ackerror
    		my $trap = NexTone::Trapposter->new();
			$trap->sendAndLogTrap("1", "008");
    	}else{
    		##tcp connection failuer/timeout
    		my $trap = NexTone::Trapposter->new();
			$trap->sendAndLogTrap("1", "001");
    	}

        _printError($self, "Post failed: " . $res->status_line . '/' . $res->content);
        _printError($self, "unable to post cdr entry ($self->{_curFile}:$self->{_curLine})");
        _printError($self, "number of cdrs in buffer ($self->{_cdrCNT})");
        return undef;
    }

    return 1;
}


#####################################
# convert HHH:MM:SS format to seconds
#####################################
sub _tosec
{
    my ($hr, $min, $sec) = split(/\:/, shift(@_));
    return ($hr*3600)+($min*60)+$sec;
}


# log an error message and set the errstr
sub _printError
{
    my $self = shift;
    $errstr = shift;

    if (defined($self->{_logger}))
    {
	$self->{_logger}->error($errstr, (caller(0)));
    }
    else
    {
        carp "" . (caller(0))[3] . ": $errstr";
    }

    return 1;
}


# log an warning message and set the errstr
sub _printWarn
{
    my $self = shift;
    $errstr = shift;

    if (defined($self->{_logger}))
    {
	$self->{_logger}->warn($errstr, (caller(0)));
    }
    else
    {
        carp "" . (caller(1))[3] . ": $errstr";
    }

    return 1;
}


# log a debug message
sub _printDebug
{
    my $self = shift;
    my $msg = shift;
    my $level = shift;

    if (defined($self->{_logger}))
    {
	$self->{_logger}->debug($msg, $level, (caller(0)));
    }

    return 1;
}

sub _updateLastFileSeen
{
    my $self = shift;

    sysseek($self->{_lastfileseenHandle}, 0, 0);
    truncate($self->{_lastfileseenHandle}, 0);
    syswrite($self->{_lastfileseenHandle}, "$self->{_curFile}" . ":" . "$self->{_curLine}");

    return 1;
}

sub endPosting
{
    my $self = shift;

    # flush the buffer
    postCDRdata($self);

    close($self->{_lastfileseenHandle}) if (defined($self->{_lastfileseenHandle}));

    return 1;
}

sub is_ipv6 
{ 
  my($ipv6) = @_; 

  return $ipv6 =~ /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/; 
} 

1;

