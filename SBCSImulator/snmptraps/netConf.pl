# ============================================================================

# Network Configurations and Changes -Snmp Trap Simulator

# ============================================================================


print "File netConf.pl imported.\n";
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

