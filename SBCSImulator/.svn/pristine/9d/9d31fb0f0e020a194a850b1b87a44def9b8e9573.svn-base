#!/usr/bin/perl
my $NewLocalHostname="";
my $NewLocalDomainname="";
my $NewPeerHostname="";
my $NewPeerDomainname="";
my $PeerEth1IP="";
my $LocalEth1IP="";
my $PeerEth0IP="";
my $LocalEth0IP="";
my $LocalHostname="";
my $LocalDomainname="";
my $PeerHostname="";
my $PeerDomainname="";

#pre-defined eth1 addresses
my $Node1ETH1IP="169.254.20.1";
my $Node2ETH1IP="169.254.20.2";
#pre-defined hostname
my $Node1Uname="genview-rsm0";
my $Node2Uname="genview-rsm1";
my $TmpDir ="/var/tmp";
my $OcfsDir = "/etc/ocfs2";

my $CONTROL_INTF=eth1;

####################################################################################################################
# This script updates hostname, domain name in the local system and peer system.
# Following are the tasks that are performed by this script
# - Sets up ssh key sharing between local system and peer system on eth1 ipaddress. With this no password is required
#   during SSH and scp communications to the peer system on peer eth1 ip addtess
# - Reads local system new hostname/domainname and peer system local hostname/domainname from user input
# - Creates tmp dir /var/tmp/rsmha to store backup files on local system and peer system
# - Stops  required services and unmount paritions
# - Updates cluster.conf file with new hostnames on local/peer ssytem
# - Updates /etc/hosts file with new hostname,domain name on local and peer system
# - Updates /etc/HOSTNAME with new host.domain name on local and peer system
# - Updates hostname with hostname, domain name commmand on local and peer system
# - mount partitions and restart services

#  This script should be used
# - For new RSM HA installation, once the disk image is copied into RSM HA boxes, run this script to change hostname and
#   domain name
####################################################################################################################

&main();

##
# main method
##

sub main{

    print "### HOSTNAME UPDATE STARTED ###\n";
    &init();

    # setup ssh key
    &setup_sshKey();

    # setup data
    &setup_data();

    # get user input
    &get_config_data();


    # stop hearbeat
    &stop_services();

    #update configuration file
    &update_OCFS_configuration("cluster.conf");

    #update hostname and domain name
    &update_host_domainName();

    # restart services
    &restart_services();

    print "#### HOSTNAME UPDATE COMPLETED ####\n";
}

##
# Create tmp dir and get peer eth1 ip address
##
sub init()
{
    #create tmp dir to store backup/required files
    if (-d $TmpDir){
        if(!-d "$TmpDir/rsmha"){
            &run_command("mkdir /var/tmp/rsmha");
        }
        $TmpDir =  "/var/tmp/rsmha";
    }
    # Get Peer eth1 ipaddress
    my $eth1IP= &run_command("ifconfig $CONTROL_INTF | grep \"inet addr\" | cut -d':' -f2 |cut -d' ' -f1");
    if("$eth1IP" == ""){
        $eth1IP= &run_command("ifconfig $CONTROL_INTF | grep \"inet6 addr\" | cut -d' ' -f13| cut -d/ -f1");
    }

    $LocalEth1IP = $eth1IP;
    if($eth1IP=~m/$Node1ETH1IP/){
        $PeerEth1IP=$Node2ETH1IP;

    }else{
        if($eth1IP=~m/$Node2ETH1IP/){
            $PeerEth1IP=$Node1ETH1IP;
        }else{
            print "Hostname update failed. Invalid $CONTROL_INTF $eth1IP.\n";
            exit 2;
        }
    }

}

##
#  Set up key sharing between local and peer system on eth1 ipaddress
##
sub setup_sshKey()
{
    my $priKey = "/root/.ssh/id_rsa";
    my $pubKey = "$priKey.pub";

    system("rm -f $priKey $pubKey");
    &run_command("ssh-keygen -t rsa -b 2048 -f $priKey -N ''");

    print "Please enter peer system ssh";
    &run_command("cat $pubKey | ssh -o StrictHostKeyChecking=no root\@$PeerEth1IP 'cat >> .ssh/authorized_keys'");
    &run_command("ssh root\@$PeerEth1IP \" rm -f $priKey $pubKey \""); 
    &run_command(" ssh root\@$PeerEth1IP \"ssh-keygen -t rsa -b 2048 -f $priKey -N ''\"");
    &run_command(" scp root\@$PeerEth1IP:$pubKey /root/.ssh/authorized_keys");    

}


##
# Read local and peer system hostname/domainname/eth0/eth1 details
##

