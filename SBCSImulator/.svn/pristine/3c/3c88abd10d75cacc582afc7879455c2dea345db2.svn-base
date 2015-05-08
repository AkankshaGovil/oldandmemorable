package NexTone::Logger;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION = 1.00;
@ISA = qw(Exporter);

use Carp;
use Fcntl;
use POSIX qw(strftime);
use Config::Simple;
use IO::File;
use Data::Dumper;
use File::Copy;


# some global variables
our $NONE = 0;
our $ERROR = 1;
our $WARN = 2;
our $INFO = 3;
our $DEBUG1 = 4;
our $DEBUG2 = 5;
our $DEBUG3 = 6;
our $DEBUG4 = 7;

our $errstr = '';

my @Levels = ('NONE', 'ERROR', 'WARN', 'INFO', 'DEBUG1', 'DEBUG2', 'DEBUG3', 'DEBUG4');


# package private variables
my $FILE_CHECK_PERIOD = 30;  # check the log config file every 30 seconds
my $lastFileCheckTime = 0;


#
# call with either
#        logfilename, loglevel, logoptions
# or
#        loggingConfigFilename
#
sub new
{
    my $class = shift;
    my ($logfile, $level, $options, $logType) = @_;
    my $logconfigfile = undef;

    $class = ref($class) || $class;

    # if only logfile is defined, we need to take the logging config
    # from a file, if level is also defined, then the logging config
    # is passed to us
    if (!defined($level))
    {
        $logconfigfile = $logfile;
        ($logType, $logfile, $level, $options) = _processConfigFile($logconfigfile);
        $lastFileCheckTime = time;
    }
    elsif ($level == $NONE)
    {
        # if log level is NONE that means the logging config file is defined
        # and some other process may have started logging and we have to just append
        $logconfigfile = $logfile;
        ($logType, $logfile, $level, $options) = _processConfigFile($logconfigfile);
        $lastFileCheckTime = time;
        $options->{'mode'} = 'append';
    }

    if (!defined($logfile))
    {
        $errstr = "Unable to determine log file name: $!";
        return undef;
    }
    if (!defined($logType))
    {
        $logType = 'CONSOLE';
    }

    my $flag = O_RDWR|O_CREAT;
    if ($options->{'mode'} ne 'append')
    {
        $flag |= O_TRUNC;
    }

    my $self = {
        _logconfigfile => $logconfigfile,
        _logType => $logType,
        _logfile => $logfile,
        _logfileHandle => undef,
        _level => $level,
        _options => $options,
        _totalBytes => 0,
        _fflag => $flag,
    };

    if ("$logType" eq 'FILE')
    {
        unless(sysopen(LOGFILE, $logfile, $flag))
        {
            $errstr = "Cannot open \"$logfile\": $!";
            return undef;
        }
        $self->{_logfileHandle} = *LOGFILE;
    }

    bless $self => $class;

    _validateOptions($self);

    return $self;
}


#     logType = FILE | CONSOLE
#     filename = <log file name>
#     level = INFO | ERROR | WARN | DEBUG1 | DEBUG2 | DEBUG3 | DEBUG4 | NONE
#     mode = create | append
#     maxSize = xxxx (bytes)
#     maxIndex = xx (number of file rotations)
#     truncatePercent = xx  (percent of file to truncate)
sub _processConfigFile
{
    my $cfile = shift;

    my $config = undef;
    eval{$config = new Config::Simple(filename=>"$cfile", mode=>O_RDONLY)};
    if ($@)
    {
        $errstr = "Error reading config file: $@";
        return undef;
    }
    my %cfghash = $config->param_hash();

    my %options;
    $options{'mode'} = $cfghash{'default.mode'};
    $options{'maxSize'} = $cfghash{'default.maxSize'};
    $options{'maxIndex'} = $cfghash{'default.maxIndex'};
    $options{'truncatePercent'} = $cfghash{'default.truncatePercent'};

    my $level = $NONE;
    if ($cfghash{'default.level'} eq 'ERROR')
    {
        $level = $ERROR;
    } elsif ($cfghash{'default.level'} eq 'WARN')
    {
        $level = $WARN;
    } elsif ($cfghash{'default.level'} eq 'INFO')
    {
        $level = $INFO;
    } elsif ($cfghash{'default.level'} eq 'DEBUG1')
    {
        $level = $DEBUG1;
    } elsif ($cfghash{'default.level'} eq 'DEBUG2')
    {
        $level = $DEBUG2;
    } elsif ($cfghash{'default.level'} eq 'DEBUG3')
    {
        $level = $DEBUG3;
    } elsif ($cfghash{'default.level'} eq 'DEBUG4')
    {
        $level = $DEBUG4;
    }

    return ($cfghash{'default.logType'}, $cfghash{'default.filename'}, $level, \%options);
}


