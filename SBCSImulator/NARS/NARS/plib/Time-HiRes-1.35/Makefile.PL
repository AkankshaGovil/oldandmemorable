
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
#

require 5.002;

use Config;
use ExtUtils::MakeMaker;

# if you have 5.004_03 (and some slightly older versions?), xsubpp
# tries to generate line numbers in the C code generated from the .xs.
# unfortunately, it is a little buggy around #ifdef'd code.
# my choice is leave it in and have people with old perls complain 
# about the "Usage" bug, or leave it out and be unable to compile myself
# without changing it, and then I'd always forget to change it before a 
# release. Sorry, Edward :)

sub TMPDIR {
    my $TMPDIR =
	(grep(defined $_ && -d $_ && -w _,
	      ((defined $ENV{'TMPDIR'} ? $ENV{'TMPDIR'} : undef),
	       qw(/var/tmp /usr/tmp /tmp))))[0]
		   unless defined $TMPDIR;
    $TMPDIR || die "Cannot find writable temporary directory.\n";
}

sub try_compile_and_link {
    my ($c, %args) = @_;

    my ($ok) = 0;
    my ($tmp) = (($^O eq 'VMS') ? "sys\$scratch:tmp$$" : TMPDIR . '/' . "tmp$$");
    local(*TMPC);

    my $obj_ext = $Config{obj_ext} || ".o";
    unlink("$tmp.c", "$tmp$obj_ext");

    if (open(TMPC, ">$tmp.c")) {
	print TMPC $c;
	close(TMPC);

	$cccmd = $args{cccmd};

	my $errornull;

	my $COREincdir = $Config{'archlibexp'} . '/' . 'CORE';
	my $ccflags = $Config{'ccflags'} . ' ' . "-I$COREincdir";
	if ($^O eq 'VMS') {
            my $perl_core = $Config{'installarchlib'};
            $perl_core =~ s/\]$/.CORE]/;
            $cccmd = "$Config{'cc'} /include=(perl_root:[000000],$perl_core) $tmp.c"; 
        }

        if ($args{silent}) {
	    $errornull = "2>/dev/null" unless defined $errornull;
	} else {
	    $errornull = '';
	}

	$cccmd = "$Config{'cc'} -o $tmp $ccflags $tmp.c @$LIBS $errornull"
	    unless defined $cccmd;
	if ($^O eq 'VMS') {
	    open( CMDFILE, ">$tmp.com" );
	    print CMDFILE "\$ SET MESSAGE/NOFACILITY/NOSEVERITY/NOIDENT/NOTEXT\n";
	    print CMDFILE "\$ $cccmd\n";
	    print CMDFILE "\$ IF \$SEVERITY .NE. 1 THEN EXIT 44\n";  # escalate
	    close CMDFILE;
	    system("\@ $tmp.com");
	    $ok = $?==0;
	    for ("$tmp.c", "$tmp$obj_ext", "$tmp.com", "$tmp$Config{exe_ext}") { 
		1 while unlink $_; 
	    }
        }
        else
        {
	    system($cccmd);
	    $ok = -s $tmp && -x _;
	    unlink("$tmp.c", $tmp);
        }
    }
    
    $ok;
}

sub has_gettimeofday {
    # confusing but true (if condition true ==> -DHAS_GETTIMEOFDAY already)
    return 0 if $Config{'d_gettimeod'} eq 'define';
    return 1 if try_compile_and_link(<<EOM); 
#include "EXTERN.h" 
#include "perl.h" 
#include "XSUB.h" 
#ifdef I_SYS_TYPES 
#   include <sys/types.h>
#endif

#ifdef I_SYS_TIME
#   include <sys/time.h>
#endif

#ifdef I_SYS_SELECT
#   include <sys/select.h>	/* struct timeval might be hidden in here */
#endif
static int foo()
{
    struct timeval tv;
    gettimeofday(&tv, 0);
}
int main _((int argc, char** argv, char** env))
{
    foo();
}
EOM
    return 0;
}

sub has_x {
    my ($x, %args) = @_; 

    return 1 if
    try_compile_and_link(<<EOM, %args);
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef I_UNISTD
#   include <unistd.h>
#endif

#ifdef I_SYS_TYPES
#   include <sys/types.h>
#endif

#ifdef I_SYS_TIME
#   include <sys/time.h>
#endif

int main _((int argc, char** argv, char** env))
{
	$x;
}
EOM
    return 0;
}

