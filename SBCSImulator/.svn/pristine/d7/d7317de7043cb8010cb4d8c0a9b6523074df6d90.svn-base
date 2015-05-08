# ============================================================================

# Snmp Trap Simulator

# ============================================================================


#! /usr/bin/perl

eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q' 

if 0;

use strict;

use Net::SNMP qw(:ALL);

require 'readConf.pl';
  
require 'netConf.pl';

require 'sendTraps.pl';


#### From readConf.pl


my @valuesFromConfig=&readConfig();
my $simulatorCount= $valuesFromConfig[0];
my $initialIp=$valuesFromConfig[1];
my $prefixHostname=$valuesFromConfig[2];
my $rsmIp=$valuesFromConfig[3];
my $path=$valuesFromConfig[4];	


my $count = 0;

#### Main Fuctionality

for ($trapId,$rsmIp,$initialIp,$path,$count; $count < $simulatorCount; $count++) {
	my $virtualIp=&createVirtualIp($initialIp,$count,$path);
	&sendSnmpTrap ($rsmIp,$virtualIp,$trapId);
	&deleteVirtualIp ($virtualIp ,$count);
}






##### Same as above -- A shorter approach
#### From readConf.pl
#my @valuesFromConfig=&readConfig();

#my $count = 0;

#### Main Fuctionality
#for (@valuesFromConfig,$count; $count < $valuesFromConfig[0]; $count++) {
#	my $virtualIp=&createVirtualIp($valuesFromConfig[1],$count,$valuesFromConfig[4]);
#	&sendSnmpTrap ($valuesFromConfig[2],$virtualIp,$valuesFromConfig[3]);
#	####&deleteVirtualIp ($virtualIp ,$count);
#
#}

### another -- use package filename.pl; in all parent files and here use filename::methodname instead of &methodname

exit 0;