sub _validateOptions
{
    my $self = shift;

    if (!defined($self->{_options}->{'maxSize'}) ||
        $self->{_options}->{'maxSize'} < 0)
    {
        $self->{_options}->{'maxSize'} = 1048576;  # one meg
    }

    if (!defined($self->{_options}->{'maxIndex'}) ||
        $self->{_options}->{'maxIndex'} < 0)
    {
        $self->{_options}->{'maxIndex'} = 0;
    }

    if (defined($self->{_options}->{'truncatePercent'}))
    {
        if ($self->{_options}->{'truncatePercent'} <= 0 ||
            $self->{_options}->{'truncatePercent'} > 100)
        {
            $self->{_options}->{'truncatePercent'} = 100;
        }
    }
    else
    {
        $self->{_options}->{'truncatePercent'} = 10;
    }

#    print "truncate =  $self->{_options}->{'truncatePercent'}\n";

    return 1;
}


# get the next available index
# moves .1 to .2, .2 to .3 and so on and finally returns 1
sub _getNextIndex
{
    my $self = shift;

    my $index = ($self->{_options}->{'maxIndex'} - 1);
    while ($index > 0)
    {
        if (-f "$self->{_logfile}.$index")
        {
            # file exists, move if needed
            if ($index < $self->{_options}->{'maxIndex'})
            {
                my $nextIndex = ($index+1);
                move("$self->{_logfile}.$index", "$self->{_logfile}.$nextIndex");
            }
        }
        $index--;
    }

    return 1;
}


