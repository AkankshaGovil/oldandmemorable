#!/usr/bin/perl

use Socket;

my $hostIP;
my $organization;
my $city;
my $state;
my $country;
my $sslPassword;
my $resp;
my $jboss_home = '/opt/nxtn/jboss/server/rsm';
my $jbosswebsar ='jbossweb.sar';
my $keystoreFile = '/tmp/rsm.keystore';
my $serverCert = '/tmp/server.cer';
my $clientTruststoreFile = '/tmp/client.truststore';

if (! @ARGV) {
# get input from user
    print "Please enter the following details to create ssl certificate :   \n";
    getUserData("Enter your host IP address:  ",$hostIP,"127.0.0.1","IP");
    getUserData("Enter your organization [myOrganization]:  ",$organization,"myOrganization","false");
    getUserData("Enter your city [myCity]:  ",$city,"myCity","false");
    getUserData("Enter your state [myState]:  ",$state,"myState","false");
    getUserData("Enter your country code [XX]:  ",$country,"XX","false");
    validatePassword();
}
else {
# Fast Forward install: get input from command line arguments
    $hostIP = $ARGV[0];
    $sslPassword = $ARGV[1];
    $organization = '';
    $city = '';
    $state = '';
    $country = '';
#redirect STDOUT and STDERR to /dev/null
    open(STDOUT, ">/dev/null");
    open(STDERR, ">/dev/null");
}

#create  keystore file
system( "/opt/nxtn/jdk/bin/keytool -genkey -keyalg RSA  -keypass \'$sslPassword\' -alias server_cert -keystore $keystoreFile  -validity 365  -storepass \'$sslPassword\'  -dname \"CN=$hostIP, OU=$organization, O=$organization, L=$city, ST=$state, C=$country\"");

print "created keystore file ";
#create server certificate
system( "/opt/nxtn/jdk/bin/keytool -export -alias server_cert -keystore $keystoreFile -storepass \'$sslPassword\' -keypass \'$sslPassword\' -file \'$serverCert\'");

#create client trustore
system("/opt/nxtn/jdk/bin/keytool -noprompt -import -v -keystore $clientTruststoreFile -storepass \'$sslPassword\' -file \'$serverCert\'  -dname \"CN=$hostIP, OU=$organization, O=$organization, L=$city, ST=$state, C=$country\"");

#copy rsm.keystore to /opt/nxtn/jboss/server/rsm/conf
system ("cp $keystoreFile  $jboss_home/conf");

#copy client.truststore to /opt/nxtn/jboss/server/rsm/conf
system ("cp $clientTruststoreFile  $jboss_home/conf");


#update ssl password in jboss-service.xml 

system ("cp $jboss_home/conf/jboss-service.xml $jboss_home/conf/jboss-service.xml.orig");
system ("cp $jboss_home/conf/jboss-service.xml $jboss_home/conf/jboss-service.xml.old");

replacePassword( "$jboss_home/conf/jboss-service.xml.old", "$jboss_home/conf/jboss-service.xml");

#update ssl password in server.xml
system( " cp $jboss_home/deploy/$jbosswebsar/server.xml $jboss_home/deploy/$jbosswebsar/server.xml.orig");
system( " cp $jboss_home/deploy/$jbosswebsar/server.xml $jboss_home/deploy/$jbosswebsar/server.xml.old");
replacePassword( "$jboss_home/deploy/$jbosswebsar/server.xml.old", "$jboss_home/deploy/$jbosswebsar/server.xml");

#remove temp files

system ("rm -rf  $jboss_home/conf/jboss-service.xml.old");
system( " rm -rf $jboss_home/deploy/$jbosswebsar/server.xml.old");
system( " rm -rf $keystoreFile");
system( " rm -rf $clientTruststoreFile");
system( " rm -rf $serverCert");

sub replacePassword(){
my $inFile = $_[0];
my $outFile = $_[1];

open(FIN, "<$inFile");
open(FOUT, ">$outFile");

while(my $line  = <FIN>)
{
   if($line =~m/SSL_PASSWORD/){
     $line =~s/\@SSL_PASSWORD\@/$sslPassword/e;
   }
 
   print FOUT $line;
}

close (FIN);
close (FOUT);
}

sub getUserData(){
print $_[0];
$resp = <>;
chomp($resp);
  label1: while(1){
 
  if (($_[3] eq 'IP') and (($resp eq "") or ((!defined(inet_aton($resp))) and (!is_ipv6($resp))))) {
      print " Invalid IP Address   \n";
      print $_[0];
      $resp = <>;
      chomp($resp);
      next label1;
  }
  else{
      if( $resp eq ""){
        $_[1] = $_[2];
      }else{
        $_[1] = $resp;
      }
      last label1;
    }
  }
}

sub validatePassword(){
print "Enter key password [at least 6 characters]:  ";
system ("stty -echo");
chop($resp = <>);
$sslPassword = $resp;
print "\n";
system ("stty echo");
print "Re-enter key  password:  ";
system ("stty -echo");
my $resp1 = <>;
chop($resp1);
my $newPassword = $resp1;
print "\n";
system ("stty echo");

my $speciaChar = '[^a-zA-Z0-9~!@#\\$\\%\\^\\*_\\-\\+=\\|\\\\.\\?]';
my $firstChar = '[a-zA-Z0-9]';

    if(!($sslPassword =~m/^$firstChar/))
    {
        print "Invalid password string: Password should start with an alphanumberic character.\n";
        validatePassword();
    } elsif ($sslPassword =~m/$speciaChar+/){
        print "Invalid password string. Only letters (a-z A-Z), numbers (0-9), and  ~ ! @ # \$ \% ^ *  _ - + =  |  \ . ? characters are allowed.\n";
        validatePassword();
    } elsif ( length($sslPassword) < 6 ){
        print "Password must be atleast 6 characters \n";
        validatePassword();
    } elsif ($sslPassword ne $newPassword){
        print  "Sorry, passwords do not match \n";
        validatePassword();
    } 
}

sub is_ipv6 
{ 
  my($ipv6) = @_; 

  return $ipv6 =~ /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/; 
} 
