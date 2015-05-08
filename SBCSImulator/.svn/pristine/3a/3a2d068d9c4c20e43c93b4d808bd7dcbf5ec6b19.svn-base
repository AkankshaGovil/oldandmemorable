@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl -w
#line 15

use strict;

use DBI::Shell;
shell(@ARGV);
exit(0);

__END__

=head1 NAME

dbish	- Interactive command shell for the Perl DBI

=head1 SYNOPSIS

  dbish <options> dsn [user [password]]

=head1 DESCRIPTION

This tool is a command wrapper for the DBI::Shell perl module.
See L<DBI::Shell(3)> for full details.

=head1 SEE ALSO

L<DBI::Shell(3)>, L<DBI(3)>

=cut

__END__
:endofperl