sub setup_data(){
    #create tmpdir in peer system
    system("ssh root\@$PeerEth1IP \"rm -rf /var/tmp/rsmha\"");
    system("ssh root\@$PeerEth1IP \"mkdir /var/tmp/rsmha\"");

    # get /etc/hosts file from peer system
    print "Reading /etc/hosts file from peer system \n";
    &run_command("scp root\@$PeerEth1IP:/etc/hosts /$TmpDir");

    # get hostname and domain name
    print "Reading hostname,domainname from local server\n";
    $LocalHostname =  &run_command("hostname");
    $LocalDomainname = &run_command("cat /etc/HOSTNAME  | cut -d '.' -f2,3");

    print "Reading hostname, domainname from peer server\n";

    $PeerHostname   =  &run_command("ssh root\@$PeerEth1IP hostname");
    $PeerDomainname = &run_command("ssh root\@$PeerEth1IP \"cat /etc/HOSTNAME  | cut -d '.' -f2,3\"");
    # get local eth0 IP
    $LocalEth0IP= &run_command("ifconfig eth0 | grep \"inet addr\" | cut -d':' -f2 |cut -d' ' -f1");
    if("$LocalEth0IP" == ""){
        $LocalEth0IP= &run_command("ifconfig eth0 | grep \"inet6 addr\" | cut -d' ' -f13| cut -d/ -f1");
    }
    # get peer eth0 IP
    $PeerEth0IP= &run_command("ssh root\@$PeerEth1IP \"ifconfig eth0 | grep \'inet addr\' | cut -d':' -f2 |cut -d' ' -f1\"");
    if("$PeerEth0IP" == ""){
        $PeerEth0IP= &run_command("ssh root\@$PeerEth1IP \"ifconfig eth0 | grep \'inet6 addr\' | cut -d' ' -f13| cut -d/ -f1\"");
    }
    chop$LocalHostname;
    chop$LocalDomainname;
    chop$PeerHostname;
    chop$PeerDomainname;
}

##
#  Read user input
##
sub get_config_data(){
    # Get local systen hostname
    $NewLocalHostname= &get_data("Please enter hostname[no domain name]:");
    # Get local system domain name
    $NewLocalDomainname= &get_data("Please enter domainname:");
    # Get peer system hostname
    $NewPeerHostname= &get_data("Please enter peer hostname[no domain name]:");
    # Get peer system domain name
    $NewPeerDomainname= &get_data("Please enter peer domainname:");
}

##
# Stop the services before updating hostname and domain name
##

sub stop_services(){
    print "Stopping hearbeat ...\n";
    &run_command("/etc/init.d/heartbeat stop");

    print "Stopping hearbeat on peer system ...\n";
    &run_command("ssh root\@$PeerEth1IP \"/etc/init.d/heartbeat stop\"");

    # umount partitions
    print "Unmounting SAN Partitions...\n";
    &run_command("umount /opt/nxtn");
    &run_command("umount /opt/mysql/data");
    &run_command("umount /opt/mysql/log");

    # stop oracle clustered file system
    print "Stopping oracle clustered file system ... \n";
    &run_command("/etc/init.d/ocfs2 stop");
    &run_command("/etc/init.d/o2cb stop");

    print "Stopping oracle clustered file system on peer system... \n";
    &run_command("ssh root\@$PeerEth1IP \"/etc/init.d/ocfs2 stop\"");
    &run_command("ssh root\@$PeerEth1IP \"/etc/init.d/o2cb stop\"");

}     

##
#  Read data from user
##

sub get_data(){
    my ($prompt) = @_;
    print "$prompt";
    my $resp = <>;
    chop$resp;
    if( length($resp) == 0 ){
        print "Please enter valid value\n";
        &get_data($prompt);
    }else{
        return $resp;
    }
}

##
#  Run system commands
##

sub run_command()
{
    my ($command) = @_;
    my $ret =   `$command`;
    my $ret_code = $?;
    if($ret_code != 0){
        print "Hostname update failed due to $command. Return code: $ret_code. Please check your server.\n";
        exit 2;
    }
    return $ret;
}


##
#  Update cluster.conf file with  local and peer system new hostname
##
sub update_OCFS_configuration(){
    print "Updating oracle clustered file system configuration file...\n";
    my ($filename) = @_;
    my $tmp_filename = $filename.".tmp";

	&run_command("sed s/$LocalHostname/$NewLocalHostname/ $OcfsDir/$filename > $OcfsDir/$tmp_filename");
	&run_command("sed s/$PeerHostname/$NewPeerHostname/ $OcfsDir/$tmp_filename > $OcfsDir/$filename");

	#copy the original file into tmp dir in peer system
	&run_command("ssh root\@$PeerEth1IP \"cp -p $OcfsDir/$filename $TmpDir/$filename.orig\"");

	print "Copying $filename into peer system ...\n";
	&run_command("scp /$OcfsDir/$filename root\@$PeerEth1IP:$OcfsDir");
}


