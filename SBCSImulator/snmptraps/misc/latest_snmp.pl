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

my ($session, $error) = Net::SNMP->session(
   -hostname  => '10.216.74.10',
   -community => 'public',
   -localaddr => $input_ip,
   -port      => '162',      # Need to use port 162 
);

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

## Trap specifying all values

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => '10.216.74.10',
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
   printf("Trap specifying all values sent.\n");

}
## Trap for link up

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => '10.216.74.10',
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
   printf("Trap-2 sent.\n");
   printf("Trap for link up sent.\n");

}

## Trap for link down

my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => '10.216.74.10',
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
   printf("Trap-3 sent.\n");
   printf("Trap for link down sent.\n");

}


## A trap using mainly default values

my @varbind = ('1.3.6.1.2.1.2.2.1.7.0', INTEGER, 1);

$result = $session->trap(-varbindlist  => \@varbind); 

if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
   printf("Trap-4 sent.\n");
   printf("Trap with default values sent.\n");

}

$session->close();

## Create a new object with the version set to SNMPv2c 
## to send a snmpV2-trap.

($session, $error) = Net::SNMP->session(
   -hostname  => '10.216.74.10',
   -community => 'public',
   -localaddr => $input_ip,
   -localport => '162',
   -port      => '162',      # Need to use port 162
   -version   => 'snmpv2c'
);

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

$result = $session->snmpv2_trap(
   -varbindlist => [
      '1.3.6.1.2.1.1.3.0', TIMETICKS, 600,
      '1.3.6.1.6.3.1.1.4.1.0', OBJECT_IDENTIFIER, '1.3.6.1.4.1.326' 
   ]
);

if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("SNMPv2-Trap-PDU sent.\n");
}



$session->close();

exit 0;

# ============================================================================


