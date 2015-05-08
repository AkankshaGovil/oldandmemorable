#! /usr/bin/perl 


eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;
# simple script to send snmp trap from honeyd   ---------- to startr  bash a.pl 10.201.1.199 10.216.74.10 162 162


# ============================================================================

use strict;

use Net::SNMP qw(:ALL);

use strict;

use Net::SNMP qw(:ALL);


my ($session, $error) = Net::SNMP->session(
   -hostname  => '10.216.74.10',
   -community => 'public',
   -port      => '162',      # Need to use port 162
);

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

my $srcip=$ARGV[0];
my $dstip=$ARGV[1];
my $srcport=$ARGV[2];
my $dstport=$ARGV[3];
my $result = $session->trap(

# ============================================================================

# $Id: trap.pl,v 1.1 2007/06/04 21:35:22
# simple script to send snmp trap from honeyd

# ============================================================================

my ($session, $error) = Net::SNMP->session(
   -hostname  => '10.216.74.10',
   -community => 'public',
   -port      => SNMP_TRAP_PORT,      # Need to use port 162
));

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

my $srcip=$ARGV[0];
my $dstip=$ARGV[1];
my $srcport=$ARGV[2];
my $dstport=$ARGV[3];
my $result = $session->trap(
   -enterprise   => '1.3.6.1.4.1.50000',
   -generictrap  => 6,
   -specifictrap => 1,
   -varbindlist  => [
      '1.3.6.1.4.1.50000.1.1', OCTET_STRING, "$srcip",
      '1.3.6.1.4.1.50000.1.2', OCTET_STRING, "$dstip",
      '1.3.6.1.4.1.50000.1.3', OCTET_STRING, "$srcport",
      '1.3.6.1.4.1.50000.1.4', OCTET_STRING, "$dstport"
   ]
);

$session->close();


exit 0;
