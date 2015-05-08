#! /usr/bin/perl

eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;

printf("Please enter an IP address to send a trap to :- ");
my $input_ip = <> ;
printf("\n");
printf("The IP entered is:-");
printf($input_ip);
printf("\n");

# ============================================================================

# $Id: trap.pl,v 4.1 2002/05/06 12:30:37 dtown Rel $

# Copyright (c) 2000-2002 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP qw(:ALL); 


my $returncode = `snmptrap -v 2c -c public 10.201.1.150 10.201.1.10 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0`; # backticks
system("snmptrap -v 2c -c public 10.201.1.150 10.201.1.10 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
exec 'snmptrap -v 2c -c public 10.201.1.150 10.201.1.11 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0';



#my $returncode = `snmptrap -v 2c -c public 10.216.74.10 10.201.1.199 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0`; # backticks
#system("snmptrap -v 2c -c public 10.216.74.10 10.201.1.199 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
#exec 'snmptrap -v 2c -c public 10.216.74.10 10.201.1.199 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0';

my $returncode = `snmptrap -v 2c -c public 10.216.74.10 10.201.1.198 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0`; # backticks
system("snmptrap -v 2c -c public 10.216.74.10 10.201.1.198 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
exec 'snmptrap -v 2c -c public 10.216.74.10 10.201.1.198 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0';


my $returncode = `snmptrap -v 2c -c public 10.216.74.10 10.201.1.197 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0`; # backticks
system("snmptrap -v 2c -c public 10.216.74.10 10.201.1.197 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
exec 'snmptrap -v 2c -c public 10.216.74.10 10.201.1.197 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0';

my $returncode = `snmptrap -v 2c -c public 10.216.74.10 10.201.1.196 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0`; # backticks
system("snmptrap -v 2c -c public 10.216.74.10 10.201.1.196 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
exec 'snmptrap -v 2c -c public 10.216.74.10 10.201.1.196 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0';

my $returncode = `snmptrap -v 2c -c public 10.216.74.10 10.201.1.195 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0`; # backticks
system("snmptrap -v 2c -c public 10.216.74.10 10.201.1.195 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
exec 'snmptrap -v 2c -c public 10.216.74.10 10.201.1.195 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0';

exit 0;

# ============================================================================


