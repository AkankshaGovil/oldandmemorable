#!/usr/bin/perl

# Script to block server ports using iptables or ipchains depending on the kernel version of the operating system.
# The scripts blocks all ports except the ones required by RSM 
# The user has been allowed to enter ports other than the default and add to the list so that they could be enabled  
# author Amit Kumar 
# date : 9/7/2008 

# command to find out version of kernel present on the machine 
my $kernelCommand = " uname -r "  ;

# variable to store version of kernel on the machine 
my $kernelVersion ;

#variable to denote whether the kernel supports blocking of ports. Is 1 if kernel supports it .
my $supported ; 

# variable to store the command used to block ports . May have only two values 'iptables' or 'ipchains'
my $command ;

# finds nextone home 
my $nextonehome = $ARGV[1] ;
my $filename = "/.portlist.txt" ;

# variable to store the path of file having the list of ports to be opened 
my $allowedPortsFile = $nextonehome.$filename;

# to store server ip address. To be received from parent script. If not a simple perl script to find is given below 
my $serveripaddr = $ARGV[0] ;

# for storing the type of os (redhat / suse or fedora )
my $ostype = "suse" ;

# filename to store the generated ip tables rules 
my $iptablesrules = "iptablesrules.txt" ; 

# name of the firewall service 
my $firewallservice = "RSMFirewall" ;

# variables to store various parameters of the command 
my $addRuleArg ="-A " ; 
my $delRuleArg ="-D " ; 
my $flush = " -F " ;
my $policyRuleArgs=" INPUT -j REJECT "  ;
my $tcpArg = " -p tcp " ;
my $udpArg = " -p udp " ;
my $portString = " --destination-port " ;
my $portArg = " " ; 
my $interfaceArgString = " -i " ;
my $interfaceArg = " eth0 " ;	# to be verified by the user 
my $statement = " " ;
my @userports = () ;
my @portarray =(22,80,162,443,8080,8081) ;

sub checkforsupport () {
	#gets kernel version 
	open (CONSOLE, " $kernelCommand  |");
	while (<CONSOLE>){
 		$kernelVersion=$_;
	}

	# logic to check the kernel version 
	$check=substr($kernelVersion,0,1) ;
	if ($check==2) {
		$check=substr($kernelVersion,2,1) ; 
   		$supported = 1 ;	
		if ($check>=4) {	
			$command = "iptables" ;
   		}
   		elsif ($check < 4 && $check >= 2  ) {
			$command = "ipchains" ;
    		} else {	
			$supported = 0 ; 
    		}	
	}
	elsif ($check > 2 ) {
		# For verisons 2.2 upto 2.4 ipchains are to used instead of iptables 
		$supported = 1 ;
		$command="iptables" ;
	}
	else {
		$supported = 0 ;	
		#ipchains and iptables are not supported by the kernel version ;
	}

}

#To ascertain the type of OS  
sub getOS () {
	#The variable may be unexported, so not using ENV
	open (CONSOLE, " echo \$MACHTYPE |");
	while (<CONSOLE>){
 		$ostype=$_;
	}
	chomp($ostype);
	if((!defined($ostype)) || !($ostype =~m/redhat/i || $ostype =~m/suse/i))	{
		print ("\n Unable to determine operating system automatically " );
		$reenter = 1 ;
		$oschoice = 's' ;
		while ($reenter == 1 ) {
			print ( "\n. Select the Operating System installed (R for Redhat , F for Fedora , S for Suse) ");
			$oschoice = <STDIN> ;
			chomp ($oschoice) ;
			if ( ! ($oschoice =~ /[rRfFsS]/) ) {
				print ("Unknown Operating System selected. The ports cannot be blocked.") ;
				print ("\n Press 1 to change your selection ") ;
				$reenter = <STDIN> ;
				chomp($reenter);
				
			}  else {
				$reenter = 0 ;
			}
		}
		if ( $oschoice =~ /[rRFf]/) {
			$ostype = " redhat " ;
		} elsif ($oschoice =~ /[sS]/) {
			$ostype = " suse " ;
		} else {
			$supported = 0
		}
	}	
}

 # for user additions / deletions 
