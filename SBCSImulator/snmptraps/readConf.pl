# ============================================================================

# Read Configurations File - Snmp Trap Simulator

# ============================================================================


#### Read from the config file - config.txt

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
  return($trapSimCount, $initialIp, $rsmIp, $trapId, $path);	
}

