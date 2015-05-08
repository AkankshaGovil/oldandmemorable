# use warnings;
# use strict;


#! /usr/bin/perl

eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;

my $version=1;
use lib '/usr/lib/mrtg2'; # location of SNMP_Session.pm and BER.pm

my $trap_receiver = "10.216.74.10";
my $trap_community = "SNMP_Traps";
my $trap_session = $version eq '1'
    ? SNMP_Session->open ($trap_receiver, $trap_community, 162)
    : SNMPv2c_Session->open ($trap_receiver, $trap_community, 162);
my $myIpAddress = "10.201.1.199";
my $start_time = time;


sub link_down_trap ($$) {
  my ($if_index, $version) = @_;
  my $genericTrap = 2;          # linkDown
  my $specificTrap = 0;
  my @ifIndex_OID = ( 1,3,6,1,2,1,2,2,1,1 );        # UPDATE: not ifIndexOID
  my @ifDescr_OID = ( 1,3,6,1,2,1,2,2,1,2 );        # UPDATE: added
  my $upTime = int ((time - $start_time) * 100.0);
  my @myOID = ( 1,3,6,1,4,1,2946,0,8,15 );

  warn "Sending trap failed"
    unless ($version eq '1')
        ? $trap_session->trap_request_send (encode_oid (@myOID),
                                            encode_ip_address ($myIpAddress),
                                            encode_int ($genericTrap),
                                            encode_int ($specificTrap),
                                            encode_timeticks ($upTime),
                                            [encode_oid (@ifIndex_OID,$if_index),
                                             encode_int ($if_index)],
                                            [encode_oid (@ifDescr_OID,$if_index),
                                             encode_string ("foo")])
            : $trap_session->v2_trap_request_send (\@linkDown_OID, $upTime,
                                                   [encode_oid (@ifIndex_OID,$if_index),
                                                    encode_int ($if_index)],
                                                   [encode_oid (@ifDescr_OID,$if_index),
                                                    encode_string ("foo")]);
}

link_down_trap 123, $version;
