
# ============================================================================

# Snmp Trap Simulator

# ============================================================================


#! /usr/bin/perl

eval '(exit $?0)' && eval 'exec /usr/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/bin/perl $0 $argv:q'
if 0;

use strict;

use Net::SNMP qw(:ALL);


my @valuesFromConfig=&readConfig();
my $trapSimCount= $valuesFromConfig[0];
my $initialIp=$valuesFromConfig[1];
my $rsmIp=$valuesFromConfig[2];
my $trapId=$valuesFromConfig[3];
my $path=$valuesFromConfig[4];

print "Values retrieved from the config file:-\n";
print "trapSimCount=$trapSimCount\n";
print "intialIp=$initialIp\n";
print "rsmIp=$rsmIp\n"; 
print "trapId=$trapId\n";
print "path=$path\n";


my $count = 0;

for ($trapId,$rsmIp,$initialIp,$path,$count; $count < $trapSimCount; $count++) {
	
	my $virtualIp = &createVirtualIp ($initialIp,$count,$path);
	&sendSnmpTrap ($rsmIp,$virtualIp,$trapId);
	####&deleteVirtualIp ($virtualIp ,$count);

}


exit 0;


#### Read from the config file - config.txt

sub readConfig{

  my $file = "config.txt";
  my @values =();
  open(my $data, '<', $file) or die "Could not open '$file'\n";
  while (my $line =<$data>) {
    chomp $line;
    my @lines = grep { not /^#/ } <$data>;
    while (my $text=<@lines>){
	my @fields = split "=" , $text;
   	push(@values,$fields[1]);
       }
     }
  return @values;
  print "trapSimCount=$values[0]\n";
  print "intialIP=$values[1]\n";
  print "rsmIp=$values[2]\n"; 
  print "trapId=$values[3]\n";
  $trapSimCount=$values[0];
  $initialIp=$values[1];
  $rsmIp=$values[2];
  $trapId=$values[3];
  close($data);
  return($trapSimCount, $initialIp, $rsmIp, $trapId);	
}

#### Add Agent Address

sub addAgentAddress{

 my($v_ip,$path) = @_;
 my $a= $v_ip . ',';
 my $b= $v_ip.' ';
 my $file = $path;
 open(my $data, '<', $file) or die "Could not open '$file'\n";
 my $add;
 while (my $line =<$data>) {
    chomp $line;
    if($line =~  m/agentaddress/i)
      {$add=$line;}
     }
 close($data);

 open(my $data, '<', $file) or die "Could not open '$file'\n";
 while (my $line =<$data>) {
    chomp $line;
    if($line =~  $add){
    if($line =~ /($a)/) {
     if ($line =~ /($b)/){   
        print "Agent Address Exists\n";
        }}
    else{
	print "Agent address needs to be added\n";
	my $newline=$line.",".$v_ip;
	system("perl -pi -e 's/$line/$newline/' $file");
	print "Agent address added , hence restarting SNMP...";
 &restartSnmp();
	} 
  }
 }
 close($data);
 }


#### Restart SNMP

sub restartSnmp{
   print "Restarting SNMP.....";
   system ("/etc/init.d/snmpd restart");
  # sleep(5);
}

#### Add Virtual IP  

sub createVirtualIp {
   my($ip,$count,$path) = @_;
   my @ipnum=split(/\./,$ip);
   my $last=$ipnum[-1]+$count;   
   my $retval = pop(@ipnum);
   push @ipnum, $last;
   my $virtualIp=join(".",@ipnum); 
   print "Adding Virtual IP:- $virtualIp \n";
   system("ip addr add $virtualIp/16 dev eth0");
   &addAgentAddress($virtualIp,$path);
   return $virtualIp;

}

#### Delete Virtual IP

sub deleteVirtualIp {
   my($virtualIp,$count) = @_;
   print "Deleting Virtual IP:- $virtualIp \n";
   system("ip addr delete $virtualIp/16 dev eth0");

}

#### Send Snmp Traps
 
sub sendSnmpTrap {
   my($rsmIp,$virtualIp,$trapId) = @_;

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


   if ($trapId == '1' || $trapId == '6'){

   ## Trap for - warm start

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
	}

   if ($trapId == '2' || $trapId == '6'){
   ## Trap for - COLD_START

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
	}

   if ($trapId == '3' || $trapId == '6'){
   #Trap for - AUTHENTICATION_FAILURE

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
	}

   if ($trapId == '4' || $trapId == '6'){
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
	}
   if ($trapId == '5' || $trapId == '6'){
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
	}
   

   $session->close();
   
}