##
#  Update local and peer system /etc/hosts and /etc/HOSTNAME files with new hostname and domain name
##
sub update_host_domainName(){

    # replace /etc/HOSTNAME file

    print "Updating /etc/HOSTNAME file ...\n";
    my $LocalHostDomainName = $NewLocalHostname.".".$NewLocalDomainname;
    system ("cp /etc/HOSTNAME $TmpDir/HOSTNAME.orig");
    &run_command( "echo $LocalHostDomainName > /etc/HOSTNAME");

    # replace /etc/HOSTNAME file on peer system
    print "Updating /etc/HOSTNAME file on peer system...\n";
    my $PeerHostDomainName = $NewPeerHostname.".".$NewPeerDomainname;
    &run_command("ssh root\@$PeerEth1IP \"cp /etc/HOSTNAME $TmpDir/HOSTNAME.orig\"");
    &run_command( "ssh root\@$PeerEth1IP \"echo $PeerHostDomainName > /etc/HOSTNAME\"");


    #take  /etc/hosts backup file
    system ("cp /etc/hosts $TmpDir/hosts.orig");

    # replace local etc/hosts file
    print "Updating /etc/hosts file ...\n";
    &update_hostfile("/etc/hosts");

    #take  peer /etc/hosts backup file
    &run_command("ssh root\@$PeerEth1IP \"cp /etc/hosts $TmpDir/hosts.orig\"");

    # replace peer etc/hosts file
    print "Updating peer /etc/hosts file ...\n";
    &update_hostfile("$TmpDir/hosts");
    &run_command("scp $TmpDir/hosts root\@$PeerEth1IP:/etc/hosts");
    
    #run hostname domainname command
    print "Executing hostname command  ...\n";
    &run_command("hostname $NewLocalHostname");

    print "Executing domainname command  ...\n";
    &run_command("domainname $NewLocalDomainname");

    #run hostname domainname command on peer system
    print "Executing hostname command  on peer system ...\n";
    &run_command("ssh root\@$PeerEth1IP hostname $NewPeerHostname");

    print "Executing domainname command on peer system  ...\n";
    &run_command("ssh root\@$PeerEth1IP domainname $NewPeerDomainname");

}

##
# update /etc/hosts filename with new hostname and new domain name
##

sub update_hostfile(){
    my ($filename) = @_;

    my $tmp_filename = $filename.".tmp";
	open(FIN,"<$filename");
	open(FOUT,">$tmp_filename");

    my $PeerHostDomainname =   $PeerHostname.".".$PeerDomainname;
    my $LocalHostDomainname =   $LocalHostname.".".$LocalDomainname;

    my $NewPeerHostDomainname   =   $NewPeerHostname.".".$NewPeerDomainname;
    my $NewLocalHostDomainname  =   $NewLocalHostname.".".$NewLocalDomainname;


    my $tmp_LocalEth0IP    =   $LocalEth0IP;
    my $tmp_PeerEth0IP     =   $PeerEth0IP;
    my $tmp_LocalEth1IP    =   $LocalEth1IP;
    my $tmp_PeerEth1IP     =   $PeerEth1IP;

    chomp$tmp_LocalEth0IP;
    chomp$tmp_PeerEth0IP;
    chomp$tmp_LocalEth1IP;
    chomp$tmp_PeerEth1IP;


    #replace uname

	while(my $line = <FIN>)
	{
	    $update=0;
	    #replace local/peer uname

	    if($line=~m/$tmp_LocalEth1IP/){
	        
	        $line =$tmp_LocalEth1IP."\t".$NewLocalHostname."\n";
        }
	    if($line=~m/$tmp_PeerEth1IP/){
	        $line =$tmp_PeerEth1IP."\t".$NewPeerHostname."\n";
        }
	    if($line=~m/$tmp_LocalEth0IP/){
	        $line =$tmp_LocalEth0IP."\t".$NewLocalHostDomainname." ".$NewLocalHostname."\n";
        }
	    if($line=~m/$tmp_PeerEth0IP/){
	        $line =$tmp_PeerEth0IP."\t".$NewPeerHostDomainname." ".$NewPeerHostname."\n";
        }
 		print FOUT $line;
	}
	close FIN;
	close FOUT;
	&run_command("mv $tmp_filename $filename");
}

##
#  Restart all services after updating new hostname and domain name
##

sub restart_services(){
    print "Starting oracle clustered file system on local system ... \n";
    &run_command("/etc/init.d/o2cb start");
    &run_command("/etc/init.d/ocfs2 start");


    print "Starting oracle clustered file system on peer system ... \n";
    &run_command("ssh root\@$PeerEth1IP \"/etc/init.d/o2cb start\"");
    &run_command("ssh root\@$PeerEth1IP \"/etc/init.d/ocfs2 start\"");

    print "Mounting partitions on local system ...\n";
    &run_command("mount -a");
}
