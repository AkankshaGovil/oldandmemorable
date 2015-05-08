package NexTone::Poster;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
use LWP::UserAgent;
$VERSION = 1.00;
@ISA = qw(Exporter);

use Carp;
use POSIX qw(strftime);


# some global variables
our $errstr = "";


# module private variables

###################################################################
# create and return a new https poster object
###################################################################
sub new
{
    my $class = shift;
    my ($user, $pass, $url, $loggerref) = @_;
    my $ua = LWP::UserAgent->new();
    my $logger = $$loggerref;

    $logger->debug1("url = $url");
    $logger->debug1("user = $user");
    $logger->debug1("pass = $pass");


    $ua->agent("HttpsPoster/0.1 ");
    my $req = HTTP::Request->new(POST =>$url);
    $req->push_header(Connection => 'Keep-Alive');
    $req->content_type('application/x-www-form-urlencoded');
    $req->authorization_basic($user,$pass);
    $class = ref($class) || $class;

    my $self = {
        _logger => $logger,
        _ua		=> $ua,
        _user 	=> $user,
        _pass 	=> $pass,
        _url 	=> $url, 
	_req	=> $req
    };

    bless $self => $class;

    return $self;
}


sub post
{
    my $self = shift;
	my ($postData) = @_;
    _printDebug($self, "Posting to the URL: " . $self->{_url}, $NexTone::Logger::DEBUG4);
    $self->{_req}->content($postData);
    my $res = ($self->{_ua})->request($self->{_req});
    if (!$res->is_success) {
        _printError($self, "Post to the URL: " . $self->{_url} . " failed: " . $res->status_line);
    return undef;
    }
    if(!defined($res->content)){
    	_printDebug($self, "Post to the URL: " . $self->{_url} . " returned: undef", $NexTone::Logger::DEBUG4);
	return undef;
    }
    _printDebug($self, "Post to the URL: " . $self->{_url} . " returned: " . $res->content, $NexTone::Logger::DEBUG4);
    return $res->content;
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


# log an error message and set the errstr
sub _printError
{
    my $self = shift;
    $errstr = shift;

    if (defined($self->{_logger}))
    {
    	($self->{_logger})->error($errstr, (caller(0)));
    }
    else
    {
        carp "" . (caller(0))[3] . ": $errstr";
    }

    return 1;
}



1;
