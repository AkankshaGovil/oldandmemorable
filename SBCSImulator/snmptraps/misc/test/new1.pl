#!/usr/bin/perl


eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;

use Net::SNMP;

# requires a hostname and a community string as its arguments
($session,$error) = Net::SNMP->session(Hostname => '10.216.74.10',
                                       Community => 'public');

die "session error: $error" unless ($session);

# iso.org.dod.internet.mgmt.mib-2.interfaces.ifNumber.0 = 
#   1.3.6.1.2.1.2.1.0
$result = $session->get_request("1.3.6.1.2.1.1.3.0");

die "request error: ".$session->error unless (defined $result);

$session->close;

print "System Up Time: ".$result->{"1.3.6.1.2.1.1.3.0"}."\n";
