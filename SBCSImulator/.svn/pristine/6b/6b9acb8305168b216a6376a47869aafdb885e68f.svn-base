#!/usr/bin/perl


eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;

use NetSNMP::agent (':all');
use NetSNMP::ASN qw(ASN_OCTET_STR ASN_INTEGER);

use SNMP::Util;
$host = 'localhost';
$community = "public";
$ifNumberOID = '.1.3.6.1.2.1.2.1.0';
$ifTypeOID = '.1.3.6.1.2.1.2.2.1.3';
$ifOperStatusOID = '.1.3.6.1.2.1.2.2.1.8';
$output = "serverlist.txt";

$snmp = new SNMP::Util(-device => $host,
		       -community => $community);
open (OUTPUT, ">> $output");
       
$ifNumber = $snmp->get('v',$ifNumberOID);

$i = 1;

while ($i <= $ifNumber)
{
	$ifType = $snmp->get('v',"$ifTypeOID\.$i");
	if ($ifType =~ m/.*tokenRing.*/i)
	{
		$ifOperStatus = $snmp->get('v',"$ifOperStatusOID\.$i");
		print (OUTPUT "$host:$ifType:$ifOperStatus Status\n");
	}
	elsif ($ifType =~ m/.*ethernet.*/i)
	{
		$ifOperStatus = $snmp->get('v',"$ifOperStatusOID\.$i");
		print (OUTPUT "$host:$ifType:$ifOperStatus\n");
	}
	$i++;
}
close (OUTPUT);