# takes actions for any options specified:
#     mode = create | append
#     maxSize = xxxx (bytes)
#     maxIndex = xx (number of file rotations)
#     truncatePercent = xx  (percent of file to truncate)
sub _checkOptions
{
    my $self = shift;

    # handle file limit
    if ($self->{_options}->{'maxSize'} > 0 &&
        $self->{_totalBytes} > $self->{_options}->{'maxSize'})
    {
#        print ("totalBytes =  $self->{_totalBytes}   maxSize = $self->{_options}->{'maxSize'}\n");

        # file limit has reached
        if ($self->{_options}->{'maxIndex'} > 0)
        {
            # handle file rotation
            my $nextIndex = _getNextIndex($self);
            close($self->{_logfileHandle});
            move("$self->{_logfile}", "$self->{_logfile}.$nextIndex");
            unless(sysopen(LOGFILE, $self->{_logfile}, $self->{_fflag}))
            {
                $errstr = "Cannot open \"$self->{_logfile}\": $!";
                return undef;
            }
            $self->{_logfileHandle} = *LOGFILE;
            $self->{_totalBytes} = 0;
        }
        else
        {
            # just chop 'truncatePercent' of the file at a time
            if ( $self->{_options}->{'truncatePercent'} == 100)
            {
                # just remove the whole content of the file
                sysseek($self->{_logfileHandle}, 0, 0);
                truncate($self->{_logfileHandle}, 0);
                $self->{_totalBytes} = 0;
            }
            else
            {
#                print "will truncate a percent\n";

                # try to chop top 'bytesToRemove' number of bytes
                my $curPosition = sysseek($self->{_logfileHandle}, 0, 1);
                my $bytesToRemove = int($curPosition * $self->{_options}->{'truncatePercent'} / 100);
                my $readPosition = $bytesToRemove;  # beginning read position
                my $readSize = $bytesToRemove - 1;  # I am not so clear about the boundaries...
                my $writePosition = 0;  # start writing from the beginning of the file

                # write a comment
                sysseek($self->{_logfileHandle}, $writePosition, 0);
                $writePosition += syswrite($self->{_logfileHandle}, "[trunc...]");

                while ($readPosition < $curPosition)
                {
                    my $buf;
#                    print "1: curPos = $curPosition  readPosition = $readPosition writePos = $writePosition  bytesToRemove = $bytesToRemove  readSize = $readSize\n";
                    # read the bytes
                    sysseek($self->{_logfileHandle}, $readPosition, 0);
                    my $retval = sysread($self->{_logfileHandle}, $buf, $readSize);
                    if ($retval)
                    {
                        $readPosition += $retval;
                    }
                    else
                    {
#                        print "retval for read = $retval    :  $!\n";
                    }
#                    print "2: curPos = $curPosition  readPosition = $readPosition writePos = $writePosition  bytesToRemove = $bytesToRemove  readSize = $readSize\n";

                    # write the bytes
                    sysseek($self->{_logfileHandle}, $writePosition, 0);
                    $retval = syswrite($self->{_logfileHandle}, $buf);
                    if ($retval)
                    {
                        $writePosition += $retval;
                    }
                    else
                    {
#                        print "retval for write = $retval        : $!\n";
                    }
#                    print "3: curPos = $curPosition  readPosition = $readPosition writePos = $writePosition  bytesToRemove = $bytesToRemove  readSize = $readSize\n";
                }
                truncate($self->{_logfileHandle}, $writePosition);
                $self->{_totalBytes} = sysseek($self->{_logfileHandle}, 0, 1);

#                print "\nfile size = $self->{_totalBytes}\n";
            }
        }
    }

    return 1;
}


sub _reloadConfigFile
{
    my $self = shift;

    # only do this if we were instantiated with a logging config file
    if (defined($self->{_logconfigfile}))
    {
        # see if we need to reload the config file contents
        if ((time - $lastFileCheckTime) > $FILE_CHECK_PERIOD)
        {
#            print time . ": checking for file changes\n";

            $lastFileCheckTime = time;
            my ($logType, $logfile, $level, $options) = _processConfigFile($self->{_logconfigfile});
            if (!defined($logType))
            {
                $logType = 'CONSOLE';
            }

            $self->{_logType} = $logType;
            $self->{_level} = $level;
            if ($options->{'mode'} ne 'append')
            {
                $self->{_fflag} |= O_TRUNC;
            }
            else
            {
                $self->{_fflag} &= ~O_TRUNC;
            }
            $self->{_options} = $options;
#            print "options maxIndex = $options->{'maxIndex'}\n";

            if ("$logType" eq 'CONSOLE' &&  defined($self->{_logfileHandle}))
            {
                # changed from file logging to console logging
                close($self->{_logfileHandle});
                $self->{_logfileHandle} = undef;
                $self->{_logfile} = '';
            }
            if ("$logType" eq 'FILE')
            {
                if (defined($self->{_logfileHandle}))
                {
                    if (defined($logfile))
                    {
                        if ("$logfile" ne "$self->{_logfile}")
                        {
                            # handle log file name change
                            close($self->{_logfileHandle});
                            $self->{_logfileHandle} = undef;
                            $self->{_logfile} = $logfile;
                            unless(sysopen(LOGFILE, $self->{_logfile}, $self->{_fflag}))
                            {
                                $errstr = "Cannot open \"$self->{_logfile}\": $!";
                                $lastFileCheckTime -= $FILE_CHECK_PERIOD; # check again soon
                                return undef;
                            }
                            $self->{_logfileHandle} = *LOGFILE;
                            $self->{_totalBytes} = 0; 
                        }
                    }
                    else
                    {
                        # logfile not defined in the config file
                        close($self->{_logfileHandle});
                        $self->{_logfileHandle} = undef;
                        $lastFileCheckTime -= $FILE_CHECK_PERIOD; # check again soon
                    }
                }
                else
                {
                    # changed from console logging to file logging
                    # (or previous file logging failed)
                    $self->{_logfile} = $logfile;
                    unless (sysopen(LOGFILE, $self->{_logfile}, $self->{_fflag}))
                    {
                        $errstr = "Cannot open \"$self->{_logfile}\": $!";
                        $lastFileCheckTime -= $FILE_CHECK_PERIOD; # check again soon
                        return undef;
                    }
                    $self->{_logfileHandle} = *LOGFILE;
                    $self->{_totalBytes} = 0;
                }
            }
        }
    }

    return 1;
}


