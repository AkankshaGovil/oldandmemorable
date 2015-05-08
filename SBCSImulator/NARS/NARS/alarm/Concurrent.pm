#!/usr/bin/perl

package Net::Daemon::Concurrent;

#
# Concurrent server
#
require 5.004;
use strict;

require Net::Daemon;

use vars qw($VERSION @ISA);
$VERSION = '0.01';
@ISA = qw(Net::Daemon); # to inherit from Net::Daemon

sub Version ($) { 'Calculator Example Server, 0.01'; }

# Add a command line option "--base"
    sub Options ($) {
    my($self) = @_;
    my($options) = $self->SUPER::Options();
    $options->{'base'} = { 'template' => 'base=s',
                       'description' => '--base'
                        };
    $options;
}

# Treat command line option in the constructor
sub new ($$;$) {
    my($class, $attr, $args) = @_;
    my($self) = $class->SUPER::new($attr, $args);
    if ($self->{'parent'}) {
        # Called via Clone()
        $self->{'base'} = $self->{'parent'}->{'base'};
    } else {
        # Initial call
        if ($self->{'options'}  &&  $self->{'options'}->{'base'}) {
            $self->{'base'} = $self->{'options'}->{'base'}
        }
    }
    if (!$self->{'base'}) {
        $self->{'base'} = 'dec';
    }
    $self;
}

sub cred {
    my $self = shift;
    $self->Debug("New client connected ($self).");
    my $rc =  eval {
        if (!$self->Accept()) {
            $self->Error('Refusing client');
            $self->Debug("Child terminating.");
            $self->Close();
            return 0;
        } else {
            $self->Debug('Accepting client');
            return 1;
        }
    };

    return $rc;
}

sub Bind ($) {
    my $self = shift;
    my $fh = '';
    my $child_pid;

    $SIG{'CHLD'} = 'IGNORE';
    if (!$self->{'socket'}) {
        $self->{'proto'} ||= ($self->{'localpath'}) ? 'unix' : 'tcp';

        if ($self->{'proto'} eq 'unix') {
            my $path = $self->{'localpath'}
                or $self->Fatal('Missing option: localpath');
            unlink $path;
            $self->Fatal("Can't remove stale Unix socket ($path): $!")
                if -e $path;
            my $old_umask = umask 0;
            $self->{'socket'} =
                IO::Socket::UNIX->new('Local' => $path,
                                      'Listen' => $self->{'listen'} || 10)
                      or $self->Fatal("Cannot create Unix socket $path: $!");
            umask $old_umask;
        } else {
            $self->{'socket'} = IO::Socket::INET6->new
                ( 'LocalAddr' => $self->{'localaddr'},
                  'LocalPort' => $self->{'localport'},
                  'Proto'     => $self->{'proto'} || 'tcp',
                  'Listen'    => $self->{'listen'} || 10,
                  'Reuse'     => 1)
                    or $self->Fatal("Cannot create socket: $!");
        }
    }
    $self->Log('notice', "Server starting");

    if ((my $pidfile = ($self->{'pidfile'} || '')) ne 'none') {
        $self->Debug("Writing PID to $pidfile");
        my $fh = Symbol::gensym();
        $self->Fatal("Cannot write to $pidfile: $!")
            unless (open (OUT, ">$pidfile")
                    and (print OUT "$$\n")
                    and close(OUT));
    }

    if (my $dir = $self->{'chroot'}) {
        $self->Debug("Changing root directory to $dir");
        if (!chroot($dir)) {
            $self->Fatal("Cannot change root directory to $dir: $!");
        }
    }

    if (my $group = $self->{'group'}) {
        $self->Debug("Changing GID to $group");
        my $gid;
        if ($group !~ /^\d+$/) {
            if (my $gid = getgrnam($group)) {
                $group = $gid;
            } else {
                $self->Fatal("Cannot determine gid of $group: $!");
            }
        }
        $( = ($) = $group);
    }

    if (my $user = $self->{'user'}) {
        $self->Debug("Changing UID to $user");
        my $uid;
        if ($user !~ /^\d+$/) {
            if (my $uid = getpwnam($user)) {
                $user = $uid;
            } else {
                $self->Fatal("Cannot determine uid of $user: $!");
            }
        }
        $< = ($> = $user);
    }

    my $time = $self->{'loop-timeout'} ?
        (time() + $self->{'loop-timeout'}) : 0;

    my $client;
        my $rin = '';
        vec($rin,$self->{'socket'}->fileno(),1) = 1;

    while (!$self->Done()) {
        undef $child_pid;
        my($rout, $t);

        if ($time) {
            my $tm = time();
            $t = $time - $tm;
            $t = 0 if $t < 0;
            $self->Debug("Loop time: time=$time now=$tm, t=$t");
        }

        my($nfound) = select($rout=$rin, undef, undef, $t);

        if ($nfound < 0) {
            if (!$child_pid  and
                ($! != POSIX::EINTR() or !$self->{'catchint'})) {
                $self->Fatal("%s server failed to select(): %s",
                             ref($self), $self->{'socket'}->error() || $!);
            }
        } 
        elsif ($nfound) {
            if (vec($rout, $self->{'socket'}->fileno(), 1)) {
                my $client = $self->{'socket'}->accept();
                if (!$client) {
                    if (!$child_pid  and
                        ($! != POSIX::EINTR() or !$self->{'catchint'})) {
                        $self->Error("%s server failed to accept: %s",
                        ref($self), $self->{'socket'}->error() || $!);
                    }
                } else {
                    if ($self->{'debug'}) {
                        my $from = $self->{'proto'} eq 'unix' ?
                            'Unix socket' :
                            sprintf('%s, port %s',
                                # SE 19990917: display client data!!
                                $client->peerhost(),
                                $client->peerport());
                        $self->Debug("Connection from $from");
                    }
                    my $sth = $self->Clone($client);
                    $self->Debug("Child clone: $sth\n");
                    if ($sth->cred()) {
                            vec($rin,$client->fileno(),1) = 1;
                        $self->{'peers'}{$client->fileno()} = \$sth;    
                    }
                    else {
                        undef $sth;    
                    }
                }
                $nfound--;    # Processed one fd
            }
            elsif ($self->{'peers'}) {
                my $fd;
                foreach $fd (keys %{$self->{'peers'}}) {
                    if (vec($rout, $fd, 1)) {
                        if (!${$self->{peers}{$fd}}->Run()) {
                            # connection closed 
                                vec($rin,$fd,1) = 0;
                            undef ${$self->{'peers'}{$fd}};    
                            delete $self->{'peers'}{$fd};    
                        }
                        $nfound--;
                    }
                }
            }

            $self->Debug("Warning: Hanging file descriptor \n") if ($nfound);
        }
        if ($time) {
            my $t = time();
            if ($t >= $time) {
                $time = $t;
                if ($self->{'loop-child'}) {
                    $self->ChildFunc('Loop');
                } else {
                    $self->Loop();
                }
                $time += $self->{'loop-timeout'};
            }
        }
    }
    $self->Log('notice', "%s server terminating", ref($self));
}

1;
