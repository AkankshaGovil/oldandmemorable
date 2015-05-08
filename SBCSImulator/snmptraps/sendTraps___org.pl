# ============================================================================

# Send Traps -Snmp Trap Simulator

# ============================================================================



print "File sendTraps.pl imported.\n";


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
    	   -agentaddr    => $virtualIp,
	   -version      => 'snmpv2c',
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
   	   -agentaddr    => $virtualIp,
	   -version      => 'snmpv2c',
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
   	   -agentaddr    => $virtualIp,
	   -version      => 'snmpv2c',
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
   	   -agentaddr    => $virtualIp,
	   -version      => 'snmpv2',
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
   	   -agentaddr    => $virtualIp,
	   -version      => 'snmpv2',
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




