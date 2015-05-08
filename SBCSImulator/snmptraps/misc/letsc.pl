#! /usr/bin/perl


eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;



use strict;

use Net::SNMP qw(:ALL);


system("snmptrap -v 2c -c public 10.216.74.10 10.201.1.10 linkUp ifIndex.1 i 1 ifAdminStatus.1 i up ifOperStatus.1 i up ifDescr s eth0");
print "Trap for link up sent\n";
system("snmptrap -v 2c -c public 10.216.74.10 10.201.1.10 linkDown ifIndex.1 i 1 ifAdminStatus.1 i down ifOperStatus.1 i down ifDescr s eth0");
print "Trap for link down sent\n";


       # print "Deleting Virtual IP:- $v_ip \n";
       # system("ip addr delete $v_ip/16 dev eth0");



exit 0;


