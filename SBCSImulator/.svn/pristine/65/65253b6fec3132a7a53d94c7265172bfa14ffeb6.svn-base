#! /usr/bin/perl


eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;



use strict;

use Net::SNMP qw(:ALL);


my $file = "config.txt";

my @values =();
open(my $data, '<', $file) or die "Could not open '$file'\n";

while (my $line = <$data>) {
  chomp $line;

  my @fields = split "=" , $line;
  push(@values,$fields[1]);

}
print "no=$values[1]\n";
print "ip=$values[2]\n";
print "rsm=$values[3]\n";
my $no=$values[1];
my $s_ip=$values[2];
my $rsm=$values[3];

# ============================================================================

# $Id: trap.pl,v 4.1 2002/05/06 12:30:37 dtown Rel $

# Copyright (c) 2000-2002 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

#### Adding IP adresses 



my $ip=$s_ip;
my $count = 1;

for ($rsm,$ip,$count; $count <= $no; $count++) {
        my @ipnum=split(/\./,$ip);
      
        my $last=$ipnum[-1]+$count;   
        my $retval = pop(@ipnum);
        push @ipnum, $last;
        my $v_ip=join(".",@ipnum); 
        print "Adding Virtual IP:- $v_ip \n";
        system("ip addr add $v_ip/16 dev eth0");
        
        system("snmptrap -v 2c -c public $rsm $v_ip linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
        print "Trap for link up sent\n";
	system("snmptrap -v 2c -c public $rsm $v_ip linkDown ifIndex.1 i 1 ifAdminStatus.1 i down ifOperStatus.1 i down ifDescr s eth0");
	print "Trap for link down sent\n";


       # print "Deleting Virtual IP:- $v_ip \n";
       # system("ip addr delete $v_ip/16 dev eth0");


}
exit 0;