sub unixinit {
    $DEFINE = '';

    $LIBS = [];

    # this might break the link, try it if it can't find some things you 
    # honestly think should be in there...
    # $LIBS = ['-lucb -lbsd'];

    # ... but ucb is poison for Solaris, and probably Linux. honest.
    $LIBS = [] if $Config{'osname'} eq 'solaris';
    $LIBS = [] if $Config{'osname'} eq 'linux';
    $LIBS = ['-lm'] if $Config{'osname'} =~ /sco/i;

    # For nanosleep
    push @$LIBS, '-lrt'		unless $Config{'osname'} =~ /irix/;
    push @$LIBS, '-lposix4'	;

    my @goodlibs;

    select(STDOUT); $| = 1;

    print "Checking for libraries...\n";
    for my $lib (@$LIBS) {
	print "Checking for $lib...\n";
	$LIBS = [ $lib ];
	if ($Config{$libs =~ /\b$lib\b/} || has_x("time(0)", silent => 1)) {
	    push @goodlibs, $lib;
	}
    }
    @$LIBS = @goodlibs;
    print @$LIBS ?
	  "You have extra libraries: @$LIBS.\n" :
          "You have no extra libraries.\n";
    print "\n";

    print "Looking for gettimeofday()...\n";
    my $has_gettimeofday;
    if ($Config{'d_gettimeod'}) {
	$has_gettimeofday++;
    } elsif (has_gettimeofday()) {
	$DEFINE .= ' -DHAS_GETTIMEOFDAY';
	$has_gettimeofday++;
    }

    if ($has_gettimeofday) {
	print "You have gettimeofday().\n\n";
    } else {
	die <<EOD
Your operating system does not seem to have the gettimeofday() function.
(or, at least, I cannot find it)

There is no way Time::HiRes is going to work.

I am awfully sorry but I cannot go further.

Aborting configuration.

EOD
    }

    print "Looking for setitimer()...\n";
    my $has_setitimer;
    if ($Config{d_setitimer}) {
        $has_setitimer++;
    } elsif (has_x("setitimer(ITIMER_REAL, 0, 0)")) {
        $has_setitimer++;
        $DEFINE .= ' -DHAS_SETITIMER';
    }

    if ($has_setitimer) {
        print "You have setitimer().\n\n";
    } else {
	print "No setitimer().\n\n";
    }

    print "Looking for getitimer()...\n";
    my $has_getitimer;
    if ($Config{d_getitimer}) {
        $has_getitimer++;
    } elsif (has_x("getitimer(ITIMER_REAL, 0)")) {
        $has_getitimer++;
        $DEFINE .= ' -DHAS_GETITIMER';
    }

    if ($has_getitimer) {
        print "You have getitimer().\n\n";
    } else {
	print "No getitimer().\n\n";
    }

    if ($has_setitimer && $has_getitimer) {
	print "You have interval timers.\n\n";
    } else {
	print "No interval timers.\n\n";
    }

    print "Looking for ualarm()...\n";
    my $has_ualarm; 
    if ($Config{d_ualarm}) {
        $has_ualarm++;
    } elsif (has_x ("ualarm (0, 0)")) {
        $has_ualarm++;
	$DEFINE .= ' -DHAS_UALARM';
    }

    if ($has_ualarm) {
        print "You have ualarm().\n\n";
    } else {
	print "Whoops! No ualarm()!\n";
	if ($setitimer) {
	    print "You have setitimer(); we can make a Time::HiRes::ualarm()\n\n";
	} else {
	     print "We'll manage.\n\n";
	}
    }

    print "Looking for usleep()...\n";
    my $has_usleep;
    if ($Config{d_usleep}) {
	$has_usleep++;
    } elsif (has_x ("usleep (0)")) {
	$has_usleep++;
	$DEFINE .= ' -DHAS_USLEEP';
    }

    if ($has_usleep) {
	print "You have usleep().\n\n";
    } else {
	print "Whoops! No usleep()! Let's see if you have select().\n";
        if ($Config{'d_select'} eq 'define') {
	    print "You have select(); we can make a Time::HiRes::usleep()\n\n";
	} else {
	    print "No select(); you won't have a Time::HiRes::usleep()\n\n";
	}
    }

    print "Looking for nanosleep()...\n";
    my $has_nanosleep;
    if ($Config{d_nanosleep}) {
	$has_nanosleep++;
    } elsif (has_x ("nanosleep (NULL, NULL)")) {
	$has_nanosleep++;
	$DEFINE .= ' -DHAS_NANOSLEEP';
    }

    if ($has_nanosleep) {
	print "You have nanosleep().  You can mix subsecond sleeps with signals.\n\n";
    } else {
	print "Whoops! No nanosleep()!  You cannot mix subsecond sleeps with signals.\n";
    }

    if ($DEFINE) {
        $DEFINE =~ s/^\s+//;
        if (open(XDEFINE, ">xdefine")) {
	    print XDEFINE $DEFINE, "\n";
	    close(XDEFINE);
        }
    }
}

sub doMakefile {
    @makefileopts = ();

    if ($] >= 5.005) {
	push (@makefileopts,
	    'AUTHOR'    => 'Jarkko Hietaniemi <jhi@iki.fi>',
	    'ABSTRACT_FROM' => 'lib/Time/HiRes.pm',
	);
	$DEFINE .= " -DATLEASTFIVEOHOHFIVE";
    }

    push (@makefileopts,
	'NAME'	=> 'Time::HiRes',
	'VERSION_FROM' => 'lib/Time/HiRes.pm', # finds $VERSION
	'LIBS'	=> $LIBS,   # e.g., '-lm' 
	'DEFINE'	=> $DEFINE,     # e.g., '-DHAS_SOMETHING' 
	'XSOPT'	=> $XSOPT,
    # do not even think about 'INC' => '-I/usr/ucbinclude', Solaris will avenge.
	'INC'	=> '',     # e.g., '-I/usr/include/other' 
        'MAN3PODS'  => {},  # Pods will be built by installman.
	'dist'      => {
	    'CI'       => 'ci -l',
	    'COMPRESS' => 'gzip -9f', 
	    'SUFFIX'   => 'gz',
	},
        clean => { FILES => "xdefine" },
    );

    WriteMakefile(@makefileopts);
}

sub main {
    print <<EOM;

Configuring Time::HiRes...

EOM

    if ($^O =~ /Win32/i) {
      $DEFINE = '-DSELECT_IS_BROKEN';
      $LIBS = [''];
    } else {
      unixinit();
    }
    configure;
    doMakefile;
    my $make = $Config{'make'} || "make";
print  <<EOM;

Done configuring.

Now you may issue '$make'.  Do not forget also '$make test'.

EOM
}

&main;

# EOF
