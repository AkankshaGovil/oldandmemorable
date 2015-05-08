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
print "trapSimCount=$values[2]\n";
print "intialIP=$values[4]\n";
print "rsmIp=$values[6]\n";
my $trapSimCount=$values[2];
my $initialIp=$values[4];
my $rsmIp=$values[6];

# ============================================================================

# $Id: trap.pl,v 4.1 2002/05/06 12:30:37 dtown Rel $

# Copyright (c) 2000-2002 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

#### Adding IP adresses 



my $ip=$initialIp;
my $count = 0;

for ($rsmIp,$ip,$count; $count < $trapSimCount; $count++) {
        my @ipnum=split(/\./,$ip);
      
        my $last=$ipnum[-1]+$count;   
        my $retval = pop(@ipnum);
        push @ipnum, $last;
        my $virtualIp=join(".",@ipnum); 
        print "Adding Virtual IP:- $virtualIp \n";
        system("ip addr add $virtualIp/16 dev eth0");
        # system("ip addr delete $virtualIp/16 dev eth0");


my ($session, $error) = Net::SNMP->session(
   -hostname  => $rsmIp,
   -community => 'public',
   -localaddr => $virtualIp,
   -port      => '162',      # Need to use port 162
);

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

## Trap specifying all values --warm start

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => $rsmIp,
   -generictrap  => WARM_START,
   -specifictrap => 0,
   -timestamp    => 12363000,
   -varbindlist  => [
      '1.3.6.1.2.1.1.1.0', OCTET_STRING, 'Hub',
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub'
   ]
);

if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
   printf("Trap-1 sent.\n");
   printf("Trap for warm start sent.\n");

}


## Trap specifying all values --COLD_START

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => $rsmIp,
   -generictrap  => COLD_START,
   -specifictrap => 0,
   -timestamp    => 12363000,
   -varbindlist  => [
      '1.3.6.1.2.1.1.1.0', OCTET_STRING, 'Hub',
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub'
   ]
);


if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
   printf("Trap-2 sent.\n");
   printf("Trap for cold start sent.\n");

}


#p specifying all values --AUTHENTICATION_FAILURE

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => $rsmIp,
   -generictrap  => AUTHENTICATION_FAILURE,
   -specifictrap => 0,
   -timestamp    => 12363000,
   -varbindlist  => [
      '1.3.6.1.2.1.1.1.0', OCTET_STRING, 'Hub',
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub'
   ]
);


if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
   printf("Trap-3 sent.\n");
   printf("Trap for authentication failure sent.\n");

}

# Trap for link up

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => $rsmIp,
   -generictrap  => LINK_UP,
   -specifictrap => 0,
   -timestamp    => 12363000,
   -varbindlist  => [
      '1.3.6.1.2.1.1.1.0', OCTET_STRING, 'Hub',
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub'
   ]
);

if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
   printf("Trap-4 sent.\n");
   printf("Trap for link up sent.\n");

}

## Trap for link down

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => $rsmIp,
   -generictrap  => LINK_DOWN,
   -specifictrap => 0,
   -timestamp    => 12363000,
   -varbindlist  => [
      '1.3.6.1.2.1.1.1.0', OCTET_STRING, 'Hub',
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub'
   ]
);

if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
   printf("Trap-5 sent.\n");
   printf("Trap for link down sent.\n");

}


$session->close();

print "Deleting Virtual IP:- $virtualIp \n";
system("ip addr delete $virtualIp/16 dev eth0");

}
exit 0;