sub _formString
{
    my $self = shift;
    my $level = shift;
    my $msg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    _reloadConfigFile($self) or return "$errstr";

    if (defined($self->{_logfileHandle}))
    {
        _checkOptions($self);
    }

    my $dt = strftime "%Y-%m-%d %H:%M:%S", localtime;
    if (!defined($pack))
    {
        ($pack, $file, $line) = caller(3);
    }

    return "$dt [$$] $level: $file $line $pack - $msg\n";
}


sub _writeMsg
{
    my $self = shift;
    my $errmsg = shift;
    my $level = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    if ($self->{_level} < $level)
    {
        return 1;
    }

    eval {
        my $str = _formString($self, $Levels[$level], $errmsg, $pack, $file, $line);

        if ($self->{_logType} eq 'CONSOLE')
        {
            print STDOUT $str;
        }
        elsif (defined($self->{_logfileHandle}))
        {
            sysseek($self->{_logfileHandle}, 0, 2);  # get to the end of the file
            my $total = syswrite($self->{_logfileHandle}, $str);
            if ($total)
            {
                $self->{_totalBytes} += $total;
            }
        }
    };

    return 1;
}


sub debug
{
    my $self = shift;
    my $errmsg = shift;
    my $level = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    if (!defined($level))
    {
        $level = $DEBUG4;
    }

    _writeMsg($self, $errmsg, $level, $pack, $file, $line);

    return 1;
}


sub debug1
{
    my $self = shift;
    my $errmsg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    return _writeMsg($self, $errmsg, $DEBUG1, $pack, $file, $line);
}


sub debug2
{
    my $self = shift;
    my $errmsg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    return _writeMsg($self, $errmsg, $DEBUG2, $pack, $file, $line);
}


sub debug3
{
    my $self = shift;
    my $errmsg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    return _writeMsg($self, $errmsg, $DEBUG3, $pack, $file, $line);
}


sub debug4
{
    my $self = shift;
    my $errmsg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    return _writeMsg($self, $errmsg, $DEBUG4, $pack, $file, $line);
}


sub info
{
    my $self = shift;
    my $errmsg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    return _writeMsg($self, $errmsg, $INFO, $pack, $file, $line);
}


sub warn
{
    my $self = shift;
    my $errmsg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    return _writeMsg($self, $errmsg, $WARN, $pack, $file, $line);
}


sub error
{
    my $self = shift;
    my $errmsg = shift;

    my $pack = shift;
    my $file = shift;
    my $line = shift;

    return _writeMsg($self, $errmsg, $ERROR, $pack, $file, $line);
}


sub DESTROY
{
    my $self = shift;

    if (defined($self->{_logfileHandle}))
    {
        close($self->{_logfileHandle});
    }
}


1;