sub getUserChoice () {

	my $menuchoice=0 ;
	print ("Press y to allow (open) any other port, otherwise any other key to continue.. ") ; 
	$choice=<STDIN> ;
 	while ($choice =~ /[yY]/ ) {
    		$flag="success" ;
		print ("Port Menu \n 1. Add a port to be opened \n 2. Disable an opened port \n 0. Exit "); 
		print ("\n. Note: The mandatory list of RSM ports cannot be modified.");
		$flag="wronginput" ;
		while ( $flag eq "wronginput") {
			print ("\n Enter your choice :") ;
			$menuchoice = <STDIN> ;
			if ( $menuchoice =~ /[0-2]/) {
				$flag="success" ;
			}
			if ( $flag eq "wronginput") {
				print ("Choose between 0, 1 or 2  ") ;
			}
		}
		if ( $menuchoice == 0 ) {
			$choice = 'n' ;
		}
		else {
    			$reenter = 1 ;
			while ($reenter == 1) {
				print ("Enter the port number :") ;
    				$portno = <STDIN> ;
				# to check the validity of the port entered 
    				if ( $portno =~  /[0-9]*/ ) {
 					if ($portno > 0 && $portno < 65536 ) {
	     					chomp($portno) 	 ;
	     				}
        				else {
              					$flag="invalidport" ;
					} 
   				}
    				else {
					$flag="invalidentry" ;
   				}	
				if ($flag eq "invalidport" ) {
					print (" Port number should lie between 0 and 65535 . Enter Again: ") ;
					$reenter = 1;
     				}
				elsif ($flag eq "invalidentry"  ) {
					print (" Invalid Entry. Please enter a number again: ") ;
					$reenter = 1;	
				}
				else {
					$reenter = 0 ;
				}
			}
			if  ($menuchoice == 1 ) {
				push(@userports,$portno) ;
				print ("Press y to make further changes or any other key to continue..  ") ; 
 	     			$choice=<STDIN> ;
			}
			elsif ($menuchoice == 2 ) {
				$delflag = 0 ;
				for ($index = 0 ; $index <= $#userports; $index++) {
					if ($userports[$index]==$portno) {
						$temp=$userports[$#portarray] ;
						$userports[$#portarray]=$userports[$index] ;
						$userports[$index]=temp ;
						pop(@userports) ;
						$delflag=1 ;
					}
				}
				if ($delflag==1){
					print ("Port number successfully removed from the opened port list. ") ;	
				}
				else {
					print ("Port number not present in the opened port list ") ;	
				}
				print (" Do you wish to make any further changes (y/n) ") ; 
 	     			$choice=<STDIN> ;
			}
			else {
				#do nothing 
			}	 
 		}
	}
	splice(@portarray,$#portarray+1,0,@userports);
}

#perform actions if supported 
sub doAction () {
	if ($supported == 0) {
		# prints msgs and exits 
		print (" The kernel does not support the blocking of ports. \n") ;
	} else {
 		print ("Security script is going to disable all other ports except the following: \n ") ;  
 		#open (ENABLEDPORTS ," $allowedPortsFile " ) ; 
 		#if (!<ENABLEDPORTS>) {
 		#print ("Cannot find file ") ;
		#} 
		# Using Hardcoded list for the time being 
		#my $portList = <ENABLEDPORTS> ;
		#@portarray  = split (",",$portList) ;
		#close ENABLEDPORTS ;


		# loop to print the ports to be enabled only 
 		for ($count = 0 ; $count <= $#portarray ; $count++) {
			print (" $portarray[$count] \n ") ;
		}


	#&getUserChoice() ;
	
	# confirming the interface from user 
	$ethchoice = "0" ;
	while ($ethchoice =~ /[0]/ ) {
		print ("\nEnter the management interface being used <eth0> ") ;	
		$interfaceArg = <STDIN> ;
		chomp($interfaceArg) ;
		if ($interfaceArg eq "" ) {
			$interfaceArg = " eth0 " ;
			$ethchoice = "1" ; 
		}
		else {
			print (" Interface entered is $interfaceArg. Press 0 to change, or any other key to continue ")  ;
			$ethchoice = <STDIN> ;
		}
		
	}

  	# sorts the array in order of increasing port number 
	$length = $#portarray ;
   	for ($i = 0 ; $i <= $length ; $i++) {
		$small= $portarray[$i] ; 
		for ( $j= $i+1 ; $j <= $length ;$j++) {
			if ( $small > $portarray[$j]) {
		        	$small =$portarray[$j] ;
				$portarray[$j] = $portarray[$i];
				$portarray[$i] = $small;
			}
		}	
	}

	# checks for duplicates in the port list  
  	push(@sortedportarray,$portarray[0]); 
  	for ($i = 1,$k = 1 ; $i <= $#portarray ; $i++) {	
     		$flag = 0 ;
		for ($j= 0 ; $j <= $#sortedportarray ; $j++) 	 { 
		        if ($sortedportarray[$j] == $portarray[$i])   {
 			$flag = 1 ;
			break ;	
	 	   	}	
   		}	
		if ($flag == 0 ) {
			$sortedportarray[$k] = $portarray[$i] ;
			$k++ ;
		}

  	}


       	print (" Final list of opened ports: \n  ") ;
   	for  ($index = 0 ; $index <= $#sortedportarray ; $index++) {
		print (" $sortedportarray[$index] \n ") ;
    	}


   	#print (" Writing ports to file ... \n  ") ;
   	#open (ENABLEDPORTS ,">$allowedPortsFile " ) ;
   	#for  ($index = 0 ; $index <= $#sortedportarray ; $index++) {	
   	#	print ENABLEDPORTS "$sortedportarray[$index]" ;	 
	#	if ( $index!=$#sortedportarray ) {
	# 		print ENABLEDPORTS "," ;	 
	#	}
    	#}	
   	#close ENABLEDPORTS ;
   	#print (" Ports written to file. \n  ") ;

	# Blocking ports in ranges between the allowed ports  
	if ($command eq "iptables") {
		$addRuleArg ="-A " ; 
		$delRuleArg ="-D " ; 
		$flush = " -F " ;
		$policyRuleArgs=" INPUT -j REJECT "  ;
		$tcpArg = " -p tcp " ;
		$udpArg = " -p udp " ;
		$portString = " --destination-port " ;
		$portArg = " " ; 
		$interfaceArgString = " -i " ;
		$statement = " " ;
	} elsif ($command eq "ipchains") {
		$addRuleArg ="-A " ; 
		$delRuleArg ="-D " ; 
		$flush = " -F " ;
		$policyRuleArgs=" input -j DENY "  ;
		$tcpArg = " -p tcp " ;
		$udpArg = " -p udp " ;
		$portString = " -d $serveripaddr " ;
		$portArg = " " ; 
		$interfaceArgString = " -i " ;
		$statement = " " 
	
	} else {
		# do nothing  
	}

	if ( $ostype =~  m/redhat/i) {
		system (" service $command stop ") ;
	}

	#print ("\nFlushing Existing $command Rules ...\n ") ;
	system (" $command $flush ") ;
   	#SSprint (" Generating Rules .... \n ") ;
   	
	
	$initport = 0 ;
  	$finalport = 0 ;
   	
	# calculating ranges between allowed ports 
	for  ($index = 0 ; $index <= $#sortedportarray ; $index++) {		
		$finalport=$sortedportarray[$index]-1 ;
		if ($finalport > $initport ) {
			$portArg = "$initport:$finalport" ;
			$statement  =$command."  ".$addRuleArg.$policyRuleArgs.$tcpArg.$portString.$portArg.$interfaceArgString.$interfaceArg ;
			system("$statement ")	;
   			$statement = $command."  ".$addRuleArg.$policyRuleArgs.$udpArg.$portString.$portArg.$interfaceArgString.$interfaceArg ;
			system("$statement ")	;
		}
		$initport = $sortedportarray[$index] + 1  ; 
	}	


  	$finalport = 65536 ;
 	if ($finalport != $initport) {
 		$finalport = $finalport - 1 ;	
		$portArg = "$initport:$finalport" ;
	 	$statement = $command."  ".$addRuleArg.$policyRuleArgs.$tcpArg.$portString.$portArg.$interfaceArgString.$interfaceArg ;
 		system ("$statement ")	;
 		$statement = $command."  ".$addRuleArg.$policyRuleArgs.$udpArg.$portString.$portArg.$interfaceArgString.$interfaceArg ;
 		system("$statement ")	;
 	}  	 

	#print (" Saving Rules ... ") ;
	
	if ( $ostype =~  m/redhat/i) {
		system (" service $command save ") ;
		system (" service $command start ") ;
	} else {
		system (" $command-save > $nextonehome/$iptablesrules") ;
		open (FIREWALL ,"> /etc/init.d/$firewallservice " ) ;
		print FIREWALL  " #Created during the RSM installation process \n " ;
		print FIREWALL  " #Provides for blocking of the ports by restoring iptables rules on startup \n " ;
		print FIREWALL  " #Any changes should be avoided without the knowledge of NextPoint support \n " ;
		print FIREWALL  " $command-restore < $nextonehome/$iptablesrules " ; 
		close FIREWALL ;
		system (" chmod +x /etc/init.d/$firewallservice \n ") ;
		system (" chkconfig -a $firewallservice \n ") ;
	}
}

}
###############################################main##########################################


#checks if support for script is available or not 
&checkforsupport() ;

# gets the OS of the machine being used 
&getOS(); 

# peforms actions to block ports 
&doAction() ;




