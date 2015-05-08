# ============================================================================

# Read Configurations File - Snmp Trap Simulator

# ============================================================================


#### Read from the config file - config.txt

my @valuesFromConfig=&readConfig();
my $simulatorCount= $valuesFromConfig[0];
my $initialIp=$valuesFromConfig[1];
my $prefixHostname=$valuesFromConfig[2];
my $rsmIp=$valuesFromConfig[3];
my $path=$valuesFromConfig[4];				

print "Values retrieved from the config file:-\n";
print "simulatorCount=$simulatorCount\n";
print "intialIp=$initialIp\n";
print "prefixHostname=$prefixHostname\n";
print "rsmIp=$rsmIp\n"; 
print "path=$path\n"; 

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
  print "simulatorCount=$values[0]\n";
  print "intialIP=$values[1]\n";
  print "prefixHostname=$values[2]\n";
  print "rsmIp=$values[3]\n"; 
  print "path=$values[4]\n"; 
  $simulatorCount=$values[0];
  $initialIp=$values[1];
  $prefixHostname=$values[2];
  $rsmIp=$values[3];
  $path=$values[4];
  close($data);
  return($simulatorCount, $initialIp,$prefixHostname,$rsmIp,$path);	
}

