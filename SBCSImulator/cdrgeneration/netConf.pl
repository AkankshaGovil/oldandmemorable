# ============================================================================

# Network Configurations and Changes -Snmp Trap Simulator

# ============================================================================


print "File netConf.pl imported.\n";

#### Add Host Name 

sub addHostname{

 my($v_ip,$path,$count,$prefixHostname) = @_;
 my $a= $v_ip . ',';
 my $b= $v_ip.' ';
 my $file = $path;

 open(my $data, '<', $file) or die "Could not open '$file'\n";
 while (my $line =<$data>) {
    chomp $line;
    if($line =~  m/$v_ip/i){
        print "Host Name Exists\n";
        }
    else{
    print "Adding hostname\n";
    my $newline=$prefix.Hostname$count."	".$v_ip;
    system("echo '$newline' >> $path");
    print "Hostname added.";
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
   my($ip,$count,$path,$prefixHostname) = @_;
   my @ipnum=split(/\./,$ip);
   my $last=$ipnum[-1]+$count;   
   my $retval = pop(@ipnum);
   push @ipnum, $last;
   my $virtualIp=join(".",@ipnum); 
   print "Adding Virtual IP:- $virtualIp \n";
   system("ifconfig eth0:$count $virtualIp");
   print "OK";
   &addHostname($virtualIp,$count,$path,$prefixHostname);
   return $virtualIp;

}
