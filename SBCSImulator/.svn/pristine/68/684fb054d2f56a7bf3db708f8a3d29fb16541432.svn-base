#!/usr/bin/perl

##
## ivmssinstall
##

use strict;

##typeofinstall refers to whether it's RSM installation, RSMLite or RSMGVU installation.
##1 indicates the RSM Server, 2 indicates the RSMLite and 3 indicates RSMGVU.

my $typeOfInstall = 1;
my $typeOfInstallString = "RSM Server";
my $SWMF = 0; # if set then it's SWM upgrade
my $PRE6 = 0; # if set then SWM upgrade for pre 6.0 to 6.x

my $Self = "RSMInstall";
my $SelfVersion = "8.1.0.0d0";
## This is what I do...
my $Product = "ivms";
my $InstallLogFile = "rsminstall.log";
my $UpgradeLogFile = "rsmupgrade.log";
my $UninstallLogFile = "rsmuninstall.log";
my $AdmMediaFile = "rsm.tar";
my $Unpack = "tar xf ";
my $Unzip = "unzip ";
my $TmpDir = "/var/tmp";
my $UsrDir = "/usr/local";
my $OptDir = "/opt/nxtn";
my $UsrJava = "/usr";
my $NextoneHome = "/home/nextone";
my $JAVA_HOME="";
my $MySQLServerX86Rpm = "MySQL-server-enterprise-5.0.90-0.sles10.i586.rpm";
my $MySQLClientX86Rpm = "MySQL-client-enterprise-5.0.90-0.sles10.i586.rpm";
my $MySQLSharedX86Rpm = "MySQL-shared-enterprise-5.0.90-0.sles10.i586.rpm";
my $SshDir = "/etc/ssh";
# These are currently not included
my $MySQLServerIA64Rpm = "MySQL-server-5.0.21-1.glibc23.ia64.rpm";
my $MySQLClientIA64Rpm  = "MySQL-client-5.0.21-1.glibc23.ia64.rpm";

my $MySQLServerEM64TRpm = "MySQL-server-community-5.0.92-1.sles10.x86_64.rpm";
my $MySQLClientEM64TRpm = "MySQL-client-community-5.0.92-1.sles10.x86_64.rpm";
my $MySQLSharedEM64TRpm = "MySQL-shared-enterprise-5.0.90-0.sles10.x86_64.rpm";

my $MySQLServerRHEL64TRpm="MySQL-server-5.0.92-1.glibc23.x86_64.rpm";
my $MySQLClientRHEL64TRpm="MySQL-client-5.0.92-1.glibc23.x86_64.rpm";
my $MySQLSharedRHEL64TRpm="MySQL-shared-compat-5.5.20-1.el6.x86_64.rpm";
my $Perl_DBD_MySQL=		  "perl-DBD-MySQL-4.014-1.el6.rfx.x86_64.rpm";

my $FreeRadiusRPMForRHEL="freeradius-2.1.10-5.el6.x86_64.rpm";
my $FreeRadiusUtilRPMForRHEL="freeradius-utils-2.1.10-5.el6.x86_64.rpm";
my $GBRadiusAuthRPMForRHEL="gb-radiusauth-config-1-5.x86_64.rpm";
my $DpendentRadiusRPMForRHEL="libtool-ltdl-2.2.6-15.5.el6.x86_64.rpm";

my $MySQLServerRpm = $MySQLServerX86Rpm;
my $MySQLClientRpm = $MySQLClientX86Rpm;
my $MySQLSharedRpm = $MySQLSharedX86Rpm;
# variable to store current jdk version required to run rsm
my $J2sdkVersion = "jre1.6.0_18";
# variable to point to jdk installation program
my $J2sdkRpm    = "jre1.6.0_18-linux-x64.bin";
my $J2sdk_64    = "jre1.6.0_18-linux-x64.bin";
my $J2sdk_64Version = "jre1.6.0_18";
my $JBoss = "jboss-5.1.0.GA-jdk6.zip";
my $JBossAS = "jboss-as";
my $JBossVersion = "jboss-5.1.0.GA-jdk6";
my $JBossTomcatSar="jbossweb.sar";
my $JBossWebDeploy="jbossweb.deployer";

my $wasDbBackedUp = 'n';
my $bnBackUpFile="bnBackup.sql";
my $entireDBBackup = "DBBackup.sql";
my $BackupFile="";
my $DBRestored='n';
my $MySqlInstalled='n';
my $JBossDir = "$OptDir/jboss";
my $JBossDeployDir="$OptDir/jboss/server/rsm/deploy";
my $JBossDeployersDir="$OptDir/jboss/server/rsm/deployers";
my $JBossDeployDirSuffix = "/server/rsm/deploy";
my $JBossConfDir        =       "$OptDir/jboss/server/rsm/conf";
my $JBossConfDirSuffix  =  "/server/rsm/conf";
my $JBossLibDir =       "$OptDir/jboss/lib";
my $JBossLibDirSuffix   = "/lib";
my $JBossServerLibDir = "$OptDir/jboss/server/rsm/lib";
my $JBossServerLibDirSuffix = "/server/rsm/lib";
my $JBossBackupDir = "$OptDir/rsm/jboss/";
my $MinTmpSpace = 1000000;
my $MinBkSpace  = 10;
my $ROOT_Password = "";
my $MySqlDir;
my $MySqlLog;
my $DB_Username = "ivms";
my $DB_Password = "ivms";
my $UpgradeBak;
my $StartDir = `pwd`;
my $oldMysqlTraces = "y";
my $UPGRADEFILEPREFIX="ivms-tables-upgrade";
my $DOWNGRADEFILEPREFIX="ivms-tables-downgrade";
my $IVMSLITEUPGRADEFILEPREFIX="ivmslite-tables-upgrade";
my $CDRTABLESQL="ivms-cdr-table";
my $cdrTableListFile="cdrTableList";
my $MemString4G="CONFIG_HIGHMEM4G=y";
my $MemString64G="CONFIG_HIGHMEM4G=y";
my $IVMSINDEX=".ivmsindex";
my $loopBackIp = "127.0.0.1";
my $loopBackIp_2="127.0.0.2";
my $ETC_HOSTS="/etc/hosts";
my $ETC_SYSCONFIG_NETWORK="/etc/sysconfig/network";
my $MySqlProcStr="mysqld";
my $appender;
my $FileLogger;
my $File_Screen_Logger;
my $layout;
my $MySqlWaitTime=5;
my $MSWHostName ="localhost";
my $MSWPort="5432";
my $PostgreScriptTrig="rsm_lite_triggers.sql";
my $runDownGradeSQLOnFailure=0;
my $DowngradeScript="";
my $libmysqlold32="libmysql-32bit.zip";
my $libmysqlold64="libmysql-64bit.zip";
my $OptNxtn = "/opt/nxtn";
my $NextoneOpt = "$OptNxtn/rsm";
my $libdir;
my $unziprpm="unzip-5.50-345.i586.rpm";
my $ziprpm="zip-2.3-732.i586.rpm";
my $ManagementIp="127.0.0.1";
my $ivmsLiteDataRestored=0;
my $ivmsLiteDataBackedUp=0;
my $ivmsLiteDumpFile="ivmsLiteDump.sql";
my $upgrade=0;

my $isRedundancySetup=0;
my $Hardware = "";
my $HA_ManagementIP = "";
my $HA_MyNodeName = "";
my $HA_MyNodeIP = "";
my $HA_PeerNodeName = "";
my $HA_PeerNodeIP = "";
my $HA_MyNodeHeartbeatIP = "";
my $HA_PeerNodeHeartbeatIP = "";
my $HA_Node1Uname="";
my $HA_Node2Uname="";
my $isPeerHAInstalled=0;
#my $HA_PingNodeIP = "";
#my $HA_AutoFailBack = "";
#my $HA_MasterNodeName = "";
my $HA_SecondInstall = 0;
my $HA_SecondInstallInitDB = "n";
my $LogFile;
my $oldSSLCertPass;
my $oldSSLCertFile;

my $PortBlockingScriptName = "ExtraneousServiceBlock.pl" ;

#variables identifing system directly and firewall available 
my $systemConfigDirectory = "/etc/sysconfig" ; 
my $firewallConfigFile = "SuSEfirewall2" ; 
my $SuSE9firewallConfigFile = "SuSEfirewall2.v9" ;
my $SuSE9HAfirewallConfigFile = "SuSEfirewall2_HA.v9" ;
my $SuSE10firewallConfigFile = "SuSEfirewall2.v10" ;
my $SuSE10HAfirewallConfigFile = "SuSEfirewall2_HA.v10" ;
my $SuSEVersion="" ;
my $UpgradeLog="";
#name of script to check whether correct version of RSM Linux is installed
my $checkOSScriptName = "rsm_os_check.sh" ;

#variable to be set 1 by developer to skip OS verification and other checks 
my $isCheckDisabled = 0 ;
my $RSM_OS_TYPE;
$RSM_OS_TYPE=$ENV{"RSM_OS_TYPE"};

#variable to search for in nextoneJboss to include changes for ulimit and core settings 
my $nextoneJbossUlimitString = "#ulimit and core settings to be updated in case of RSM server install" ;

#array to hold all network interfaces present on the machine  
my @interfaceArray = () ;

#array to hold all management network interfaces present on the machine  
my @mgmtInterfaceArray = () ;

#array to hold all internal network interfaces present on the machine  
my @intInterfaceArray = () ;

my $isJarrell=0;
my $isAnnapolis=0;
my $Node1ETH1IP="169.254.20.1";
my $Node2ETH1IP="169.254.20.2";
my $iVMSBakDir;
my $isInstall=0;
my $HA_ResourcePath = "/usr/lib/ocf/resource.d/genband";
my $HA_DataFile    =   $NextoneOpt."/.ha_data";

#variable to hold the RSMLinux version supporting the version of RSM being installed.
my $RSMLinuxVersion='8.0.2-2'; 
my $RHELOsVersion='6.2';
 
#variable to hold the name of teh release file of RSM Linux 
my $relFileName="/etc/RSMLinux-release";
my $RHELRelFileName="/etc/redhat-release";

#variables for new Mysql Installation 
my $HA_mysql_data_mount_pt="/opt/mysql/data";
my $HA_mysql_log_mount_pt="/opt/mysql/log";
my $Mysql_data_mount_pt="/opt/nxtn/mysql/data";
my $Mysql_log_mount_pt="/opt/nxtn/mysql/log";
my $HA_mysql_link="/opt/nxtn/mysql";
my $HA_mysql_mount_pt="/opt/mysql";
my $HA_mysql_data_dir="/opt/nxtn/mysql/data";
my $HA_mysql_log_dir="/opt/nxtn/mysql/log";
my $mysql_installed_data_dir="";
my $mysql_installed_log_dir="";


use FindBin;
use lib $FindBin::Bin."/site_perl/5.8.0";
use Log::Log4perl qw(:easy);
use Getopt::Std;
use Data::Dumper;
use XML::Simple;
use Config::Simple;
use IO::Handle;
use Cwd 'abs_path';
use backup;

if(&GetProcessorType()=~m/x86_64/)
{
        use lib $FindBin::Bin."/vendor_perl/5.10.0/x86_64-linux-thread-multi";
        $libdir="/usr/lib64";
}
else
{
        use lib $FindBin::Bin."/vendor_perl/5.10.0";
        $libdir="/usr/lib";
}
use DBI;

chop $StartDir;

##
## use this function to run system commands
##
sub run_command()
{
    my ($command) = @_;
    my $ret =   `$command`;
    my $ret_code = $?;
    if($ret_code != 0){
        &FailedInstall("Error occured while executing $command. Return code: $ret_code. ");
    }
    return $ret;
}

##
##Use this function to display a message to the user and pause
##
sub GetResponse ()
{
        if ( $SWMF == 0 )
        {
			print "Hit <CR> to continue...\n";
			my $resp = <>;
		}
}

##
##
##
sub GetSpecialResponse ()
{
        print "Hit <CR> to continue. (OR) <Ctrl-C> to abort..\n";
        my $resp = <>;
}

##
##Use this  function when a no response means that the setup cannot be continued
##
sub GetBooleanResponse ()
{
        while (1)
        {
                my ($mess) = @_;
                $mess = $mess." [y\/n] :";
                $File_Screen_Logger->info("$mess");
                my $resp;
                chomp($resp = <>);
                $FileLogger->info("User responded \'$resp\'");
                $resp =lc($resp);
                $resp =substr($resp,0,1);
                if ($resp eq 'n')
                {
                        print("\n Setup cannot continue\nHit <CR> to return to menu\n");
                        $resp=<>;
                        exit 0;
                }
                if ($resp eq 'y')
                {
                        return;
                }
        }
}
##
## Use this function to get a yes/no response from the user
##
sub GetBooleanCharResponse ()
{
        while(1)
        {
                my ($mess) = @_;
                $mess = $mess." [y\/n] :";
                $File_Screen_Logger->info("$mess");
                my $resp;
                chomp($resp = <>);
                $FileLogger->info("User responded \'$resp\'");
                $resp =lc($resp);
                $resp =substr($resp,0,1);
                if ($resp eq 'n')
                {
                        return 'n';
                }
                if ($resp eq 'y')
                {
                        return 'y';
                }
        }
}

sub PrintHelpMessage ()
{
        print "$Self version $SelfVersion\n";
        print "$Self -v -h \n";
        print "$Self -m  to install RSM package\n";
        print "$Self -w  to install RSMLite package\n";
        print "$Self -d iVMS to uninstall RSM\n";
        print "$Self -d iVMSLite to uninstall RSMLite\n";
        print "$Self -u iVMS to upgrade RSM\n";
        print "$Self -u iVMSLite to upgrade RSMLite\n";

        exit 0;
}

##
## Privilege check, we need root privilege to install softwares
##
sub CheckForSuperuser ()
{
        ###########################
        ## Must be root
        ###########################
        my $logname = `/usr/bin/id -u -n`;
        chomp $logname;
        if ( "$logname" ne "root" )
        {
                &FailedSetupNoCleanupRequired("\nYou must be super-user to run this script.\nExiting....\n ");
        }
}


##
## Set password for MySQL root user
##
sub SetMySQLPasswd ()
{
        $FileLogger->info("entering");
        my $resp = "";
        my $status;
        while (1)
        {
                print "Type new password for MySQL root user :";
                my $status = system ("stty -echo");
                chop($resp = <>);
				if($resp eq "")
                {
                        print "\nMySQL root user password cannot be blank.\n";
                        next;
                }
                my $Password1 = $resp;
                print " \n";
                $status = system ("stty echo");
                print "Retype new password for MySQL root user :";
                $status = system ("stty -echo");
                chop($resp = <>);
                my $Password2 = $resp;
                print " \n";
                $status = system ("stty echo");
                if ($Password1 ne $Password2)
                {
                        print "Sorry, passwords do not match\n";
                        next;
                }
                if ($Password1 eq $Password2)
                {
                        last;
                }
        }

        $ROOT_Password = $resp;
        $status = system ("/usr/bin/mysqladmin -u root password '$ROOT_Password'");
        if($status)
        {
                &FailedInstall("Unable to change mysql root password");
        }
        $File_Screen_Logger->info("Credentials of MySql root user modified \n");
        $FileLogger->info("exiting");
}

sub HA_GetRootPasswd()
{
    print "Type  database root password :";

    my $resp = "";
    my $status;
    my $status = system ("stty -echo");
    chop($resp = <>);
    $ROOT_Password = $resp;
    my $status = system ("stty echo");
    print " \n";
}

##
## Get a new password from the user, continues till both  passwords entered match, this is used in case of new MySql installation.
##
sub GetPasswd ()
{
        $FileLogger->info("entering");
        my ($username) = @_;
        my $resp = "";
        my $status;
        while (1)
        {
                print "Type new database password for RSM :";
                my $status = system ("stty -echo");
                chop($resp = <>);
				if($resp eq "")
                {
                        print "\nRSM database password cannot be blank.";
                        next;
                }
                my $Password1 = $resp;
                print " \n";
                $status = system ("stty echo");
                print "Retype new database password for RSM :";
                $status = system ("stty -echo");
                chop($resp = <>);
                my $Password2 = $resp;
                print " \n";
                $status = system ("stty echo");
                if ($Password1 ne $Password2)
                {
                        print "Sorry, passwords do not match\n";
                        next;
                }
                if ($Password1 eq $Password2)
                {
                        last;
                }
        }
        $FileLogger->info("exiting");
        return $resp;
}

##
##Get the root password for MySql, checks the correctness of the password by calling the mysqladmin command with root username and supplied password.
##
sub GetMySQLPasswd ()
{
        $FileLogger->info("entering");
        my $resp = "";
        my $status;
        while (1)
        {
                print "Type password for MySQL root user :";
                my $status = system ("stty -echo");
                chop($resp = <>);
                my $Password1 = $resp;
                print " \n";
                $status = system ("stty echo");
                $status = system ("/usr/bin/mysqladmin -u root --password=\"$Password1\" status > /dev/null 2>&1" );
                $status=($? >> 8);
                if ($status)
                {
                        print "Sorry, either incorrect password, or mysql is not running\n";
                        &GetBooleanResponse("Do you want to enter password again ?");
                        next;
                }
                else
                {
                        last;
                }
        }

        $ROOT_Password = $resp;
        $FileLogger->info("exiting");
}
##
## Prompts for and creates a temporary directory to which the media file is extracted
##
sub GetTempDir ()
{
        $FileLogger->info("entering");
        my ($op) = @_;
        my $resp;
        my $tmpspace;
        my $status;
        # Get name of tmp directory to be used during install process

	 #print "Enter tmp directory to be used during $op [$TmpDir] :";

        # Read..
	# $resp = <>;
	# chop $resp;
	# if ($resp ne "")
        # {
	#        $TmpDir = $resp;
	# }
        if (!-d $TmpDir)
        {
				my $CreateDir;
                if ( $SWMF == 0 )
				{
					$CreateDir=&GetBooleanCharResponse("The directory $TmpDir does not exist, do you want it to be created");
				} else {
					$FileLogger->info("Doing installation through SWM, temporary directory does not exist, so creating it.");
					$CreateDir="y";
				}
                if($CreateDir eq "n")
                {
                        &FailedInstall($TmpDir." not found");
                }
                $status = system("mkdir -p $TmpDir");
                if ($status)
                {
                        &FailedInstall($TmpDir." could not be created: ".$!);
                }
        }

        # Obtain the size of $TmpDir
        $tmpspace = &GetDiskUsage($TmpDir);
        if ($tmpspace < $MinTmpSpace)
        {
                &FailedInstall("Cannot proceed with RSM $op... \nInsufficient disk space in $TmpDir.. \nAtleast $MinTmpSpace kb required in $TmpDir.\n");
        }
        $TmpDir = $TmpDir."/ivmsinstall";
        if (!-d $TmpDir)
        {
                system("umask 0000; mkdir $TmpDir");
        }
        $status = system ("rm -rf $TmpDir/*");
        $FileLogger->info("exiting");
}


##
## Prompt for and validate the media file, by default the ivms.tar file containing all the rpms
##
sub GetMediaFile ()
{
    $FileLogger->info("entering");
    my $resp;
    my $mediaFile;
    $mediaFile = $AdmMediaFile;
    chdir "$StartDir";
    if ( ! -f $mediaFile)
    {
           $FileLogger->warn("Unable to find $mediaFile ");
           &FailedInstall("unable to find the media file");
    }
    # while (1)
    # {
        ## Get name of mediafile
	#$mediaFile = $AdmMediaFile;
	# $File_Screen_Logger->info("Enter mediafile [$mediaFile] :");

        # Read..
	# $resp = <>;
	# chop $resp;
	# $FileLogger->info("User said \'$resp\'");
	# if ($resp ne "")
	# {
	#         $mediaFile = $resp;
	# }


#	  chdir "$StartDir";

#	 if ( ! -f $mediaFile)
#	 {
#	       $FileLogger->warn("Unable to find $mediaFile ");
#	       &FailedInstall("unable to find the media file");
#	        GetResponse ();
#	 }
	#else
	#{
	#        last;
	#}
    # }
    $FileLogger->info("exiting");
}


##
## untar the given media file to the $TmpDir
##
sub ExtractMediaFile ()
{
        $FileLogger->info("entering");
        my $status;
        chdir $StartDir;

        $File_Screen_Logger->info("Extracting the media file..");
        $status = system ("cp $AdmMediaFile $TmpDir/.");
        chdir $TmpDir;
        $status = system ("$Unpack $AdmMediaFile");

        if ($status)
        {
                &FailedInstall("/usr/bin/tar : $status \n");
        }

        $File_Screen_Logger->info("Extracting the media file..done ");
        $FileLogger->info("exiting");
}


##
## Get the disk usage of the partition where the given directory resides
##

sub GetDiskUsage ()
{
        $FileLogger->info("entering");
        my ($givenDir) = @_;
        my $tmpBuf;
        my $status;
        my $space;

        $tmpBuf = $StartDir."/tmp00";
        if($RSM_OS_TYPE eq "RHEL"){
        	$status = system ("df --direct -k $givenDir | grep \/ | tr -s ' ' ' ' | cut -d\" \" -f4 > $tmpBuf");
        }else{
        $status = system ("df -k $givenDir | grep \/ | tr -s ' ' ' ' | cut -d\" \" -f4 > $tmpBuf");
        }
        open (tmp, "<$tmpBuf");
        $space = <tmp>;
        close tmp;
        $status = system ("rm -rf $tmpBuf");
        $FileLogger->info("exiting");
        return $space;
}


##
## Prompt and return a valid directory
##
sub GetDir ()
{
    $FileLogger->info("entering");
    my ($prompt, $defaultValue) = @_;
    my $resp;

	 while (1)
    {
        if ( $SWMF == 0 )
		{
			$File_Screen_Logger->info("$prompt [$defaultValue] : ");
			$resp = <>;
			chop $resp;
			$FileLogger->info("User said \'$resp\'");
		}
        if ($resp ne "")
        {
            $defaultValue = $resp;
        }

        if (! -d $defaultValue)
        {
            $File_Screen_Logger->warn("\tUnable to find $defaultValue\n");
        }
        else
        {
            last;
        }
    }
        $FileLogger->info("exiting");
    return $defaultValue;
}

##
##Get the version of the currently installed RSM version, this information is stored in the file .ivmsindex located in NEXTONE_HOME (earlier /home/nextone, now /opt/nxtn/rsm)
##
sub getiVMSVersion()
{
$FileLogger->info("entering");
 my $ivmsversion="";
 #my $versionfile = $NextoneHome."/".$IVMSINDEX;
 my $versionfile = $NextoneOpt."/".$IVMSINDEX;
 if(! (-e $versionfile))
 {
        $versionfile = $NextoneHome."/".$IVMSINDEX;
 }
 if(-e $versionfile) {
        $ivmsversion=`cat $versionfile`;
        chop $ivmsversion;
        $FileLogger->info("Detected existing version $ivmsversion of $typeOfInstallString Package \n");
 }
 $FileLogger->info("exiting");
        return $ivmsversion;
}

##
##Create the .ivmsindex file
##
sub setiVMSVersion()
{
 $FileLogger->info("entering");
 my ($ivmsversion)=@_;
 #my $versionfile=$NextoneHome."/".$IVMSINDEX;
 my $versionfile=$NextoneOpt."/".$IVMSINDEX;
 my $oldversionfile=$versionfile."old";
 my $status;
 if(-f $versionfile) {
         $status=system("mv $versionfile $oldversionfile");
 }

 #chdir $NextoneHome;
 chdir $NextoneOpt;
 $status=system("echo $ivmsversion > $versionfile");
 #push (@files_copied,$IVMSINDEX);
 $FileLogger->info("exiting");
}


##
## Install jboss, in this function we first check if JBoss is running, if so we try to stop it. Then we check the currently installed version of JBoss, if it is not same as current JBoss version (the directory name contains the version), we go on to install JBoss. The user can specify any directory to install JBoss, the default is /op/nextone/jboss-<version>), in both cases we create a softlink /opt/nxtn/jboss pointing to the actual jboss directory
##
sub InstallJBoss ()
{
        $FileLogger->info("entering");
        my $status;
        my $installDir = $OptDir;
        my $procName = "run.jar";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ProcExist($procName, $outFile))
        {
                $File_Screen_Logger->info("JBoss is running, attempting to stop JBoss\n");
                my $status = system ("/etc/init.d/jboss stop > /dev/null 2>&1");
                my $procExists=&WaitProcExit($procName,10);
                if($procExists)
                {
                        my $status = system("kill -9 `ps -ef | grep run.jar | grep -v grep | tr -s ' ' | cut -d ' ' -f2` >/dev/null 2>&1 ");
                        my $procExists=&WaitProcExit($procName,10);
                        if($procExists)
                        {
                                &FailedInstall("Couldn't shutdown JBoss ...\nShutdown JBoss and try again ...\n");
                        }
                }

        }
        print "Preparing to install JBoss .. \n";

        if ( -d "$OptDir/jboss")
        {
            my $curJBoss = abs_path("$OptDir/jboss");
            if ($curJBoss =~ /$JBossVersion/)
            {
                $File_Screen_Logger->info( "Current JBoss is up to date\n");
                return;
            }

			# check if jboss RPM is installed by Fast Forward
			# We have not to match the earlier JBoss when we are upgrading to new one, so checking against the current version
			my $ff_jbossversion = $JBossVersion;
			my $buf = `rpm -qa`;
			chomp($buf);
			if (($buf=~m/$ff_jbossversion/)) {
				$File_Screen_Logger->info( "Current JBoss is up to date\n");
				return;
			}
        }
	if($PRE6 == 0) {
           $installDir = &GetDir("Enter the directory for JBoss installation", $OptDir);
		}
        my $status;

        if ( -d "$OptDir/jboss")
        {
            $status = system ("unlink $OptDir/jboss");
        }

        chdir $installDir;

        # check if it is already there
        if ( ! -d $JBossVersion )
        {
            Extract_JBoss();
        }

        $status = system ("rm -rf $OptDir/jboss");
        $status = system ("ln -s $installDir/$JBossVersion $OptDir/jboss");


        $File_Screen_Logger->info( "Installing JBoss ..done \n");
        $FileLogger->info("exiting");
	if($PRE6 == 0){
        	GetResponse ();
	}
}

sub Extract_JBoss(){
    my $status;
    print "Extracting JBoss  .. \n";
    $status = system ("$Unzip $TmpDir/$JBoss");
    if($status)
    {
        &FailedInstall("Unable to install JBoss $TmpDir/$JBoss ".$!);
    }
    print "Extracting JBoss ..done \n";
}

sub InstallJdk_64()
{
	chdir $TmpDir;
	my $AbsJ2sdk_64Rpm = $TmpDir."\/".$J2sdk_64;
	my $jdkversion = "1.6.0_18";

	print "Installing Java J2SDK ..  \n";
	if ( -d "$OptDir/jdk")
	{
		system("$OptDir/jdk/bin/java -version 2> jdk.version");
		my $versionString = `cat jdk.version`;
		chomp($versionString);
		if ($versionString =~ /$jdkversion/) {
			if ($versionString =~ /64-Bit/) {
				$File_Screen_Logger->info( "Current J2sdk is up to date\n");
				return;
			}
		}
		# check if the JDK is installed by Fast Forward
		my $ff_jdkversion = "1.6.0_18";
		if ($versionString =~ /$ff_jdkversion/) {
			if ($versionString =~ /64-Bit/) {
				$File_Screen_Logger->info( "Current J2sdk is up to date\n");
				return;
			}
		}
	}
	$File_Screen_Logger->info( "Installing Java $jdkversion in $OptDir...\n");
        $UsrJava = $OptDir;
        chdir "$UsrJava";
        my $DstUsrJava=$UsrJava."\/".$J2sdk_64Version;
        my $status;
        if (-d $DstUsrJava)
        {
                $status = system ("unlink $OptDir/jdk >/dev/null 2>&1");
                $status = system ("rm -rf $DstUsrJava");
        }
        $status = system ("chmod +x $AbsJ2sdk_64Rpm");
		if($PRE6 == 1 || $SWMF == 1 ){
			$status = system ("echo \"yes\" | $AbsJ2sdk_64Rpm 1>/dev/null");
		} else {
        	$status = system ("$AbsJ2sdk_64Rpm");
		}
        if($status)
        {
                &FailedInstall("Unable to install JDK".$!);
        }
        if  (-l "$OptDir/jdk")
        {
           $status = system ("unlink $OptDir/jdk");
        }
        $status = system ("ln -s $DstUsrJava $OptDir/jdk");
        chdir $TmpDir;
        system("unzip -qq jstack-jdk1.6.0_18.zip");
        system ("cp $TmpDir/jstack-jdk1.6.0_18/lib/tools.jar $OptDir/jdk/lib/");
        system ("cp $TmpDir/jstack-jdk1.6.0_18/bin/jstack $OptDir/jdk/bin/");
        system ("cp $TmpDir/jstack-jdk1.6.0_18/jre/lib/amd64/libattach.so $DstUsrJava/lib/amd64/");
        system ("rm -rf $TmpDir/jstack-jdk1.6.0_18");
        $File_Screen_Logger->info( "Installing Java J2SDK in $DstUsrJava..done \n");
}

##
## Install JDK, if the currently installed version is not up-to-date.s
##

sub InstallJdk ()
{
        $FileLogger->info("entering");
        $FileLogger->info( "Beginning with Java installation  \n");
	# GetResponse ();

	if ( -f $TmpDir."\/".$J2sdk_64 ) {
		InstallJdk_64();
		return;
	}

        chdir $TmpDir;
        my $AbsJ2sdkRpm = $TmpDir."\/".$J2sdkRpm;
        if ( ! -f $AbsJ2sdkRpm)
        {
                &FailedInstall("Unable to find $J2sdkRpm in $TmpDir  \n");
        }

        print "Installing Java J2SDK ..  \n";
        if ( -d "$OptDir/jdk")
        {
			my $jdkversion = "1.6.0_18";
			system("$OptDir/jdk/bin/java -version 2> jdk.version");
			my $versionString = `cat jdk.version`;
			chomp($versionString);
			if ($versionString =~ /$jdkversion/) {
                $File_Screen_Logger->info( "Current J2sdk is up to date\n");
                return;
            }
        }

        $UsrJava = &GetDir("Enter the directory for JAVA installation", $OptDir);
        $File_Screen_Logger->info( "Installing Java in $UsrJava\n");
        chdir "$UsrJava";
	# change for bug  36139
        # removed magic string for jdk version
        my $DstUsrJava=$UsrJava."\/".$J2sdkVersion;
	# change for bug  36139
        my $status;
        if (-d $DstUsrJava)
        {
                # Change for bug number 22820
                $status = system ("unlink $OptDir/jdk");
                #End Change for Bug number 22820
                $status = system ("rm -rf $DstUsrJava");
        }
        $status = system ("chmod +x $AbsJ2sdkRpm");
        $status = system ("$AbsJ2sdkRpm");
        if($status)
        {
                &FailedInstall("Unable to install JDK".$!);
        }
	# change for bug  36139
        # remove the symbolic link jdk if exist and then link it to new java version
        if  (-l "$OptDir/jdk")
        {
           $status = system ("unlink $OptDir/jdk");
        }
        # change for bug  36139
        $status = system ("ln -s $DstUsrJava $OptDir/jdk");
        $File_Screen_Logger->info( "Installing Java J2SDK in $DstUsrJava..done \n");
        $FileLogger->info("exiting");

}
##
## Selects the MySql package corresponding to the processor, detect the type of processor, and select the appropriate MySql rpm, exit installation if the said version is not found
##
sub SelectMySqlPackage ()
{
        $FileLogger->info("entering");
        my $processortype = &GetProcessorType();
        my $processorResponse ="";
        if($processortype=~m/x86_64/)
        {
        		if($RSM_OS_TYPE eq "RHEL")
        		 {
        		
        				$MySQLServerRpm =     $MySQLServerRHEL64TRpm ;
                        $MySQLClientRpm =     $MySQLClientRHEL64TRpm ;
        				$MySQLSharedEM64TRpm= $MySQLSharedRHEL64TRpm;                
	       		 }
#                $processorResponse = &GetBooleanCharResponse("64-bit processor detected, install MySql for EM64T for better performance (y/n)?\n");
                else 
                 {
                        $MySQLServerRpm =     $MySQLServerEM64TRpm ;
                        $MySQLClientRpm =     $MySQLClientEM64TRpm ;
                 }
#               else
#                {
#                        $MySQLServerRpm =    $MySQLServerX86Rpm;
#                        $MySQLClientRpm =    $MySQLClientX86Rpm;
#                }
                $FileLogger->info("exiting");
                return;
        }
        if($processortype=~m/ia64/)
        {
                &FailedInstall("MySql for IA64 processors is currently not supported, please contact GENBAND representative");
                $processorResponse = &GetBooleanCharResponse("64-bit processor detected, select MySql for IA64 for better performance  (y/n)?\n");
                if($processorResponse eq 'y')
                {
                        $MySQLServerRpm =    $MySQLServerIA64Rpm;
                        $MySQLClientRpm =    $MySQLClientIA64Rpm;
                }
                else
                {
                        $MySQLServerRpm =    $MySQLServerX86Rpm;
                        $MySQLClientRpm =    $MySQLClientX86Rpm;
                }
                $FileLogger->info("exiting");
                return;
        }
        if($processortype=~m/i386/)
        {
                print "32-bit processor detected, selecting x86 package\n";
                $MySQLServerRpm =    $MySQLServerX86Rpm ;
                $MySQLClientRpm =    $MySQLClientX86Rpm ;
                $FileLogger->info("exiting");
                return;
        }
        $processorResponse = &GetBooleanCharResponse("Unable to determine processor type, install default (x86) MySql package (y/n)?\n");
        if($processorResponse eq 'y')
        {
                $MySQLServerRpm =    $MySQLServerX86Rpm;
                $MySQLClientRpm =    $MySQLClientX86Rpm;
                $FileLogger->info("exiting");
                return;
        }
        &FailedInstall("Installation failed, could not detect processor, unable select MySql package for installation...");
}

##
## Get the processor type of the system
##
sub GetProcessorType()
{
        my $filetmp = "processortype";
        my $status = system("uname -pi > $filetmp");
        my $processortype = &getStringFrmFile($filetmp);
        system("rm $filetmp");
        return $processortype;

}

##
## Display an error message, clean up the temp directory, and exit.
## To be used if setup is to exit without doing any work. 
## It does not clean up the earlier installation or any work done during setup
##
sub FailedSetupNoCleanupRequired()
{
        $FileLogger->info("entering FailedSetupNoCleanupRequired() ");
        my ($failureMessage) = @_;
        $File_Screen_Logger->fatal("Installation failed due to ".$failureMessage." Please see log for details.");
        GetResponse();
        if($TmpDir ne "/var/tmp")
        {
                system ("/bin/rm -rf $TmpDir");
        }
        $FileLogger->info("exiting");
        system ("/bin/rm -rf $TmpDir");
        exit 2;
}

##
## Display an error message, clean up the temp directory, and exit.
##
sub FailedInstall()
{
        $FileLogger->info("entering");
        my ($failureMessage) = @_;
        $File_Screen_Logger->fatal("Installation failed due to ".$failureMessage." Please see log for details.");
        if($wasDbBackedUp eq 'y')
        {

                if($MySqlInstalled eq 'y')
                {
                        DataRestore();
                }
                else
                {
                        $File_Screen_Logger->info("If you want to restore your old database, try running the SQL script $BackupFile");
                }
        }
        GetResponse();
        if($TmpDir ne "/var/tmp")
        {
                system ("/bin/rm -rf $TmpDir");
        }
        $FileLogger->info("exiting");
        system ("/bin/rm -rf $TmpDir");
        if(!$isPeerHAInstalled && $isInstall){

            system("/bin/rm -rf $OptDir/rsm");
            system("/bin/rm -rf $OptDir/jdk*");
            system("/bin/rm -rf $OptDir/jboss*");
        }

        exit 2;
}

##
##Display an error message, attempt to rollback the database changes clean up the temp directory, and exit.
##
sub FailedUpgrade()
{
        $FileLogger->info("entering");
        my ($failureMessage) = @_;
        $File_Screen_Logger->fatal("Upgrade failed due to ".$failureMessage." Please see log for details.");
        chdir $TmpDir;
        if($runDownGradeSQLOnFailure)
        {
                if(defined($DowngradeScript) && (-f $DowngradeScript))
                {
                        system("mysql -uroot --password=$ROOT_Password  -f <$DowngradeScript >/dev/null 2>&1");
                }
        }
#
# As per the fix of PRS#135635 no data backups shall be taken during upgrade. Hence no data restore to be 
# called in case upgradation fails.
#
        #if($wasDbBackedUp eq 'y')
        #{

        #        if($MySqlInstalled eq 'y')
        #        {
        #                DataRestore();
        #        }
        #        else
        #        {
        #                $File_Screen_Logger->info("If you want to restore your old database, try running the SQL script $BackupFile");
        #       }
        #}
        if($typeOfInstall==2 && $ivmsLiteDataBackedUp==1)
        {
                my $restoreDataResp=&GetBooleanCharResponse("Restore bn schema from dump?");
                if($restoreDataResp=='y')
                {
                        ivmsLiteDataRestore();
                        if(!$ivmsLiteDataRestored)
                        {
                                $File_Screen_Logger->warn("Unable to restore data, please restore data manually using pg_restore, the dump file is $ivmsLiteDumpFile");
                        }
                }
        }
        GetResponse();
        if($TmpDir ne "/var/tmp")
        {
                system ("/bin/rm -rf $TmpDir");
        }
        $FileLogger->info("exiting");

	if ($isRedundancySetup) {
		&HA_StopJBoss();
		&HA_StopMySQL();
		#&HA_UnMountDisk();
		$File_Screen_Logger->info("Upgrade failed. Please restart heartbeat using '/etc/init.d/heartbeat start'.");
	}

        exit 2;
}

##
## Backup the database(s)
##
sub Databackup()
{
        $FileLogger->info("entering");
        my $dbresp = &GetBooleanCharResponse("Do you want to backup your database? A large amount of space and time may be required depending on the size of your database.");
        if($dbresp eq 'y')
        {
				# start MySQL server
				system ("/etc/init.d/mysql start >/dev/null 2>&1");
                GetMySQLPasswd();
                my $status=1;
                while(1)
                {
                        $File_Screen_Logger->info("Which database(s) to backup (all/bn)[bn]");
                        my $resp = <>;
                        chomp($resp);
                        $FileLogger->info("User responded \'$resp\'");
                        if ($resp eq "")
                        {
                                $FileLogger->info("Trying to backup \'bn\' database");
                                $status = backup::BackupOneDB( $ROOT_Password,"bn", $StartDir."\/".$bnBackUpFile,$FileLogger,$File_Screen_Logger);
                                $BackupFile=$StartDir."\/".$bnBackUpFile;
                                last;
                        }
                        if ($resp eq "all")
                        {
                                $FileLogger->info("Trying to backup \'all\' databases");
                                $status = backup::BackupAllDatabases( $ROOT_Password, $StartDir."\/".$entireDBBackup,$FileLogger,$File_Screen_Logger);
                                $BackupFile=$StartDir."\/".$entireDBBackup;
                                last;
                        }
                        if ($resp eq "bn")
                        {
                                $FileLogger->info("Trying to backup \'bn\' database");
                                $status = backup::BackupOneDB( $ROOT_Password,"bn", $StartDir."\/".$bnBackUpFile,$FileLogger,$File_Screen_Logger);
                                $BackupFile=$StartDir."\/".$bnBackUpFile;
                                last;
                        }
                }
                if($status == 0)
                {
                        $FileLogger->info("Successfully backed up database");
                        $wasDbBackedUp = 'y';
                }
                else
                {
                        $FileLogger->info("Unable to backup database");
                }
        }
        $FileLogger->info("exiting");

}

##
## Restore the database that was backed up earlier.
##
sub DataRestore()
{
        $FileLogger->info("entering");
        my $restoreResp =&GetBooleanCharResponse("Do you want to restore the database, that you chose to backup. We have already tried to rollback any changes?");
        my $status=1;
        if($restoreResp eq 'y')
        {
                $File_Screen_Logger->info("Attempting to restore old tables...This might take a long time depending on the size of your old database, do not abort..");
                $status = system("/usr/bin/mysql -u root --password=$ROOT_Password <$BackupFile");
                if($status)
                {
                        $File_Screen_Logger->info("Failed...");
                        $File_Screen_Logger->info("If you want to restore your old database, try running the SQL script $BackupFile");

                }
                else
                {
                        $DBRestored='y';
                        $File_Screen_Logger->info("Succeded...");
                }
        }
        else
        {
                $File_Screen_Logger->info("If you want to restore your old database, try running the SQL script $BackupFile");
        }
        $FileLogger->info("exiting");
}

##
##Backup data of ivmslite
##
sub ivmsLiteDataBackup
{
        $FileLogger->info("Entering ivmsLiteDataBackup");
        my($MSWUser,$MSWPwd)=@_;

        my $status = system("pg_dump -U$MSWUser -f$ivmsLiteDumpFile -nbn  msw");
        if(!$status)
        {
                $ivmsLiteDataBackedUp=1;
        }
        $FileLogger->info("Exiting ivmsLiteDataBackup");
}

##
##Restore data of ivmslite
##
sub ivmsLiteDataRestore
{
        $FileLogger->info("Entering ivmsLiteDataRestore");
        my($MSWUser,$MSWPwd)=@_;
        my $status=system("psql -U$MSWUser msw -c\"drop schema bn cascade;\">/dev/null 2>&1");
        $status = system("psql -U$MSWUser msw <$ivmsLiteDumpFile >/dev/null 2>&1");
        if($status==0)
        {
                $ivmsLiteDataRestored=1;
                $File_Screen_Logger->info("Successfully restored data");
        }
        $FileLogger->info("Exiting ivmsLiteDataRestore");
}



##
## Create the loggers for our application
##

sub CreateLogger()
{
        my ($LogFile,$Level)=@_;
        Log::Log4perl->easy_init("$Level");
        $FileLogger = get_logger("ivmslogger1");
        $File_Screen_Logger=get_logger("ivmslogger2");
        $appender = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",filename => "$LogFile",mode => "append",);
        $layout = Log::Log4perl::Layout::PatternLayout->new("%d %p> %F{1}:%L %M  %m%n");
        $appender->layout($layout);
        $FileLogger->add_appender($appender);
        $File_Screen_Logger->add_appender($appender);
        my $appender2 = Log::Log4perl::Appender->new("Log::Log4perl::Appender::Screen");
        my $layout2 = Log::Log4perl::Layout::PatternLayout->new("%m%n");
        $appender2->layout($layout2);
        $File_Screen_Logger->add_appender($appender2);
}

##
## Install MySql server. Cleans up the existing mysql data directories
##
sub InstallMySqlServer()
{
        $FileLogger->info("entering");
        # Changed the installation script to procced without installing MysqlServer
        #
#       &GetBooleanResponse("Remove traces of any old MySQL installation?");
        chdir $StartDir;
        my $status=1;
        my $procName = "$MySqlProcStr";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ProcExist($procName, $outFile))
        {
            $File_Screen_Logger->info("MySql is running, attempting to stop MySql\n");
            $status =  system ("/etc/init.d/mysql stop");
            my $procExists=&WaitProcExit($procName,4);
            if($procExists)
            {
                &FailedInstall("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");
            }
        }
        if( -f "/etc/my.cnf")
        {
            $status = system ("mv /etc/my.cnf /etc/my.cnf.old");
        }
        $status = system ("rm -rf /var/lib/mysql");
        $status = system ("rm -rf /var/lib/mysql-bak");

        ##
        ## Create Database directory
        ##

        
        $MySqlDir = "$OptNxtn/mysql/data";
        
	my $ret=0;
	my $userPrompt=0;
	my $mount_data=" $MySqlDir ";
	my $cmd=" mount | grep $MySqlDir ";
	my $dataDirCreated=0;	
	$ret=&getOutputFromConsole($cmd);
	
	if (!($ret=~m/$mount_data/))
    	{
        	$userPrompt=1;
    	}
	
	if ($userPrompt) {
        	$File_Screen_Logger->info("Enter directory to be used for creating database [$OptNxtn/mysql/data] :");
		
        my $resp = <>;
        chomp($resp);
        $FileLogger->info("User responded \'$resp\'");
        if ($resp ne "")
        {
            $MySqlDir = $resp;

            if (!-d $MySqlDir)
            {
                my $CreateDir=&GetBooleanCharResponse("The directory $MySqlDir does not exist, do you want it to be created");
                if($CreateDir eq "n")
                {
                   &FailedInstall($MySqlDir." not found");
                }
                $status = system("mkdir -p $MySqlDir");
				$dataDirCreated=1;
                if ($status)
                {
                    &FailedInstall($MySqlDir." could not be created: ".$!);
                }
                
            }
            if (! -d "$OptNxtn/mysql")
            {
            	$status = system ("mkdir -p $OptNxtn/mysql");
            	if ($status)
               	{
               	    &FailedInstall("$OptNxtn/mysql/ could not be created for symbolic links: ".$!);
               	}
            }
        }
	} else {
		$File_Screen_Logger->info("Found requisite mount points. Will create database in default location.");
	}
        

	$File_Screen_Logger->info("Directory to be used for creating database : $MySqlDir  ");	

        if (! -d $MySqlDir)
        {
           $status = system ("rm -rf $MySqlDir");
           $status = system ("mkdir -p $MySqlDir");
	   $dataDirCreated == 1;
        }

        # Read..
=head1
        if($MySqlDir ne "\/mysqldata")
        {
           $MySqlDir = $MySqlDir."\/mysqldata";
        }
=cut
        if (-f $MySqlDir)
        {
             # Changed the file to allow the install
             # in case the user does not want to delete the old installation
             &GetBooleanResponse("Delete file $MySqlDir?");
             $status = system ("rm -rf $MySqlDir");
        }
        if (-d $MySqlDir && $dataDirCreated == 0)
        {
#            &GetBooleanResponse ("Delete contents of $MySqlDir?");
             my $DeleteMysqlDirectory = &GetBooleanCharResponse ("Setup needs to clean up the contents of $MySqlDir. Delete contents of $MySqlDir?");
             if($DeleteMysqlDirectory eq "y")
             {
                 $File_Screen_Logger->info("Deleting contents of $MySqlDir.. \n");
                 print "This may take a long time...\n";
                 print "Please do not abort...\n";
                 $status = system("rm -rf $MySqlDir/*");
             }
        	else {
		&FailedInstall("setup cannot proceed without deleting contents of $MySqlDir \n");
	     }
        }
        else
        {
             $status = system ("mkdir -p $MySqlDir");
        }

        if ($MySqlDir ne "$OptNxtn/mysql/data")
        {
            $status = system ("rm -rf $OptNxtn/mysql/data");
            $status = system ("ln -s $MySqlDir $OptNxtn/mysql/data");
        }

        ##
        ## Create database logs directory
        ##

        $userPrompt=0;
        $MySqlLog = "$OptNxtn/mysql/log";
        $mount_data=" $MySqlLog ";
	my $cmd=" mount | grep $MySqlLog ";
	my $logDirCreated=0;
	$ret=&getOutputFromConsole($cmd);
	
    	if (!($ret=~m/$mount_data/))
    	{
        	$userPrompt=1;
    	}

	if ($userPrompt) {

        	$File_Screen_Logger->info("Enter directory to be used for creating database logs [$OptNxtn/mysql/log] :");
        	
        
        # Read..
        my $resp = <>;
        chomp($resp);
        $FileLogger->info("User responded \'$resp\'");
        if ($resp ne "")
        {
            $MySqlLog = $resp;
            if ( !-d $MySqlLog)
            {
                my $CreateDir=&GetBooleanCharResponse("The directory $MySqlLog does not exist, do you want it to be created");
                if($CreateDir eq "n")
                {
                        &FailedInstall($MySqlLog." not found");
                }
                $status = system("mkdir -p $MySqlLog");
		$logDirCreated=1;
                if ($status)
                {
                        &FailedInstall($MySqlLog." could not be created: ".$!);
                }
            }
	}
	}else {
		$File_Screen_Logger->info("Found requisite mount points. Will create database logs in default directory  			");			
	
        }
	$File_Screen_Logger->info("Directory to be used for creating database logs: $MySqlLog  ");	

=head2
        if($MySqlLog ne "\/mysqllogs")
        {
            $MySqlLog = $MySqlLog."/mysqllogs";
        }
=cut
	if (! -d $MySqlLog)
        {
            $status = system ("mkdir $MySqlLog");
        }
        
	if (-f $MySqlLog)
        {
            &GetBooleanResponse("Delete file $MySqlLog?");
            $status = system ("rm -rf $MySqlLog");
        }
         if (-d $MySqlLog && $logDirCreated==0)
        {
#           &GetBooleanResponse ("Delete contents of $MySqlLog?");
            my $DeleteMySqlLog = &GetBooleanCharResponse ("Setup needs to clean up the contents of $MySqlLog. Delete contents of $MySqlLog?");
            if($DeleteMySqlLog eq "y")
            {
                $File_Screen_Logger->info("Deleting $MySqlLog..");
                print "This may take a long time...\n";
                print "Please do not abort...\n";
                $status = system("rm -rf $MySqlLog/*");
            }
	    else {
		&FailedInstall("setup cannot proceed without deleting contents of $MySqlLog \n");
		}
        }
        else
        {
            $status = system ("mkdir $MySqlLog");
        }

        if ($MySqlLog ne "$OptNxtn/mysql/log")
        {
           $status = system ("rm -rf $OptNxtn/mysql/log");
           $status = system ("ln -s $MySqlLog $OptNxtn/mysql/log");
        }

        chdir $TmpDir;
        $File_Screen_Logger->info("Installing $MySQLServerRpm ..");
        if ( ! -f $MySQLServerRpm)
        {
           &FailedInstall("Unable to find $MySQLServerRpm \n");
        }

	# Remove RPMs (if existing) before installing fresh version.
        my $mysqlCurrentVersion = &getMySqlVersion();

        if(!($mysqlCurrentVersion=~m/0\.0/)){

	    #Get name of existing RPM
	    my $existingRPM = `rpm -qa | grep MySQL-server`;
	    chomp($existingRPM);
	    if($RSM_OS_TYPE eq "RHEL")
	   {
		$status =  system ("/usr/sbin/setenforce Permissive");
		$status=  system(" sed -i.bak \"s/SELINUX=enforcing/SELINUX=permissive/g\" /etc/selinux/config ");
	    $status = system ("rpm -e --nodeps `rpm -qa |grep -i mysql`");	
		$status = system ("rpm -i  $MySQLSharedEM64TRpm");
	   }
	   else
	   {
	    my $status = system ("rpm -e $existingRPM");

	    }
	}

        $status = system ("rpm -i --force $MySQLServerRpm");
	my $rpmIns = `rpm -qa | grep MySQL-server`;
	chomp($rpmIns);
	if(!($MySQLServerRpm=~m/$rpmIns/))
        {
            &FailedInstall("Unable to install MySql server. Are all dependencies installed?\n ".$!);
        }
	if($RSM_OS_TYPE eq "RHEL"){
		$status = system ("rpm -i $Perl_DBD_MySQL ");
	}

        $File_Screen_Logger->info("Installing $MySQLServerRpm ..done");
        chdir $TmpDir;
        $FileLogger->info("exiting");

}



##
## Install MySql server on HA setup. Creates mysql data on the SAN itself 
## 
##
sub HA_InstallMySqlServer()
{
        $FileLogger->info("entering");
        # Changed the installation script to procced without installing MysqlServer
        #
#       &GetBooleanResponse("Remove traces of any old MySQL installation?");
        chdir $StartDir;
        my $status=1;
        #Databackup();
        my $procName = "$MySqlProcStr";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ProcExist($procName, $outFile))
        {
            $File_Screen_Logger->info("MySql is running, attempting to stop MySql\n");
            $status =  system ("/etc/init.d/mysql stop");
            my $procExists=&WaitProcExit($procName,4);
            if($procExists)
            {
                &FailedInstall("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");
            }
        }
        if( -f "/etc/my.cnf")
        {
            $status = system ("mv /etc/my.cnf /etc/my.cnf.old");
        }
        $status = system ("rm -rf /var/lib/mysql");
        $status = system ("rm -rf /var/lib/mysql-bak");

        ##
        ## Create Database directory
        ##
	my $ret=0;
	my $mount_data=" $HA_mysql_data_mount_pt ";
	my $cmd=" /etc/init.d/ocfs2 status | grep \"Active OCFS2 mountpoints\" ";
	$ret=&getOutputFromConsole($cmd);	

    	if (!($ret=~m/$mount_data/))
    	{
        	&FailedSetupNoCleanupRequired("Cannot find $HA_mysql_data_mount_pt as active ocfs mount point. Please make sure system is installed properly.");
    	}

	$mount_data=" $HA_mysql_log_mount_pt ";
	
    	if (!($ret=~m/$mount_data/))
    	{
        	&FailedSetupNoCleanupRequired("Cannot find $HA_mysql_log_mount_pt as active ocfs mount point. Please make sure system is installed properly.");
    	}
	
	$ret=0;
	if ( -d $HA_mysql_link) {
		$cmd=" readlink $HA_mysql_link ";
		$ret=&getOutputFromConsole($cmd);
		
		if ($ret eq "$HA_mysql_mount_pt" || $ret eq "$HA_mysql_mount_pt/" ) {
			$MySqlDir = "$OptNxtn/mysql/data" ;
			$MySqlLog = "$OptNxtn/mysql/log" ;
		} else {
			# to be checked. in case the link is a dir then what ? 
			system("rm -rf 	$HA_mysql_link");
			system("ln -s $HA_mysql_mount_pt $HA_mysql_link");	
			$MySqlDir = "$OptNxtn/mysql/data" ;
			$MySqlLog = "$OptNxtn/mysql/log" ;
		} 
	} else {
		system("ln -s $HA_mysql_mount_pt $HA_mysql_link");	
		$MySqlDir = "$OptNxtn/mysql/data" ;
		$MySqlLog = "$OptNxtn/mysql/log" ;
	}

	
        $File_Screen_Logger->info("Directory to be used for creating database is : $MySqlDir :");
       
        #if (! -d $MySqlDir)
        #{    
	#   $status = system ("rm -rf $MySqlDir");
        #   $status = system ("mkdir -p $MySqlDir");
        #}

        #if (-f $MySqlDir)
        #{        
        #    &GetBooleanResponse("Delete file $MySqlDir?");
        #    $status = system ("rm -rf $MySqlDir");
        #}
       
        #if (-d $MySqlDir )
        #{
             my $DeleteMysqlDirectory = &GetBooleanCharResponse ("Setup needs to clean up the contents of $MySqlDir. Delete contents of $MySqlDir?");
             if($DeleteMysqlDirectory eq "y")
             {
                 $File_Screen_Logger->info("Deleting contents of $MySqlDir.. \n");
                 print "This may take a long time...\n";
                 print "Please do not abort...\n";
                 $status = system("rm -rf $MySqlDir/*");
             }else {
		&FailedInstall("setup cannot proceed without deleting contents of $MySqlLog \n");
 	    }
        #}
        #else
        #{
        #     $status = system ("mkdir -p $MySqlDir");
        #}

        ##
        ## Create database logs directory
        ##

        $File_Screen_Logger->info("Directory to be used for creating database logs : $MySqlLog ");

        #if (! -d $MySqlLog)
        #{
        #    $status = system ("mkdir $MySqlLog");
        #}

        #if (-f $MySqlLog)
        #{
        #    &GetBooleanResponse("Delete file $MySqlLog?");
        #    $status = system ("rm -rf $MySqlLog");
        #}
        #if (-d $MySqlLog)
        #{

            my $DeleteMySqlLog = &GetBooleanCharResponse ("Setup needs to clean up the contents of $MySqlLog.Delete contents of $MySqlLog?");
            if($DeleteMySqlLog eq "y")
            {
                $File_Screen_Logger->info("Deleting contents of $MySqlLog..");
                print "This may take a long time...\n";
                print "Please do not abort...\n";
                $status = system("rm -rf $MySqlLog/*");
            }else {
		&FailedInstall("setup cannot proceed without deleting contents of $MySqlLog \n");
 	    }
        #}
        #else
        #{
        #    $status = system ("mkdir $MySqlLog");
        #}

        chdir $TmpDir;
        $File_Screen_Logger->info("Installing $MySQLServerRpm ..");
        if ( ! -f $MySQLServerRpm)
        {
           &FailedInstall("Unable to find $MySQLServerRpm \n");
        }

	# Remove RPMs (if existing) before installing fresh version.
        my $mysqlCurrentVersion = &getMySqlVersion();

        if(!($mysqlCurrentVersion=~m/0\.0/)){

	    #Get name of existing RPM
	    my $existingRPM = `rpm -qa | grep MySQL-server`;
	    chomp($existingRPM);
	    my $status = system ("rpm -e $existingRPM");
	}

        $status = system ("rpm -i --force $MySQLServerRpm");
	my $rpmIns = `rpm -qa | grep MySQL-server`;
	chomp($rpmIns);
	if(!($MySQLServerRpm=~m/$rpmIns/))
        {
            &FailedInstall("Unable to install MySql server. Are all dependencies installed?\n ".$!);
        }

        $File_Screen_Logger->info("Installing $MySQLServerRpm ..done");
        chdir $TmpDir;
        $FileLogger->info("exiting");

}

##
##Change owner of mysql directories to user mysql
##
sub ConfigureMySqlServer()
{
        $FileLogger->info("entering");

        SetMySQLPasswd ();

        ##
        ## Shutdown MySQL Database, copy databse files to $MySQLDir
        ## Create /etc/my.cnf
        ##

        $File_Screen_Logger->info("Shutting down MySQL Database.. \n");
        my $status = system ("/usr/bin/mysqladmin -u root --password=\"$ROOT_Password\" shutdown");
        $status = system ("mv /var/lib/mysql /var/lib/mysql-bak");
        $status = system ("rm -rf /var/lib/mysql");

        $status = system ("chown mysql:mysql $MySqlDir");
        $status = system ("chown mysql:mysql $OptNxtn/mysql");
        $status = system ("chown mysql:mysql $OptNxtn/mysql/log");
        $status = system ("chown mysql:mysql $OptNxtn/mysql/data");
        $status = system ("chown mysql:mysql $MySqlLog");

        $status = system ("ln -s $MySqlDir /var/lib/mysql");
        $status = system ("chown mysql:mysql /var/lib/mysql");
        $status = system ("mv /var/lib/mysql-bak/mysql /var/lib/mysql");
        $status = system ("rm -rf /var/lib/mysql-bak");

        $File_Screen_Logger->info("Customizing MySQL configuration file..");

        ModifyMyCnf ();

        # Changed to remove the warning if my.cnf is not present
        if (-f "/etc/my.cnf")
        {
           $status = system ("mv /etc/my.cnf /etc/my.cnf.bak");
        }
        $status = system ("cp my.cnf /etc/my.cnf");

        $File_Screen_Logger->info("Customizing MySQL configuration file..done");
        if(-f "/etc/rc.d/rc3.d/S99mysql")
        {
             $status = system ("rm /etc/rc.d/rc3.d/S99mysql");
        }
        $status = system ("ln -s /etc/init.d/mysql /etc/rc.d/rc3.d/S99mysql");

		##
		## Start the MySQL database
		##
		$File_Screen_Logger->info("Creating MySQL Database.. ");
		print "This will take a long time...\n";
		print "Please do not abort...\n";
		$status = system ("/etc/init.d/mysql start >/dev/null 2>&1");
		$MySqlInstalled='y';
		$File_Screen_Logger->info("MySql Database created in $MySqlDir ");
		chdir $StartDir;
		$FileLogger->info("exiting");
}

##
##Install MySql client
##
sub InstallMySqlClient()
{
        $FileLogger->info("entering");
        if ( ! -f $MySQLClientRpm)
        {
                &FailedInstall("Unable to find $MySQLClientRpm \n");
        }

        $File_Screen_Logger->info("Installing MySQL Client..");

        my $existingRPM = `rpm -qa | grep MySQL-client`;
        chomp($existingRPM);

	if ($existingRPM ne '')
	{
	    my $status = system ("rpm -e $existingRPM");
	}

        my $status = system ("rpm -i --force $MySQLClientRpm");
	my $rpmIns = `rpm -qa | grep MySQL-client`;
	chomp($rpmIns);
	if(!($MySQLClientRpm=~m/$rpmIns/))
        {
                &FailedInstall("Unable to install MySql client.Are all dependencies installed?\n ".$!);
        }

        $File_Screen_Logger->info("Installing MySQL Client..done ");
        $FileLogger->info("exiting");
}

##
##Install license, iVMSLite installation only
##
sub InstallLicense()
{
        $FileLogger->info("entering");
        my ($MSWUser,$MSWPwd)=@_;
        chdir $TmpDir;
        my $status;
        my $license="$TmpDir/iVMSLiteLicense.sql";

        if ( ! -f $license)
        {
                &FailedInstall("Unable to find license file\n");
        }
        open(LICENSE,"<$license");
        my $tmplicense=$license.".tmp";
        open (TMPLIC,">$tmplicense");
        print TMPLIC "\\c msw;\n";
        print TMPLIC "set search_path=bn;\n";
        while (<LICENSE>)
        {
                print TMPLIC $_;
        }
        close LICENSE;
        close TMPLIC;
        $status=system("psql -U$MSWUser -h$MSWHostName -dmsw --quiet <$tmplicense");
        system("rm $tmplicense");
        if ($status)
        {
                &FailedInstall("Unable to install license.");
        }

        $FileLogger->info("exiting");
}


##
##Install the zip and unzip rpms, iVMSLite only, as they are not installed by default
##
sub InstallZip()
{
        $FileLogger->info("entering");
        chdir $TmpDir;
        if(! -f $ziprpm || !-f $unziprpm)
        {
                &FailedInstall("zip rpms not found");

        }
        my $status=system("rpm -i --force --nodeps $ziprpm");
        my $status1=system("rpm -i --force --nodeps $unziprpm");
        if($status || $status1)
        {
                &FailedInstall("Unable to install zip");
        }
        $FileLogger->info("exiting");
}
##
## Install the package
##

# update the jre/java time with respect to RSM server
sub update_time_jar
{
    # @args = ("command", "arg1", "arg2");
    my($update_jar_path) = "tzupdater.jar";
    if ( -e $update_jar_path) {
      my(@args) = ("java", "-jar", $update_jar_path, "-u");
      system(@args);
      $FileLogger->info("$update_jar_path is executed for updating jre/java time");
    }
    else
    {
     $FileLogger->info("tzupdater.jar does not exixst in  rsm.tar");
    }
}


sub InstallPackage ()
{
    $isInstall=1;
    #get the hardware type
	if($typeOfInstall!=3) {
		&getHardwareType();
	}
    # Must be privileged.
    CheckForSuperuser ();
    # commented the function as in case of ivms list multiple ip addresses will be exposed
    my $status;
    my $resp;

    #############################################
    ## $StartDir for creating install log
    ## $StartDir for reading media file by default
    ###############################################

    my $InstallLog = $StartDir."\/".$InstallLogFile;
    $LogFile =  $InstallLog;
    &CreateLogger("$InstallLog", "DEBUG");

    open (ERROR, "> $InstallLog");
    STDERR->fdopen(\*ERROR, "w");

    # In case of installation of RSM server check if updated version of RSMLinux has been installed or not
	#if ($typeOfInstall==1 && $isCheckDisabled != 1 ) {
		#&checkIfCorrectRSMOSInstalled();
	#}

    #RSM install
    if($RSM_OS_TYPE eq "RHEL"){
    	&CheckHostConsistency();
    }
    if($typeOfInstall==1) {
        if( $isCheckDisabled != 1){
            &checkIfCorrectRSMOSInstalled();
        }

        # Are we installing a redundant RSM?
        &HA_GetRedundancyFlag();
        # Is HA installed in the peer RSM server?
        &HA_GetPeerHAInstalledFlag();

        if ($isRedundancySetup) {
            print "Installing high availability RSM system ...\n";
            &HA_processing();
        	&HA_Init();
 	        &HA_VerifySystem();
			if ($isPeerHAInstalled) {
				my $peerInstallResp = &GetBooleanCharResponse("Installing RSM system on second server. Do you wish 					to continue ? ");	
				if ($peerInstallResp eq 'n') {
					$resp=&FailedSetupNoCleanupRequired("user abort while installing RSM on second server.");
				}
			}

            &HA_StopProcesess();
        }
    }


    if (-f "$OptNxtn/rsm/.ivmsindex")
    {
       my $curversion=`cat $OptNxtn/rsm/.ivmsindex`;
       chomp($curversion);
       if($curversion ne "")
       {
           if (!$isRedundancySetup) {
               # this is to allow the other node to be able to installed
               $resp=&FailedSetupNoCleanupRequired("RSM version ($curversion) is already installed. Either unistall the previous RSM and install the nsw RSM or upgrade the RSM \n \n ");
           }
        }
    }

    if($StartDir=~m/ /)
    {
        &FailedSetupNoCleanupRequired("The directory name : \'$StartDir\' contains spaces, for successfull installation, please ensure that any directory/file names/paths do not contain spaces.");
    }
    $File_Screen_Logger->info("Proceeding to install $typeOfInstallString Package... ");
    # Get name of tmp directory to be used during install process
    &GetTempDir("installation");
    $status = &CreateHomeDir();
    if($status)
    {
        &FailedSetupNoCleanupRequired("Failed to create $NextoneOpt ....\n ");
    }

=head1
    if(!-d $OptDir)
    {
        $status=system("mkdir -p $OptDir");
        if ($status)
        {
                print("$OptDir is not present, failed to create it");
        }
    }
=cut
    ## Get name of mediafile
    &GetMediaFile();

    $UpgradeBak = $TmpDir."\/narsbak";
    $status = system ("mkdir $UpgradeBak");

    ExtractMediaFile();

	if (!$isRedundancySetup) {
		TestHostNameConsistency();
	}

    ##
    ## Go through the steps.
    ##

    # Initially clean machine of any old traces...

    if($typeOfInstall==1)   #RSM install
    {
		# update my.cnf file
        &UpdateMyCnf();

        $status = system ("mkdir -p /var/log");

        if ($isRedundancySetup) {
            &HA_CollectHAInfo();
            #&HA_SetupSshKey();
            &HA_UpdateConfig();
        }
        chdir $TmpDir;

        # Check for currently installed vsersion of mysql
        my $mysqlInstallresponse = 'y';
		my $iscurrentMysqlValid='n';
        my $mysqlCurrentVersion = &getMySqlVersion();
        if ($isRedundancySetup && $isPeerHAInstalled) {
                $mysqlInstallresponse = 'n';
                $HA_SecondInstallInitDB = 'n';
		} else {
			if (!($mysqlCurrentVersion=~m/0\.0/))  
			{
				# If any version of mysql is installed, it checks the mysql installation. 
				$File_Screen_Logger->info("Detected: $mysqlCurrentVersion");
				$File_Screen_Logger->info("Checking current mysql installation....");	
				
				# In case an existing mysql installation is detected while installing RSM
				# setup checks whether the files of the existing installation are in the mount partition 
				# and the consistency of the /etc/my.cnf file. If everything checks out the existing installation of 
				# of mysql is used.	
				
				if ($isRedundancySetup) {	
					$iscurrentMysqlValid=&HA_checkMySQLInstallation();			
				} else {
					$iscurrentMysqlValid=&checkMySQLInstallation();			
				}

				if ($iscurrentMysqlValid eq 'f') 
				{
					$mysqlInstallresponse = 'y';
				}
				else 
				{
					if ($iscurrentMysqlValid eq 'y') 
					{
						$mysqlInstallresponse = 'n';
					}
					else 
					{	       
						$File_Screen_Logger->info("Problems found with the current MySql installation.");
						$mysqlInstallresponse = &GetBooleanCharResponse("Do you want to install a fresh MySQL server? Please take a backup of the existing installation before proceeding. Select n if you wish to keep any existing MySql data/logs.");
						if ($mysqlInstallresponse eq 'n') 
						{
							&FailedSetupNoCleanupRequired("user aborted while installing fresh mysql.");
						}
					}
				}
			}
		}
        if(&GetProcessorType()=~m/x86_64/)
        {
            if(! -f $libmysqlold64)
            {
                &FailedInstall($libmysqlold64." was not found");
            }
            $status=system("unzip -n -qq $libmysqlold64 -d /");
            if($status)
            {
                $File_Screen_Logger->warn("Unable to extract $libmysqlold64 , some functionalities, eg upgraderatingdata, upgradecapabilities might not work");
            }

        }
        else
        {
            if(! -f $libmysqlold32)
            {
                &FailedInstall($libmysqlold32." was not found");
            }
            $status=system("unzip -n -qq $libmysqlold32 -d /");
            if($status)
            {
                $File_Screen_Logger->warn("Unable to extract $libmysqlold32 , some functionalities, eg upgraderatingdata, upgradecapabilities might not work");
            }

        }
        if(!$isPeerHAInstalled && $mysqlInstallresponse eq 'y') {
            SelectMySqlPackage();
			if ($isRedundancySetup) {		
				HA_InstallMySqlServer();
			} else {
				InstallMySqlServer();
			}
            InstallMySqlClient();
            ConfigureMySqlServer();
        } else {
            if ($isPeerHAInstalled) {
                &HA_StopMySQL();
                SelectMySqlPackage();
                HA_SecondInstallMySqlServer();
                InstallMySqlClient();
                HA_SecondConfigureMySqlServer();
            }
            else {
                &UpgradeMySql($mysql_installed_data_dir,$mysql_installed_log_dir);
                &GetMySQLPasswd();
				## Change MySQL root password if it is blank("")
				if($ROOT_Password eq "")
				{
					$File_Screen_Logger->info("Current MySQL root user password is empty. For security reasons, please reset the password.\n");
					SetMySQLPasswd ();
				}	
            }
        }
    }
    else    #iView only install
    {
#               SelectMySqlPackage();
#               InstallMySqlClient();
    }


    chdir $TmpDir;

    #if there is an existing bn.properties, use it to get default values
#   $status = system ("/bin/cp -pr $NextoneOpt/bn.properties $TmpDir/.");


    #setup bn.properties
    if(!$isPeerHAInstalled){
        $status = system ("chmod +x createIvmsCfg.act");
        if($typeOfInstall!=2)
        {
            $File_Screen_Logger->info("Configuring $typeOfInstallString properties ");
            $status = system ("./createIvmsCfg.act -f bn.properties -d .");
        }
    }
    ##
    ## Install Java
    ##
	if($typeOfInstall!=3){
		# In RSMGVU mode no need to install Java, as it is installed by GVU installer or will be present before hand.
		InstallJdk ();
	}
    if($typeOfInstall==2) {
		# Required in RSMLite mode only
        &InstallZip();
    }
    ## Install JBoss

	if($typeOfInstall!=3){
		InstallJBoss();
		update_time_jar
	}

	if($typeOfInstall==3) 
    {
		GetMySQLPasswd ();
	}
	
    if($typeOfInstall!=2) 
    {
         if(!$isPeerHAInstalled){
            $File_Screen_Logger->info("Configuring the parameters for MySQL Database.. ");
            print "This will take a long time..\n";
            print "Please do not abort..\n";
            $status = 1;
            my $counter = $MySqlWaitTime;
            while ($status)
            {
                $status = system ("/usr/bin/mysqladmin -u root --password=\"$ROOT_Password\" status > /dev/null 2>&1" );
                if($status ==0)
                {
                    last;
                }
                print "..";
                sleep 10;
            }
            print "\n";
            $DB_Password = &GetPasswd($DB_Username);
            chdir $TmpDir;
            if (!$HA_SecondInstall || $HA_SecondInstallInitDB eq 'y') {
                $status = system ("chmod +x db-ivms.sh");
                $status = system ("./db-ivms.sh  i /usr/bin/mysql root \"$ROOT_Password\" \"$SelfVersion\" \"$DB_Username\" \"$DB_Password\"");
                if($status)
                {
                    &FailedInstall("Unable to configure database.\n");
                }

                $File_Screen_Logger->info("Configuring the parameters for MySQL Database..done");
            }
        }

    }

    else
    {
        chdir $TmpDir;
        my $MSWUser;
        my $MSWSloanyUser = "slon";
        my $MSWPwd="";
        while(1)
        {

                $File_Screen_Logger->info("MSX needs to be installed before installing $typeOfInstallString and ");
                $File_Screen_Logger->info(" MSX should be stopped before proceeding this installation \n");
				my $mswStatusResp;
                if ( $SWMF == 0 )
				{
					$mswStatusResp =  &GetBooleanCharResponse("Please enter y to continue after stopping msx");
				} else {
					$mswStatusResp =  "y";
				}
                if($mswStatusResp eq "n")
                {
                    $File_Screen_Logger->error(" Unable to continue install \n");
                    return 1;
                }
                StopMsw();
                $MSWHostName=$ManagementIp;
                $MSWUser=$ENV{'MSWUSER'};
                $MSWPwd=$ENV{'PGPASSWORD'};
                #Changes the user to msw to match the request of msw team
                # Changed for the bug number 22828
                if($status)
                {
						my $tryAgain;
                        if ( $SWMF == 0 )
						{
							$tryAgain = &GetBooleanCharResponse("Unable to create database on the server $MSWHostName using supplied username and password\n Please make sure that the hostname, port, username and password are correct, and that the user has sufficient privileges. Do you want to try again? ");
						} else {
							$tryAgain = "n";
						}
                        if($tryAgain eq 'n')
                        {
                                &FailedInstall("Unable to create database on the server $MSWHostName using supplied username and password");
                        }
                }
 				last;
        }
            $File_Screen_Logger->info("Configuring $typeOfInstallString properties ");
            if(!(-f $libdir."/libpq.so.3") && (-f $libdir."/libpq.so.4"))
            {
                    chdir $libdir;
                    system("ln -s libpq.so.4 libpq.so.3");
            }
            chdir $TmpDir;
            if($MSWPwd)
            {
                    $status = system ("./createIvmsCfg.act -f bn.properties -d . -i . -u $MSWUser -t $MSWHostName -p $MSWPwd -w $MSWPort -m $ManagementIp");
            }
            else
            {
                    if ( $SWMF == 0 )
					{
						$status = system ("./createIvmsCfg.act -f bn.properties -d . -i . -u $MSWUser -t $MSWHostName -w $MSWPort -m $ManagementIp");
					} else {
						$status = system ("./createIvmsCfg.act -x -f bn.properties -d . -i . -u $MSWUser -t $MSWHostName -w $MSWPort -m $ManagementIp");
					}
            }
            ## Added the changed scripts for the fixing the error during sloan startup
            $status = system ("cp $TmpDir/bn.properties $NextoneOpt/.");
#               FireSlony($MSWUser);
        }


        chdir $TmpDir;
        if($typeOfInstall!=2)
        {
                if(!$isPeerHAInstalled)
                {
                    &UpdateMySqlXml($DB_Username, $DB_Password);
                }
                if($typeOfInstall != 3)
				{
					SNMPConfiguration();
				}
        }

        if(!$isPeerHAInstalled){
            ## Copy configuration files
            CreateAlarmScriptsDir ();
            CreateUIDir();
            CreateSWMDir();

            UpdateS99local ();
            CreateStreamDir();

            &CopyConfFiles($TmpDir,$JBossDir);

        }

        chdir $TmpDir;
		if($typeOfInstall!=3){
			if (!$isRedundancySetup){
				$status = system ("cp $TmpDir\/nextoneJBoss /etc/init.d/jboss");
				$status = system ("chmod +x /etc/init.d/jboss");
			}

			$status = system ("cp $TmpDir\/nextoneMySQL /etc/init.d/mysql");
			$status = system ("chmod +x /etc/init.d/mysql");
		}
		
	    if ($isRedundancySetup) {

            # save HA configuration info into $HA_DataFile
            &HA_SaveInfo();
            &HA_CopyConfigFiles();
			$status = system ("sh -c \"chkconfig mysql off\" >/dev/null 2>&1");
			$status = system ("sh -c \"chkconfig ocfs2 off\" >/dev/null 2>&1");
			$status = system ("sh -c \"chkconfig o2cb off\" >/dev/null 2>&1");
        	# start heartbeat automatically
        	&run_command("/sbin/insserv /etc/init.d/rclocal");

	}

	if (!$isRedundancySetup) {
        	# Change for the bug 22687
		if( $ENV{'$MC'} ne "SunOS" )
		{
			$status =system("/sbin/chkconfig --add jboss > /dev/null 2>&1");
			$status =system("/sbin/chkconfig --add mysql > /dev/null 2>&1");
		}
		else
		{
			$status =system("ln -s /etc/init.d/jboss /etc/rc.d/rc3.d/S99jboss");
		}
		# End Changes for Bug 22687
	}

	#copy pam for java configuration
	if($typeOfInstall!=3){
		if(&GetProcessorType()=~m/x86_64/) {
		  $status = system ("cp $TmpDir\/libjpam_64.so $OptDir/jdk/lib/amd64/libjpam.so");
		  $status = system ("unlink /lib64/libpam.so >/dev/null 2>&1");
		  $status = system ("ln -s /lib64/libpam.so.0 /lib64/libpam.so");
		} else {
		  $status = system ("cp $TmpDir\/libjpam_32.so $OptDir/jdk/lib/i386/libjpam.so");
		  $status = system ("unlink /lib/libpam.so >/dev/null 2>&1");
		  $status = system ("ln -s /lib/libpam.so.0 /lib/libpam.so");
		}
		if($RSM_OS_TYPE eq "RHEL"){
			$status = system ("cp $TmpDir\/jpam_RHEL /etc/pam.d/jpam");	
		}else{
		$status = system ("cp $TmpDir\/jpam /etc/pam.d/jpam");
		}
		
		$status = system ("chmod 666 /etc/pam.d/jpam");
	}
	
    if(!$isPeerHAInstalled){
        # create ssl certificate
        chdir "$StartDir";
        system("chmod +x ./ssl_cert.pl");
		if ( $SWMF == 0 )
		{
			$status=system("./ssl_cert.pl");
		} else {
			$status=system("./ssl_cert.pl $ManagementIp blueneon");
		}
    }
    if (!$isRedundancySetup) {
        $File_Screen_Logger->info("Starting the JBoss Server..");
        $status = system ("/etc/init.d/jboss start  > /dev/null &");
    }
    if($typeOfInstall==2)
    {
    	if($SWMF == 1)
		{
			StartMsw();
		}
		else
		{
        	$File_Screen_Logger->info("Please start msx manually..");
        }
    }

	if ($typeOfInstall == 1)
	{
		if(! ($RSM_OS_TYPE eq "RHEL" )){
		&copyFirewallConfigFile() ;
		}
	}

	if ($typeOfInstall == 1)
	{
		if(($RSM_OS_TYPE eq "RHEL" )){
		&installRadiusRPMsForRHEL() ;
		&updateMyCnfAndJbossForRHEL();
		}
	}
    print "Install Log created in  $InstallLog \n";
    if(!$isPeerHAInstalled){
        &setiVMSVersion($SelfVersion);
    }


    $File_Screen_Logger->info("Successfully installed $typeOfInstallString!!");
    GetResponse ();

	#Limiting ssh access to protocol version 2.
	if($typeOfInstall!=3){
		modifySshProtocol();
		GetResponse ();
	}	


    if ($isRedundancySetup && $isPeerHAInstalled) {
        &HA_Cleanup();
        $File_Screen_Logger->info("####################################################################################################");
        $File_Screen_Logger->info("###### PLEASE RESTART $HA_MyNodeName AND $HA_PeerNodeName AFTER FIREWALL CONFIGURATION CHANGES######");
        $File_Screen_Logger->info("####################################################################################################");
    }

	# Manage RSM System ports.Called at last to prevent any ssh disconnection
	if ($typeOfInstall == 1)
	{
		#&blockUnwantedPorts();
		&deployFirewall() ;
	}
    $status = system ("/bin/rm -rf $TmpDir");
    $FileLogger->info("exiting");

}

sub StopMsw()
{
        # Start Change msw stop
        # Check the status of the msw
        # if msw is running then stop the msw
        my $procName = "gis";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ProcExist($procName, $outFile))
        {
        $File_Screen_Logger->info("MSX is running, attempting to stop it...\n");
        my $status = system ("/usr/local/nextone/bin/iserver all stop > /dev/null 2>&1");
        my $procExists=&WaitProcExit($procName,10);
                if($procExists)
                {
                        &FailedInstall("Please Shutdown the MSX and try again ...\n");
                }
        }
        # End of Change to stop msw

}

sub StartMsw()
{
        # Change Start
        # Start the msw before exiting
        if($typeOfInstall==2)
        {
                my $procNameMsw = "gis";
                my $outFileMsw = $TmpDir."/".$procNameMsw.".proc";
                my $status = system ("/usr/local/nextone/bin/iserver all start > /dev/null 2>&1");
                $File_Screen_Logger->info("Starting the msx..");
                sleep(4);
                if(!&ProcExist($procNameMsw, $outFileMsw))
                {
                        $File_Screen_Logger->info("Unable to start msx. Please start the msx manually!!");

                }else
                {
                        $File_Screen_Logger->info("msx Started successfully!!");
                }
        }
}

##
## Upgrade package.
##

sub UpgradePackage ()
{
    my $JBossDir;
    my $resp;
    my $bkspace;
    my $status;

    my $tabUpgradeFile;
    my $routesnamesschema="empty";    
    # Must be privileged.
    CheckForSuperuser ();

    $UpgradeLog = $StartDir."\/".$UpgradeLogFile;
    $LogFile = $UpgradeLog;
    open (ERROR, "> $UpgradeLog");
    STDERR->fdopen(\*ERROR, "w");
    &CreateLogger("$UpgradeLog", "DEBUG");

    # In case of upgradation of RSM server check if updated version of RSMLinux has been installed or not
    if ($typeOfInstall==1 && $isCheckDisabled != 1 ) {
	    &checkIfCorrectRSMOSInstalled();	
    }

    # In case of upgradation of RSM server notify user to take a backup of the rsm database before proceeding with the setup
    # and exit setup if not already done so.

   
    if($typeOfInstall==1) {  #RSM upgrade
        # Are we upgrading  redundant RSM?
        &HA_GetRedundancyFlag();
        &HA_GetPeerHAInstalledFlag();
        
	 # The message to take the DB backup should not appear while upgrading the second server.
 
        if ($isRedundancySetup) { 
                 if(!$isPeerHAInstalled) { 
                        &promptUserToTakeDBBackupBeforeUpgrade(); 
                } 
        }else { 
                &promptUserToTakeDBBackupBeforeUpgrade(); 
        }  
  
        if ($isRedundancySetup) {
            print "Upgrading high availability RSM system...\n";

           # if (!-f "/etc/init.d/heartbeat") {
           #     &FailedUpgrade("Cannot find heartbeat package. Please make sure heartbeat is installed properly.");
           # }
            # Stop heartbeat if it is running
           #&HA_StopHeartbeat();
            # tell user to stop heartbeat on peer node before proceeding
           # &HA_WarnUserToStopPeerNode();
            # Stop JBoss if it is running
           # &HA_StopJBoss();
            # Stop MySQL if it is running
           # &HA_StopMySQL();

            # mount shared disk
           # print "Mounting shared disk...\n";
           # &HA_MountDisk();
           # print "Shared disk mounted\n";

            &HA_processing();
            &HA_Init();
            &HA_VerifySystem();
	     if ($isPeerHAInstalled) {
		my $peerInstallResp = &GetBooleanCharResponse("Upgrading RSM system on second server. Do you wish to 				continue ? ");	
		if ($peerInstallResp eq 'n') {
			$resp=&FailedSetupNoCleanupRequired("user abort while upgrading RSM on second server.");
		}
            }	
            &HA_StopProcesess();

            # start MySQL server so that database can be upgraded
            #$status = system ("/etc/init.d/mysql start >/dev/null 2>&1");
            #$status = system ("$HA_ResourcePath/mysql start");

        }
	}

    if($StartDir=~m/ /)
    {
        &FailedSetupNoCleanupRequired("The directory name : \'$StartDir\' contains spaces, for successfull installation, please ensure that any directory/file names do not contain spaces.");
    }

    $ivmsLiteDumpFile=$StartDir."/$ivmsLiteDumpFile";

    my $curiVMSVersion = &getiVMSVersion();

    #if ($isPeerInstalled)
    #{
    #    my $versionData =   `cat    $HA_DataFile `;
    #    $File_Screen_Logger->info("Upgrading from \n");
	#}
	#else
	#{
	    $File_Screen_Logger->info("Upgrading from $curiVMSVersion to $SelfVersion\n");
	#}

    if ($curiVMSVersion eq ""){
        &FailedSetupNoCleanupRequired("Unable to detect the current software version, not proceeding with the upgrade") ;
    }

    if (!$isPeerHAInstalled)
    {
        if (($curiVMSVersion =~m /4\.0/) && ($typeOfInstall == 1))
        {
            # for upgrade from 4.0 to 4.2 and above RSM, warn the user about the potential data loss during migration
            my $resp = &GetBooleanCharResponse("WARNING:\nWhile migrating the rating information, there is a potential for the loss of all unused rating data. Some examples of the unused rating data will be, a rate (plan) entry referring to a period that does not exist or a route entry referring to a region that does not exist. While such entries were not being used by the system anyway, there may be some cases where you would want to retain them. (For e.g., if you are in the middle of entering from rating information). Only the unused data will be lost. Do you wish to continue with the upgrade?");
            if ($resp ne "y")
            {
                &FailedUpgrade("Aborting upgrade...");
            }
        }
    }
	## Get name of tmp directory to be used during upgrade process
    &GetTempDir("upgrade");
    #system("cp -r vendor_perl $TmpDir/.  >/dev/null 2>&1");

	## Get name of mediafile
	if (!$isPeerHAInstalled)
	{
        $status = &CreateHomeDir();
        if($status){
            &FailedUpgrade("Failed to create $NextoneOpt ....\n");
        }

        if($curiVMSVersion =~m/4\.2/)
        {
            $NextoneHome="/opt/nextone/ivms";
        }

        # Create alarm scripts directory
        CreateAlarmScriptsDir ();
        CopyHomeToOpt();
    }

    ## Get name of mediafile
    &GetMediaFile();

    ##
    ## Get directory for JBoss backup
    ##

    $iVMSBakDir = $StartDir;
    $bkspace = &GetDiskUsage($iVMSBakDir);

    if ($bkspace < $MinBkSpace)
    {
        CopyOptToHome();
        &FailedUpgrade("Cannot proceed with RSM upgrade... \n"."Insufficient disk space in $iVMSBakDir.. \n"."At least $MinBkSpace kb required in $iVMSBakDir.. \n");
    }

    $iVMSBakDir = $iVMSBakDir."\/ivmsbackup-".time;
    &ExtractMediaFile();

	if ($isRedundancySetup) {
		&HA_CollectHAInfo();
		&HA_UpdateConfig();
#		&HA_SetupSshKey();
	}
	else {
		TestHostNameConsistency();
	}

    ##
    ## Upgrade JBoss
    ##
    # backup the current SSL cert

#    if(!$isPeerHAInstalled){
#	    &saveSSLCert();
#    }
    chdir $TmpDir;
    if (!$isPeerHAInstalled){
        my $JBoss42Dir = "\/opt\/nxtn\/jboss";
        my $JBoss40Dir = "\/usr\/local\/jboss";

        if($curiVMSVersion =~m/4\.0/)
        {
            $JBossDir=$JBoss40Dir;
        }
        else
        {
            $JBossDir=$JBoss42Dir;
        }

        $status = system ("rm -rf $iVMSBakDir");
        $status = system ("mkdir $iVMSBakDir");
        if( -d $JBossDir."/server/default")
        {
        	system ("mv $JBossDir/server/default/ $JBossDir/server/rsm/ >/dev/null 2>&1");
        }

        system ("rm -f $JBossDir/server/rsm/log/server.log* >/dev/null 2>&1");
        $status = system ("/bin/cp -pr $JBossDir/* $iVMSBakDir/.");
        &saveSSLCert();
        chdir $TmpDir;

        # in SWM upgrade, JDK and JBoss upgrade are handled by NxLinux
        if($typeOfInstall!=3) {
			if ( $SWMF == 0 || $PRE6 == 1)
			{
				InstallJdk();
				InstallJBoss();
				update_time_jar();
			}
			if( $PRE6 == 1) {
				 &InstallZip();
			
			}
  
		}

        chdir $TmpDir;
        if(-f $NextoneOpt."/bn.properties")
        {
                $status = system ("/bin/cp -pr $NextoneOpt/bn.properties $TmpDir/.");
        }
        elsif(-f $NextoneHome."/bn.properties")
        {
                $status = system ("/bin/cp -pr $NextoneHome/bn.properties $TmpDir/.");
        }
        print "Configuring $typeOfInstallString properties \n";

        #setup bn.properties
        $status = system ("chmod +x createIvmsCfg.act");
        if($typeOfInstall!=2)
        {
             $status = system ("./createIvmsCfg.act -d .");
        }

    }
    ##
    ## Verify if mysql process is running
    ##

    if($typeOfInstall!=2)
    {
	    if($typeOfInstall==1)
		{
		   # Upgrade path for RSM server (not RSMLite)
			&UpdateMyCnf();	
		   #my $status = system('pgrep mysqld > /dev/null 2>&1');
		   #$status = $?>>8;
		   #if($status)
		   #{
			#    &restoreOlderVersion();
				#CopyOptToHome();
				#$status = system ("cp -pr $iVMSBakDir/* $JBossDir/.");
				#&restartProcesses();
				#if (!$isRedundancySetup) {
					#question is: if mysql is not running, why even bother starting jboss?
				#    $File_Screen_Logger->info("Starting JBoss Server..\n");
				#    $status = system ("/etc/init.d/jboss start  > /dev/null &");
				#}
			 #   &FailedUpgrade("MySQL not running, cannot upgrade database..\n"."Exiting RSM upgrade ...\n"."All settings reverted to earlier version..\n"."Upgrade Log created in  $UpgradeLog \n");
			#}

			my $mysqlUpgraderesponse = 'n';

	       ## detect mysql version and force upgrade if not 5.0.90
	       $File_Screen_Logger->info("Looking for MySQL ...");
	       my $mysqlUpgraderesponse = 'n';
	       my $mysqlCurrentVersion = &getMySqlVersion();
	       if($mysqlCurrentVersion=~m/5\.0\.90/)
	        {
	           $mysqlUpgraderesponse = 'n';
	           $File_Screen_Logger->info("Detected: $mysqlCurrentVersion");
	           $File_Screen_Logger->info("Current MySql is up to date");
	       }else
	       {
	           $mysqlUpgraderesponse = 'y';
	           $File_Screen_Logger->info("upgrading MySQL to 5.0.90 ...");
	       }

	       ## Update my.cnf. Set the binding address to 127.0.0.1
	       #updateMyCnf($MySqlProcStr);

			if(&GetProcessorType()=~m/x86_64/)
			{
					if(! -f $libmysqlold64)
					{
							&FailedUpgrade($libmysqlold64." was not found");
					}
					$status=system("unzip -n -qq $libmysqlold64 -d /");
					if($status)
					{
							$FileLogger->warn("Unable to extract $libmysqlold64 , some functionalities, eg upgraderatingdata, upgradecapabilities might not work");
					}
			}
			else
			{
					if(! -f $libmysqlold32)
					{
							&FailedUpgrade($libmysqlold32." was not found");
					}
					$status=system("unzip -n -qq $libmysqlold32 -d /");
					if($status)
					{
							$FileLogger->warn("Unable to extract $libmysqlold32 , some functionalities, eg upgraderatingdata, upgradecapabilities might not work");
					}
			}
		   if($mysqlUpgraderesponse eq 'y')
		   {
				my $procName = "$MySqlProcStr";
				my $outFile = $TmpDir."/".$procName.".proc";
				if(&ProcExist($procName, $outFile))
				{
					stopMySQL($procName);
				}

	            chdir $TmpDir;
	            SelectMySqlPackage();
	            $File_Screen_Logger->info("Upgrading $MySQLServerRpm .. ");
	            if ( ! -f $MySQLServerRpm)
	            {
	                 &FailedUpgrade("Unable to find $MySQLServerRpm \n");
	            }
	            $status=0;
	            $status = system ("rpm -U --force --nodeps $MySQLServerRpm");
	            my $rpmIns = `rpm -qa | grep MySQL-server-enterprise`;
	            chomp($rpmIns);
	            if(!($MySQLServerRpm=~m/$rpmIns/))
	            {
	                &FailedUpgrade("Unable to install MySql server\n");
	            }

	            $File_Screen_Logger->info("Upgrading $MySQLServerRpm ..done ");

	            if ( ! -f $MySQLClientRpm)
	            {
	                 &FailedUpgrade("Unable to find $MySQLClientRpm \n");
	            }

	            print "Upgrading MySQL Client..   \n";

	            $status = system ("rpm -U --force --nodeps $MySQLClientRpm");
	            my $rpmIns = `rpm -qa | grep MySQL-client-enterprise`;
	            chomp($rpmIns);
	            if(!($MySQLClientRpm=~m/$rpmIns/))
	            {
	                &FailedUpgrade("Unable to install MySql client\n");
	            }
	            if(!(-f "$OptNxtn/mysql/data") && !(-d "$OptNxtn/mysql/data"))
	            {
	                my $curMysqlDat=abs_path("/mysqldata");
	                if($curMysqlDat)
	                {
	                    system("mkdir -p $OptNxtn/mysql");
	                    system("ln -s $curMysqlDat $OptNxtn/mysql/data");
	                }
	            }
	            if(!(-f "$OptNxtn/mysql/log") && !(-d "$OptNxtn/mysql/log"))
	            {
	                my $curMysqlLog=abs_path("/mysqllogs");
	                if($curMysqlLog)
	                {
	                    system("mkdir -p $OptNxtn/mysql");
	                    system("ln -s $curMysqlLog $OptNxtn/mysql/log");
	                }
	            }


	            if(!(-f "$OptNxtn/mysql/data") && !(-d "$OptNxtn/mysql/data"))
	            {
	                    my $curMysqlDat=abs_path("/mysqldata");
	                    if($curMysqlDat)
	                    {
                            system("mkdir -p $OptNxtn/mysql");
                            system("ln -s $curMysqlDat $OptNxtn/mysql/data");
	                    }
	            }
	            if(!(-f "$OptNxtn/mysql/log") && !(-d "$OptNxtn/mysql/log"))
	            {
                    my $curMysqlLog=abs_path("/mysqllogs");
                    if($curMysqlLog)
                    {
                    	system("mkdir -p $OptNxtn/mysql");
                        system("ln -s $curMysqlLog $OptNxtn/mysql/log");
                    }
	            }
	            $File_Screen_Logger->info("Upgrading MySQL Client..done   ");

	        }
	        # update my.cnf
	        ModifyMyCnf();
	        if (-f "/etc/my.cnf")
	        {
	           $status = system ("mv /etc/my.cnf /etc/my.cnf.bak");
	        }
	        $status = system ("cp my.cnf /etc/my.cnf");        

	        #$File_Screen_Logger->info("Restarting MySQL server...");
	        #$status = system ("/etc/init.d/mysql start >/dev/null 2>&1");
		}
        ##
        ## Upgrade database
        ##
        if(!$isPeerHAInstalled){
            #if($isRedundancySetup)
            #{
            #    &run_command("$HA_ResourcePath/mysql start");
            #}else{
                &run_command("/etc/init.d/mysql start");
            #}
            $resp = "";
            my $pw_cnt = 0;
            while ($pw_cnt < 3)
            {
                print "Enter password for MySQL user \'root\':";
                $status = system ("stty -echo");
                chop($resp = <>);
                $status = system ("stty echo");
                print " \n";
                $ROOT_Password = $resp;
                $status = system ("/usr/bin/mysqladmin -u root --password=\"$ROOT_Password\" status > /dev/null 2>&1" );
                $status=($? >> 8);
                if($status)
                {
                    $pw_cnt = $pw_cnt +1;
                    print "Password for MySQL user \'root\' is incorrect \n";
                }
                if(!$status)
                {
                    #last;
                    $pw_cnt = 4;
                }
            }
	    ## Change MySQL root password if it is blank("")
	    if($ROOT_Password eq "")
	    {
		    print "Current MySQL root user password is empty. For security reasons, please reset the password.\n";
	        SetMySQLPasswd ();
	    }

            if ($status)
            {
                CopyOptToHome();
                $status = system ("cp -pr $iVMSBakDir/* $JBossDir/.");
                &restartProcesses();
                #if (!$isRedundancySetup) {
                #    $File_Screen_Logger->info("Starting JBoss Server..");
                #    $status = system ("/etc/init.d/jboss start  > /dev/null &");
                #}
                &FailedUpgrade("Exiting upgrade ...\nAll settings reverted to earlier version..\nUpgrade Log created in  $UpgradeLog \n");
            }
            if (!($curiVMSVersion eq $SelfVersion)) {
                CheckDupMswIp ("root", $ROOT_Password, $TmpDir, $iVMSBakDir, $UpgradeLog);
        # Providing handling for hr tables during upgrade.This code will execute only if the hrlogs table exists before upgrade
        	$FileLogger->info("Starting to drop tables which exist in hrlogs table");
        	&deleteHRTables();        
        	$FileLogger->info("All hr tables except hrlogs are dropped successfully");
		# Changes corresponding to Wavecrest 142826
			chdir $StartDir;
			$File_Screen_Logger->info("Starting Migratecdrtohrdata.pl");
			$status = system("./migratecdrtohrdata.pl -User=root -Password=$ROOT_Password");
      		$File_Screen_Logger->info("completed executing Migratecdrtohrdata.pl");
				
                ##
                ## Create upgrade database file
                ##
                chdir $TmpDir;
                my $dummybn="new_dummy_bn".time."";
                system("sed \"s/\%DBNAME\%/$dummybn/g;\" $TmpDir/bn.sql>installtables.sql");

                system("mysql -uroot --password=$ROOT_Password <installtables.sql");

                if($curiVMSVersion =~m/4\.0/)
                {
                    chdir $StartDir;
                    $status=system("chmod +x createtables.pl");
                    if(!defined($ROOT_Password))
                    {
                        $status=system("./createtables.pl -user=root -newdb=$dummybn");
                    }
                    else
                    {
                        $status=system("./createtables.pl -user=root -password=$ROOT_Password -newdb=$dummybn");
                    }
                }

                chdir $TmpDir;
                open(DROPDUMMY,">Dropdummy.sql");
                print DROPDUMMY "drop database if exists $dummybn";
                close(DROPDUMMY);

                $File_Screen_Logger->info("Upgrading Database...");
		#Database to be backed up before starting upgrade operation.(PRS 135635)
                #Databackup();
                if (($curiVMSVersion =~m /4\.0/) && ($typeOfInstall == 1))
                {
                    chdir $StartDir;
                    system("mysql -uroot --password=$ROOT_Password -f <gettime.sql >/dev/null 2>&1");
                    system("chmod +x upgraderatingdata.pl");
                    if($ROOT_Password eq "")
                    {
                        $status=system("./upgraderatingdata.pl -user=root -dbname=bn -newdb=$dummybn");
                    }
                    else
                    {
                        $status=system("./upgraderatingdata.pl -user=root -password=$ROOT_Password  -dbname=bn -newdb=$dummybn");
                    }

                    if($status)
                    {
                        chdir $TmpDir;
                        $status = system("/usr/bin/mysql  --user=root --password=\"$ROOT_Password\" < Dropdummy.sql");
                        &FailedUpgrade("Upgrade of rating data failed");
                    }
                    my $regionsInMemory = &upgradeRegionsInMemoryTable();
                }
                chdir $StartDir;
                if($curiVMSVersion =~m/4\.0/)
                {
                    $status=system("chmod +x upgradeActions.pl");
                    if(defined($ROOT_Password))
                    {
                            $status=system("./upgradeActions.pl -User=root -password=$ROOT_Password -ver=$SelfVersion");
                    }
                    else
                    {
                            $status=system("./upgradeActions.pl -User=root -ver=$SelfVersion");
                    }
                }


                #added data for Vnet, Subnets, triggers and periods
                if($curiVMSVersion =~m/4\.0/)
                {
                    chdir $StartDir;
                    $status=system("chmod +x generateUpgradeSQLScript.pl");
                    if(!defined($ROOT_Password))
                    {
                        $status=system("./generateUpgradeSQLScript.pl -user=root");
                    }
                    else
                    {
                        $status=system("./generateUpgradeSQLScript.pl -user=root -password=$ROOT_Password");
                    }
                }

                # Update zone in Endpoint to "" for single partition system.
                if($curiVMSVersion =~m/4\.0/)
                {
                    chdir $StartDir;
                    $status=system("chmod +x upgradeZoneInEPForSinglePartition.pl");
                    if(!defined($ROOT_Password))
                    {
                         $status=system("./upgradeZoneInEPForSinglePartition.pl -user=root");
                    }
                    else
                    {
                         $status=system("./upgradeZoneInEPForSinglePartition.pl -User=root -Password=$ROOT_Password");
                    }
                }

                
                 $cdrTableListFile=$TmpDir."/".$cdrTableListFile;
                 # Added to fix the upgrade of routes table
                 my $routesStatus=&upgradeRoutesTable();
                 if($routesStatus)
                 {
                    $File_Screen_Logger->error("Unable to upgrade routes table unable to continue upgrade");
                    return 1;
                 }
                 # Script to backup Endpoints subnetip and subnetmask for later conversion to 4.3. See Bug 51207
                 if($curiVMSVersion =~m/4\.0/)
                 {

                      my $status = system("mysql --user=\"root\" --password=\"$ROOT_Password\" bn -e \"drop table if exists ep_upgrade_bakup\"");
                    my $status = system("mysql --user=\"root\" --password=\"$ROOT_Password\" bn -e \"create table ep_upgrade_bakup select endpointid, subnetip,subnetmask from endpoints\"");
                 }

                 createDBUpgradeScr($curiVMSVersion, $SelfVersion, $cdrTableListFile,$dummybn);
                 createDBDowngradeScr($curiVMSVersion, $SelfVersion, $cdrTableListFile,$dummybn);
                 
                 my $tabUpgradeSqlFile = $TmpDir."\/".$UPGRADEFILEPREFIX."-".$curiVMSVersion."-".$SelfVersion.".sql";

                 my $cdrTableSqlFile = $TmpDir."\/".$CDRTABLESQL."-".$curiVMSVersion."-".$SelfVersion.".sql";
                 my $cdrTableInfFile = $TmpDir."\/".$CDRTABLESQL."-".$curiVMSVersion."-".$SelfVersion.".inf";
                 #copy the generated file into install dir for debugging
                 system ("cp $tabUpgradeSqlFile $StartDir");
                 if (!-f $tabUpgradeSqlFile)
                 {
                    &restoreOlderVersion();
                    #CopyOptToHome();
                    #$status = system ("cp -pr $iVMSBakDir/* $JBossDir/.");
                    #if (!$isRedundancySetup) {
                    #    $File_Screen_Logger->info("Starting JBoss Server..");
                    #    $status = system ("/etc/init.d/jboss start  > /dev/null &");
                    #}
                    print "Upgrade Log created in  $UpgradeLog \n";
                    &FailedUpgrade("Upgrade from $curiVMSVersion to $SelfVersion is not supported \n"."All settings reverted to earlier version..\n");
                 }

                 chdir $TmpDir;
                 $status = system ("chmod +x db-ivms.sh");
                 $status = system ("./db-ivms.sh  u /usr/bin/mysql root \"$ROOT_Password\" \"$SelfVersion\" \"$DB_Username\" \"$DB_Password\" \"$curiVMSVersion\" ");
                 $runDownGradeSQLOnFailure=1;
                 if($status)
                 {
                    &FailedUpgrade("Unable to configure database.\n");
                 }

                 # Script to update Endpoints subnetip and subnetmask. See Bug 51207
                 if($curiVMSVersion =~m/4\.0/)
                 {
                    my $status = system("mysql --user=\"root\" --password=\"$ROOT_Password\" bn -e \"update endpoints,ep_upgrade_bakup set endpoints.subnetmask=case when ep_upgrade_bakup.subnetmask>=0 then ep_upgrade_bakup.subnetmask else 4294967296+ep_upgrade_bakup.subnetmask end where endpoints.id=ep_upgrade_bakup.endpointid\"");
                    my $status = system("mysql --user=\"root\" --password=\"$ROOT_Password\" bn -e \"update endpoints,ep_upgrade_bakup set endpoints.subnetip=case when ep_upgrade_bakup.subnetip>=0 then ep_upgrade_bakup.subnetip else 4294967296+ep_upgrade_bakup.subnetip end where endpoints.id=ep_upgrade_bakup.endpointid\"");
                    my $status = system("mysql --user=\"root\" --password=\"$ROOT_Password\" bn -e \"drop table if exists ep_upgrade_bakup\"");
                 }

                 # After upgrade, errors table should have new error codes and error descriptions. Support provided as part of PR#168650.
                 chdir $StartDir;
                 system("chmod +x updateErrors.pl");
                 if($ROOT_Password eq "")
                 {
                    $status=system("./updateErrors.pl -user=root ");
                 }
                 else
                 {
                    $status=system("./updateErrors.pl -user=root -password=$ROOT_Password");
                 }
                    
                 if($status)
                 {
                    $File_Screen_Logger->error("Unable to update errors table");
                 }
                 
                 chdir $StartDir;
                 system("chmod +x upgradecapabilities.pl");
                 if($ROOT_Password eq "")
                 {
                    $status=system("./upgradecapabilities.pl -user=root -oldversion=$curiVMSVersion -newversion=$SelfVersion");

                 }
                 else
                 {
                    $status=system("./upgradecapabilities.pl -user=root -password=$ROOT_Password -oldversion=$curiVMSVersion -newversion=$SelfVersion");

                 }

                 system("chmod +x upgradeevents.pl");
                 if($curiVMSVersion =~m/4\.0/)
                 {
                    if($ROOT_Password eq "")
                    {
                        $status=system("./upgradealarms.pl -user=root ");
                        $status=system("./upgradeevents.pl -user=root ");
                    }
                    else
                    {

                        $status=system("./upgradealarms.pl -user=root -password=$ROOT_Password");
                        $status=system("./upgradeevents.pl -user=root -password=$ROOT_Password");
                    }
                    $status = system("/usr/bin/mysql  --user=root --password=\"$ROOT_Password\" < /var/tmp/dataMigrationSQLScript.sql"); ##
                    system("rm -rf /var/tmp/dataMigrationSQLScript.sql");
                }
                if($curiVMSVersion =~m/4\.2/)
                {
                    if($ROOT_Password eq "")
                    {
                        $status=system("./upgradeevents.pl -user=root ");
                    }
                    else
                    {
                        $status=system("./upgradeevents.pl -user=root -password=$ROOT_Password");
                    }
                }
		
		#Script to update routes_partition table to add index on carrier column
		system("chmod +x alterTableForIndex.pl");
		if($ROOT_Password eq "")
		{
			$status=system("./alterTableForIndex.pl -table=routes -column=Carrier -User=root -addindextomaintable=false");
		}
		else
		{			
			$status=system("./alterTableForIndex.pl -table=routes -column=Carrier -User=root -Password=$ROOT_Password -addindextomaintable=false");
		}
                chdir $TmpDir;
                $File_Screen_Logger->info("Begin to upgrade CDR Tables...\n");
                if ( -f $cdrTableListFile && -f $cdrTableInfFile)
                {

                    upgradeCdrTables($cdrTableInfFile, $cdrTableListFile, $CDRTABLESQL, $cdrTableSqlFile);
                    $status = system("/usr/bin/mysql  --user=root --password=\"$ROOT_Password\"  < $cdrTableSqlFile");
                }

                if($status)
                {
                   $cdrTableSqlFile = $TmpDir."\/".$CDRTABLESQL."-".$SelfVersion."-".$curiVMSVersion.".sql";
                   $cdrTableInfFile = $TmpDir."\/".$CDRTABLESQL."-".$SelfVersion."-".$curiVMSVersion.".inf";
                   upgradeCdrTables($cdrTableInfFile, $cdrTableListFile, $CDRTABLESQL, $cdrTableSqlFile);
                   $status = system("/usr/bin/mysql  -f --user=root --password=\"$ROOT_Password\" < $cdrTableSqlFile");
                   &FailedUpgrade("Error in upgrading cdr tables");
                }
								$File_Screen_Logger->info("Upgrade CDR Tables ...done!\n");
                # Handles data migration from earlier versions
                DBDataPostMigration($curiVMSVersion, $SelfVersion, $dummybn);
		
                # drop the dummy database
                chdir $TmpDir;
                $status = system("/usr/bin/mysql  --user=root --password=\"$ROOT_Password\" < Dropdummy.sql");
                CreateStreamDir();
                $File_Screen_Logger->info("Update the Database ...done!\n");
            }
            else { #for if (!($curiVMSVersion eq $SelfVersion))
                #bypass the database upgrade if we upgrade from the same version
                print "RSM database is up to date.\n";
            }
        }
    }
    else
    {
           # Upgrade path for RSMLite
        chdir $TmpDir;
        my  $MSWHostName=$ManagementIp;
        my  $MSWUser=$ENV{'MSWUSER'};
        my  $MSWPwd=$ENV{'PGPASSWORD'};
        $File_Screen_Logger->info("Configuring $typeOfInstallString properties ");
        if(!(-f $libdir."/libpq.so.3") && (-f $libdir."/libpq.so.4"))
        {
               chdir $libdir;
               system("ln -s libpq.so.4 libpq.so.3");
        }
        chdir $TmpDir;
        # in SWM upgrade, $MSWPwd is not set
        if($MSWPwd)
        {
                $status = system ("./createIvmsCfg.act -f bn.properties -d . -i . -u $MSWUser -t $MSWHostName -p $MSWPwd -w $MSWPort -m $ManagementIp -g .");
        }
        else
        {
            # in SWM upgarde, passing FF flag of '-x' to createIvmsCfg.act, which has modified updateMswInfo accordingly
            if ( $SWMF == 0 )
            {
                $status = system ("./createIvmsCfg.act -f bn.properties -d . -i . -u $MSWUser -t $MSWHostName -w $MSWPort -m $ManagementIp -g .");
            } else {
                $status = system ("./createIvmsCfg.act -f bn.properties -d . -i . -u $MSWUser -t $MSWHostName -w $MSWPort -m $ManagementIp -g . -x");
            }
        }
    }

    if(!$isPeerHAInstalled){
        CreateUIDir();
        CreateSWMDir();
    }
    if($typeOfInstall==1) {
        SNMPConfiguration();
    }
    # we are not using $JBossDir since the location of JBoss directory is changing from /usr/local/jboss to $OptNxtn/jboss

    # in case of Fast Forward installed JBoss, the /opt/nxtn/jboss/server is a link.
    # as a result, the 'server' directory under $iVMSBakDir is really a link.
    # We need to make a copy of mysql-ds.xml before copying from the $TmpDir.
    my $ff_mysqlxml = $TmpDir."/ff_mysqlxml.old";
    my $cpstatus;
    my $ivmsdbpswd;	
    if($typeOfInstall==1) {
        if(!$isPeerHAInstalled){
            #This file is only required in RSM server, and was being copied in RSM Lite upgrade also, so moving it to server block.
            $status = system ("cp $iVMSBakDir/server/rsm/deploy/mysql-ds.xml $JBossDir/server/rsm/deploy/. ");
            my $old_mysqlxml;
            if($curiVMSVersion =~m/4\.0/) {
                $old_mysqlxml = $UsrDir."/jboss/server/rsm/deploy/mysql-ds.xml";
            }
            else {
                $old_mysqlxml = $OptDir."/jboss/server/rsm/deploy/mysql-ds.xml";
            }
            $cpstatus = system("cp $old_mysqlxml $ff_mysqlxml");
        }
    }

    if(!$isPeerHAInstalled){
        &UpgradeConfFiles ($iVMSBakDir);
        &CopyConfFiles($TmpDir, $OptDir."/jboss");
        if($typeOfInstall==1)
        {
			if((!$cpstatus) && (-f $ff_mysqlxml)){
            	&upgradeMySqlXml($OptDir."/jboss/server/rsm/deploy/mysql-ds.xml",$ff_mysqlxml,"$TmpDir/mysql-ds.xml");
			}
			else
			{
				$File_Screen_Logger->warn("MySql configuration not found in RSM, creating new configuration.");
				while (1) {
					print "Enter database password for RSM (user - ivms):";
					system ("stty -echo");
					chop($ivmsdbpswd = <>);
					system ("stty echo");
					print " \n";			
					$status = system ("/usr/bin/mysqladmin -u ivms --password=\"$ivmsdbpswd\" status > /dev/null 2>&1" );
                	$status=($? >> 8);
                	if ($status)
                	{
	                	$File_Screen_Logger->error("Sorry, either incorrect password, or mysql is not running\n");
		  		    	my $newPwdChoice = &GetBooleanCharResponse ("Do you want to enter a new password for the user? ");
     					if($newPwdChoice eq "n")
     					{
							next;
     					}                        		
						else
						{
					 		$ivmsdbpswd=&GetPasswd($DB_Username);
							my $usrStatus=&changeIvmsUserPasswd($ivmsdbpswd);			
                			if($usrStatus)
                			{
                    			&FailedUpgrade("unable to configure RSM user for database.\n");
                			}
                			else							{
								$File_Screen_Logger->info("Changed password of RSM user for database.");
							}
							last;
						}
                	}
                	else					{
						last;
        	        }
				}
				&UpdateMySqlXml($DB_Username, $ivmsdbpswd);
				system ("cp $TmpDir/mysql-ds.xml $JBossDeployDir/.");
			}
        }
        #$status = system ("cp $iVMSBakDir/server/rsm/deploy/mysql-ds.xml $JBossDir/server/rsm/deploy/. ");
        if (!$isRedundancySetup){
            $status = system ("cp $TmpDir\/nextoneJBoss /etc/init.d/jboss");
            $status = system ("chmod +x /etc/init.d/jboss");
            $status = system ("chmod +x /etc/init.d/mysql");
        }
        my $routesNamesStatus;
		if($typeOfInstall!=2) {
			cleanPeriodsBreakdownTable();
			UpdateVersionField("root",$ROOT_Password);
            my $routesnamesTableExistsInBn = checkForRoutesnamesTableExistence("bn",$ROOT_Password);
			if($routesnamesTableExistsInBn==0 && !($routesnamesschema eq "empty")){
				$routesNamesStatus=&createRoutesNamesTable($routesnamesschema);
			   	if($routesNamesStatus)
         		{
		    		$File_Screen_Logger->error("Unable to create routesnames table . Unable to continue upgrade");
            		return 1;
         		}
            }
		}
    }
    $status = system ("cp $TmpDir\/nextoneMySQL /etc/init.d/mysql");
    $status = system ("chmod +x /etc/init.d/mysql");

	if ($isRedundancySetup)
	{
	    &HA_StopMySQL();
	    &HA_CopyConfigFiles();
		# unlink /etc/rc.d/rcN.d/mysql and jboss script
		#$status = system ("sh -c \"chkconfig mysql off\" >/dev/null 2>&1");
		#$status = system ("sh -c \"chkconfig jboss off\" >/dev/null 2>&1");

		# create link /etc/rc.d/rcN.d/heartbeat -> /etc/init.d/heartbeat
		$status = &run_command ("sh -c \"chkconfig heartbeat off\"");
		$status = &run_command ("sh -c \"chkconfig ocfs2 off\"");
		$status = &run_command ("sh -c \"chkconfig o2cb off\"");
		#$status = &run_command ("sh -c \"chkconfig heartbeat on\"" );
		$status = &run_command("/sbin/insserv /etc/init.d/rclocal");
		# save HA configuration info into $HA_DataFile
		if(!$isPeerHAInstalled)
		{
		    &HA_SaveInfo();
        }
	}

	if (!$isRedundancySetup) {
		# Change for the bug 22687
		if( $ENV{'$MC'} ne "SunOS" )
		{
			$status =system("/sbin/chkconfig --add jboss > /dev/null 2>&1");
            		$status =system("/sbin/chkconfig --add mysql > /dev/null 2>&1");			
		}
		else
		{
			$status =system("/bin/cp /etc/init.d/jboss /etc/rc3.d/S99jboss");
		}
		# End Changes for Bug 22687
	}

	if($typeOfInstall!=3) {	
		if($curiVMSVersion =~m/4\.0/)
		{
			#The variable may be unexported, so not using ENV
			my $osType = `echo \$MACHTYPE`;
			chomp($osType);
			if(!defined($osType) || !($osType =~m/redhat/i || $osType =~m/suse/i))
			{
				$File_Screen_Logger->warn("Unable to determine oeprating system");
				my $resp = &GetBooleanCharResponse("Are you using RedHat Linux?");
				if($resp eq "y")
				{
					$osType = "redhat";
				}
			}
			if($osType =~m/redhat/)
			{
				if(-f "/etc/sysconfig/iptables")
				{
					system ("/etc/init.d/iptables stop");
					system ("mv /etc/sysconfig/iptables /etc/sysconfig/iptables.old");
					open (FIN,"</etc/sysconfig/iptables.old");
					open (FOUT,">/etc/sysconfig/iptables");
					while(my $line = <FIN>)
					{
						$line =~s/8080/80/;
						$line =~s/8443/443/;
						# added port for 28028 fix
						if($line =~m /REJECT/){
							print FOUT "-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 8081 -j ACCEPT\n";
						}
						# For 4.2 we don't have to open the 1010x ports
						if($line !~m /--dport\s+1010/) {
							print FOUT $line;
						}
						#print FOUT $line;
					}
					close (FIN);
					close (FOUT);
					system("/etc/init.d/iptables start");
				}
				else
				{
					$File_Screen_Logger->warn("Could not find the file /etc/sysconfig/iptables, please update your iptables configuration manually!");
				}
			}
		}
	}
    UpdateS99local ();

	#copy pam for java configuration
	if($typeOfInstall!=3) {	
		if(&GetProcessorType()=~m/x86_64/) {
		  $status = system ("cp $TmpDir\/libjpam_64.so $OptDir/jdk/lib/amd64/libjpam.so");
		  $status = system ("unlink /lib64/libpam.so >/dev/null 2>&1");
		  $status = system ("ln -s /lib64/libpam.so.0 /lib64/libpam.so");
		} else {
		  $status = system ("cp $TmpDir\/libjpam_32.so $OptDir/jdk/lib/i386/libjpam.so");
		  $status = system ("unlink /lib/libpam.so >/dev/null 2>&1");
		  $status = system ("ln -s /lib/libpam.so.0 /lib/libpam.so");
		}
		$status = system ("cp $TmpDir\/jpam /etc/pam.d/jpam");
		$status = system ("chmod 666 /etc/pam.d/jpam");
	}
	
    # in SWM upgarde, no question be asked but restore SSL cert always
    my $choice;
    if(!$isPeerHAInstalled)
    {
        if ( $SWMF == 0 )
        {
            # for upgrade, we ask if user wants to keep the old SSL cert
            while (1) {
                $File_Screen_Logger->info("Do you want to keep the current SSL certificate? (yes/no) [yes]:  \n");
                $choice = <>;
                chomp($choice);
                if($choice eq "") {
                    $choice = "yes";
                    last;
                }
                elsif ($choice eq "yes") {
                    last;
                }
                elsif ($choice eq "no") {
                    last;
                }
                else {
                    next;
                }
                }
        } else {
            $choice = "yes";
        }

        if ($choice eq "yes") {
            &restoreSSLCert();
        }
        else {
            # create ssl certificate
            chdir $StartDir;
            system("chmod +x ssl_cert.pl");
            $status=system("./ssl_cert.pl");
        }

    }

	if (!$isRedundancySetup) {
		print "Starting JBoss Server..\n";
		$status = system ("/etc/init.d/jboss start  > /dev/null &");
	}

	if ($typeOfInstall == 1 && !($curiVMSVersion =~m/4\.0/))
	{
		&copyFirewallConfigFile();
	}
	if ($typeOfInstall == 1 && $curiVMSVersion =~m/5\./)
	{
		&checkPAMUsersData();
	}	
    $File_Screen_Logger->info("Successfully upgraded $typeOfInstallString from $curiVMSVersion to $SelfVersion !! ");
    if(!$isRedundancySetup || $isPeerHAInstalled)
    {
        &setiVMSVersion($SelfVersion);
    }

	#if ($isRedundancySetup) {
		# unmount shared disk
	#	&HA_UnMountDisk();
	#}

    print "Upgrade Log created in  $UpgradeLog \n";
    $File_Screen_Logger->info("$curiVMSVersion JBoss backed up in $iVMSBakDir ");


    if ($isRedundancySetup && $isPeerHAInstalled) {
        &HA_Cleanup();
        $File_Screen_Logger->info("####################################################################################################");
        $File_Screen_Logger->info("###### PLEASE RESTART $HA_MyNodeName AND $HA_PeerNodeName AFTER FIREWALL CONFIGURATION CHANGES######");
        $File_Screen_Logger->info("####################################################################################################");
    }


    if ( $SWMF == 0 )
    {
        GetResponse ();
    }
	#Limiting ssh access to protocol version 2.
	if($typeOfInstall!=3){
		modifySshProtocol();
		if ( $SWMF == 0 ){
			GetResponse ();
		}
	}

	# Manage RSM System ports.Called at last to prevent any ssh disconnection  
	if ($typeOfInstall == 1 && !($curiVMSVersion =~m/4\.0/))
	{
		#&blockUnwantedPorts();
		&deployFirewall();
	}
    #Clean up...
    $status = system ("rm -rf $TmpDir");
    $FileLogger->info("exiting");

}



##
## Migrate NARS to RSM
##


sub MigrateNars ()
{
        $FileLogger->info("entering");


## stop tomcat
## call install RSM
## upgrade nars db to 2.06c3
## run bnmigrate
## read web.xml to bn.properties
## read web.xml to mysql-ds.xml
$FileLogger->info("exiting");

}


sub updateMyCnf(){
    my ($mysqlprocName) = @_;
    my $inFile = "/etc/my.cnf";
    my $outFile ="/etc/my.cnf.new";
    system ("cp /etc/my.cnf /etc/my.cnf.orig");

    open(FIN, "<$inFile");
    open(FOUT, ">$outFile");
    my $isMyCnfUpdate = 'y';
    while(my $line  = <FIN>)
    {
        #if my.cnf already contains bind_address do not update the file
       if($line =~m/bind_address/){
            $isMyCnfUpdate  =   'n';
            last;
            $File_Screen_Logger->info("my.cnf already contains binding address, do not update my.cnf\n");
       }
       print FOUT $line;
       if($line =~m/\[mysqld\]/){
         print FOUT "bind_address    = 127.0.0.1 \n";
       }


    }

    close (FIN);
    close (FOUT);
    if($isMyCnfUpdate eq 'y'){
        $File_Screen_Logger->info("Updated my.cnf with binding address\n");
        system ("cp /etc/my.cnf.new /etc/my.cnf");
        stopMySQL($mysqlprocName);
    }
    system ("rm /etc/my.cnf.new ");
}

sub stopMySQL(){
    my ($procName) = @_;
    if ($isRedundancySetup){
        &HA_StopMySQL();
    }else{
        $File_Screen_Logger->info("MySql is running, attempting to stop MySql\n");
        my $status =system ("/etc/init.d/mysql stop");
        my $procExists=&WaitProcExit($procName,4);
        if($procExists)
        {
                &FailedUpgrade("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");
        }
    }
}

##
##Get currently installed version of MySql
##
sub getMySqlVersion()
{
        $FileLogger->info("entering");
        my $filetmp = $TmpDir."\/mysqlversion";
	my $mysqlversion= "0.0";
	if($RSM_OS_TYPE eq "RHEL")
	{
	$mysqlversion= "";
	}
	if ( -f "/usr/bin/mysqladmin")
	{
           my $status = system("mysqladmin -V > $filetmp");
           $mysqlversion = getStringFrmFile($filetmp);
	}
        $FileLogger->info("exiting");
        return $mysqlversion;
}

sub getStringFrmFile()
{
        my ($filename) = @_;
        open FIN, "<$filename";
        my $line = <FIN>;
        return $line;
}

##
## Create DB schema upgrade script
##

sub createDBUpgradeScr ()
{
        my ($oldVersionString, $newVersionString, $cdrTableListFile,$dummybn) = @_;
        my $upgradeInfFile = $TmpDir."\/".$UPGRADEFILEPREFIX.".inf";
        my $upgradeSqlFile = $TmpDir."\/".$UPGRADEFILEPREFIX."-".$oldVersionString."-".$newVersionString.".sql";
        my $upgradeSqlFileTmp = $TmpDir."\/".$UPGRADEFILEPREFIX."-".$oldVersionString."-".$newVersionString.".sql".".tmp";
        my $upgradeCdrTableInfFileTmp = $TmpDir."\/".$CDRTABLESQL."-".$oldVersionString."-".$newVersionString.".inf".".tmp";
        my $upgradeCdrTableInfFile = $TmpDir."\/".$CDRTABLESQL."-".$oldVersionString."-".$newVersionString.".inf";
        my $upgradeInfFile = $TmpDir."\/".$UPGRADEFILEPREFIX.".inf";

        my $status;
        my $line;
        chdir $TmpDir;
        system("chmod +x consolidatedalter.pl");
#       print("./consolidatedalter.pl -user=root -password=$ROOT_Password -version=$oldVersionString -source=bn -target=$dummybn -conversiontype=upgrade -props=upgrade.properties -spe=upgrade-specials.inf -outfile=$upgradeInfFile");
#       exit;
        if($ROOT_Password eq "")
        {
                $status=system("./consolidatedalter.pl -user=root -version=$oldVersionString -source=bn -target=$dummybn -conversiontype=upgrade -props=upgrade.properties -spe=upgrade-specials.inf -outfile=$upgradeInfFile");
        }
        else
        {
                $status=system("./consolidatedalter.pl -user=root -password=$ROOT_Password  -version=$oldVersionString -source=bn -target=$dummybn -conversiontype=upgrade -props=upgrade.properties -spe=upgrade-specials.inf -outfile=$upgradeInfFile");
        }
        if($status)
        {
                &FailedUpgrade("Unable to generate upgrade script");
        }


# check to see if summary schema is changed, we would like to truncate data
# first as alter big table may take long time

       open(GREP, "grep 'ALTER TABLE `cdrsummary`' $upgradeInfFile |");
        my $grep = <GREP>;
        close GREP;
        my $truncate=0;
        if($grep =~m/cdrsummary/) {
                print "Schema is changed for cdrsummary, truncating all records from the table ... \n";
                $status=system("mysql -uroot --password=$ROOT_Password -e'truncate bn.cdrsummary'");
                $truncate=1;
        }
        
        open(GREP, "grep 'ALTER TABLE `sellsummary`' $upgradeInfFile |");
        $grep = <GREP>;
        close GREP;
        if($grep =~m/sellsummary/) {
                print "Schema is changed for sellsummary, truncating all records from the table ... \n";
                $status=system("mysql -uroot --password=$ROOT_Password -e'truncate bn.sellsummary'");
                $truncate=1;
        }
        
        open(GREP, "grep 'ALTER TABLE `buysummary`' $upgradeInfFile |");
        $grep = <GREP>;
        close GREP;
        if($grep =~m/buysummary/) {
                print "Schema is changed for buysummary, truncating all records from the table ... \n";
                $status=system("mysql -uroot --password=$ROOT_Password -e'truncate bn.buysummary'");
                $truncate=1;
        }


        open SIN, "<$upgradeInfFile";
        open SOUT, ">$upgradeSqlFileTmp";
        open CDROUT, ">$upgradeCdrTableInfFile";
        		
         print SOUT "use bn;";
         print SOUT "SET FOREIGN_KEY_CHECKS=0;";
         print SOUT "\n";
         while ($line = <SIN>)
         {
#                 $line = <SIN>;
#                  if (! defined($line)) {last label2;}
                 if($line !~m/$CDRTABLESQL/)
                 {
                         print SOUT "$line";
                 }
                 if($line =~m/$CDRTABLESQL/)
                 {
                         print CDROUT "$line";
                         $line =~s/$CDRTABLESQL/cdr/g;
                         print SOUT "$line";
                 }
         }
        print SOUT "select CDRTableName from cdrlogs into outfile '".$cdrTableListFile."';\n";
        
# check to see if PwdChangeTime is added to users table, if yes, we need to set the value to be now()

        open(GREP, "grep 'PwdChangeTime' $upgradeInfFile |");
 		my $grep = <GREP>;
        close GREP;
		if($grep =~m/PwdChangeTime/) {
			print "New column PwdChangeTime is detected, value reset query is added to upgrade file ... \n";
			print SOUT "update users set PwdChangeTime=unix_timestamp(now()) where PwdChangeTime=0;\n";
		}
        if($truncate){
            print SOUT "UPDATE cdrlogs set Status = Status&~2;\n";
        }		

# make sure default periods has correct value set
			print "Correcting values of default system periods ... \n";
			print SOUT "UPDATE periods set StartWeekDays=2, EndWeekDays=32 WHERE PeriodId=1 and Period='Weekday';\n";
			print SOUT "UPDATE periods set StartWeekDays=64, EndWeekDays=1 WHERE PeriodId=2 and Period='Weekend';\n";
			print SOUT "DELETE FROM periods_breakdown WHERE PeriodId=1 and Period='Weekday';\n";
			print SOUT "DELETE FROM periods_breakdown WHERE PeriodId=2 and Period='Weekend';\n";
			print SOUT "INSERT INTO periods_breakdown values(1,-1,'Weekday',1,0,0,0,-1,-1,-1,1,-1,-1,59,59,23,-1,-1,-1,5,-1,-1);\n";
			print SOUT "INSERT INTO periods_breakdown values(2,-1,'Weekend',1,0,0,0,-1,-1,-1,6,-1,-1,59,59,23,-1,-1,-1,0,-1,-1);\n";
			

         close SIN;
         close SOUT;
         close CDROUT;
#         if ($newVersionCnt eq 2)
#         {
                if( -f $upgradeSqlFileTmp) {
                        $status = system("mv $upgradeSqlFileTmp $upgradeSqlFile");
                }
                if ( -f $upgradeCdrTableInfFileTmp) {
                        $status = system("cp $upgradeCdrTableInfFileTmp $upgradeCdrTableInfFile");
                }

#         }
}

##
## Create DB schema downgrade script, we need this if something goes wrong
##

sub createDBDowngradeScr ()
{
        my ($oldVersionString, $newVersionString, $cdrTableListFile,$dummybn) = @_;
        my $downgradeInfFile = $TmpDir."\/".$DOWNGRADEFILEPREFIX.".inf";
        my $downgradeSqlFile = $TmpDir."\/".$DOWNGRADEFILEPREFIX."-".$newVersionString."-".$oldVersionString.".sql";
        my $downgradeSqlFileTmp = $TmpDir."\/".$DOWNGRADEFILEPREFIX."-".$newVersionString."-".$oldVersionString.".sql".".tmp";
        my $downgradeCdrTableInfFileTmp = $TmpDir."\/".$CDRTABLESQL."-".$newVersionString."-".$oldVersionString.".inf".".tmp";
        my $downgradeCdrTableInfFile = $TmpDir."\/".$CDRTABLESQL."-".$newVersionString."-".$oldVersionString.".inf";
        system("chmod +x consolidatedalter.pl");
        my $status;
        chdir $TmpDir;
        if($ROOT_Password eq "")
        {
                system("./consolidatedalter.pl -user=root -version=$oldVersionString -source=$dummybn -target=bn -conversiontype=downgrade -props=downgrade.properties -outfile=$downgradeInfFile");
        }
        else
        {
                system("./consolidatedalter.pl -user=root -password=$ROOT_Password -version=$oldVersionString -source=$dummybn -target=bn -conversiontype=downgrade -props=downgrade.properties -outfile=$downgradeInfFile");
        }

        open SIN, "<$downgradeInfFile";
        open SOUT, ">$downgradeSqlFileTmp";
        open CDROUT, ">$downgradeCdrTableInfFile";
        my $line;
        print SOUT "use bn;";
        print SOUT "SET FOREIGN_KEY_CHECKS=0;";
        print SOUT "\n";
        while ($line = <SIN>)
        {
#                 $line = <SIN>;
                if (! defined($line)) {last }
                if($line !~m/$CDRTABLESQL/)
                {
                        print SOUT "$line";
                }
                if($line =~m/$CDRTABLESQL/)
                {
                        print CDROUT "$line";
                        $line =~s/$CDRTABLESQL/cdr/g;
                        print SOUT "$line";
                }
        }
        print SOUT "select CDRTableName from cdrlogs into outfile '".$cdrTableListFile."down';";
        close SIN;
        close SOUT;
        close CDROUT;
                if( -f $downgradeSqlFileTmp) {
                        $status = system("cp $downgradeSqlFileTmp $downgradeSqlFile");
                        $DowngradeScript=$downgradeSqlFile;
                }
                if ( -f $downgradeCdrTableInfFileTmp) {
                        $status = system("cp $downgradeCdrTableInfFileTmp $downgradeCdrTableInfFile");
                }

}

##
# Migrates data from 4.0,4.2,4.3 to 5.0
##

sub DBDataPostMigration()
{
        chdir $StartDir;
        system("chmod +x dbdatapostupdate.pl");
		system("chmod +x upgradeCdrAlarmsToMultipleThresholdCdrAlarms.pl");

        my $status;
       
        my ($oldVersionString, $newVersionString, $dummybn) = @_;
        my $upgradeInfFile = "upgrade-specials.inf";
        if($ROOT_Password eq "")
        {
                $status=system("./dbdatapostupdate.pl -user=root -version=$oldVersionString -source=bn -target=$dummybn  -upgradeDataFile=$upgradeInfFile -log=$LogFile");
			$status=system("./upgradeCdrAlarmsToMultipleThresholdCdrAlarms.pl -user=root -log=$LogFile");
        }
        else
        {
                $status=system("./dbdatapostupdate.pl -user=root -password=$ROOT_Password  -version=$oldVersionString -source=bn -target=$dummybn -upgradeDataFile=$upgradeInfFile  -log=$LogFile");
			$status=system("./upgradeCdrAlarmsToMultipleThresholdCdrAlarms.pl -user=root -password=$ROOT_Password -log=$LogFile");
        }
        if($status)
        {
                &FailedUpgrade("post data migration failed");
        }
}

##
## Generate script to upgrade the cdr tables, uses the script generated in createDBUpgradeScr
##

sub upgradeCdrTables()
{
        $FileLogger->info("Starting creation of SQL file for cdr tables");
        my ($cdrTableInfFile, $cdrTableListFile, $cdrTableStr, $cdrTableSqlFile) = @_;
        open SIN, "<$cdrTableInfFile";
        open TIN, "<$cdrTableListFile";
        open FOUT, ">$cdrTableSqlFile";
        my @tableNames = <TIN>;
        my @sqlStatements = <SIN>;
        close SIN;
        close TIN;
        print FOUT "use bn;";
        my $success;
        my $sqlFile = "/tmp/checkCDRTables.sql";
        my $tableListFile = "/tmp/cdrlist.txt";
        my $index =0;
        my $execute = 0;

        system("echo 'use bn; \n' 'show tables like \"cdr%\"; \n' > \"$sqlFile\"");

        if($ROOT_Password eq "")
        {
                $success = system("/usr/bin/mysql  --user=root < \"$sqlFile\" > \"$tableListFile\"");
        }
        else
        {
                $success = system("/usr/bin/mysql  --user=root --password=$ROOT_Password < \"$sqlFile\" > \"$tableListFile\"");
        }

        open SIN, "<$tableListFile";
        my @existingTableNames = <SIN>;
        close SIN;
        foreach my $tableName (@tableNames)
        {
            chomp($tableName);
            for ($index = 0 ; $index <= $#existingTableNames; $index++) {
            chomp($existingTableNames[$index]);
                if ($existingTableNames[$index] eq $tableName) {
                    $execute = 1;
                }
            }
            if($execute > '0')
            {
            	my $isFileWrite;
                foreach my $sqlStatement (@sqlStatements)
                {
                        my $line = $sqlStatement;
                        $line =~s/$cdrTableStr/$tableName/g ;
                        $isFileWrite = print FOUT "$line";
                        if (!$isFileWrite) {
                        	&FailedUpgrade("Error in upgrading cdr tables. Insufficient disk space in $TmpDir ");
                        }
                        $File_Screen_Logger->info("INFO: Upgrading CDR table name: $tableName \n ");
                }
            }
            else
            {
                $File_Screen_Logger->info("WARNING: The table $tableName does not exist in database but its entry is present in \'cdrlogs\' table\n");
            }
            $execute = 0;
        }
	    system("rm -rf \"$sqlFile\"");
	    system("rm -rf \"$tableListFile\"");

        close FOUT;
        my $upgradeLogDir = "$StartDir/upgrade_cdr_tables_log_".time;
		system("mkdir -p $upgradeLogDir");
        system("cp -r $cdrTableInfFile $upgradeLogDir");
        system("cp -r $cdrTableListFile $upgradeLogDir");
        system("cp -r $cdrTableSqlFile $upgradeLogDir");
        
        $FileLogger->info("SQL file for cdr tables created successfully.");
}


##
## Uninstall's package.
##

sub UninstallPackage ()
{
		# Must be privileged.
        CheckForSuperuser ();
        open (ERROR, "> $UninstallLogFile");
        STDERR->fdopen(\*ERROR, "w");

        &CreateLogger("$UninstallLogFile", "DEBUG");
        my $resp;
        my $curversion;
        my $status;

	if($typeOfInstall==1) {
		# Are we uninstalling a redundant RSM?
		&HA_GetRedundancyFlag();
		if ($isRedundancySetup) {
		    &HA_processing();
		    &HA_Init();
		    &HA_StopProcesess();
		    
			# Stop heartbeat if it is running
			#&HA_StopHeartbeat();
			# tell user to stop heartbeat on peer node before proceeding
			#&HA_WarnUserToStopPeerNode();
			# Stop JBoss if it is running
			#&HA_StopJBoss();
			# Stop MySQL if it is running
			#&HA_StopMySQL();

			# mount shared disk
			#print "Mounting shared disk...\n";
			#&HA_MountDisk();
			#print "Shared disk mounted\n";

			# start MySQL server so that database can be operated on
			$status = system ("$HA_ResourcePath/mysql start >/dev/null 2>&1");
		}
	}

        if (-f "$OptNxtn/rsm/.ivmsindex")
        {
                $curversion=`cat $OptNxtn/rsm/.ivmsindex`;
                chomp($curversion);
        }

        if($curversion eq "")
        {
                $curversion="Unknown version";
        }
		
		if ( $SWMF == 0 )
        {
            $resp=&GetBooleanCharResponse("Uninstall RSM package, version: $curversion");
        } else {
			$FileLogger->info("Uninstalling RSMLite through SWM");
            $resp="y";
        }

        if($resp ne "y")
        {
            if ($isRedundancySetup) {
                #	&HA_UnMountDisk();
                # start heartbeat
                $status = system ("/etc/init.d/heartbeat start >/dev/null 2>&1");
                $File_Screen_Logger->info("Starting heartbeat on peer system ...\n");
                &run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"/etc/init.d/heartbeat start\"");
            }
            $File_Screen_Logger->info("User chose not to uninstall");
            exit 1;
        }

        my $jdk=abs_path("$OptNxtn/jdk");
        my $jboss=abs_path("$OptNxtn/jboss");
        my $mysqldata=abs_path("$OptNxtn/mysql/data");
        my $mysqllog=abs_path("$OptNxtn/mysql/log");
        my $procName = "run.jar";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(!$isRedundancySetup)
        {

            if(&ProcExist($procName, $outFile))
            {
                    $File_Screen_Logger->info("JBoss is running, attempting to stop JBoss\n");
                    my $status = system ("/etc/init.d/jboss stop > /dev/null 2>&1");
                    my $procExists=&WaitProcExit($procName,10);
                    if($procExists)
                    {
                            my $status = system("kill -9 `ps -ef | grep run.jar | grep -v grep | tr -s ' ' | cut -d ' ' -f2` >/dev/null 2>&1 ");
                            my $procExists=&WaitProcExit($procName,10);
                            if($procExists)
                            {
                                print("Couldn't shutdown JBoss ...\nShutdown JBoss and try again ...\n");
                                return 1;
							}
                    }
            }
        }
        if($typeOfInstall!=2)
        {
			my $status;
            GetMySQLPasswd();
			##mysql does not support the new mysql password algo, so we change the password to the old formats, and change them back after we're done
			open (TMP2,">fix_privileges_old_pwd_tmp.sql");
			print TMP2 "USE mysql;";
			print TMP2 "UPDATE user SET password=OLD_PASSWORD('$ROOT_Password') WHERE user='root';\n";
			print TMP2 "FLUSH PRIVILEGES;";
			close (TMP2);


			open (TMP1,">fix_privileges_new_pwd_tmp.sql");
			print TMP1 "USE mysql;";
			print TMP1 "UPDATE user SET password=PASSWORD('$ROOT_Password') WHERE user='root';\n";
			print TMP1 "FLUSH PRIVILEGES;";
			close (TMP1);
			$status =system("mysql -u root --password=$ROOT_Password  < fix_privileges_old_pwd_tmp.sql");
			if($status)
			{
                 print ("Unable to change root password to old version, cannot continue.");
                 exit 1;
			}

			my $dbh;
			my $sth;
			$dbh = DBI->connect("dbi:mysql:dbname=bn;", "root", $ROOT_Password, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
			$sth = $dbh->prepare("select username from users where userid != 1");
			$sth->execute;
			$status=system("mkdir -p /home/.backup");
            if($status)
            {
	            $File_Screen_Logger->error("Unable to backup users data");
	            return 1;
            }
			my $date = `date '+%m-%d-%y-%H%M%S'`;
			$status=system("mkdir -p /home/.backup/$date");
            if($status)
            {
	            $File_Screen_Logger->error("Unable to backup users data");
	            return 1;
            }
				        
			while (my($username)=$sth->fetchrow_array) {
				chomp($date);											#To Remove the new line char from $date
				my $flag=system("id $username  > /dev/null 2>&1");		#To check whether the user is valid system user or not, 
				if($flag eq 0){											#if yes then zero is returned else non-zero value is returned. 
				system("mv -f /home/$username /home/.backup/$date/ >/dev/null 2>&1");
				$status=system("userdel -r $username >/dev/null 2>&1");
				if($status)
				{
					$File_Screen_Logger->error("Unable to remove users from system");
					return 1;
				}
				}
			}
			if ($sth)
			{
			   	$sth->finish;
			}
			if ($dbh)
			{
			   	$dbh->disconnect;
			}

            $status=system("mysql -uroot --password=$ROOT_Password -e'drop database bn'");
            if($status)
            {
                $File_Screen_Logger->error("Unable to drop database bn unable to continue uninstall");
                return 1;
            }
        }

        if($typeOfInstall==2)
        {
                #Changed the user to ivmsClient based on the user in msw
                ##pankaj
                my $MSW_User=$ENV{'MSWUSER'};
				#print "Enter postgres username [ivmsclient]: ";
				#my $MSW_User=<>;
				#chomp($MSW_User);
				#if($MSW_User eq "")
				#{
					#$MSW_User="ivmsclient";
				#}
                #$File_Screen_Logger->info("MSX needs to be installed before uninstalling iVMS Lite and ");
				#$File_Screen_Logger->info(" MSX should be stopped before proceeding this uninstallation of $typeOfInstallString\n");
				#my $mswStatusResp =  &GetBooleanCharResponse("Please enter y to continue after stopping msx");
				#if($mswStatusResp eq "n")
				#{
					#$File_Screen_Logger->error(" Unable to continue uninstall \n");
					#return 1;
				#}
				#StopMsw();
                # remove rsmlite specific tables
				#$status = system("psql -U$MSW_User -dmsw -c\"drop table license;\">/dev/null 2>&1");
				#$status = system("psql -U$MSW_User -dmsw -c\"drop table users;\">/dev/null 2>&1");
				#$status = system("psql -U$MSW_User -dmsw -c\"drop table groups;\">/dev/null 2>&1");
				#$status = system("psql -U$MSW_User -dmsw -c\"drop table msws;\">/dev/null 2>&1");
				#$status = system("psql -U$MSW_User -dmsw -c\"drop table sessions;\">/dev/null 2>&1");
				#$status = system("psql -U$MSW_User -dmsw -c\"drop table trails;\">/dev/null 2>&1");
    
				#if($status)
				#{
					#$File_Screen_Logger->warn("Unable to drop rsmlite tables, continuing with uninstall.");
				#}
        }
		if($typeOfInstall!=3){
			if(-f $jdk || -d $jdk)
			{
					if ( $SWMF == 0 )
					{
						$resp=&GetBooleanCharResponse("Remove $jdk");
					} else {
						$FileLogger->info("Removing JDK");
						$resp="y";
					}
					
					if($resp eq "n")
					{
							$File_Screen_Logger->info("Continuing uninstall without removing $jdk");
					}
					else
					{
							system("rm -rf $jdk");
							system("rm -rf $OptNxtn/jdk");
					}
			}

			if(-f $jboss || -d $jboss)
			{
					if ( $SWMF == 0 )
					{
						$resp=&GetBooleanCharResponse("Remove $OptNxtn/jboss");
					} else {
						$FileLogger->info("Removing JDK");
						$resp="y";
					}
					
					if($resp eq "n")
					{
							$File_Screen_Logger->info("Continuing uninstall without removing $jboss");
					}
					else
					{

							if(-f "$OptNxtn/jboss" || -d "$OptNxtn/jboss")
							{
								system("rm -rf $OptNxtn/jboss");
								system("rm -rf $OptNxtn/$JBossVersion");
							}
							if(-f "/etc/init.d/jboss")
							{
							   system("rm /etc/init.d/jboss");
							}
					}
			}
		}
		if (!$isRedundancySetup) {
			if((-f $mysqldata || -d $mysqldata) && (-f $mysqllog || -d $mysqllog) && $typeOfInstall==1)
			{

				$resp=&GetBooleanCharResponse("Remove $mysqldata and $mysqllog");
				if($resp eq "n")
				{
					$File_Screen_Logger->info("Continuing uninstall without removing $mysqldata");
					#if ($isRedundancySetup) {
						#system ("/etc/init.d/mysql stop");
					#}
            }
            else
            {
                my $procName = "$MySqlProcStr";
                my $outFile = $TmpDir."/".$procName.".proc";
                if(&ProcExist($procName, $outFile))
                {
                    $File_Screen_Logger->info("MySql is running, attempting to stop MySql\n");
                    my $status = system ("/etc/init.d/mysql stop >/dev/null 2>&1");
                    my $procExists=&WaitProcExit($procName,4);
                    if($procExists)
                    {
                        print("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");
                        return 1;
                    }
                }

                system("rm -rf $mysqldata");
                system("rm -rf $OptNxtn/mysql/data");
                system("rm -rf $mysqllog");
                system("rm -rf $OptNxtn/mysql/log");
                if(-f "/etc/rc.d/rc3.d/S99mysql")
                {
                    system ("rm /etc/rc.d/rc3.d/S99mysql");
                }
                system("rm /etc/init.d/mysql");
                system("rm /etc/my.cnf");

            }
        }



    }

    system ("rm -rf $OptNxtn/rsm");

    if ($isRedundancySetup) {
        # unmount shared disk
        #&HA_UnMountDisk();
        # remove heartbeat configuratio files
        &HA_RemoveHeartbeatConfigFiles();
        &HA_StopMySQL();
    }

    $File_Screen_Logger->info("RSM package successfully uninstalled!");
    # undoing firewall changes. Called at last to prevent any ssh disconnection
    if ($typeOfInstall == 1)
    {
        &removeFirewall() ;
    }

}

##
##Using user response and /tmp/nars/web-sample.xml creates /tmp/nars/web.xml,
##
sub UpgradeWebXml ()
{
        $FileLogger->info("entering");
        my $xs = new XML::Simple();
        my $file = $TmpDir."\/WEB-INF\/web.xml";
        open(FD, "> $file");
        my $sampleWebXml = $TmpDir."\/web-head.xml";
        my $titleWebXml = $TmpDir."\/web-title.xml";
        my $oldWebXml = $UpgradeBak."\/WEB-INF\/web.xml";
        my $tailWebXml = $TmpDir."\/web-tail.xml";
        my $titleWebXml = $TmpDir."\/web-title.xml";
        my $ref = $xs->XMLin($sampleWebXml,forcearray=>1, NormaliseSpace => 2, SuppressEmpty => '');
        my $old = $xs->XMLin($oldWebXml,forcearray=>1, NormaliseSpace => 2, SuppressEmpty => '');
        my $writer = XML::Simple->new(noattr => 1, rootname => 'web-app', suppressempty => 1);

        if (! -f $oldWebXml)
        {
                &FailedUpgrade("nars.war is missing web.xml !! \n"."Cannot Proceeed ....\n");
        }
        $DB_Username = readXMLHash ("alarmd","DB_Username",$old);
        print "Enter DB_Username [$DB_Username] : ";
        chop(my $resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $DB_Username = $resp;
        }
        updateXMLHash("alarmd","DB_Username",$DB_Username,$ref);
        updateXMLHash("nars","DB_Username",$DB_Username,$ref);

        $DB_Password = "nextone";
        $DB_Password = readXMLHash ("alarmd","DB_Password",$old);
        print "Enter DB_Password [$DB_Password] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $DB_Password = $resp;
        }
        updateXMLHash("alarmd","DB_Password",$DB_Password,$ref);
        updateXMLHash("nars","DB_Password",$DB_Password,$ref);

        my $SMTP_Server = "smtp.nextone.com";
        $SMTP_Server = readXMLHash ("alarmd","SMTP_Server",$old);
        print "Enter SMTP_Server [$SMTP_Server] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $SMTP_Server = $resp;
        }
        updateXMLHash("alarmd","SMTP_Server",$SMTP_Server,$ref);

        my $POP_Server = "pop3.nextone.com";
        $POP_Server = readXMLHash ("alarmd","POP_Server",$old);
        print "Enter POP_Server [$POP_Server] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $POP_Server = $resp;
        }
        updateXMLHash("alarmd","POP_Server",$POP_Server,$ref);

        my $Email_User = "iportal-ecall\@nextone.com";
        $Email_User = readXMLHash ("alarmd","Email_User",$old);
        print "Enter Email User[$Email_User] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $Email_User = $resp;
        }
        updateXMLHash("alarmd","Email_User",$Email_User,$ref);

        my $Email_Password = "abc123";
        $Email_Password = readXMLHash ("alarmd","Email_Password",$old);
        print "Enter Email User Password[$Email_Password] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $Email_Password = $resp;
        }
        updateXMLHash("alarmd","Email_Password",$Email_Password,$ref);

        my $Email_From = "iportal-ecall\@nextone.com";
        $Email_From = readXMLHash ("alarmd","Email_From",$old);
        print "Enter Email From[$Email_From] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $Email_From = $resp;
        }
        updateXMLHash("alarmd","Email_From",$Email_From,$ref);

        my $MSW_Address = "127.0.0.1";
        $MSW_Address = readXMLHash ("alarmd","MSW_Address",$old);
        print "Enter MSX IP Address[$MSW_Address] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $MSW_Address = $resp;
        }
        updateXMLHash("alarmd","MSW_Address",$MSW_Address,$ref);

        my $DB_Address = "127.0.0.1";
        my $DB_URL = readXMLHash ("alarmd","DB_URL",$old);
        my @splitDBUrl = split(/\/\//,$DB_URL);
        my @splitDBAddr = split(/\//,$splitDBUrl[1]);
        $DB_Address = $splitDBAddr[0];
        print "Enter DB IP Address[$DB_Address] :";
        chop($resp = <>);
        print " \n";
        if ($resp ne "")
        {
                $DB_Address = $resp;
        }
        my $DB_Name = "nars";
        $DB_URL = "jdbc:mysql:\/\/".$DB_Address."\/".$DB_Name;
        updateXMLHash("alarmd","DB_URL",$DB_URL,$ref);
        updateXMLHash("nars","DB_URL",$DB_URL,$ref);

        my $rateCalledNumber = readXMLHash ("nars","rateCalledNumber",$old);
        if ($rateCalledNumber eq "")
        {
                $rateCalledNumber="ATDEST";
        }
        $resp = "initial";
        while (not ($resp eq "AFTERSRCCP" || $resp eq "FROMSRC" || $resp eq "ATDEST" || $resp eq ""))
        {

                print "Enter rateCalledNumber {FROMSRC, AFTERSRCCP, ATDEST} [$rateCalledNumber] :";
                chop($resp = <>);
                print " \n";
                if($resp eq "")
                {
                        $resp = $rateCalledNumber;
                }
        }
        if ($resp eq "AFTERSRCCP" || $resp eq "ATDEST" || $resp eq "FROMSRC")
        {
                $rateCalledNumber = $resp;
                updateXMLHash("nars","rateCalledNumber",$rateCalledNumber,$ref);
        }

        print FD $writer->XMLout( $ref );
        close(FD);

        DeleteLine ();
        my $status = system ("cat $tailWebXml >> $file");
        $status = system ("cat $file >> $titleWebXml");
        $status = system ("mv $titleWebXml  $file");
        $FileLogger->info("exiting");
}

##
## Updates the $ref XML hash with param-value obtained from user
##
sub updateXMLHash
{
        $FileLogger->info("entering");

        my $servlet_name = $_[0];
        my $param_name = $_[1];
        my $param_value = $_[2];
        my $ref = $_[3];

        foreach my $servlet (@{$ref->{servlet}})
        {
                if ($servlet->{'servlet-name'}->[0] eq $servlet_name)
                {
                        foreach my $param (@{$servlet->{'init-param'}})
                        {
                                if ($param->{'param-name'}->[0] eq $param_name)
                                {
                                        $param->{'param-value'}->[0] = $param_value;
                                }
                        }
                }
        }
        $FileLogger->info("exiting");

}

##
## Returns the param-value from the $ref XML hash
##
sub readXMLHash
{
        $FileLogger->info("entering");

        my $servlet_name = $_[0];
        my $param_name = $_[1];
        my $ref = $_[2];

        foreach my $servlet (@{$ref->{servlet}})
        {
                if ($servlet->{'servlet-name'}->[0] eq $servlet_name)
                {
                        foreach my $param (@{$servlet->{'init-param'}})
                        {
                                if ($param->{'param-name'}->[0] eq $param_name)
                                {
                                        return $param->{'param-value'}->[0];

                                }
                        }
                }
        }
        $FileLogger->info("exiting");
}

##
##Modify the mysql configuration file /etc/my.cnf
##
sub ModifyMyCnf()
{

$FileLogger->info("entering");
    my $rem_data_file=0;
    my $mysqld_innodb_data_file_path="innodb_data_file_path =";

    if($isInstall){
        my $fdspace = &GetDiskUsage("$MySqlDir");
        my $data_file_size=4*1024*1024;
        $fdspace = ($fdspace * 60 / 100);
        $fdspace = sprintf("%.0f",$fdspace);
        my $num_data_files= $fdspace/$data_file_size;
        $num_data_files = sprintf("%.0f",$num_data_files);
        $rem_data_file = ($fdspace * 1024) % ($data_file_size * 1024);
        $rem_data_file = $rem_data_file / (1024 * 1024);
        $rem_data_file = sprintf("%.0f",$rem_data_file);
        my $i = 1;

                $MySqlWaitTime = $MySqlWaitTime*$num_data_files;
        while($i<=$num_data_files)
        {
                $mysqld_innodb_data_file_path=$mysqld_innodb_data_file_path."$OptNxtn/mysql/data/ibdata".$i.":4000M;";
                $i+=1;
        }

        if($rem_data_file > 0)
        {
                $mysqld_innodb_data_file_path=$mysqld_innodb_data_file_path."$OptNxtn/mysql/data/ibdata".$i.":".$rem_data_file."M";
        }


    }else{
        #copy innodb files path from old /etc/my.cnf file

#        my @mysql_data_files_list = `ls -ltrh /opt/nxtn/mysql/data/ibdata*`;
#        my $index=0;
#        my $filelist="";

#        for ($index = 0 ; $index <= $#mysql_data_files_list; $index++) {
#             my @entry_list = split (/ +/,$mysql_data_files_list[$index]);
#             chomp $entry_list[8];
#             $mysqld_innodb_data_file_path = $mysqld_innodb_data_file_path.$entry_list[8].":".$entry_list[4]. ";";
#        }

#        $mysqld_innodb_data_file_path = substr($mysqld_innodb_data_file_path,0,length($mysqld_innodb_data_file_path) -1);
        my $cnfFile = "/etc/my.cnf";
	    if (! -e "$cnfFile" ){
            &FailedUpgrade("Exiting upgrade ...\nAll settings reverted to earlier version..\nUpgrade Log created in  $UpgradeLog \n");
	    }

        open (FINPUT, "< $cnfFile")
            or die "Couldn't open file to read ! \n";

        while(my $line  = <FINPUT>)
        {
            if($line !~m/^#/){
               if($line =~m/innodb_data_file_path/){
                 $mysqld_innodb_data_file_path =$line;
                 last;
               }
            }
        }

        close (FINPUT);

    }

    ReplaceStr("mysqld_innodb_data_file_path",$mysqld_innodb_data_file_path);
    $FileLogger->info("exiting");
}

sub DeleteLine ()
{

        my $webFile = $TmpDir."\/WEB-INF\/web.xml";
        my $webFileTmp = $TmpDir."\/WEB-INF\/web-tmp.xml";
        open (FINPUT, "< $webFile")
                or die "Couldn't open file to read ! \n";

        open (FOUTPUT, "> $webFileTmp")
                or die "Couldn't open file to write ! \n";
        my $inline;
        while ($inline = <FINPUT>)
        {
                if($inline !~m/\<\/web-app/)
                {
                        print FOUTPUT "$inline";
                }
        }
        close FINPUT;
        close FOUTPUT;
        my $status = system ("cp $webFileTmp $webFile");
        chdir $TmpDir;
}

sub VerifyHighMem()

{
        my $osVersion = `uname -r`;
        my $confFile = "/boot/config-".$osVersion;
        if ( ! -f $confFile)
        {
                return 1;
        }
        open CONFIG, "</$confFile";
        my $line;
        while($line=<IN>)
        {
                if(($line =~m/$MemString4G/) || ($line =~m/$MemString64G/))
                {
                        return 0;
                }
        }
        return 1;
}
##
##Checks the entries in /etc/hosts for the current hostname, if it's mapped to multiple IP addresses, this is not a fool-proof function, so we only display a warning
##
sub TestHostNameConsistency()
{
        my $cnt=0;
        my $hostname;
        my $status=system("hostname >hostname.txt");
        if($status)
        {
            # in SWM upgarde, always fail if unable to get hostname
            my $resp;
            if ( $SWMF == 0 )
            {
                $resp=&GetBooleanCharResponse("Unable to test for hostname consistency, are you sure you wish to continue? ");
            } else {
                $resp = "n";
            }
                if($resp eq "n")
                {
                        &FailedInstall("Unable to test for hostname consistency");

                }
        }
        open (HSTNM,"<hostname.txt");
        while(<HSTNM>)
        {
                $hostname=$hostname.$_;
                chomp($hostname);
        }
        close HSTNM;
        open(ETCHOSTS,"</etc/hosts");
        while(my $line=<ETCHOSTS>)
        {
#               print $line;
                if($line=~m/$hostname/ && !($line=~m/127\./) &&!($line=~m/^#/))
                {
                        $cnt++;
                }
        }
        close ETCHOSTS;

        if($cnt<2 && $upgrade && $typeOfInstall==2)
        {
                my $props="$OptNxtn/rsm/bn.properties";
                my $config;
                chdir $TmpDir;
                if (-f $props && -T $props )
                {
                        $config = new Config::Simple(filename=>$props);
                }
                else
                {
                        $File_Screen_Logger->warn("Cannot read config file $props");
                }

                my %propertieshash = $config->param_hash();
                #get the names of msws
                my $ivmsServerIp=$propertieshash{'default.ivmsServerIp'};
                if($ivmsServerIp ne "127.0.0.1")
                {
                        $cnt=2;
                }

        }

#       my $ManagementIp="";
#        if($cnt>1)
	my $TempIp="";
	if ($typeOfInstall == 2)
        {
#                while(1)
#                {
                    # in SWM upgarde, MSX management IP is taken by calling nxconfig.pl
                    if ( $SWMF == 0 )
                    {
                        $File_Screen_Logger->info("Please specify the MSX Management IP[$ManagementIp]:  \n");
                        $TempIp=<>;
                        chomp($TempIp);
                        if($TempIp ne"")
                        {
                              $ManagementIp="$TempIp";
#                              last;
                        }
#                }
                    } else {
                        my $myMSWName=`hostname`;
                        chomp($myMSWName);
                        $ManagementIp=`/usr/local/nextone/bin/nxconfig.pl -S | grep -w mgmt-ip | grep $myMSWName | tr -s ' ' | cut -d ' ' -f4`;
                        chomp($ManagementIp);
                    }
        }

        open(JBossScrIn,"<$TmpDir/nextoneJBoss");
        open(JBossScrOut,">$TmpDir/nextoneJBoss.tmp");
        my $JbossBindIp="0.0.0.0";
        my $JbossBindShutDownIp="0.0.0.0";
        my $JvmIPv4Parameter="java.net.preferIPv4Stack";
        my $JvmIPv6Parameter="java.net.preferIPv6Stack";
        while(my $line=<JBossScrIn>)
        {
                if ($typeOfInstall == 2)
                {
					if(($ManagementIp ne"") && ($ManagementIp ne"127.0.0.1"))
					{
					   if (is_ipv6($ManagementIp)) {
							$JbossBindIp="["."$ManagementIp"."] ";
							$JbossBindShutDownIp="["."$ManagementIp"."] ";
					   } else {
                            $JbossBindIp="$ManagementIp ";
                            $JbossBindShutDownIp="$ManagementIp ";					   
					   }
					}
				}
		if ($typeOfInstall == 1 ) {
			if ( $line=~m/$nextoneJbossUlimitString/ ) {
				print JBossScrOut $line;
				$line="#set the ulimit to generate core when java crashes\n";
				print JBossScrOut $line;
				$line="ulimit -c unlimited\n" ;
				print JBossScrOut $line;
				$line="#set the core filepath\n";
				print JBossScrOut $line;
				$line="echo /var/log/RSMcore-%e-%p-%t > /proc/sys/kernel/core_pattern\n" ;
				print JBossScrOut $line;
				$line="\n"
			}
		}
		
                $line=~s/%MANAGEMENTIP%/-b $JbossBindIp/;
                $line=~s/%SHUTDOWNIP%/-s $JbossBindShutDownIp/;
                $line=~s/$JvmIPv4Parameter/$JvmIPv6Parameter/;
                print JBossScrOut $line;
        }
        close JBossScrIn;
        close JBossScrOut;
        system("mv $TmpDir/nextoneJBoss.tmp $TmpDir/nextoneJBoss");
}
sub ReplaceStr()
{
        $FileLogger->info("entering");
        my $status;
        my $myCnfFile = $TmpDir."\/my.cnf";
        my $myCnfFileTmp = $TmpDir."\/my.cnf.tmp";
        open IN, "</$myCnfFile";
        open OUT, ">$myCnfFileTmp";
        my $line;
        my $old_string = $_[0];
        my $new_string = $_[1];
        while($line = <IN>)
        {
                if($line !~m/$old_string/)
                {
                        print OUT "$line";
                }
                if($line =~m/$old_string/)
                {
                        $line =~s/$old_string/$new_string/;
                        print OUT "$line";
                }
        }
        close IN;
        close OUT;
        $status = system("cp $myCnfFileTmp $myCnfFile");
        $FileLogger->info("exiting");
}

##
##Install mysql as a service
##
    sub UpdateS99local()
{
        $FileLogger->info("entering");
        my $S99file = "/etc/rc.d/rc2.d/S99local";
        my $S99filetmp = $TmpDir."/S99local.tmp";
        my $status;
        open SIN, "<$S99file";
        open SOUT, ">$S99filetmp";
        my $line;
        my $old_string = "tomcat";
        my $new_string = "jboss";
        my $lineMatch = "0";
        my $exp = "### BEGIN INIT INFO";
        my $exp_frag = "0";
        while($line = <SIN>)
        {
                if(($line !~m/$old_string/) && ($line !~m/$new_string/))
                {
                        print SOUT "$line";
                }
                if($line =~m/$new_string/)
                {
                        if($exp_frag eq "0")
                        {
                           print SOUT "### BEGIN INIT INFO \n# Provides: local \n# Required-Start:  \n# Required-Stop:  \n# Default-Start:  2 3 4 5  \n# Required-Stop: \n# Default-Stop: 0 1 6 \n### END INIT INFO \n";
                        }
                        print SOUT "$line";
                        $lineMatch = "1";
                }
        }
        close SIN;
        close SOUT;
        if ($lineMatch eq "0" )
        {
                $status = system ("echo \"### BEGIN INIT INFO \n# Provides: local \n# Required-Start:  \n# Required-Stop:  \n# Default-Start:  2 3 4 5  \n# Required-Stop: \n# Default-Stop: 0 1 6 \n### END INIT INFO \n/etc/init.d/jboss start \" >> $S99filetmp");
        }
        $status = system("cp $S99filetmp $S99file");
        $FileLogger->info("exiting");
}

sub cleanPeriodsBreakdownTable()
{
		my $curiVMSVersion = &getiVMSVersion();
        my $status;
        my $sqlFile = "/tmp/cleanPeriodsBreakdown.sql";

        if ($typeOfInstall == 1)
        {
			$FileLogger->info("CleanPeriodsBreakdown...");
                system("echo 'delete from bn.periods_breakdown; \n' > \"$sqlFile\"");
                $status = system("/usr/bin/mysql  --user=root --password=\"$ROOT_Password\" < \"$sqlFile\"");
                system("rm -rf \"$sqlFile\"");

        }
}

sub UpdateVersionField()
{
	my ($DB_User,$DB_Pwd) = @_;
        my $curiVMSVersion = &getiVMSVersion();
        if (($curiVMSVersion !~m /4\.2/) && ($typeOfInstall == 1))
        {
		# The intention of this function is to set bn.endpoints.version to 0
		$FileLogger->info("Update Endpoints' VersionField...");
		
		open (TMP2,">fix_privileges_old_pwd_tmp.sql");
		print TMP2 "USE mysql;";
		print TMP2 "UPDATE user SET password=OLD_PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
		print TMP2 "FLUSH PRIVILEGES;";
		close (TMP2);
		open (TMP1,">fix_privileges_new_pwd_tmp.sql");
		print TMP1 "USE mysql;";
		print TMP1 "UPDATE user SET password=PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
		print TMP1 "FLUSH PRIVILEGES;";
		close (TMP1);
		system("mysql -u $DB_User --password=$DB_Pwd  < fix_privileges_old_pwd_tmp.sql");

		my $dbh;
		my $sth;
        if (($curiVMSVersion =~m/4\.0/) && ($typeOfInstall == 1))
        {

            eval{
                $dbh = DBI->connect("dbi:mysql:dbname=bn;", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
                $sth = $dbh->prepare("select serialnumber,port,clusterid,version from bn.endpoints where version !=0;");
                $sth->execute;
                while( my($serialnumber,$port,$clusterid,$version)=$sth->fetchrow_array){
                    if($version==0){
					    $dbh->do("update bn.endpoints set version=0 where serialnumber='$serialnumber' and port=$port and clusterid=$clusterid");
					    $dbh->do("update bn.endpoints set version=0 where serialnumber='$serialnumber' and port=$port and clusterid=$clusterid");
				    }
				    else{                
                        $dbh->do("update bn.endpoints set version=0 where serialnumber='$serialnumber' and port=$port and clusterid=$clusterid");
                    }                        
                }
                if($dbh){
                    $dbh->commit;
                    $dbh->do("commit;");
                    $dbh->disconnect;
                }
            }
        }

        }
}

sub createRoutesNamesTable(){
	my ($routesnamesschema) = @_;
	open (TMP1, ">routesnamesschematemp.sql");
	print TMP1 "use bn;";
	print TMP1 "$routesnamesschema";
	close (TMP1);
	my $status = system("mysql -uroot --password=$ROOT_Password < routesnamesschematemp.sql ");
    $FileLogger->info("exiting createRoutesNamesTable()");
    return $status;
}
##
##Copy the configuration files
##
sub CopyConfFiles()
{
        $FileLogger->info("entering");
        my($TmpDir, $JBossDir) = @_;
        ## Copy configuration files
        my $JBossDeployDir = $JBossDir.$JBossDeployDirSuffix;
        my $JBossConfDir   = $JBossDir.$JBossConfDirSuffix;
        my $JBossServerLibDir   = $JBossDir.$JBossServerLibDirSuffix;
        my $JBossLibDir = $JBossDir.$JBossLibDirSuffix;
        my $status;
        $status = system ("mkdir -p /var/log");
        $status = system ("mkdir -p $NextoneOpt");
        $status = system ("mkdir -p $JBossDeployDir/ivms.war");
        $status = system ("rm -rf \/opt/ivms");
        $status = system ("ln -s $NextoneOpt \/opt/ivms");
        $status = system ("rm -rf \/var/ivms");
        $status = system ("ln -s $NextoneOpt \var\ivms");
        $status = system ("rm -rf $OptDir/jboss/server/rsm/work/*");
        $status = system ("rm -rf $OptDir/jboss/server/rsm/tmp/");
        if($RSM_OS_TYPE eq "RHEL"){
        	$status = system ("cp $TmpDir\/rsmauth_config /bin/rsmauth_config");
        	chmod 777,"/bin/rsmauth_config" ;
        }



#Removed the comment
        #importing the certificate
        chdir $StartDir;
        my $certfile="server.crt.der";
#        print "Enter the name of the certificate file to import for using with postgres connections, with full path if it is not at the same directory as the installer [$certfile]";
#        my $resp=<>;
#        chomp($resp);
#        if($resp ne "")
#        {
#                $certfile=$resp;
#        }
        my $alias="postgres";
	#print "Enter the alias to use [$alias]";
	#my $resp=<>;
	#chomp($resp);
	#if($resp ne "")
	#{
	#        $alias=$resp;
	#}
        $status = system("./importcert.sh $certfile $alias");
        if($status)
        {
                $File_Screen_Logger->warn("Unable to import certificate $certfile, some features may not work. You may also try using the script importcert.sh to import the certificate\n");
        }
#End of comment removal

        chdir $TmpDir;
        if($typeOfInstall ==2)
        {
                system("mkdir -p bn");
                system("mv bn.ear bn/");
                if(! -f "web_iview_only.xml")
                {
                        &FailedInstall("web_iview_only.xml not found");
                }
                if(! -f "jboss_iview.xml")
                {
                        &FailedInstall("jboss_iview.xml not found");
                }
                if(! -f "ejb-jar_iview.xml")
                {
                        &FailedInstall("ejb-jar_iview.xml not found");
                }
                
# zip -f won't work if system clocks are out of sync, so extracting and recreating archive
                chdir $TmpDir."/bn";
                system("unzip -qq bn.ear");
                system("mkdir bnweb");
                system("mv bnweb.war bnweb/");
                chdir $TmpDir."/bn/bnweb";
                system("unzip -qq bnweb.war");
                system("cp $TmpDir/web_iview_only.xml $TmpDir/bn/bnweb/WEB-INF/web.xml");
                system("cp $TmpDir/jboss_iview.xml $TmpDir/bn/bnweb/META-INF/jboss.xml");
                system("cp $TmpDir/ejb-jar_iview.xml $TmpDir/bn/bnweb/META-INF/ejb-jar.xml");

                system("rm bnweb.war");
                system("zip -r -q bnweb.war *");
                system("mv bnweb.war ../");
                chdir $TmpDir."/bn";
                system("rm -rf bnweb");
                system("rm bn.ear");
                system("zip -r -q bn.ear *");
                $status=system("mv bn.ear ../");
                if($status)
                {
                        &FailedInstall("Unable to copy bn.ear");
                }
        }
        chdir $TmpDir;
        $status = system ("cp $TmpDir/bn.ear $JBossDeployDir/.");

        if($typeOfInstall==2)
        {
                if(-f "$JBossDeployDir/mysql-ds.xml")
                {
                        system("rm $JBossDeployDir/mysql-ds.xml");
                }
        }
        else
        {
                $status = system ("cp $TmpDir/mysql-ds.xml $JBossDeployDir/.");
        }

		$status = system ("cp $TmpDir/rsm-destinations-service.xml $JBossDeployDir/.");
		$status = system ("cp $TmpDir/THIRDPARTYLICENSEREADME.txt $OptDir/.");
        $status = system ("cp $TmpDir/jboss-service.xml $JBossConfDir/jboss-service.xml");
        $status = system ("cp $TmpDir/jboss-login-config.xml $JBossConfDir/login-config.xml");
        $status = system ("cp $TmpDir/tomcat-server.xml $JBossDeployDir/$JBossTomcatSar/server.xml");

        $status = system ("cp $TmpDir/tomcat-web.xml $JBossDeployersDir/jbossweb.deployer/web.xml");
        # Commented the following as there is no classloader issue. uncomment and copy the appropriate file when there
        # is class loader issue
        #$status = system ("cp $TmpDir/tomcat-jboss-service.xml $JBossDeployDir/$JBossTomcatSar/META-INF/jboss-service.xml");

        # Copying index.html to JBoss ROOT.war directory
        $status = system ("cp $JBossDeployDir/ROOT.war/index.html $JBossDeployDir/ROOT.war/index.html.orig");
        $status = system ("cp $TmpDir/index.html $JBossDeployDir/ROOT.war/index.html");
        # Modifying web.xml of JBoss ROOT.war to include index.html as the welcome page
        $status = system ("cp $JBossDeployDir/ROOT.war/WEB-INF/web.xml $JBossDeployDir/ROOT.war/WEB-INF/web.xml.orig");
        $status = system ("cp $TmpDir/web.xml $JBossDeployDir/ROOT.war/WEB-INF/web.xml");
        $status = system ("cp $TmpDir/index.html $JBossDeployDir/ivms.war/index.html");

        #$status = system ("cp $JBossDir/server/all/lib/jgroups.jar $JBossDir/server/rsm/lib/jgroups.jar");
        $status = system ("cp $TmpDir/xstream-1.1.2.jar $JBossDir/server/rsm/lib/xstream-1.1.2.jar");
        $status = system ("cp $TmpDir/users.properties $JBossConfDir/.");
        $status = system ("cp $TmpDir/roles.properties $JBossConfDir/.");
        # Start Change Added for changing the jboss-log4j.xml file in conf dir
        $status = system ("cp $TmpDir/jboss-log4j.xml $JBossConfDir/jboss-log4j.xml");
        # End Change Added for changing the jboss-log4j.xml file in  conf dir

        $status = system ("cp $TmpDir/bn.properties $NextoneOpt/.");
        $status = system ("cp $TmpDir/cdr-fields.xml $NextoneOpt/.");
        $status = system ("cp $TmpDir/cdrExpDBDefs.xml $NextoneOpt/.");

        $status = system ("cp $TmpDir/web-app_2_2.dtd $NextoneOpt/.");
	$status = system ("cp $TmpDir/report.dtd $NextoneOpt/.");
        $status = system ("cp $TmpDir/map.xml $NextoneOpt/.");
        $status = system ("cp $TmpDir/jfreechart.jar $JBossServerLibDir/.");
        $status = system ("cp $TmpDir/gen_cp $NextoneOpt/.");
        $status = system ("cp $TmpDir/jcommon.jar $JBossServerLibDir/.");

	    # Hibernate3.jar and cglib.jar are only copied for jboss 5.1.0
	    $status = system ("cp $TmpDir/hibernate3.jar $JBossServerLibDir/.");
	    $status = system ("cp $TmpDir/cglib.jar $JBossServerLibDir/.");

        $status = system ("cp $TmpDir/jdom.jar $JBossLibDir/.");

		if($typeOfInstall != 3)
        {
			$status = system ("rm -rf $JBossDeployDir/iview.war");
			$status = system ("mkdir $JBossDeployDir/iview.war");
			$status = system ("unzip -qq $TmpDir/iview.war -d $JBossDeployDir/iview.war");
			$status = system ("cp $TmpDir/installer-jre1_5.jar $JBossDeployDir/iview.war/installer-jre1_5.jar");
			$status = system ("cp $TmpDir/jre-6u18-linux-i586.bin $JBossDeployDir/iview.war/jre-6u18-linux-i586.bin");
			$status = system ("cp $TmpDir/jre-6u18-windows-i586-s.exe $JBossDeployDir/iview.war/jre-6u18-windows-i586-s.exe");
			$status = system ("cp $TmpDir/jrenative-windows1_5.jar $JBossDeployDir/iview.war/jrenative-windows1_5.jar");
		}

	# copy jmx-console and web-console to deploy if any
	print	"Moving jmx-console and web-console archive files to JBoss deploy directory if any...\n";
	if (-d $JBossConfDir."/jmx-console.war") 
	{
		$status = system ("mv $JBossConfDir/jmx-console.war $JBossDeployDir");
		print	"Moved jmx-console.war to deploy directory\n";
	}
	if (-d $JBossConfDir."/console-mgr.sar") {
		$status = system ("mv $JBossConfDir/console-mgr.sar $JBossDeployDir/management");
		print	"Moved console-mgr.sar to deploy directory\n";
	}
		
        #$status = system ("cp $TmpDir/jmx-console-jboss-web.xml $JBossDeployDir/jmx-console.war/WEB-INF/jboss-web.xml");
        #$status = system ("cp $TmpDir/jmx-console-web.xml $JBossDeployDir/jmx-console.war/WEB-INF/web.xml");
        #$status = system ("cp $TmpDir/web-console-jboss-web.xml $JBossDeployDir/management/console-mgr.sar/web-console.war/WEB-INF/jboss-web.xml");
        #$status = system ("cp $TmpDir/web-console-web.xml $JBossDeployDir/management/console-mgr.sar/web-console.war/WEB-INF/web.xml");
        $status = system ("cp $TmpDir/jboss-run.sh $JBossDir/bin/run.sh");
		
        # disable jmx-console authentication
		$status = system ("cp $TmpDir/jmx-invoker-service.xml $JBossDeployDir/.");
	$status = system ("cp $TmpDir/jboss510-profile.xml $JBossConfDir/bootstrap/profile.xml");
		

		# disable access to jmx-console and web-console by moving the archive to conf dir
		print	"Disabling JBoss jmx-console and web-console services if any...\n";
		if (-d $JBossDeployDir."/jmx-console.war") 
		{
			print	"Disabled JBoss jmx-console service\n";
 			$status = system ("mv $JBossDeployDir/jmx-console.war $JBossBackupDir");
 		}
 		if (-d $JBossDeployDir."/management/console-mgr.sar") 
 		{
 			print	"Disabled JBoss web-console service\n";
 			$status = system ("mv $JBossDeployDir/management/console-mgr.sar $JBossBackupDir");
 		}
 		if (-d $JBossDeployDir."/admin-console.war") 
 		{
 			print	"Disabled JBoss web-console service\n";
 			$status = system ("mv $JBossDeployDir/admin-console.war $JBossBackupDir");
 		}
		
		system("mkdir -p $NextoneOpt/ui");
		system("mkdir -p $NextoneOpt/deploy/ui.war");	
        # Added the file to copt the run.conf to set the JAVA_HOME
        $status = system ("cp $TmpDir/jboss-run.conf $JBossDir/bin/run.conf");
        $status = system ("cp $TmpDir/SVGView.exe $NextoneOpt/deploy/ui.war/.");
        $status = system ("cp $TmpDir/Generics.xsl $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/DeviceHardWareDetail.xsl $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/DeviceSoftWareDetail.xsl $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/.truststore $NextoneOpt/.");
#       $status = system ("cp $TmpDir/SVGViewCarbon.bin $NextoneHome/ui/.");
        $status = system ("cp $TmpDir/SVGViewCarbon.bin $NextoneOpt/deploy/ui.war/.");
#       push (@files_copied,"ui/SVGViewCarbon.bin");
#       $status = system ("cp $TmpDir/adobesvg-3.01x88-linux-i386.tar.gz $NextoneHome/ui/.");
        $status = system ("cp $TmpDir/adobesvg-3.01x88-linux-i386.tar.gz $NextoneOpt/deploy/ui.war/.");
        $status = system ("mkdir -p $NextoneOpt/deploy/ui.war/svg");
        # Added for the bug 20380
        $status = system ("cp $TmpDir/SVGend.svginc $NextoneOpt/deploy/ui.war/.");
        $status = system ("cp $TmpDir/SVGstart.svginc $NextoneOpt/deploy/ui.war/.");
        # Added for the bug 20380
#       push (@files_copied,"ui/adobesvg-3.01x88-linux-i386.tar.gz");
        $status = system ("cp $TmpDir/logger.properties $NextoneOpt/.");
        if($typeOfInstall==1)
        {
                $status = system ("cp $TmpDir/example-mapping.xml $NextoneOpt/CDRStream/transform/.");
                $status = system ("cp $TmpDir/export-mapping.xml $NextoneOpt/CDRStream/transform/.");
                if($status)
                {
                        $FileLogger.warn("Unable to copy mapping files some features may not work correctly");
                }
				$status = system ("cp -r $TmpDir/mibs $NextoneOpt/.");
				$status = system ("cp $TmpDir/changeowner.sh $NextoneOpt/.");

        }
        $status = system ("cp $TmpDir/rsmWSDL.tar $NextoneOpt/.");
	# adding executable permission for scripts in bin directory of jboss
		system("chmod +x $JBossDir/bin/*.sh");
        #&UpdateWebserivcePort();
	    &changeSecurePort();
        CreateArchiveDir();
        $FileLogger->info("exiting");

}

# To redirect requests from http to https port
sub changeSecurePort()
{
    my $file = "$JBossConfDir/bindingservice.beans/META-INF/bindings-jboss-beans.xml";
    my $sString='\$port \+ 363';	
    my $rString='443'; 	

    my $tmpFile = "/tmp/510.xml";
    open (FIN, "<$file");
    open (FOUT, ">$tmpFile");
    my $line="";
    while($line=<FIN>)
    {
	$line=~ s/$sString/$rString/;
	print FOUT $line;
    }
    close FIN;
    close FOUT;
    system("mv $tmpFile $file");
}

sub UpdateWebserivcePort()
{
    my $file = "$OptDir/jboss/server/rsm/deploy/jbossws.sar/META-INF/jboss-service.xml";
	my $tmpFile = "$TmpDir/443.xml";
	open (FIN, "<$file");
	open (FOUT, ">$tmpFile");
	my $line="";
	while($line=<FIN>)
	{
		$line=~s/<attribute name="WebServiceSecurePort">8443<\/attribute>/<attribute name="WebServiceSecurePort">443<\/attribute>/;
		print FOUT $line;
	}
	close FIN;
	close FOUT;
	system("mv $tmpFile $file");
}

sub ModifyJbossServerLogXML()
{
        my ($JBossDir)=@_;
        my $JBossConfDir   = $JBossDir.$JBossConfDirSuffix;
        my $status=system("mv $JBossConfDir/jboss-log4j.xml $TmpDir/jboss-log4j.xml.tmp");
        if($status)
        {
                  &FailedInstall("Couldn't find $JBossConfDir/jboss-log4j.xml");
        }
        open (FIN, "<$TmpDir/jboss-log4j.xml.tmp");
        open (FOUT, ">$TmpDir/jboss-log4j.xml");
        my $line="";
        while($line=<FIN>)
        {
                $line=~s/<param name="File" value="\${jboss.server.home.dir}\/log\/server.log"\/>/<param name="File" value="\/var\/log\/server.log"\/>/;
                print FOUT $line;
        }
        close FIN;
        close FOUT;
         $status = system("mv $TmpDir/jboss-log4j.xml $JBossConfDir/jboss-log4j.xml");
}

##
## backup the current SSL cert
##
sub saveSSLCert()
{
	my $jboss_home = '/opt/nxtn/jboss/server/rsm';
	
	if (!-d $jboss_home)
	{
		$jboss_home = '/opt/nxtn/jboss/server/default';
	}
	
	$oldSSLCertPass = "";
	$oldSSLCertFile = "";
	open(FIN, "<$jboss_home/conf/jboss-service.xml");
	while(my $line  = <FIN>) {
		if ($line =~ m/<attribute name=\"KeyStorePass\">(.*)<\/attribute>/i) {
			$oldSSLCertPass = $1;
		}
		if ($line =~ m/<attribute name=\"KeyStoreURL\">\${jboss\.server\.home\.dir}\/conf\/(.*)<\/attribute>/i) {
			$oldSSLCertFile = $1;
		}
	}
	close (FIN);
	system("cp $jboss_home/conf/$oldSSLCertFile $TmpDir/$oldSSLCertFile.save");
}

##
## restore the current SSL cert
##
sub restoreSSLCert()
{
	my $jboss_home = '/opt/nxtn/jboss/server/rsm';
	
	system("cp $jboss_home/conf/jboss-service.xml $TmpDir/jboss-service.xml.old");
	open(FIN, "<$TmpDir/jboss-service.xml.old");
	open(FOUT, ">$jboss_home/conf/jboss-service.xml");
	while(my $line  = <FIN>) {
		$line =~ s/<attribute name=\"KeyStorePass\">(.*)<\/attribute>/<attribute name=\"KeyStorePass\">$oldSSLCertPass<\/attribute>/i;
		$line =~ s/<attribute name=\"KeyStoreURL\">\${jboss\.server\.home\.dir}\/conf\/(.*)<\/attribute>/<attribute name=\"KeyStoreURL\">\${jboss\.server\.home\.dir}\/conf\/$oldSSLCertFile<\/attribute>/i;
		print FOUT $line;
	}
	close (FIN);
	close (FOUT);

	system("cp $jboss_home/deploy/jbossweb.sar/server.xml $TmpDir/server.xml.old");
	open(FIN, "<$TmpDir/server.xml.old");
	open(FOUT, ">$jboss_home/deploy/jbossweb.sar/server.xml");
	while(my $line  = <FIN>) {
		$line =~ s/keystorePass=\"(.*)\"/keystorePass=\"$oldSSLCertPass\" sslProtocol = \"TLS\" server=\"Undisclosed\"/i;
		$line =~ s/keystoreFile=\"\${jboss\.server\.home\.dir}\/conf\/(.*)\"/keystoreFile=\"\${jboss\.server\.home\.dir}\/conf\/$oldSSLCertFile\"/i;
		print FOUT $line;
	}
	close (FIN);
	close (FOUT);

	system("cp $TmpDir/$oldSSLCertFile.save $jboss_home/conf/$oldSSLCertFile");

	# clean up
	system("rm -f $TmpDir/$oldSSLCertFile.save");
	system("rm -f $TmpDir/jboss-service.xml.old");
	system("rm -f $TmpDir/server.xml.old");
}

##
##Upgrade configuration files
##
sub UpgradeConfFiles ()
{
        $FileLogger->info("entering");
        my ($iVMSBakDir) = @_;
        my $JBossDeployDir = $iVMSBakDir."/".$JBossDeployDirSuffix;
        my $JBossConfDir   = $iVMSBakDir."/".$JBossConfDirSuffix;
        my $JBossServerLibDir   = $iVMSBakDir."/".$JBossServerLibDirSuffix;
        my $JBossLibDir = $iVMSBakDir."/".$JBossLibDirSuffix;
        my $status;
        if($typeOfInstall==1)
        {
                if((&Upgrade("users.properties")))
                {
                        $status = system ("cp $JBossConfDir/users.properties $TmpDir/.");
                }
        }
        $FileLogger->info("exiting");

}

sub Upgrade ()
{
        $FileLogger->info("entering");
        my ($filename) = @_;
        my $upgrade = 1;
        my $userresponse = &GetBooleanCharResponse("Do you want to use old $filename");
        if($userresponse eq 'n')
        {
                $upgrade = 0;
        }
        $FileLogger->info("exiting");
        return $upgrade;

}

sub getUserInput ()
{

  my ($defaultMessage, $defaultValue, $numTries)=@_;
  my $value="";
  while($numTries ne 0 and $value eq "")
  {
        print $defaultMessage;
        my $resp = <>;
        chomp($resp);
        $FileLogger->info("User responded \'$resp\'");
        if ($resp ne "")
        {
                $defaultValue=$resp;
        }
        $value=$defaultValue;
        $numTries=$numTries-1;
  }
return $value;

}
##
##Replace the tokens in mysql-ds.xml with their proper values
##
sub UpdateMySqlXml()

{
        $FileLogger->info("entering");
        my($username, $password) = @_;
        my $mysqldsxmlfile = "$TmpDir/mysql-ds.xml";
        my $mysqldsxmlfiletmp = $TmpDir."/mysql-ds.tmp";
        if($typeOfInstall== 2)
        {
                return;
#               $mysqldsxmlfile = "$TmpDir/postgres-ds.xml";
#               $mysqldsxmlfiletmp = $TmpDir."/postgres-ds.tmp";
        }
        my $status;
        open SIN, "<$mysqldsxmlfile";
        open SOUT, ">$mysqldsxmlfiletmp";
        my $line;
        my $username_string = "USERNAME";
        my $password_string = "PASSWORD";
        my $hostname_string = "HOSTNAME";
        my $portnumber_string= "PORTNUMBER";
        while($line = <SIN>)
        {

                $line =~s/$username_string/$username/;
                $line =~s/$password_string/$password/;
#               if($typeOfInstall == 2)
#               {
#                       $line =~s/$hostname_string/$MSWHostName/;
#                       $line =~s/$portnumber_string/$MSWPort/;
#               }
                print SOUT "$line";
        }
        close SIN;
        close SOUT;
        $status = system("cp $mysqldsxmlfiletmp $mysqldsxmlfile");
        $FileLogger->info("exiting");
}
##
##Creates the stream directory
##
sub CreateStreamDir()
{
        $FileLogger->info("entering");
#       my $home=$NextoneHome;
        my $home=$NextoneOpt;
        if (-d $home)
        {
                my $status=&CreateDir($home,"CDRStream");
                $status=&CreateDir($home."/CDRStream","log");
                $status=&CreateDir($home."/CDRStream","transform");
        }
        else
        {
                &FailedInstall("$home doesn't exist ...\n");
        }
        $FileLogger->info("exiting");
}



sub SNMPConfiguration()
{
		if($RSM_OS_TYPE eq "RHEL"){
     	return ;  	
    	}
        print "Configuring SNMPd\n";

        `cat /etc/snmp/snmpd.conf | grep 'agentXSocket tcp:127.0.0.1:705'`;
		if($? == 0 )
		{
			$FileLogger->info("Configuration already present... Not doing any thing");
		}
		else
		{
			$FileLogger->info("Configuration not present... adding");
			`/usr/bin/sed --in-place '/^agentxtimeout.*5/{
			aagentXSocket tcp:127.0.0.1:705
			}' /etc/snmp/snmpd.conf`;
			$FileLogger->info("Configuration added");
			$FileLogger->info("Restarting snmpd .... ");
			`/etc/init.d/snmpd restart`;
			$FileLogger->info("Restarted snmpd .... ");

		}
		print "Configuring SNMPd done\n";
}


##
##Creates the swm directory
##

sub CreateSWMDir()
{
        $FileLogger->info("entering to create SWM directory");
        my $home=$NextoneOpt;
        my $swmdir = "swm";
        my $installablesDir = "installables";
        my $licenseDir = "license";
        my $reconizedPackageDir = "reconizedPackage";
        my $deviceBackupDir = "deviceBackup";
        if (-d $home)
        {
            if(!-d $home."/".$swmdir) {
                my $status=&CreateDir($home,$swmdir);
            }
            if(!-d $home."/".$swmdir."/".$installablesDir) {
                my $status=&CreateDir($home."/".$swmdir,$installablesDir);
            }
            if(!-d $home."/".$swmdir."/".$licenseDir) {
                my $status=&CreateDir($home."/".$swmdir,$licenseDir);
            }
            if(!-d $home."/".$swmdir."/".$reconizedPackageDir) {
                my $status=&CreateDir($home."/".$swmdir,$reconizedPackageDir);
            }
            if(!-d $home."/".$swmdir."/".$deviceBackupDir) {
                my $status=&CreateDir($home."/".$swmdir,$deviceBackupDir);
            }

        }
        else
        {
                &FailedInstall("$home doesn't exist ...\n");
        }
        $FileLogger->info("exiting after create SWM directory");
}


##
##Creates the ui directory
##

sub CreateUIDir()
{
        $FileLogger->info("entering");
#       my $home=$NextoneHome;
        my $home=$NextoneOpt;
        my $uidir = "ui";
        my $svgdir = "svg";
        if (-d $home)
        {
            if(!-d $home."/".$uidir) {
                my $status=&CreateDir($home,"ui");
            }
            if(!-d $home."/".$uidir."/".$svgdir) {
                my $status=&CreateDir($home."/".$uidir,"svg");
            }

        }
        else
        {
                &FailedInstall("$home doesn't exist ...\n");
        }
        $FileLogger->info("exiting");
}

##
##Creates the archive directory
##

sub CreateArchiveDir()
{
        $FileLogger->info("entering");
#        my $home=$NextoneHome;
        my $home=$NextoneOpt;
        if (-d $home)
        {
                my $status=&CreateDir($home,"provBkup");
                if($typeOfInstall == 1)
                {
                $status=system("chown mysql:mysql $home/provBkup");
        }
        }
        else
        {
                &FailedInstall("$home doesn't exist ...\n");
        }
        $FileLogger->info("exiting");
}


 ##
 ## Create alarmscripts directory
 ##
 sub CreateAlarmScriptsDir()
 {
    my $home=$NextoneOpt;
    my $alarmscriptdir=$home."/alarmscripts";
    if (-d $home)
    {
        if (!(-d $alarmscriptdir))
        {
            my $status=&CreateDir($home,"alarmscripts");
            if($status)
            {
                print "Unable to create scripts directory";
            }
        }
    }
    else
    {
        print "$home doesn't exist ...\n";
        GetResponse ();
        exit 2;
    }
 }


##
##Creates the home directory
##

sub CreateHomeDir()
{
        $FileLogger->info("entering");
        my $status=system("mkdir -p $NextoneOpt");
        $FileLogger->info("exiting");
        return $status;
}

##
##Creates a directory
##

sub CreateDir()
{
        $FileLogger->info("entering");
        my ($path,$name)=@_;
        if(!-d $path."/".$name)
        {
		$FileLogger->info("$path/$name doesn't exist...\n");
		$FileLogger->info("Creating $path/$name ...\n");
                my $status=system("mkdir $path/$name");
                if($status)
                {
                        return 1;
                }
                else
                {
			$FileLogger->info("Created $path/$name ...\n");
                }
        }
	else
	{
		$FileLogger->info("$path/$name directory exists ...\n");
	}
        $FileLogger->info("exiting");
        return 0;

}

##
##Checks if the supplied process name is running
##

sub ProcExist()
{
        my ($procName, $outFile) = @_;
        $FileLogger->info("entering ".$procName);

        my $status = system("ps -ef | grep $procName | grep -v grep > $outFile");
        my $size = -s $outFile;
        if ($size > 0)
        {
                $FileLogger->info("exiting 1");
                return 1;
        }
        else
        {
                $FileLogger->info("exiting 0");
                return 0;
        }
}

##
##Checks if the supplied process name is running
##

sub ProcExistOnPeer()
{
        my ($procName,$outFile,$peerIP) = @_;
        $FileLogger->info("entering ".$procName);
	$FileLogger->info("arguments $procName,$outFile,$peerIP");
        my $status = system("ssh root\@$peerIP \"ps -ef | grep $procName | grep -v grep > $outFile\"");
	$status = system("scp root\@$peerIP\:$outFile $outFile ");
        my $size = -s $outFile;
        if ($size > 0)
        {
                $FileLogger->info("exiting 1");
                return 1;
        }
        else
        {
                $FileLogger->info("exiting 0");
                return 0;
        }
}


##
##runs a loop for the given period of time while waiting for the given process name to exit, returns 1 if it does not exit within that time
##

sub WaitProcExitOnPeer()
{
        my ($procName,$numTimes,$peerIP) = @_;
	$FileLogger->info("entering");
	$FileLogger->info("arguments $procName,$numTimes,$peerIP");
        my $outFile = $TmpDir."/".$procName.".proc";
        my  $i=0;
        while ($i != $numTimes)
        {
                if (!&ProcExistOnPeer($procName, $outFile,$peerIP))
                {
                        return 0;
                }
                else
                {
                        print "Waiting for $procName to exit...\n";
                        sleep 10;
                        $i++;
                }
        }
        return 1;
        $FileLogger->info("exiting");
}


##
##runs a loop for the given period of time while waiting for the given process name to exit, returns 1 if it does not exit within that time
##

sub WaitProcExit()
{
        $FileLogger->info("entering");
        my ($procName, $numTimes) = @_;
        my $outFile = $TmpDir."/".$procName.".proc";
        my  $i=0;
        while ($i != $numTimes)
        {
                if (!&ProcExist($procName, $outFile))
                {
                        return 0;
                }
                else
                {
                        print "Waiting for $procName to exit...\n";
                        sleep 10;
                        $i++;
                }
        }
        return 1;
        $FileLogger->info("exiting");
}

##
##runs a loop for the given period of time while waiting for the given process name to start, returns 0 if it does not start within that time
##

sub WaitProcStart()
{
        $FileLogger->info("entering");
        my ($procName, $numTimes) = @_;
        my $outFile = $TmpDir."/".$procName.".proc";
        my  $i=0;
        while ($i != $numTimes)
        {
                if (&ProcExist($procName, $outFile))
                {
                        return 1;
                }
                else
                {
                        print "Waiting for $procName to start...\n";
                        sleep 10;
                        $i++;
                }
        }
        return 0;
        $FileLogger->info("exiting");
}

##
##Since the NEXTONE_HOME is changing, in case of upgrading we need to copy the existing files in old home dir to the new one
##
sub CopyHomeToOpt()
{
        $FileLogger->info("entering");
        if((-d $NextoneHome) && (-d $NextoneOpt))
        {
                my $status;
                chdir $NextoneHome;
                if((-d $NextoneHome."/ui") && (! -d $NextoneOpt."/ui"))
                {
                        $status=system("mv ui/ $NextoneOpt/.");
                }
                if((-d $NextoneHome."/cdrs") && (! -d $NextoneOpt."/cdrs"))
                {
                        $status=system("mv  cdrs/ $NextoneOpt/.");
                }
                if((-d $NextoneHome."/CDRStream") && (! -d $NextoneOpt."/CDRStream"))
                {
                        $status=system("mv CDRStream/ $NextoneOpt/.");
                }
                if((-d $NextoneHome."/provBkup") && (! -d $NextoneOpt."/provBkup"))
                {
                        $status=system("mv  provBkup/ $NextoneOpt/.");
                }
                if((-d $NextoneHome."/alarmscripts") && (! -d $NextoneOpt."/alarmscripts"))
                {
                        $status=system("mv  alarmscripts/ $NextoneOpt/.");
                }
        }
        $FileLogger->info("exiting");
}
##
##Roll back the above change if upgrade fails
##
sub CopyOptToHome()
{
        $FileLogger->info("entering");
        if((-d $NextoneOpt) && (-d $NextoneHome))
        {
                my $status;
                chdir $NextoneOpt;
                if((-d $NextoneOpt."/ui") && (! -d $NextoneHome."/ui"))
                {
                        $status=system("mv  ui/ $NextoneHome/.");
                }
                if((-d $NextoneOpt."/cdrs") && (! -d $NextoneHome."/cdrs"))
                {
                        $status=system("mv  cdrs/ $NextoneHome/.");
                }
                if((-d $NextoneOpt."/CDRStream") && (! -d $NextoneHome."/CDRStream"))
                {
                        $status=system("mv  CDRStream/ $NextoneHome/.");
                }
                if((-d $NextoneOpt."/provBkup") && (! -d $NextoneHome."/provBkup"))
                {
                        $status=system("mv  provBkup/ $NextoneHome/.");
                }
                if((-d $NextoneOpt."/alarmscripts") && (! -d $NextoneHome."/alarmscripts"))
                {
                        $status=system("mv  alarmscripts/ $NextoneHome/.");
                }
        }
        $FileLogger->info("exiting");
}
##
##Redhat specific function, not used
##
sub CheckHostConsistency()
{
        $FileLogger->info("entering CheckHostConsistency() ");
        my $networkCfg = new Config::Simple($ETC_SYSCONFIG_NETWORK);
        my $hostname = $networkCfg->param("HOSTNAME");
        $FileLogger->info("$ETC_SYSCONFIG_NETWORK HOSTNAME: $hostname \n ");

        if ($hostname ne "")
        {
        			
                open SIN, "<$ETC_HOSTS";
                my $line;
                while($line = <SIN>)
                {
                        if($line =~m/$loopBackIp_2/)
                        {
                        		$FileLogger->info("Files $ETC_HOSTS and $ETC_SYSCONFIG_NETWORK are consistent. \n");
                                return ;
                        }
                }
        }

        &FailedInstall("Files $ETC_HOSTS and $ETC_SYSCONFIG_NETWORK are inconsistent. \nExiting RSM setup... \n");
        $FileLogger->info("exiting");
}

##
##Check for duplicate msw ip entries in the database
##
sub CheckDupMswIp()

{
        $FileLogger->info("entering");
        my ($user, $passwd, $tmpDir, $ivmsbakDir, $upgradeLog) = @_;
        my $distinctCnt = $tmpDir."/distinct";
        my $totalCnt = $tmpDir."/total";
        my $status = system("mysql --user=\"$user\" --password=\"$passwd\" -e \"select distinct mswip from bn.msws\" > $distinctCnt");
        my $status = system(" mysql --user=\"$user\" --password=\"$passwd\" -e \"select mswip from bn.msws\" > $totalCnt");
        my $distinctSize = -s $distinctCnt;
        my $totalSize = -s $totalCnt;
        if ($totalSize ne $distinctSize)
        {
                $status = system ("cp -pr $ivmsbakDir/* $JBossDir/.");
                print "Starting JBoss Server..\n";
                $status = system ("/etc/init.d/jboss start  > /dev/null &");
                &FailedUpgrade("There are duplicate msxip entries in msws table ...\nYou need to contact GENBAND Support for resolutions ...\nExiting upgrade ...\nAll settings reverted to earlier version..\nUpgrade Log created in  $upgradeLog \n");
        }
        else
        {
                return;
        }
        $FileLogger->info("exiting");
}

##
##Gets the user-name password from the old datasource file modifies the new file, and writes it to hte output file
##
sub upgradeMySqlXml()
{
        $FileLogger->info("entering");
        my $cnt = @_;
        my $usage = sub { print "usage: &upgradeMySqlXml(outfile, oldfile, newfile) \n"; return; };
        if($cnt < 3)
        {
                $usage->();
                return 0;
        }
        my ($outfile, $oldfile, $newfile) = @_;
        if(! -f $newfile)
        {
                &FailedUpgrade("File not found $newfile");
        }
        if(! -f $oldfile)
        {
                &FailedUpgrade("File not found $oldfile");
        }

        my $xs = new XML::Simple();
        open(FD, ">$outfile");
        my $old = $xs->XMLin($oldfile, forcearray=>1, NormaliseSpace => 2, SuppressEmpty => '');
        my $ref = $xs->XMLin($newfile, forcearray => 1, NormaliseSpace => 2, SuppressEmpty => '');
        my $writer = XML::Simple->new(noattr => 0, rootname => 'datasources', suppressempty => 1);
        my $MySqlLogInfo= &extractMySqlLogInfo("bn-mysql-ds", $old);
        if($MySqlLogInfo)
        {
                &updateMySqlLogInfo("bn-mysql-ds", $MySqlLogInfo, $ref);
        }

        $MySqlLogInfo= &extractMySqlLogInfo("bnrater-mysql-ds", $old);
        if($MySqlLogInfo)
        {
                &updateMySqlLogInfo("bnrater-mysql-ds", $MySqlLogInfo, $ref);
        }

        print FD $writer->XMLout($ref);
        $FileLogger->info("exiting");
}

##
##Checks the existing mysql version and upgrades it if that version is not up-to-date
##
sub UpgradeMySql()
{
	my ($mysql_data_dir,$mysql_log_dir)=@_;
        $FileLogger->info("entering");
        my $mysqlUpgraderesponse = 'n';
        my $mysqlCurrentVersion = &getMySqlVersion();
        my $status;
        if($mysqlCurrentVersion=~m/5\.0\.90/){
            $File_Screen_Logger->info("Current MySql is up to date \n");
            $MySqlInstalled='y';
	    #before returning, we should start mysql if it is not running
	    if (abs_path($mysql_data_dir) ne abs_path("$OptNxtn/mysql/data") ) {
		$status = system ("rm -r $OptNxtn/mysql/data");
            	$status = system ("ln -s $mysql_data_dir $OptNxtn/mysql/data");
	    }		

	    if (abs_path($mysql_log_dir) ne abs_path("$OptNxtn/mysql/log")) {
		$status = system ("rm -r $OptNxtn/mysql/log");
            	$status = system ("ln -s $MySqlDir $OptNxtn/mysql/log");
	    }
		
	    my $procName = "$MySqlProcStr";
	    my $outFile = $TmpDir."/".$procName.".proc";
	    if(!&ProcExist($procName, $outFile)) {
		    $File_Screen_Logger->info("MySql is not running, attempting to start MySql\n");
		    my $status = system ("/etc/init.d/mysql start >/dev/null 2>&1");
		    my $procExists=&WaitProcStart($procName,4);
		    if(!$procExists) {
			    &FailedSetupNoCleanupRequired("Couldn't start MySql ...\nStart MySql and try again ...\n");
		    }
	    }
            return;
        }else{
            $mysqlUpgraderesponse = 'y';
            $File_Screen_Logger->info("upgrading MySQL to 5.0.90 ...");
        }
        SelectMySqlPackage();
        if($mysqlUpgraderesponse eq 'y') {
                my $procName = "$MySqlProcStr";
                my $outFile = $TmpDir."/".$procName.".proc";
                if(&ProcExist($procName, $outFile))
                {
                        $File_Screen_Logger->info("MySql is running, attempting to stop MySql\n");
                        my $status = system ("/etc/init.d/mysql stop");
                        my $procExists=&WaitProcExit($procName,4);
                        if($procExists)
                        {
                                &FailedSetupNoCleanupRequired("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");
                        }
                }
            chdir $TmpDir;
            $File_Screen_Logger->info("Upgrading $MySQLServerRpm .. \n");
            if ( ! -f $MySQLServerRpm)
            {
                &FailedUpgrade("Unable to find $MySQLServerRpm \n");
            }

            $status = system ("rpm -U --force --nodeps $MySQLServerRpm");
            if ($status)
            {
                &FailedUpgrade("Unable to install MySql server \n".$!);
            }

            $File_Screen_Logger->info("Upgrading $MySQLServerRpm ..done \n");

            if ( ! -f $MySQLClientRpm)
            {
                &FailedUpgrade("Unable to find $MySQLClientRpm \n");
            }

            $File_Screen_Logger->info("Upgrading MySQL Client..   \n");

            $status = system ("rpm -U --force --nodeps $MySQLClientRpm");
            if ($status)
            {
                &FailedUpgrade("Unable to install MySql client \n".$!);
            }
            if (abs_path($mysql_data_dir) ne abs_path("$OptNxtn/mysql/data") ) {
		$status = system ("rm -r $OptNxtn/mysql/data");
            	$status = system ("ln -s $MySqlDir $OptNxtn/mysql/data");
	    }		

	    if (abs_path($mysql_log_dir) ne abs_path("$OptNxtn/mysql/log")) {
		$status = system ("rm -r $OptNxtn/mysql/log");
            	$status = system ("ln -s $MySqlDir $OptNxtn/mysql/log");
	    }

            $File_Screen_Logger->info("Upgrading MySQL Client..done   \n");
            $File_Screen_Logger->info("Restarting MySQL server...\n");

            $status = system ("/etc/init.d/mysql start >/dev/null 2>&1");
            $MySqlInstalled='y';

        }
        $FileLogger->info("exiting");

}

sub updateMySqlLogInfo
{
        $FileLogger->info("entering");
        my $cnt = @_;
        my $usage = sub { print "usage: &updateMySqlLogInfo(datasource, loginref, xmlref) \n"; return; };
        if($cnt < 2)
        {
                $usage->();
                return 0;
        }
        my ($ds_name, $loginref, $ref) = @_;
        foreach my $ds (@{$ref->{'local-tx-datasource'}})
        {
                if ($ds->{'jndi-name'}->[0] eq $ds_name)
                {
                        $ds->{'user-name'}->[0] = @$loginref[0];
                        $ds->{'password'}->[0] = @$loginref[1];
                }
        }
        foreach my $ds (@{$ref->{'xa-datasource'}})
        {
                if ($ds->{'jndi-name'}->[0] eq $ds_name)
                {
                        %{%{$ds->{'xa-datasource-property'}}->{'User'}}->{content}=@$loginref[0];
                        %{%{$ds->{'xa-datasource-property'}}->{'Password'}}->{content}=@$loginref[1];
                }
        }
        $FileLogger->info("exiting");
}

sub extractMySqlLogInfo
{
        $FileLogger->info("entering");
        my $cnt = @_;
        my $usage = sub { print "usage: &extractMySqlLogInfo(datasource, xmlref) \n"; return; };
        if($cnt < 2)
        {
                $usage->();
                return 0;
        }
        my ($ds_name, $ref) = @_;
        my @login = {'USERNAME','PASSWORD'};
        foreach my $ds (@{$ref->{'local-tx-datasource'}})
        {
                if ($ds->{'jndi-name'}->[0] eq $ds_name)
                {
                        @login[0] = $ds->{'user-name'}->[0];
                        @login[1] = $ds->{'password'}->[0];
                }
        }
        foreach my $ds (@{$ref->{'xa-datasource'}})
        {
                if ($ds->{'jndi-name'}->[0] eq $ds_name)
                {
                        @login[0] = %{%{$ds->{'xa-datasource-property'}}->{'User'}}->{content};
                        @login[1] = %{%{$ds->{'xa-datasource-property'}}->{'Password'}}->{content};
                }
        }
        $FileLogger->info("exiting");
        return \@login;
}


sub NotClustered()
{
        my ($str)=@_;
        $File_Screen_Logger->warn("Unable to start Slony script: $str\n");
}
##
##Get the list of MSWDbIPs and fire the slony script
##
sub FireSlony()
{
        my ($MSWUser)=@_;
        my $props="$OptNxtn/rsm/bn.properties";
        my $config;
        chdir $TmpDir;
        if (-f $props && -T $props )
        {
                $config = new Config::Simple(filename=>$props);
        }
        else
        {
                &NotClustered("Cannot read config file $props");
        }

        my %propertieshash = $config->param_hash();
        #get the names of msws
        my $mswsstr=$propertieshash{'default.bn.msws'};
        if (ref($mswsstr) ne "ARRAY")
        {
                $FileLogger->info("Cluster information not found in properties file, assuming device is not clustered, not attempting to fire Slony");
                return;
        }
        if(defined($mswsstr))
        {
                my @msws=@$mswsstr;
                if($#msws>0)
                {
                        #we assume only two machines in cluster
                        my $mswip1=$propertieshash{'default.'.$msws[0].'.MSWDBIp'};
                        my $mswip2=$propertieshash{'default.'.$msws[1].'.MSWDBIp'};


                        my $status=system("./fireBnSync.sh $MSWUser $mswip1 $mswip2 ");
                        if($status)
                        {
                                &NotClustered("Fire failed");
                                return;
                        }
                }
                else
                {
                        &NotClustered("Not sufficient number of msx's configured");
                        return;
                }
        }
        else
        {
                &NotClustered("No information about msxs detected");
                return;
        }
#       $File_Screen_Logger->info("Slony script fired successfully");
}

## Reanme the routes table
## Create an empty routes table

sub upgradeRoutesTable()
{
       $FileLogger->info("entering upgradeRoutesTable()");
       ## Add this to fix the bug during upgrade from 4.0c1-13 to 4.2
       my $status=system("mysql -uroot --password=$ROOT_Password -e'drop table if exists bn.routesnames'");

       ## Save routes table schema before dropping it
       my $routesschema = &getroutestableschema($ROOT_Password);
       open (TMP1, ">routesschematemp.sql");
       print TMP1 "use bn;";
       print TMP1 "$routesschema";
       close (TMP1);

       ## rename the routes table
       my $status=system("mysql -uroot --password=$ROOT_Password -e'drop table if exists bn.routes_old'");
       $status=system("mysql -uroot --password=$ROOT_Password -e'rename table bn.routes to bn.routes_old'");
       if($status)
       {
            $File_Screen_Logger->error("Unable to rename table routes to routes_old unable to continue uninstall");
            return 1;
       }

       $status=system("mysql -uroot --password=$ROOT_Password -e'drop table if exists bn.routes'");
       $status = system("mysql -uroot --password=$ROOT_Password < routesschematemp.sql ");

       if($status)
       {
            $File_Screen_Logger->error("Unable to create empty table routes. Unable to continue upgrade");
            return 1;
       }
       $status=system("mysql -uroot --password=$ROOT_Password -e \"update bn.actions set type='move-to-least-priority' where type='move-to-last-priority'  \" ");
       if($status)
       {
             $File_Screen_Logger->error("Unable to update the actions table, unable to continue upgrade");
             return 1;
       }

       ## create an empty table
       $FileLogger->info("exting upgradeRoutesTable()");
       return $status;
}

##
## Alter the Regions in memory Tables
##
sub upgradeRegionsInMemoryTable()
{
       $FileLogger->info("entering upgradeRegionsInMemoryTable()");
       ## rename the routes table
       my $status=system("mysql -uroot --password=$ROOT_Password -e'alter table bn.regionsinmemory CHANGE COLUMN `GROUPID` `PartitionId` TINYINT(1) NOT NULL DEFAULT -1' >/dev/null 2>&1");
       $status=system("mysql -uroot --password=$ROOT_Password -e'ALTER TABLE bn.regionsinmemory DROP INDEX `GROUPID`, ADD INDEX `PartitionId`(`PartitionId`)' >/dev/null 2>&1");
#       if($status)
#       {
#            $FileLogger->error("Unable to upgrade the regionsinmemorytable unable to continue uninstall");
#            return 1;
#       }

       ## create an empty table
       $FileLogger->info("upgradeRegionsInMemoryTable()");
       return $status;
}

# Returns the routes table schema to the caller
sub getroutestableschema()
 {
         my $DB_Pwd = $_[0];
         my $DB_User = "root";

 	 ##mysql does not support the new mysql password algo, so we change the password to the old formats, and change them back after we're done
         open (TMP2,">fix_privileges_old_pwd_tmp.sql");
         print TMP2 "USE mysql;";
         print TMP2 "UPDATE user SET password=OLD_PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
         print TMP2 "FLUSH PRIVILEGES;";
         close (TMP2);


         open (TMP1,">fix_privileges_new_pwd_tmp.sql");
         print TMP1 "USE mysql;";
         print TMP1 "UPDATE user SET password=PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
         print TMP1 "FLUSH PRIVILEGES;";
         close (TMP1);

         my $status;

         $status =system("mysql -u $DB_User --password=$DB_Pwd  < fix_privileges_old_pwd_tmp.sql");
         if($status)
         {
                 print ("Unable to change $DB_User password to old version, cannot continue.");
                 exit 1;
         }

        my $dbh;
        my $sth;
        $dbh = DBI->connect("dbi:mysql:dbname=bn;", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
        $sth = $dbh->prepare("SHOW create table bn.routes;");
        $sth->execute;
        my($table, $routesscript)=$sth->fetchrow_array;

        system("mysql -u $DB_User --password=$DB_Pwd  < fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_old_pwd_tmp.sql");

       if ($sth)
       {
           $sth->finish;
       }
       if ($dbh)
       {
           $dbh->disconnect;
       }
       return $routesscript;
 }

# Returns the routesnames table schema to the caller
sub getroutesnamestableschema()
 {
         my ($dummyBn,$DB_Pwd)=@_;
         my $DB_User = "root";
 	     ##mysql does not support the new mysql password algo, so we change the password to the old formats, and change them back after we're done
         open (TMP2,">fix_privileges_old_pwd_tmp.sql");
         print TMP2 "USE mysql;";
         print TMP2 "UPDATE user SET password=OLD_PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
         print TMP2 "FLUSH PRIVILEGES;";
         close (TMP2);
         open (TMP1,">fix_privileges_new_pwd_tmp.sql");
         print TMP1 "USE mysql;";
         print TMP1 "UPDATE user SET password=PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
         print TMP1 "FLUSH PRIVILEGES;";
         close (TMP1);
         my $status;
         $status =system("mysql -u $DB_User --password=$DB_Pwd  < fix_privileges_old_pwd_tmp.sql");
         if($status)
         {
                 print ("Unable to change $DB_User password to old version, cannot continue.");
                 exit 1;
         }
        my $dbh;
        my $sth;
        $dbh = DBI->connect("dbi:mysql:dbname=$dummyBn;", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
        $sth = $dbh->prepare("SHOW create table $dummyBn.routesnames;");
        $sth->execute;
        my($table, $routesnamesscript)=$sth->fetchrow_array;
        system("mysql -u $DB_User --password=$DB_Pwd  < fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_old_pwd_tmp.sql");
       if ($sth)
       {
           $sth->finish;
       }
       if ($dbh)
       {
           $dbh->disconnect;
       }
       return $routesnamesscript;
 }

 # Checks whether routesnames table exists or not
sub checkForRoutesnamesTableExistence()
 {
         my ($databaseName,$DB_Pwd)=@_;

         my $DB_User = "root";
	 my $count=0;
         open (TMP2,">fix_privileges_old_pwd_tmp.sql");
         print TMP2 "USE mysql;";
         print TMP2 "UPDATE user SET password=OLD_PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
         print TMP2 "FLUSH PRIVILEGES;";
         close (TMP2);
         open (TMP1,">fix_privileges_new_pwd_tmp.sql");
         print TMP1 "USE mysql;";
         print TMP1 "UPDATE user SET password=PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
         print TMP1 "FLUSH PRIVILEGES;";
         close (TMP1);
         my $status;
         $status =system("mysql -u $DB_User --password=$DB_Pwd  < fix_privileges_old_pwd_tmp.sql");
         if($status)
         {
                 print ("Unable to change $DB_User password to old version, cannot continue.");
                 exit 1;
         }
        my $dbh;
        my $sth;
        $dbh = DBI->connect("dbi:mysql:dbname=$databaseName;", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
        $sth = $dbh->prepare("show tables like 'routesnames';");
        $sth->execute;
	while( my($tables)=$sth->fetchrow_array)
	{
		$count = 1;
        }
        system("mysql -u $DB_User --password=$DB_Pwd  < fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_old_pwd_tmp.sql");
       if ($sth)
       {
           $sth->finish;
       }
       if ($dbh)
       {
           $dbh->disconnect;
       }
       return $count;
 }
#################### Redundancy stuff ########################

sub HA_CopyConfigFiles(){
        # copy heartbeat configuration files
        my $HAConfDir = "$TmpDir/haconf";
        my $status="";
        if(!$isPeerHAInstalled){
            # stop mysql server (heartbeat will start mysql)
            $File_Screen_Logger->info("Shutting down MySQL Database.. \n");
            $status = system ("/usr/bin/mysqladmin -u root --password=\"$ROOT_Password\" shutdown");

            $File_Screen_Logger->info("Removing cib.xml.sig ... \n");
            $status = &run_command ("rm -rf /var/lib/heartbeat/crm/cib.xml.sig");
            $File_Screen_Logger->info("Copying cib.xml .... \n");
            $status = &run_command("cp -p $HAConfDir\/cib.xml /var/lib/heartbeat/crm");
            $File_Screen_Logger->info("Changing heartbeat permission .... \n");
            $status = &run_command("chown \-Rv hacluster /var/lib/heartbeat/");
            $File_Screen_Logger->info("Copying ha.cf .... \n");
            $status = &run_command("cp -p $HAConfDir\/ha.cf /etc/ha.d/");
            $File_Screen_Logger->info("Copying rsmsyncpam...");
            $status = &run_command("cp -p $HAConfDir\/rsmsyncpam /usr/lib/ocf/resource.d/genband/");
            $status = &run_command("cp $TmpDir\/pam_files_to_sync /usr/lib/ocf/resource.d/genband/");
	    	$File_Screen_Logger->info("Copying jbossnew...");	
	    	$status = &run_command("cp -p $HAConfDir\/jbossnew /usr/lib/ocf/resource.d/genband/");
	    	$File_Screen_Logger->info("Copying mysql...");	
	    	$status = &run_command("cp -p $HAConfDir\/mysql /usr/lib/ocf/resource.d/genband/");		
		$File_Screen_Logger->info("Copying jbsrv...");	
	    	$status = &run_command("cp -p $HAConfDir\/jbsrv /etc/init.d/");		

			$File_Screen_Logger->info("Copying rclocal...");	
			$status = &run_command("cp -p $HAConfDir\/rclocal /etc/init.d/");

            $status = &run_command("chmod 775 /usr/lib/ocf/resource.d/genband/*");
            $status = &run_command("chmod 775 /etc/init.d/jbsrv");
            $status = &run_command("chmod 775 /etc/init.d/rclocal");

        }else{
            #copy data from peer server
            $File_Screen_Logger->info("We detect that you have already installed RSM on $HA_PeerNodeName");

            $File_Screen_Logger->info("Removing cib.xml.sig ... \n");
            $status = &run_command("rm -rf /var/lib/heartbeat/crm/cib.xml.sig");
            $File_Screen_Logger->info("Copying /var/lib/heartbeat/crm/cib.xml from $HA_PeerNodeName ...");
            &run_command("scp root\@$HA_PeerNodeHeartbeatIP:/var/lib/heartbeat/crm/cib.xml //var/lib/heartbeat/crm");

            $File_Screen_Logger->info("Changing peer heartbeat permission .... \n");
            $status = &run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"chown \-Rv hacluster /var/lib/heartbeat/\"");
			$status = &run_command("chown \-Rv hacluster /var/lib/heartbeat/");

	   
		
            $File_Screen_Logger->info("Copying /etc/ha.d/ha.cf from $HA_PeerNodeName ...");
            &run_command("scp root\@$HA_PeerNodeHeartbeatIP:/etc/ha.d/ha.cf //etc/ha.d/ha.cf");

            $File_Screen_Logger->info("Copying /usr/lib/ocf/resource.d/genband/rsmsyncpam from $HA_PeerNodeName ...");
            &run_command("scp root\@$HA_PeerNodeHeartbeatIP:/usr/lib/ocf/resource.d/genband/rsmsyncpam //usr/lib/ocf/resource.d/genband/rsmsyncpam");

            $File_Screen_Logger->info("Copying /etc/my.cnf from $HA_PeerNodeName ...");
            &run_command("scp root\@$HA_PeerNodeHeartbeatIP:/etc/my.cnf //etc");
            $status = &run_command("cp $TmpDir\/pam_files_to_sync /usr/lib/ocf/resource.d/genband/");
	    	$File_Screen_Logger->info("Copying /usr/lib/ocf/resource.d/genband/jbossnew from $HA_PeerNodeName ...");	
	    	&run_command("scp root\@$HA_PeerNodeHeartbeatIP:/usr/lib/ocf/resource.d/genband/jbossnew //usr/lib/ocf/resource.d/genband/jbossnew");	
	    	$File_Screen_Logger->info("Copying /usr/lib/ocf/resource.d/genband/mysql from $HA_PeerNodeName ...");	
	    	&run_command("scp root\@$HA_PeerNodeHeartbeatIP:/usr/lib/ocf/resource.d/genband/mysql //usr/lib/ocf/resource.d/genband/mysql");	
	    	$File_Screen_Logger->info("Copying /etc/init.d/jbsrv from $HA_PeerNodeName ...");	
	    	&run_command("scp root\@$HA_PeerNodeHeartbeatIP:/etc/init.d/jbsrv //etc/init.d/jbsrv");

	    	$File_Screen_Logger->info("Copying /etc/init.d/rclocal from $HA_PeerNodeName ...");	
	    	&run_command("scp root\@$HA_PeerNodeHeartbeatIP:/etc/init.d/rclocal /etc/init.d/rclocal");


            $status = &run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"chmod 775 /usr/lib/ocf/resource.d/genband/*\"");
            $status = &run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"chmod 775 /etc/init.d/jbsrv\"");
            $status = &run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"chmod 775 /etc/init.d/rclocal\"");
	    $status = &run_command("chmod 775 /usr/lib/ocf/resource.d/genband/*");
            $status = &run_command("chmod 775 /etc/init.d/jbsrv");   	

        }


}


##
## get redundancy flag
##
sub HA_GetRedundancyFlag()
{
	# use lsmod command to check if the fiber card driver is present
	my $status = system("lsmod | grep qla > /dev/null 2>&1");
	if ($status eq '0') {
		$isRedundancySetup = 1;
		#set a flag in $StartDir
		system("touch $StartDir/.isRedundancySetup");
	}
	else {
		$isRedundancySetup = 0;
	}

}

##
## get peerHAInstaleld flag
##
sub HA_GetPeerHAInstalledFlag()
{
    # If HA is installed in peer RSM server, .ha_installed file should be created under /opt/nxtn/rsm dir.
    # Check for that file

    if ( -f $HA_DataFile) {
        $isPeerHAInstalled = 1;
    }
    else{
        $isPeerHAInstalled = 0;
    }

}


##
## Verify the system is configured properly
##
sub HA_VerifySystem()
{
    &run_command("/etc/init.d/o2cb status");
    # Check the mounting points
    my $mount_data = "Active OCFS2 mountpoints:  /opt/mysql/log /opt/mysql/data /opt/nxtn";
    my $data = &run_command("/etc/init.d/ocfs2 status" );
    if (!($data=~m/$mount_data/))
    {
        &FailedSetupNoCleanupRequired("Cannot find 'Active OCFS2 mountpoints:  /opt/mysql/log /opt/mysql/data /opt/nxtn'. Please make sure system is installed properly.");
    }

}

##
## Stop processes before installing RSM
##
sub HA_StopProcesess()
{
## Heartbeat should be stopped first on the current standby and then the currently active server.
## Adding check to find the current DC. If not connected, heartbeat not running on current, so checking on peer.
## If not also on peer, then we can check heartbeat status and stop it

    # Stop heartbeat if it is running
	my $procName = "heartbeat";
	my $outFile = $TmpDir."/".$procName.".proc";
	my $stopHeartBeatOnPeerFirst=0;	
	my $ret=0;
	if(&ProcExist($procName, $outFile)) {
		$FileLogger->info( "Reading hostname ...\n");
		my $uname = &run_command("uname -n");
		chomp($uname);
	
		if ($uname eq "") {
			&FailedSetupNoCleanupRequired("Cannot get this node's host name from 'uname -n'\nConfigure host name and try again ...\n");
		}

		$File_Screen_Logger->info("Checking for active server ...\n");
		open (CONSOLE, " crmadmin -D | grep \"$uname\" |  grep -c -v grep | ");
        	while (<CONSOLE>){
                	$ret=$_;
        	}
		if($ret==1) {
			# heartbeat is either not running or the peernode is the current DC. 	
			# should stop the heartbeat 
			$stopHeartBeatOnPeerFirst=1; 
			
		}
	} else {
		$stopHeartBeatOnPeerFirst=1;		
	} 
		if ($stopHeartBeatOnPeerFirst==1) {
   			# tell user to stop heartbeat on peer node before proceeding
    			$File_Screen_Logger->info("Stopping heartbeat on peer system first...\n");
			my $status=&run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"/etc/init.d/heartbeat stop\"");
		 	my $peerProcExists = &WaitProcExitOnPeer($procName, 5,$HA_PeerNodeHeartbeatIP);
			if($peerProcExists) {
			&FailedSetupNoCleanupRequired("Couldn't shutdown heartbeat on peer...\nShutdown heartbeat and try again ...\n");
			}
			$File_Screen_Logger->info("Stopping heartbeat on local system ...\n");
			$status=&run_command("/etc/init.d/heartbeat stop");
			my $procExists = &WaitProcExit($procName, 5);
			if($procExists) {
			&FailedSetupNoCleanupRequired("Couldn't shutdown heartbeat ...\nShutdown heartbeat and try again ...\n");
			}
		} else {
			$File_Screen_Logger->info("Stopping heartbeat on local system ...\n");
			my $status=&run_command("/etc/init.d/heartbeat stop");
			my $procExists = &WaitProcExit($procName, 5);
			if($procExists) {
			&FailedSetupNoCleanupRequired("Couldn't shutdown heartbeat ...\nShutdown heartbeat and try again ...\n");
			}
   			# tell user to stop heartbeat on peer node before proceeding
    			$File_Screen_Logger->info("Stopping heartbeat on peer system ...\n");
			$status=&run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"/etc/init.d/heartbeat stop\"");
		 	my $peerProcExists = &WaitProcExitOnPeer($procName,5,$HA_PeerNodeHeartbeatIP);
			if($peerProcExists) {
			&FailedSetupNoCleanupRequired("Couldn't shutdown heartbeat on peer...\nShutdown heartbeat and try again ...\n");
			}
		}
    
    # stop MySQL
    &HA_StopMySQL();    
    &HA_StopMySQLOnPeer($HA_PeerNodeHeartbeatIP);  
    
}

##
## stop heartbeat
##
sub HA_StopHeartbeat()
{
	my $procName = "heartbeat";
	my $outFile = $TmpDir."/".$procName.".proc";
	if(&ProcExist($procName, $outFile)) {
		$File_Screen_Logger->info("Heartbeat is running, attempting to stop heartbeat\n");
		my $status = &run_command("/etc/init.d/heartbeat stop");
		my $procExists = &WaitProcExit($procName, 4);
		if($procExists) {
			&FailedInstall("Couldn't shutdown heartbeat ...\nShutdown heartbeat and try again ...\n");
		}
	}
}

##
## stop JBoss
##
sub HA_StopJBoss()
{
	my $procName = "run.jar";
	my $outFile = $TmpDir."/".$procName.".proc";
	if(&ProcExist($procName, $outFile)) {
		$File_Screen_Logger->info("JBoss is running, attempting to stop JBoss\n");
                my $status = system ("/etc/init.d/jboss stop > /dev/null 2>&1");
		my $procExists = &WaitProcExit($procName, 10);
		if($procExists) {
			&FailedInstall("Couldn't shutdown JBoss ...\nShutdown JBoss and try again ...\n");
		}
	}
}

##
## stop MySQL
##
#sub HA_StopMySQL()
#{
#	my $procName = $MySqlProcStr;
#	my $outFile = $TmpDir."/".$procName.".proc";
#	if(&ProcExist($procName, $outFile)) {
#		$File_Screen_Logger->info("MySQL is running, attempting to stop MySQL\n");
#		my $status = system("/etc/init.d/mysql stop");
#		my $procExists = &WaitProcExit($procName, 4);
#		if($procExists) {
#			&FailedInstall("Couldn't shutdown MySQL ...\nShutdown MySQL and try again ...\n");
#		}
#	}
#}

##
## warn user to stop heartbeat on peer node
##
sub HA_WarnUserToStopPeerNode()
{
	my $response = &GetBooleanCharResponse("Warning: Please stop heartbeat on the peer node before proceeding. \nDo you want to proceed?");
	if($response eq 'n') {
		&FailedInstall("Installation canceled\n");
	}
}

##
## check IP address
##
sub isValidIPAddress()
{
	my ($string) = @_;
	if ($string !~ /^([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)$/) {
		return 0;
	}
	my $s;
	foreach $s (($1, $2, $3, $4)) {
		if (0 > $s || $s > 255) {
			return 0;
		}
	}
	return 1;
}

##
## mount shared disk
##
sub HA_MountDisk()
{
	my $cmdOutput = "";
	my $MySQLDataDir = "$OptNxtn/mysql/data";
	my $MySQLLogDir = "$OptNxtn/mysql/log";

	my $status = system("mkdir -p $OptNxtn");
	$status = system("mkdir -p $MySQLDataDir");
	$status = system("mkdir -p $MySQLLogDir");
	$status = system("modprobe qla2300 >/dev/null 2>&1");

	$status = system("sh -c \"mount /dev/sdb1 $OptNxtn\" >/dev/null 2>&1");
	if ($status != 0) {
		$cmdOutput = `mount /dev/sdb1 $OptNxtn 2>&1`;
		if (!($cmdOutput =~ m/\/dev\/sdb1 is already mounted on $OptNxtn/i)) {
			&FailedInstall("Cannot mount /dev/sdb1 to $OptNxtn\n");
		}
	}
	$status = system("mkdir -p $MySQLDataDir");
	$status = system("sh -c \"mount /dev/sdb2 $MySQLDataDir\" >/dev/null 2>&1");
	if ($status != 0) {
		$cmdOutput = `mount /dev/sdb2 $MySQLDataDir 2>&1`;
		if (!($cmdOutput =~ m/\/dev\/sdb2 is already mounted on $MySQLDataDir/i)) {
			&FailedInstall("Cannot mount /dev/sdb2 to $MySQLDataDir\n");
		}
	}
	$status = system("mkdir -p $MySQLLogDir");
	$status = system("sh -c \"mount /dev/sdb3 $MySQLLogDir\" >/dev/null 2>&1");
	if ($status != 0) {
		$cmdOutput = `mount /dev/sdb3 $MySQLLogDir 2>&1`;
		if (!($cmdOutput =~ m/\/dev\/sdb3 is already mounted on $MySQLLogDir/i)) {
			&FailedInstall("Cannot mount /dev/sdb3 to $MySQLLogDir\n");
		}
	}
}

##
## unmount shared disk
##

#sub HA_UnMountDisk()
#{
#	chdir $StartDir;
#	my $status = system("sh -c \"umount /dev/sdb2\" >/dev/null 2>&1");
#	$status = system("sh -c \"umount /dev/sdb3\" >/dev/null 2>&1");
#	$status = system("sh -c \"umount /dev/sdb1\" >/dev/null 2>&1");
#}

##
## see if name and IP are mapped in /etc/hosts
##
sub HA_MatchNameIP()
{
	my ($name, $ip) = @_;
	my $foundMatch = 0;
	open (ETCHOSTS, "</etc/hosts");
	while (my $line = <ETCHOSTS>) {
		if ($line =~ m/$ip/ && $line =~ m/$name/i && !($line=~m/^#/)) {
			chomp($line);
			my @items = split /\s+/, $line;
			my $item;
			foreach $item (@items) {
				if ($item =~ m/^$name$/i) {
					$foundMatch = 1;
					last;
				}
			}
			last;
		}
	}
	close ETCHOSTS;

	if ($foundMatch) {
		return 1;
	}
	else {
		return 0;
	}
}

##
## collect information about HA configuration
##
sub HA_CollectHAInfo()
{
	# this node's name and IP
	# node name is `uname -n`, IP address must be eth0's IP
	$File_Screen_Logger->info( "Reading hostname ...\n");
	my $uname = &run_command("uname -n");
	chomp($uname);
	if ($uname eq "") {
		&FailedInstall("Cannot get this node's host name from 'uname -n'\nConfigure host name and try again ...\n");
	}
    $File_Screen_Logger->info( "Reading eth0 ip address...\n");
	my $eth0_ip = "";
	my @ifconfig = `/sbin/ifconfig eth0`;
	for( @ifconfig ) {
		if (( /inet addr:(\d+\.\d+\.\d+\.\d+)/ ) or ( /inet6 addr: ([a-zA-Z0-9:]+)/ )){
			$eth0_ip = $1;
			last;
		}
	}
	if ($eth0_ip eq "") {
		&FailedInstall("IP address is not configured for 'eth0'\nConfigure IP address on 'eth0' and try again ...\n");
	}
	# node name and eht0's IP must match in /etc/hosts
	$File_Screen_Logger->info( "Validating hostname and eth0 ipaddress in /etc/hosts file...\n");
	if (!&HA_MatchNameIP($uname, $eth0_ip)) {
		&FailedInstall("This node's host name ($uname) and eth0's IP address ($eth0_ip) are not mapped in /etc/hosts file\nConfigure /etc/hosts file and try again ...\n");
	}
	$HA_MyNodeName = $uname;
	$HA_MyNodeIP = $eth0_ip;
	#print "This node's host name is $HA_MyNodeName, IP address on eth0 is $HA_MyNodeIP.\n";


	# this node's heartbeat IP
    $File_Screen_Logger->info( "Reading eth1 ipaddress ...\n");
	my $eth1_ip = "";
	my @ifconfig = `/sbin/ifconfig eth1`;
	for( @ifconfig ) {
		if(( /inet addr:(\d+\.\d+\.\d+\.\d+)/ ) or ( /inet6 addr: ([a-zA-Z0-9:]+)/ )) {
			$eth1_ip = $1;
			last;
		}
	}
	if ($eth1_ip eq "") {
		&FailedInstall("IP address is not configured for 'eth1'\nConfigure IP address on 'eth1' and try again ...\n");
	}
	# Verify eth1 IPaddress correspond to uname
	$File_Screen_Logger->info("Validating hostname and eth1 ipaddress in /etc/hosts file...\n");
	if (!&HA_MatchNameIP($uname, $eth1_ip)) {
		&FailedInstall("This node's host name ($uname) and eth1's IP address ($eth1_ip) are not mapped in /etc/hosts file\nConfigure /etc/hosts file and try again ...\n");
	}


	$HA_MyNodeHeartbeatIP = $eth1_ip;

	# read HA configuration info from $HA_DataFile, if any
	&HA_ReadInfo();

	# peer node's name and IP
	# if HA is installed in the first RSM server, get the peer details from ha file

	$File_Screen_Logger->info("Reading peer system hostname ...  \n");
	$HA_PeerNodeName   =  &run_command("ssh root\@$HA_PeerNodeHeartbeatIP hostname");
	chomp $HA_PeerNodeName; 
	# Verify peer eth1 IPaddress correspond to peeruname
	$File_Screen_Logger->info("Validating peer hostname and peer eth1 ipaddress in /etc/hosts file...\n");
	if (!&HA_MatchNameIP($HA_PeerNodeName, $HA_PeerNodeHeartbeatIP)) {
		&FailedInstall("Peer system host name ($HA_PeerNodeName) and peer eth1's IP address ($HA_PeerNodeHeartbeatIP) are not mapped in /etc/hosts file\nConfigure /etc/hosts file and try again ...\n");
	}

    # management IP (cluster IP, or floating IP)
    # Get this only in the first system
    if(!$isPeerHAInstalled){
        while(1) {
            my $text = "";

            if ($HA_ManagementIP eq "") {
                $File_Screen_Logger->info("Please specify the RSM Server IP (this is the IP that client uses to access RSM):  ");
                $text = <>;
                chomp($text);
                if($text eq "") {
                    next;
                }
            }
            else {
                $File_Screen_Logger->info("Please specify the RSM Server IP (this is the IP that client uses to access RSM) [$HA_ManagementIP]:  ");
                $text = <>;
                chomp($text);
                if($text eq "") {
                    $text = $HA_ManagementIP;
                }
            }

            if (&isValidIPAddress($text)) {
                $HA_ManagementIP = $text;
                last;
            }
            else {
                $File_Screen_Logger->info("This is not a valid IP address.\n");
            }
        }
    }
   $File_Screen_Logger->info("\n");
	
#	if($isPeerHAInstalled)
#    {
#        while(1) {
#            my $text = "";

#            if ($HA_PeerNodeName eq "") {
#                $File_Screen_Logger->info("Please enter peer node's name:  \n");
#                $text = <>;
#                chomp($text);
#                if($text eq "") {
#                    next;
#                }
#            }
#            else {
#                $File_Screen_Logger->info("Please enter peer node's name [$HA_PeerNodeName]:  \n");
#                $text = <>;
#                chomp($text);
#                if($text eq "") {
#                    $text = $HA_PeerNodeName;
#                }
#            }

#            $HA_PeerNodeName = $text;
#            last;
#        }

        # peer node's heartbeat IP
#        while(1) {
#            my $text = "";

#            if ($HA_PeerNodeHeartbeatIP eq "") {
#                $File_Screen_Logger->info("Please enter peer node's heartbeat IP (the IP address on eth1):  \n");
#                $text = <>;
#                chomp($text);
#                if($text eq "") {
#                    next;
#                }
#            }
#            else {
#                $File_Screen_Logger->info("Please enter peer node's heartbeat IP (the IP address on eth1) [$HA_PeerNodeHeartbeatIP]:  \n");
#                $text = <>;
#                chomp($text);
#                if($text eq "") {
#                    $text = $HA_PeerNodeHeartbeatIP;
#                }
#            }

#            if (&isValidIPAddress($text)) {
#                $HA_PeerNodeHeartbeatIP = $text;
#                last;
#            }
#            else {
#                $File_Screen_Logger->info("This is not a valid IP address.\n");
#            }
#        }


#    }

	#while(1) {
	#	my $text = "";

	#	if ($HA_PeerNodeIP eq "") {
	#		$File_Screen_Logger->info("Please enter peer node's IP (the IP address on eth0):  \n");
	#		$text = <>;
	#		chomp($text);
	#		if($text eq "") {
	#			next;
	#		}
	#	}
	#	else {
	#		$File_Screen_Logger->info("Please enter peer node's IP (the IP address on eth0) [$HA_PeerNodeIP]:  \n");
	#		$text = <>;
	#		chomp($text);
	#		if($text eq "") {
	#			$text = $HA_PeerNodeIP;
	#		}
	#	}

	#	if (&isValidIPAddress($text)) {
	#		$HA_PeerNodeIP = $text;
	#		last;
	#	}
	#	else {
	#		$File_Screen_Logger->info("This is not a valid IP address.\n");
	#	}
	#}
	# peer node name and eht0's IP must match in /etc/hosts
	#if (!&HA_MatchNameIP($HA_PeerNodeName, $HA_PeerNodeIP)) {
	#	&FailedInstall("Peer node's host name ($HA_PeerNodeName) and IP address ($HA_PeerNodeIP) are not mapped in /etc/hosts file\nConfigure /etc/hosts file and try again ...\n");
	#}


	# ping node IP
	#while(1) {
	#	my $text = "";

	#	if ($HA_PingNodeIP eq "") {
	#		$File_Screen_Logger->info("Please enter ping node IP:  \n");
	#		$text = <>;
	#		chomp($text);
	#		if($text eq "") {
	#			next;
	#		}
	#	}
	#	else {
	#		$File_Screen_Logger->info("Please enter ping node IP [$HA_PingNodeIP]:  \n");
	#		$text = <>;
	#		chomp($text);
	#		if($text eq "") {
	#			$text = $HA_PingNodeIP;
	#		}
	#	}

	#	if (&isValidIPAddress($text)) {
	#		$HA_PingNodeIP = $text;
	#		last;
	#	}
	#	else {
	#		$File_Screen_Logger->info("This is not a valid IP address.\n");
	#	}
	#}

	# choose which node is the master node
	#while(1) {
	#	my $choice = "";
	#	my $text = "";

	#	if ($HA_MasterNodeName eq "") {
	#		$File_Screen_Logger->info("Please specify the master node (1: $HA_MyNodeName; 2: $HA_PeerNodeName):  \n");
	#		$choice = <>;
	#		chomp($choice);
	#		if($choice eq "1") {
	#			$HA_MasterNodeName = $HA_MyNodeName;
	#			last;
	#		}
	#		elsif ($choice eq "2") {
	#			$HA_MasterNodeName = $HA_PeerNodeName;
	#			last;
	#		}
	#		else {
	#			next;
	#		}
	#	}
	#	else {
	#		my $defaultChoice = "";
	#		my $defaultValue = "";
	#		if ($HA_MasterNodeName eq $HA_MyNodeName) {
	#			$defaultChoice = "1";
	#			$defaultValue = $HA_MyNodeName;
	#		}
	#		else {
	#			$defaultChoice = "2";
	#			$defaultValue = $HA_PeerNodeName;
	#		}
	#		$File_Screen_Logger->info("Please specify the master node (1: $HA_MyNodeName; 2: $HA_PeerNodeName) [$defaultChoice: $defaultValue]:  \n");
	#		$choice = <>;
	#		chomp($choice);
	#		if($choice eq "") {
	#			$text = $defaultValue;
	#		}
	#		elsif ($choice eq "1") {
	#			$text = $HA_MyNodeName;
	#		}
	#		elsif ($choice eq "2") {
	#			$text = $HA_PeerNodeName;
	#		}
	#		else {
	#			next;
	#		}

	#		if ($text ne $HA_MasterNodeName) {
#we need to warn user!
	#			my $res = &GetBooleanCharResponse("Warning: you choose a master node ($text) that is different from the one entered last time ($HA_MasterNodeName). You must make sure that the master node definition is the same on both nodes, otherwise you may risk damaging the data on the shared disk. Do you want to use this value ($text) as the master node and continue?");
	#			if($res == 'y') {
	#				$HA_MasterNodeName = $text;
	#				last;
	#			}
	#			else {
	#				next;
	#			}
	#		}
	#		else {
	#			$HA_MasterNodeName = $text;
	#			last;
	#		}
	#	}
	#}
## --
	# specify auto_failback on/off
#	while(1) {
#		my $choice = "";
#		my $text = "";

#		if ($HA_AutoFailBack eq "") {
#			$File_Screen_Logger->info("Please specify the auto_failback flag (1: on; 2: off):  \n");
#			$choice = <>;
#			chomp($choice);
#			if($choice eq "1") {
#				$HA_AutoFailBack = "on";
#				last;
#			}
#			elsif ($choice eq "2") {
#				$HA_AutoFailBack = "off";
#				last;
#			}
#			else {
#				next;
#			}
#		}
#		else {
#			my $defaultChoice = "";
#			my $defaultValue = "";
#			if ($HA_AutoFailBack eq "on") {
#				$defaultChoice = "1";
#				$defaultValue = "on";
#			}
#			else {
#				$defaultChoice = "2";
#				$defaultValue = "off";
#			}
#			$File_Screen_Logger->info("Please specify the auto_failback flag (1: on; 2: off) [$defaultChoice: $defaultValue]:  \n");
#			$choice = <>;
#			chomp($choice);
#			if($choice eq "") {
#				$text = $defaultValue;
#			}
#			elsif ($choice eq "1") {
#				$text = "on";
#			}
#			elsif ($choice eq "2") {
#				$text = "off";
#			}
#			else {
#				next;
#			}

#			if ($text ne $HA_AutoFailBack) {
#we need to warn user!
#				my $res = &GetBooleanCharResponse("Warning: you choose an auto_failback flag ($text) that is different from the one entered last time ($HA_AutoFailBack). Generally you should define this value to be the same on both nodes, otherwise the fail-over operation may not be appropriate. Do you want to use this value ($text) as the auto_failback flag and continue?");
#				if($res == 'y') {
#					$HA_AutoFailBack = $text;
#					last;
#				}
#				else {
#					next;
#				}
#			}
#			else {
#				$HA_AutoFailBack = $text;
#				last;
#			}
#		}
#	}


    # get node name details
#    &getNodeName()

}

sub getNodeName(){
     #my $ret = `cat /var/lib/heartbeat/rsm-node-id | grep \"34d2cda6-170c-4615-8088-4eed90d45802\" |  grep -c -v grep`;
     my $ret=0;
     open (CONSOLE, " cat /var/lib/heartbeat/rsm-node-id | grep \"34d2cda6-170c-4615-8088-4eed90d45802\" |  grep -c -v grep 			| ");
     while (<CONSOLE>){
 		$ret=$_;
	} 
    # match found
    if($ret==1){
        $HA_Node1Uname  =   $HA_MyNodeName;
        $HA_Node2Uname  =   $HA_PeerNodeName;
	$FileLogger->info(" Name for node id 34d2cda6-170c-4615-8088-4eed90d45802 is $HA_Node1Uname");
	$FileLogger->info(" Name for node id 1fd41a2a-0742-45bd-8a63-09d2ada467f2 is $HA_Node1Uname");
   
    }else{
        #$ret = `cat /var/lib/heartbeat/rsm-node-id | grep \"1fd41a2a-0742-45bd-8a63-09d2ada467f2\" |  grep -c -v grep`;
	open (CONSOLE, " cat /var/lib/heartbeat/rsm-node-id | grep \"1fd41a2a-0742-45bd-8a63-09d2ada467f2\" |  grep -c -v 			grep | ");
	while (<CONSOLE>){
 		$ret=$_;
	} 
        if($ret==1){
            $HA_Node2Uname  =   $HA_MyNodeName;
            $HA_Node1Uname  =   $HA_PeerNodeName;
            $FileLogger->info(" Name for node id 34d2cda6-170c-4615-8088-4eed90d45802 is $HA_Node1Uname");
	    $FileLogger->info(" Name for node id 1fd41a2a-0742-45bd-8a63-09d2ada467f2 is $HA_Node1Uname");
       
        }else{
            &FailedInstall( "Installation failed. Invalid node id in cib.xml.\n");
        }
    }
}

##
## get the Hardware details
##

sub getHardwareType(){
    if($RSM_OS_TYPE eq "RHEL"){
     return ;  	
    }
    $Hardware = `fruconfig -b | grep "Chassis OEM Field"`;
    my $Jarrell = "SR2400";
    my $Annapolis = "TIGH2U";
    if($Hardware=~m/$Jarrell/){
        $isJarrell=1;
    }
    if($Hardware=~m/$Annapolis/){
        $isAnnapolis=1;
    }
}


##
## Generate configuration files based on collected HA info
##
sub HA_UpdateConfig()
{
	# JBoss start-up script (nextoneJBoss)
    my $HAConfDir = "$TmpDir/haconf";
	&HA_UpdateIPForJBoss($HA_ManagementIP);
	if(!$isPeerHAInstalled){
        #update confiuration files
        # cib.xml
        $File_Screen_Logger->info("Updating cib.xml ....\n");
        &HA_updateConfiguration("cib.xml",$HAConfDir);
        # ha.cf
        $File_Screen_Logger->info("Updating ha.cf ....\n");
        &HA_updateConfiguration("ha.cf",$HAConfDir);
        # rsmres
        #$File_Screen_Logger->info("Updating rsmres ....\n");
        #&HA_updateConfiguration("rsmres",$HAConfDir);
        # rsmresend
        #$File_Screen_Logger->info("Updating rsmresend ....\n");
        #&HA_updateConfiguration("rsmresend",$HAConfDir);
        # rsmsyncpam
        $File_Screen_Logger->info("Updating rsmsyncpam ....\n");
        &HA_updateConfiguration("rsmsyncpam",$HAConfDir);
    }

	# adjust firewall rules
	&HA_firewallRules();
}

##
## update my.cnf
##

sub UpdateMyCnf()
{
    if($isAnnapolis){
        &run_command("cp -p $TmpDir/my.cnf.Annapolis $TmpDir/my.cnf");
    }else{
        &run_command("cp -p $TmpDir/my.cnf.Jarrell $TmpDir/my.cnf");
    }
}

##
## update configuration with collected info
##

sub HA_updateConfiguration()
{
    my($filename, $confdir) = @_;
    my $tmp_filename= $filename.".tmp";
    $FileLogger->info("Upating filename $filename with the following value set");
    $FileLogger->info(" LOCAL_UNAME = $HA_MyNodeName and PEER_UNAME = $HA_PeerNodeName and RSM_IP = $HA_ManagementIP");
    $FileLogger->info(" LOCAL_ETH1_IP = $HA_PeerNodeHeartbeatIP and PEER_ETH1_IP = $HA_PeerNodeHeartbeatIP");
    $FileLogger->info(" NODE1_UNAME = $HA_Node1Uname and NODE2_UNAME = $HA_Node2Uname");
		
	open(FIN,"<$confdir/$filename");
	open(FOUT,">$confdir/$tmp_filename");
	while(my $line = <FIN>)
	{
		$line =~ s/%LOCAL_UNAME%/$HA_MyNodeName/;
		$line =~ s/%PEER_UNAME%/$HA_PeerNodeName/;
        $line =~ s/%RSM_IP%/$HA_ManagementIP/;
		$line =~ s/%LOCAL_ETH1_IP%/$HA_PeerNodeHeartbeatIP/;
		$line =~ s/%PEER_ETH1_IP%/$HA_PeerNodeHeartbeatIP/;
		$line =~ s/%NODE1_UNAME%/$HA_Node1Uname/;
		$line =~ s/%NODE2_UNAME%/$HA_Node2Uname/;

		print FOUT $line;
	}
	close FIN;
	close FOUT;
	system("mv $confdir/$tmp_filename $confdir/$filename");
}



##
## update rsync_pam.sh with collected info
##
sub HA_updateRsync_pam()
{
	open(fin,"<$TmpDir/rsync_pam.sh");
	open(fout,">$TmpDir/rsync_pam.sh.tmp");
	while(my $line = <fin>)
	{
		$line =~ s/%PEER_HEARTBEAT_IP%/$HA_PeerNodeHeartbeatIP/;
		$line =~ s/%PEER_HEARTBEAT_IP_0%/$HA_PeerNodeIP/;
		print fout $line;
	}
	close fin;
	close fout;
	system("mv $TmpDir/rsync_pam.sh.tmp $TmpDir/rsync_pam.sh");
}

##
## Initalize data
##

sub HA_Init()
{
    # Get Peer eth1 ipaddress
    my $eth1IP= &run_command("ifconfig eth1 | grep \"inet addr\" | cut -d':' -f2 |cut -d' ' -f1");
    if("$eth1IP" == ""){
        $eth1IP= &run_command("ifconfig eth1 | grep \"inet6 addr\" | cut -d' ' -f13| cut -d/ -f1");
    }
    if($eth1IP=~m/$Node1ETH1IP/){
        $HA_PeerNodeHeartbeatIP=$Node2ETH1IP;
    }else{
        if($eth1IP=~m/$Node2ETH1IP/){
            $HA_PeerNodeHeartbeatIP=$Node1ETH1IP;
        }else{
             &FailedSetupNoCleanupRequired( "Installation failed. Invalid eth1 $HA_PeerNodeHeartbeatIP.\n");
        }
    }


	#setup key for installation
	#if key doesn't exist set them up

    my $priKey = "/root/.ssh/id_rsa";
    my $pubKey = "$priKey.pub";
	if (! -e "$priKey" || ! -e $pubKey){
        system("rm -f $priKey $pubKey");
        &run_command("ssh-keygen -t rsa -b 2048 -f $priKey -N ''");

        print "Please enter peer system ssh";
        &run_command("cat $pubKey | ssh -o StrictHostKeyChecking=no root\@$HA_PeerNodeHeartbeatIP 'cat >> .ssh/authorized_keys'");
        &run_command(" ssh root\@$HA_PeerNodeHeartbeatIP \"ssh-keygen -t rsa -b 2048 -f $priKey -N ''\"");
        &run_command(" scp root\@$HA_PeerNodeHeartbeatIP:$pubKey /root/.ssh/authorized_keys");    
    }
}


##
## set up key pair for rsync to use SSH tunnel
##
sub HA_SetupSshKey()
{
	# setup key for rsync
	my $status;
	my $priKey = "$OptDir/rsm/.ssh-key";
	my $pubKey = "$priKey.pub";

	# generate a key pair
	if (! -f "$priKey" || ! -f $pubKey) {
		system("rm -f $priKey $pubKey");
		#$status = system("ssh-keygen -t rsa -b 2048 -f $priKey -N ''");
		$status = `ssh-keygen -t rsa -b 2048 -f $priKey -N ''>> /dev/null 2>&1 &`;
        if($status) {
			&FailedInstall("Failed to generate public/private rsa key pair");
		}
	}
    sleep 5;
	# add "from" option to public key: only allow the peer to access via the key
	my $from = "from=\"*$HA_PeerNodeHeartbeatIP*,*$HA_PeerNodeIP*\" ";
	my $line = `cat $pubKey`;
	$line = $from . $line;
	open(fout,">$TmpDir/pubKey.tmp");
	print fout $line;
	close fout;

	# copy the keys to /root/.ssh
	&run_command("mv $TmpDir/pubKey.tmp /root/.ssh/authorized_keys");
	&run_command("cp $priKey /root/.ssh/ssh-key-for-rsync");

}


##
## adjust firewall rules:
##  1: open up eth1;
##  2: open 694/UDP on eth0
##
sub HA_firewallRules()
{
	chdir "$StartDir";
	system("chmod +x ./ha_firewall.sh");
	system("./ha_firewall.sh");
}

##
## update JBoss start-up script with management IP
##
sub HA_UpdateIPForJBoss()
{
	my($ip) = @_;
	open(JBossScrIn,"<$TmpDir/nextoneJBoss");
	open(JBossScrOut,">$TmpDir/nextoneJBoss.tmp");
	my $JbossBindIp = "0.0.0.0";
	my $JbossBindShutDownIp = "0.0.0.0";
    my $JvmIPv4Parameter="java.net.preferIPv4Stack";
    my $JvmIPv6Parameter="java.net.preferIPv6Stack";
	while(my $line = <JBossScrIn>) {
		if ($typeOfInstall == 1 ) {
			if ( $line=~m/$nextoneJbossUlimitString/ ) {
				print JBossScrOut $line;
				$line="#set the ulimit to generate core when java crashes\n";
				print JBossScrOut $line;
				$line="ulimit -c unlimited\n" ;
				print JBossScrOut $line;
				$line="#set the core filepath\n";
				print JBossScrOut $line;
				$line="echo /var/log/RSMcore-%e-%p-%t > /proc/sys/kernel/core_pattern\n" ;
				print JBossScrOut $line;
				$line="\n"
			}
		}
		$line =~ s/%MANAGEMENTIP%/-b $JbossBindIp/;
		$line =~ s/%SHUTDOWNIP%/-s $JbossBindShutDownIp/;
        $line=~s/$JvmIPv4Parameter/$JvmIPv6Parameter/;
		print JBossScrOut $line;
	}
	close JBossScrIn;
	close JBossScrOut;
	system("mv $TmpDir/nextoneJBoss.tmp $TmpDir/nextoneJBoss");
}

##
## read HA configuration info from $HA_DataFile
##
sub HA_ReadInfo()
{
	if (! -f "$HA_DataFile") {
		return;
	}

	open(HA_INFO,"<$HA_DataFile");

	my $nodeName_0;
	my $nodeIP_0;
	my $heartbeatIP_0;
	my $nodeName_1;
	my $nodeIP_1;
	my $heartbeatIP_1;

	while (my $line = <HA_INFO>) {
		chomp($line);
		my ($key, $value) = split /\s+/, $line;
		if ($key eq "MANAGEMENT_IP") {
			$HA_ManagementIP = $value;
		}
#		elsif  ($key eq "MASTERNODE") {
#			$HA_MasterNodeName = $value;
#		}
#		elsif  ($key eq "AUTOFAILBACK") {
#			$HA_AutoFailBack = $value;
#		}
#		elsif  ($key eq "PINGNODE") {
#			$HA_PingNodeIP = $value;
#		}
		elsif  ($key eq "NODENAME_0") {
			$nodeName_0 = $value;
		}
		elsif  ($key eq "NODEIP_0") {
			$nodeIP_0 = $value;
		}
		elsif  ($key eq "HEARTBEATIP_0") {
			$heartbeatIP_0 = $value;
		}
		elsif  ($key eq "NODENAME_1") {
			$nodeName_1 = $value;
		}
		elsif  ($key eq "NODEIP_1") {
			$nodeIP_1 = $value;
		}
		elsif  ($key eq "HEARTBEATIP_1") {
			$heartbeatIP_1 = $value;
		}
	}

	close HA_INFO;

	if ($nodeName_0 eq $HA_MyNodeName) {
		$HA_PeerNodeName = $nodeName_1;
		$HA_PeerNodeIP = $nodeIP_1;
		$HA_PeerNodeHeartbeatIP = $heartbeatIP_1;
	}
	else {
		$HA_PeerNodeName = $nodeName_0;
		$HA_PeerNodeIP = $nodeIP_0;
		$HA_PeerNodeHeartbeatIP = $heartbeatIP_0;
	}

	# The existence of the .my.cnf file indicates that the RSM has
	# already been installed from the other server
	if ( -f "$OptDir/rsm/.my.cnf") {
		$HA_SecondInstall = 1;
	}
}

##
## save HA configuration info into $HA_DataFile
##
sub HA_SaveInfo()
{
	open(HA_INFO,">$HA_DataFile");

	print HA_INFO "MANAGEMENT_IP $HA_ManagementIP\n";
	#print HA_INFO "MASTERNODE $HA_MasterNodeName\n";
	#print HA_INFO "AUTOFAILBACK $HA_AutoFailBack\n";
	#print HA_INFO "PINGNODE $HA_PingNodeIP\n";
	print HA_INFO "NODENAME_0 $HA_MyNodeName\n";
	print HA_INFO "NODEIP_0 $HA_MyNodeIP\n";
	print HA_INFO "HEARTBEATIP_0 $HA_MyNodeHeartbeatIP\n";
	print HA_INFO "NODENAME_1 $HA_PeerNodeName\n";
	print HA_INFO "NODEIP_1 $HA_PeerNodeIP\n";
	print HA_INFO "HEARTBEATIP_1 $HA_PeerNodeHeartbeatIP\n";

	close HA_INFO;

	my $status = system ("cp /etc/my.cnf /opt/nxtn/rsm/.my.cnf");
}

##
## remove heartbeat configuration files
##
sub HA_RemoveHeartbeatConfigFiles()
{
	#system("rm -f /etc/ha.d/ha.cf");
	#system("rm -f /etc/ha.d/haresources");
	#system("rm -f /etc/ha.d/authkeys");
	#system("rm -f /etc/ha.d/resource.d/pm");
	#system("rm -f /etc/ha.d/resource.d/check-wget.sh");
	#system("rm -f /etc/ha.d/resource.d/rsync_pam.sh");
	system("rm -f /etc/ha.d/pam_files_to_sync");
	#system("rm -f /root/.ssh/authorized_keys");
	#system("rm -f /root/.ssh/ssh-key-for-rsync");
}

sub HA_Cleanup()
{
    &HA_StopMySQL();
    system ("rm -rf $HA_DataFile");
}

sub HA_StopMySQL()
{
        chdir $StartDir;
        my $status=1;
        my $procName = "$MySqlProcStr";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ProcExist($procName, $outFile))
        {
            #$File_Screen_Logger->info("MySql is running, attempting to stop MySql\n");
            #$status =  system ("/etc/init.d/mysql stop");
            if(! -f "/var/run/mysql/mysqld.pid"){
                system ("/etc/init.d/mysql stop");
            }else{
                system("$HA_ResourcePath/mysql stop");
            }
            my $procExists=&WaitProcExit($procName,4);
            if($procExists)
            {
                my @pid_mysql =`pgrep -f \"mysqld\"`;
                my $index=0;
                for ($index = 0 ; $index <= $#pid_mysql; $index++) {
                    $File_Screen_Logger->info("Killing Mysql process $pid_mysql[$index]... \n");
                    `kill -9 $pid_mysql[$index]`;
                }
                # &FailedInstall("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");

            }
        }
        chdir $TmpDir;
}

sub HA_StopMySQLOnPeer()
{
        chdir $StartDir;
	my ($peerIP) = @_;
        my $status=1;
        my $procName = "$MySqlProcStr";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ProcExistOnPeer($procName, $outFile,$peerIP))
        {
            #$File_Screen_Logger->info("MySql is running, attempting to stop MySql\n");
            #$status =  system ("/etc/init.d/mysql stop");
	
		my $ret="";
		my $fileName="/var/run/mysql/mysqld.pid" ;
		open (CONSOLE, " ssh $peerIP \"ls $fileName  \" | ");
        	while (<CONSOLE>){
                	        $ret=$_;
        	}		
		chomp($ret);
		if ($ret eq $fileName) {	
			system("ssh root\@$peerIP \"$HA_ResourcePath/mysql stop\"");
		}else {
			system ("ssh root\@$peerIP \"/etc/init.d/mysql stop\"");
		}	

            my $procExists=&WaitProcExitOnPeer($procName,5,$peerIP);
            if($procExists)
            {
                my @pid_mysql =`ssh root\@$peerIP \"pgrep -f \"mysqld\"\"`;
                my $index=0;
                for ($index = 0 ; $index <= $#pid_mysql; $index++) {
                    $File_Screen_Logger->info("Killing Mysql process $pid_mysql[$index]... \n");
                     system ("ssh root\@$peerIP \"kill -9 $pid_mysql[$index]\"");
                }
                # &FailedInstall("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");

            }
        }
        chdir $TmpDir;
}


sub HA_SecondInstallMySqlServer()
{
        chdir $StartDir;
        my $status=1;
        
        if( -f "/etc/my.cnf")
        {
            $status = system ("mv /etc/my.cnf /etc/my.cnf.old");
        }
        $status = system ("rm -rf /var/lib/mysql");
        $status = system ("rm -rf /var/lib/mysql-bak");

        $MySqlDir = "$OptNxtn/mysql/data";
        $MySqlLog = "$OptNxtn/mysql/log";

        chdir $TmpDir;
        $File_Screen_Logger->info("Installing $MySQLServerRpm ..");
        if ( ! -f $MySQLServerRpm)
        {
           &FailedInstall("Unable to find $MySQLServerRpm \n");
        }
        # Remove RPMs (if existing) before installing fresh version.
        my $mysqlCurrentVersion = &getMySqlVersion();

        if(!($mysqlCurrentVersion=~m/0\.0/)){

            #Get name of existing RPM
            my $existingRPM = `rpm -qa | grep MySQL-server`;
            chomp($existingRPM);
            my $status = system ("rpm -e $existingRPM");
	    }

        $status = system ("rpm -i --force $MySQLServerRpm");
		my $rpmIns = `rpm -qa | grep MySQL-server`;
		chomp($rpmIns);
		if(!($MySQLServerRpm=~m/$rpmIns/))
		{
			&FailedInstall("Unable to install MySql server. Are all dependencies installed?\n ".$!);
		}

		$File_Screen_Logger->info("Installing $MySQLServerRpm ..done");
		chdir $TmpDir;
}

sub HA_SecondConfigureMySqlServer()
{
        $FileLogger->info("entering");

#        SetMySQLPasswd ();

        ##
        ## Shutdown MySQL Database, copy databse files to $MySQLDir
        ## Create /etc/my.cnf
        ##

        $File_Screen_Logger->info("Shutting down MySQL Database.. \n");
        #my $status = system ("/usr/bin/mysqladmin -u root --password=\"$ROOT_Password\" shutdown");
        &HA_StopMySQL();
        my $status = system ("mv /var/lib/mysql /var/lib/mysql-bak");
        $status = system ("rm -rf /var/lib/mysql");

		#$status = system ("chown mysql:mysql $MySqlDir");
        $status = system ("chown mysql:mysql $OptNxtn/mysql");
        $status = system ("chown mysql:mysql $OptNxtn/mysql/log");
        $status = system ("chown mysql:mysql $OptNxtn/mysql/data");
		#$status = system ("chown mysql:mysql $MySqlLog");

        $status = system ("ln -s $OptNxtn/mysql/data /var/lib/mysql");
        $status = system ("chown mysql:mysql /var/lib/mysql");
        $status = system ("mv /var/lib/mysql-bak/mysql /var/lib/mysql");
        $status = system ("rm -rf /var/lib/mysql-bak");

        $File_Screen_Logger->info("Copying MySQL configuration file..");
        # Changed to remove the warning if my.cnf is not present
        if (-f "/etc/my.cnf")
        {
           $status = system ("mv /etc/my.cnf /etc/my.cnf.bak");
        }
        $status = system ("cp /opt/nxtn/rsm/.my.cnf /etc/my.cnf");
        $File_Screen_Logger->info("Copying MySQL configuration file..done");

        if(-f "/etc/rc.d/rc3.d/S99mysql")
        {
             $status = system ("rm /etc/rc.d/rc3.d/S99mysql");
        }
        $status = system ("ln -s /etc/init.d/mysql /etc/rc.d/rc3.d/S99mysql");

		##
		## Start the MySQL database
		##
		#$File_Screen_Logger->info("Starting MySQL Database.. ");
		#$status = system ("/etc/init.d/mysql start >/dev/null 2>&1");
		$MySqlInstalled='y';
		chdir $StartDir;
}

sub restoreOlderVersion(){
    if(!$isPeerHAInstalled){
        CopyOptToHome();
        my $status = system ("cp -pr $iVMSBakDir/* $JBossDir/.");
        &restartProcesses();
    }

}

sub restartProcesses(){
    if ($isRedundancySetup) {
        # Stop heartbeat if it is running
        $File_Screen_Logger->info("Starting heartbeat on local system ...\n");
        my $status = &run_command("/etc/init.d/heartbeat start");

        # tell user to stop heartbeat on peer node before proceeding
        $File_Screen_Logger->info("Starting heartbeat on peer system ...\n");
        &run_command("ssh root\@$HA_PeerNodeHeartbeatIP \"/etc/init.d/heartbeat start\"");
    }else{
        &run_command("/etc/init.d/jboss start");
        &run_command("/etc/init.d/mysql start");
    }

}

# Manage RSM system ports 
#added to call the script to block all ports other than the one used by rsm ( FP 56963 )
sub blockUnwantedPorts () {
 	$FileLogger->info(" Calling Port Blocking Script "); 
	system ("./$PortBlockingScriptName $HA_ManagementIP $NextoneOpt ") ;
	$FileLogger->info(" Executed Calling Port Blocking Script "); 

}


#function to find out SuSE release version for use in deploying firewall 
sub getSuSEVersionForFirewall() {

	# checking version of suse installed 
	if($RSM_OS_TYPE ne "RHEL"){
	open (CONSOLE, " cat /etc/SuSE-release  | grep VERSION | ");
	while (<CONSOLE>){
 		$SuSEVersion=$_;
	} 
	$SuSEVersion = substr($SuSEVersion,10) ;
	chomp($SuSEVersion) ;
  }
}

# function to copy new configuration file for SuSEfirewall
sub copyFirewallConfigFile () {

	$File_Screen_Logger->info("Copying firewall configuration files ...") ;  
	&getSuSEVersionForFirewall();
	if ($SuSEVersion < 9 ) {
		# not supported for version less than 9.x 
		$FileLogger->info("SuSE firewall not supported  ") ;

	}
	if ($isRedundancySetup) {
		if ( $SuSEVersion < 10 ){
		
			$FileLogger->info("SuSE version 9.x found. Going ahead with 9.x installation.  ") ;
			my $file = "$systemConfigDirectory/$firewallConfigFile" ;

			if  ( -f $file ) {
				$FileLogger->info ("Firewall Config File $file exists. " ) ;
				$FileLogger->info ("Taking backup.. ")  ;
				system (" mv -f  $systemConfigDirectory/$firewallConfigFile $systemConfigDirectory/$firewallConfigFile.orig") ;
			}
			else {
				$FileLogger->info ("Firewall Config file $file does not exists. ") ;
			}	
			$FileLogger->info(" Copying new firewall config file .. ") ;
			system (" cp -f  $TmpDir/$SuSE9HAfirewallConfigFile $systemConfigDirectory/$firewallConfigFile ") ;

		} else {

			$FileLogger->info(" SuSE version 10.x or higher found. Going ahead with 10.x installation ") ;
			my $file = "$systemConfigDirectory/$firewallConfigFile" ;

			if  ( -f $file ) {
				$FileLogger->info ("Firewall Config File $file exists. " ) ;
				$FileLogger->info ("Taking backup.. ")  ;
				system (" mv -f  $systemConfigDirectory/$firewallConfigFile $systemConfigDirectory/$firewallConfigFile.orig") ;
			}
			else {
				$FileLogger->info ("Firewall Config file $file does not exists.") ;
			}	
			$FileLogger->info("Copying new firewall config file .. ") ;
			system (" cp -f  $TmpDir/$SuSE10HAfirewallConfigFile $systemConfigDirectory/$firewallConfigFile ") ;
		} 
	} else {
		if ( $SuSEVersion < 10 ){
		
			$FileLogger->info(" SuSE version 9.x found. Going ahead with 9.x installation.  ") ;
			my $file = "$systemConfigDirectory/$firewallConfigFile" ;

			if  ( -f $file ) {
				$FileLogger->info ("Firewall Config File $file exists. " ) ;
				$FileLogger->info ("Taking backup.. ")  ;
				system (" mv -f  $systemConfigDirectory/$firewallConfigFile $systemConfigDirectory/$firewallConfigFile.orig") ;
			}
			else {
				$FileLogger->info ("Firewall Config file $file does not exists. ") ;
			}	
			$FileLogger->info("Copying new firewall config file .. ") ;
			system (" cp -f  $TmpDir/$SuSE9firewallConfigFile $systemConfigDirectory/$firewallConfigFile ") ;

			

		} else {

			$FileLogger->info("SuSE version 10.x or higher found. Going ahead with 10.x installation ") ;
			my $file = "$systemConfigDirectory/$firewallConfigFile" ;

			if  ( -f $file ) {
				$FileLogger->info ("Firewall Config File $file exists. " ) ;
				$FileLogger->info ("Taking backup.. ")  ;
				system (" mv -f  $systemConfigDirectory/$firewallConfigFile $systemConfigDirectory/$firewallConfigFile.orig") ;
			}
			else {
				$FileLogger->info ("Firewall Config file $file does not exists.") ;
			}	
			$FileLogger->info("Copying new firewall config file .. ") ;
			system (" cp -f  $TmpDir/$SuSE10firewallConfigFile $systemConfigDirectory/$firewallConfigFile ") ;
		} 

		&modifyFirewallConfiguration();
		
	}
	$File_Screen_Logger->info("Firewall configuration files copied. ") ;  
}


#function to enable the SuSEfirewall 
sub deployFirewall () {
	
	if($RSM_OS_TYPE eq "RHEL"){
		return;
	}
	#warning the user of break in ssh connection 
	$File_Screen_Logger->info("Installation successful, now configuring firewall for security purposes... ") ;
	$File_Screen_Logger->warn("\nWARNING : During these configuration changes the ssh connection may expire for this session. Please note that this will not affect the RSM installation.") ;
	# a small pause
	sleep(2) ;

	&getSuSEVersionForFirewall();

	if ($SuSEVersion < 9 ) {
		# not supported for version less than 9.x 
		$FileLogger->info(" SuSE firewall not supported  ") ;

	} elsif ( $SuSEVersion < 10 ){
	
		$FileLogger->info(" SuSE version 9.x found. Going ahead with 9.x installation.  ") ;
		$FileLogger->info("Establishing firewall... ") ;
		system (" chkconfig -a SuSEfirewall2_init ");
		system (" chkconfig -a SuSEfirewall2_setup ");
		system (" chkconfig -a SuSEfirewall2_final ");
		#firewall starting commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_init restart > firewall.tmp ; /etc/init.d/SuSEfirewall2_setup restart > firewall.tmp ; /etc/init.d/SuSEfirewall2_final restart > firewall.tmp ; rm -f firewall.tmp ") ;
		$File_Screen_Logger->info("Firewall has been successfully deployed ") ; 

	} else {

		$FileLogger->info(" SuSE version 10.x or higher found. Going ahead with 10.x installation ") ;
		$FileLogger->info(" Establishing firewall  .. ") ;
		system (" chkconfig -a SuSEfirewall2_init ");
		system (" chkconfig -a SuSEfirewall2_setup ");
		#firewall starting commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_init restart > firewall.tmp ; /etc/init.d/SuSEfirewall2_setup restart > firewall.tmp ; rm -f firewall.tmp ");
		$File_Screen_Logger->info("Firewall has been successfully deployed.") ; 

	} 
	
	$File_Screen_Logger->info("Done") ;  
	
}

sub removeFirewall () {

	if($RSM_OS_TYPE eq "RHEL"){
		return;
	}
	$File_Screen_Logger->info ("\nRestoring original firewall changes ... \n") ;
 	sleep(2);

	&getSuSEVersionForFirewall() ;
	if ($SuSEVersion < 9 ) {

		$FileLogger->info(" SuSE firewall not installed  ") ;

	} elsif ( $SuSEVersion < 10 ){

		$FileLogger->info(" SuSE version 9.x found. Going ahead with 9.x uninstallation.") ;
		my $file = "$systemConfigDirectory/$firewallConfigFile.orig" ;
		if ( -f $file ) {
			$FileLogger->info(" Removing present configuration file and restoring original .. ") ;
			system (" rm -f $systemConfigDirectory/$firewallConfigFile") ;
			system (" mv -f $systemConfigDirectory/$firewallConfigFile.orig $systemConfigDirectory/$firewallConfigFile ") ;
		}
		$FileLogger->info("Removing  firewall  .. ") ;
		system (" chkconfig -d SuSEfirewall2_final ");
		system (" chkconfig -d SuSEfirewall2_setup ");
		system (" chkconfig -d SuSEfirewall2_init ");
		#firewall stopping commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_final stop ; /etc/init.d/SuSEfirewall2_setup stop ; /etc/init.d/SuSEfirewall2_init stop ");

	} else {

		$FileLogger->info(" SuSE version 10.x or higher found. Going ahead with 10.x uninstallation ") ;
		my $file = "$systemConfigDirectory/$firewallConfigFile.orig" ;
		if ( -f $file ) {
			$FileLogger->info("Removing present configuration file and restoring original .. ") ;
			system (" rm -f $systemConfigDirectory/$firewallConfigFile") ;
			system (" mv -f $systemConfigDirectory/$firewallConfigFile.orig $systemConfigDirectory/$firewallConfigFile ") ;
		}
		$FileLogger->info("Removing firewall  .. ") ;
		system (" chkconfig -d SuSEfirewall2_setup ");
		system (" chkconfig -d SuSEfirewall2_init ");
		#firewall stopping commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_setup stop ; /etc/init.d/SuSEfirewall2_init stop ");
		
	} 

	$File_Screen_Logger->info("Done") ; 
	

}


sub checkIfCorrectRSMOSInstalled() {

	# intialized with value 2 which is the value returned by the script if OS check fails 
	my $isCorrectOS = 2;
	my $rel='' ;
	$FileLogger->info("RSM Linux release version for the RSM version being installed is $RSMLinuxVersion") ;
	if( $RSM_OS_TYPE eq "RHEL" && -e $RHELRelFileName){
		open (CONSOLE, "cat $RHELRelFileName | grep -e \"Red \" | cut -d ' ' -f7 |");
		while (<CONSOLE>){
 			$rel=$_;
			chomp($rel);
		} 	
		$FileLogger->info("RHEL release version found is  $rel ") ;
	
 		if ($rel eq $RHELOsVersion) {
			$isCorrectOS=0;
 		} else {
			$isCorrectOS=1;
 		}			
	}
	elsif ( -e $relFileName ) {
		open (CONSOLE, "cat $relFileName | grep -e \"^VERSION = \" | cut -d ' ' -f3 |");
		while (<CONSOLE>){
 			$rel=$_;
			chomp($rel);
		} 	
		$FileLogger->info("RSM Linux release version found is  $rel ") ;
	
 		if ($rel eq $RSMLinuxVersion) {
			$isCorrectOS=0;
 		} else {
			$isCorrectOS=1;
 		}			
	} else {	
		$isCorrectOS = 2;
		$FileLogger->info("RSM Linux release file $relFileName not found !! ") ;
	}
	#$isCorrectOS = system ("./$checkOSScriptName") ;

	if ($isCorrectOS != 0 ) {
			&FailedSetupNoCleanupRequired("Correct RSM OS version not found, exiting installation.\n\n");
	}

}



#gets all configured network interfaces present on the machine
sub getAllNetworkInterfaces () {

	$FileLogger->info("Populating list of all network configured interfaces  ...  ") ;  
	my $interface = "" ;
	open (CONSOLE, " ifconfig -a| cut -d\" \" -f1 |");
		while (<CONSOLE>){
			$interface=$_;
			chomp($interface);
			if ($interface=~m/eth/)  {
				push(@interfaceArray,$interface) ;	
			}
		}
	$FileLogger->info("List populated successfully   ") ;  	
}

#prints all the interfaces present in the list
sub printNetworkInterfaces (){
	my $index = 0 ;
	for ($index = 0 ; $index <= $#interfaceArray; $index++) {
		if ($interfaceArray[$index] ne "lo" && $interfaceArray[$index] ne "" ) {
			$File_Screen_Logger->info("$interfaceArray[$index]\n") ;
		}
	}
}

#checks if network interface is present in the network interfaces list
sub checkIfValidInterface () {
	
        my ($tmp) = @_;	
	my $index = 0 ;

	if ( $tmp eq "lo" || $tmp eq "" ) {
		return 0 ;
	}

	for ($index = 0 ; $index <= $#interfaceArray; $index++) {
		if ($interfaceArray[$index] eq $tmp) {
			return 1 ;
		}
	}
	return 0 ;
}

#make changes in the firewall configuration file according to external and internal network interfaces entered by user
#
# FW_PROTECT_FROM_INTERNAL="no" opening the internal interface completely.	
# FW_PROTECT_FROM_INT="list of internal interfaces entered by user" (like "eth0 eth1")
# FW_PROTECT_FROM_EXT="list of external interfaces entered by user" (like "eth0 eth1")
#
sub updateFirewallConfigFile () {

	my $index = 0 ;
	my $extInterfaceString= "" ;
	my $intInterfaceString= "" ;
	$FileLogger->info("Updating firewall configuration files ...  ") ;  
	$File_Screen_Logger->info("Updating firewall configuration files ...  ") ;  
	&getSuSEVersionForFirewall();
	if ($SuSEVersion < 10 ) {
		$extInterfaceString= "" ;
		$intInterfaceString= "" ;

	}else {
		$extInterfaceString= "any" ;
		$intInterfaceString= "" ;
	}
	

	if ($SuSEVersion < 10 ) {
		system ( "sed --in-place=.old \	-e '/^FW_PROTECT_FROM_INTERNAL=/s/FW_PROTECT_FROM_INTERNAL=.*/FW_PROTECT_FROM_INTERNAL=\"no\"/' /etc/sysconfig/SuSEfirewall2");	

	}else {
		system ( "sed --in-place=.old \	-e '/^FW_PROTECT_FROM_INT=/s/FW_PROTECT_FROM_INT=.*/FW_PROTECT_FROM_INT=\"no\"/' /etc/sysconfig/SuSEfirewall2");	
		
	}

	for ($index = 0 ; $index <= $#mgmtInterfaceArray; $index++) {
		$extInterfaceString = "$mgmtInterfaceArray[$index] $extInterfaceString" ;
	}
	$FileLogger->info("Firewall configuration for external network : $extInterfaceString   ") ;  
	
	for ($index = 0 ; $index <= $#intInterfaceArray; $index++) {
		$intInterfaceString = "$intInterfaceArray[$index] $intInterfaceString" ;
	} 
	$FileLogger->info("Firewall configuration for internal network : $intInterfaceString   ") ;  
	system ("sed --in-place=.old \ -e '/^FW_DEV_EXT=/s/FW_DEV_EXT=.*\$/FW_DEV_EXT=\"$extInterfaceString\"/' /etc/sysconfig/SuSEfirewall2 ") ;
	system (" sed --in-place=.old \	-e '/^FW_DEV_INT=/s/FW_DEV_INT=.*\$/FW_DEV_INT=\"$intInterfaceString\" /' /etc/sysconfig/SuSEfirewall2 ") ;		
	

}

#deletes interfaces from list when they are added to external or internal network interface list by user
sub popFromInterfaceList (){

	my ($tmp) = @_;	
	my $index = 0 ;
	for ($index = 0 ; $index <= $#interfaceArray; $index++) {
		if ($interfaceArray[$index] eq $tmp) {
			delete $interfaceArray[$index];
			return ;
		}
	}	
	

}

#function to change the SuSEfirewall configuration file according to user inputs
sub modifyFirewallConfiguration () {

	$File_Screen_Logger->info("Modifying firewall configuration files ... ") ;  
	my $ifchk = 0;
	my $resp = "" ;
	my $next=0 ; 
	&getAllNetworkInterfaces();
	$File_Screen_Logger->info ("\nFirewall Configuration:");
	$File_Screen_Logger->info("\nPlease select the interface to be used as management interface:  ");
	&printNetworkInterfaces();
	while(1) {
		$File_Screen_Logger->info("Enter your choice[eth0]");
		$resp = <>;
        	chomp($resp);
		if ($resp eq "")
		{
			push(@mgmtInterfaceArray,"eth0");
			&popFromInterfaceList("eth0");
			last;
		}else {
			$ifchk = &checkIfValidInterface($resp);
			if ($ifchk == 1) {
				push(@mgmtInterfaceArray,$resp) ;
				&popFromInterfaceList($resp) ;
				$ifchk=0;
				last;
			}else {
				$File_Screen_Logger->info("Select a valid network interface from the list:");
				&printNetworkInterfaces ();	
			}
		}
	}
	while (1) {
		$File_Screen_Logger->info ("Do you wish to enter more management interfaces? (y or n) [n] ");
		$resp = <>;
        	chomp($resp);
		$next=0; 
		if ($resp eq 'y' || $resp eq 'Y' ) {
			$next = 1;	
			last;
		}elsif ($resp eq 'n' || $resp eq 'N' || $resp eq "" ) {
			$next = 0;
			last;
		}else {
			$File_Screen_Logger->info ("Enter a valid choice.");
		}
	}
	
	while ($next) {
		$File_Screen_Logger->info ("Enter your choice (Enter '0' to exit):");
		$resp = <>;
               	chomp($resp);
		if ($resp eq "0" )
		{
			$next = 0;
		} else {
			$ifchk = &checkIfValidInterface($resp) ;
			if ($ifchk == 1) {
				push(@mgmtInterfaceArray,$resp) ;
				&popFromInterfaceList($resp) ;
				$ifchk = 0;
			}else {
				$File_Screen_Logger->info("Select a valid network interface from the list:");
				&printNetworkInterfaces ();	
			}

		}
	}

	$File_Screen_Logger->info("Please select the interface to be used as internal interface:  ");
	&printNetworkInterfaces () ;
	$next = 1 ;
	
	while ($next) {
		$File_Screen_Logger->info ("Enter your choice (Enter '0' to exit):") ;
		$resp = <>;
               	chomp($resp);
		if ($resp eq "0"){
			$next=0;
		} else {
			$ifchk = &checkIfValidInterface($resp) ;
			if ($ifchk==1) {
				push(@intInterfaceArray,$resp) ;
				&popFromInterfaceList($resp) ;
				$ifchk = 0;
			}else {
				$File_Screen_Logger->info("Select a valid network interface from the list:");
				&printNetworkInterfaces ();	
			}

		}
	}	

	&updateFirewallConfigFile() ;

}
#function to control the ssh access to protocol version 2
sub modifySshProtocol() {
     print "\nUpdating SSH configuration to control its access to protocol version 2 only ...  \n" ;
     my @arrayOfCorrectPros = () ;
     my $status;
     my $ProtocolString = "Protocol";
     my @arrayComma = ();
     my @arraySpace = ();
     my $index;
     my $ind;
     my $lineTmp;
     my $IsProtocolSpecified;
     open(SshIn,"<$SshDir/sshd_config");
     open(SshOut,">$SshDir/sshd_config.tmp");
     while (my $line = <SshIn>) {
	#remove leading spaces from the line
	$line =~ s/^\s+//;
        $status = index($line, $ProtocolString);

	#check whether line starts with string "Protocol"
        if ($status eq 0) {
		$IsProtocolSpecified = 1;
		@arrayOfCorrectPros = () ;
		@arrayComma = split(/,/, $line);
		for ($index = 0 ; $index <= $#arrayComma; $index++) {
			@arraySpace = split(/ /, $arrayComma[$index]);
			for ($ind = 0 ; $ind <= $#arraySpace; $ind++) {
				if (($arraySpace[$ind] =~ m/\d/) && ($arraySpace[$ind] != 1)){
					push( @arrayOfCorrectPros,$arraySpace[$ind] ) ;	
				}	
			}
		}
		$lineTmp = join(',',@arrayOfCorrectPros);
		$line = "Protocol " . $lineTmp . "\n";
        }

        print SshOut $line;

     }
     close SshIn;
     close SshOut;
	$status = system("mv $SshDir/sshd_config.tmp $SshDir/sshd_config");
	$status = system("rm -rf $SshDir/sshd_config.tmp");
	if (!$IsProtocolSpecified){
		open (F, ">>/etc/ssh/sshd_config") || die "Could not open file: $!\n";
		print F "Protocol 2\n";
		close F;
	}
	$status = system("/etc/init.d/sshd restart");  


}

sub promptUserToTakeDBBackupBeforeUpgrade() {

     $File_Screen_Logger->info("We strongly recommend that you take a backup copy of the database before proceeding with the upgrade. To take a backup copy of your database, please run the 'rsm_backup_restore.sh' script available with the install package.");     
     my $backupFlag = &GetBooleanCharResponse ("Have you taken a backup copy of your current database ?");
     if($backupFlag eq "n")
     {
	&FailedSetupNoCleanupRequired("to backup not being taken before upgrade. Please take backup of database before proceeding with upgrade.\nExiting....\n ");
     }
     
}

#function to check the PAM Users data
sub checkPAMUsersData () {
	$File_Screen_Logger->info("\nStarting validation of configured users in the system ...") ;
	my @correctArray = () ;
	my @arrayCorruptUsers = ();
	my $status;
	my $stringToFind = "*;*;";
	my @arraySemicolon = ();
	my $index;
	my $lineOut;
	$status = system("cp /etc/security/time.conf /etc/security/time.conf.orig");
	open(timeConfIn,"</etc/security/time.conf");
	open(timeConfOut,">/etc/security/time.conf.tmp");
	while (my $line = <timeConfIn>) {
		#remove leading spaces from the line
		$line =~ s/^\s+//;
		$status = index($line, $stringToFind);
		#check whether line starts with string "stringToFind"
		if ($status eq 0) {
			@correctArray = () ;
			@arraySemicolon = split(/;/, $line);
			for ($index = 0 ; $index <= $#arraySemicolon; $index++) {
				if($index == 3){
					if(!($arraySemicolon[$index]=~m/Su/ || $arraySemicolon[$index]=~m/Mo/ 
					|| $arraySemicolon[$index]=~m/Tu/ ||$arraySemicolon[$index]=~m/We/ 
					||$arraySemicolon[$index]=~m/Th/||$arraySemicolon[$index]=~m/Fr/ 
					||$arraySemicolon[$index]=~m/Sa/||$arraySemicolon[$index]=~m/!Al/)){
						push(@arrayCorruptUsers,$arraySemicolon[$index-1]) ;
						$arraySemicolon[$index]	= "!Al".$arraySemicolon[$index];
					}
				}
				push(@correctArray,$arraySemicolon[$index] ) ;	
			}
			$lineOut = join(';',@correctArray);
		}
		else{
			$lineOut = $line;
		}
		print timeConfOut $lineOut;
	}
	close timeConfIn;
	close timeConfOut;
	my $count = 0 ;
	for my $user (@arrayCorruptUsers) {
		$count = $count+1;
	}
	if($count>0){
		$File_Screen_Logger->info("\nPam time configurations of the following ".$count." user(s) were found to be corrupt and hence rectified ...\n") ;
		for my $user (@arrayCorruptUsers) {
	        	$File_Screen_Logger->info($user."\n");
		}
		system("mv /etc/security/time.conf.tmp /etc/security/time.conf");
	}
	else{
		system("rm /etc/security/time.conf.tmp");
		system("rm /etc/security/time.conf.orig");
		$File_Screen_Logger->info("\nPam time configuration of all the users is found to be correct and hence no action is being taken ...\n") ;
	}
}

sub changeIvmsUserPasswd() {

        $FileLogger->info("entering changeIvmsUserPasswd() ");
        my ($dbPasswd) = @_;
	open (TMP1,">change_ivms_user_pwd_tmp.sql");
 	print TMP1 "USE mysql;";
	print TMP1  "UPDATE user SET password = PASSWORD('$dbPasswd') where User = 'ivms';";
	print TMP1  "UPDATE user SET password = PASSWORD('$dbPasswd') where User = '';";
	print TMP1 "FLUSH PRIVILEGES;";
 	close (TMP1);
	my $pwdStatus =system("mysql -u root --password=$ROOT_Password  < change_ivms_user_pwd_tmp.sql");
	system (" rm -f change_ivms_user_pwd_tmp.sql");
        if($pwdStatus)
         {
                 $FileLogger->info("Unable to change password of ivms user.");
                 return 1;
         }else {
		$FileLogger->info("Successfully changed password of ivms user.");
		return 0;
	}

	

}

sub HA_processing()
{
	&run_command("cat /root/.ssh/known_hosts >> /root/.ssh/known_hosts_bkup; >/root/.ssh/known_hosts");

}


#
# Checks whether the mysql data files and the mysql log directories of the current mysql installation
# are consistent with the entries in /etc/my.cnf 
# returns 'y' is installation is found to be consistent else returns 'n'
#

sub checkMySQLInstallation() {
	my $ret=0;	
	my $retStatus=0;
	my $mount_data=" $Mysql_data_mount_pt ";
	my $cmd="mount | grep $Mysql_data_mount_pt ";
	$ret=&getOutputFromConsole($cmd);
		
    if (!($ret=~m/$mount_data/)) {
       	$retStatus=&checkMyCnfDataFileConsistency("");
    } else {
		$retStatus=&checkMyCnfDataFileConsistency($Mysql_data_mount_pt);
	}
	
	if ($retStatus == 1 ) {
		$FileLogger->info(" Inconsistency found in my.cnf enteries and filesystem.\n");	
		return 'n';
	}

	if ($retStatus == 2 ) {
		$FileLogger->info(" Fresh installation detected.\n");	
		return 'f';
	}

	$ret=0;	
	$mount_data=" $Mysql_log_mount_pt ";
	$cmd=" mount | grep $Mysql_log_mount_pt ";
	$ret=&getOutputFromConsole($cmd);

	if (!($ret=~m/$mount_data/))
	{
		$retStatus=&checkMysqlLogDirectory("");
	}else {
		$retStatus=&checkMysqlLogDirectory($Mysql_log_mount_pt);
	}
	
	if ($retStatus == 1 ) {
		$FileLogger->info(" Existing mysql log directory for the installation not a mount partition .\n");
		return 'n';
	}

	if ($retStatus == 2 ) {
		$FileLogger->info(" Fresh installation detected.\n");	
		return 'f';
	}

	return 'y';
}

#
# Checks whether the mysql data files and the mysql log directories of the current mysql installation
# are present in the OCFS2 mount paritions and are consistent with the entries in /etc/my.cnf 
# returns 'y' is installation is found to be consistent else returns 'n'
#

sub HA_checkMySQLInstallation() {
	my $ret=0;
	my $retStatus=0;
	
	$retStatus=&checkMyCnfDataFileConsistency("");
	if ($retStatus == 1 ) {
		$FileLogger->info(" Inconsistency found in my.cnf enteries and filesystem.\n");		
		return 'n';
	}
	
	if ($retStatus == 2 ) {
		$FileLogger->info(" Fresh installation detected.\n");	
		return 'f';
	}
    
	$retStatus=&HA_checkMysqlLogDirectory();
	if ($retStatus == 1 ) {
		$FileLogger->info(" Existing mysql log directory for the installation is not an active OCFS2 mount partition .\n");
		return 'n';
	}
	
	if ($retStatus == 2 ) {
		$FileLogger->info(" Fresh installation detected.\n");	
		return 'f';
	}
	return 'y';
}

#
# Reads the data files entered in my.cnf and checks whether each of them exists and is of the same size on the system
# Also, checks whether the file are on the ocfs partition (in case of HA) and if they are on the mounted directory 
# "/opt/nxtn/mysql/data" in case of "/opt/nxtn/mysql/data" is a mounted partition.
#

sub checkMyCnfDataFileConsistency() {
	my ($mysql_data_file_path)= @_ ;	
	my $cnfFile = "/etc/my.cnf";
	my $mysqld_innodb_data_file_path="";	
	
 	if (! -e "$cnfFile" ){
        $FileLogger->info("Unable to find my.cnf for existing installation.\n");
		return 1;
    }

    open (FINPUT, "< $cnfFile")
        or die "Couldn't open file to read ! \n";

	while(my $line  = <FINPUT>)
	{
		if($line !~m/^#/){
		   if($line =~m/innodb_data_file_path/){
			 $mysqld_innodb_data_file_path=$line;
			 last;
		   }
		}
	}

	close (FINPUT);
	chomp($mysqld_innodb_data_file_path);	


	my $valIndex = index($mysqld_innodb_data_file_path,"=");
	my $valString = substr($mysqld_innodb_data_file_path,$valIndex+1);
	chomp($valString);
	$FileLogger->info("The innodb data file entry is : $valString.\n");

	my $startIndex=0;
	my $endIndex=0;
	my $retStatus=0;

	while ($endIndex < length($valString)) {
		$endIndex= index($valString,";",$startIndex);
		
		if ($endIndex == -1 ) {
			$endIndex=length($valString);
		}

		my $fileString=substr($valString,$startIndex,$endIndex-$startIndex);
		$startIndex=$endIndex+1;
		my $sizeIndex=index($fileString,":");
		if ($sizeIndex == -1 ) {
			$FileLogger->info("\nCannot find file size entry in string : $fileString.");;
			return 1;
		}
		my $fileName=substr($fileString,0,$sizeIndex);
		my $size = substr($fileString,$sizeIndex+1,length($fileString)-$sizeIndex-1);

		$FileLogger->info("\nData file read with name : $fileName and size : $size.");

		if ($isRedundancySetup) {
			$retStatus=&HA_checkMysqlDataFilePath($fileName);
		} else {
			$retStatus=&checkMysqlDataFilePath($mysql_data_file_path,$fileName);
		}
		
		if ($retStatus == 1 ) {
			$FileLogger->info("\nData file with name : $fileName and size : $size not in correct path.");
			return 1;
		}

		$retStatus=&checkMysqlDataFileEntry($fileName,$size);
		if ($retStatus == 1 ) {
			$FileLogger->info("\nDate file entry with name : $fileName and size : $size not consistent with filesystem.");
			return 1;
		}
	}
	if ($retStatus == 0 )
	{
		return 0;
	}
	else
	{
		$FileLogger->info("\nInnodb data file path not found. It seems its a fresh installation.\n");
		return 2;
	}
}


#
#  checks whether the file is on the "/opt/nxtn/mysql/data" mount partition if it exists
#  $dataPath contains "/opt/nxtn/mysql/data" if mount partition exists else it is blank
#
sub checkMysqlDataFilePath() {
	my ($dataPath,$fileName) = @_;
	chomp($dataPath);
	chomp($fileName);	
	my $dir = &getOutputFromConsole("dirname $fileName");
	chomp($dir);
	$dir =~ s/^\s+//;
	#my $absPath=abs_path("$dir");
	if ($dataPath ne "" && $dataPath ne $dir ){
		$FileLogger->info("Data file is not present in the $dataPath mount parition." );
		return 1;
	}	
	$mysql_installed_data_dir=$dir;
	return 0;
}

#
#  checks whether the file is on the OCFS2 partition
#  returns 0 is the file is on the OCFS2 partition else returns 1	
#
sub HA_checkMysqlDataFilePath() {
	my ($fileName) = @_;	
	my $cmd="dirname $fileName";
	my $dir = &getOutputFromConsole($cmd);
	chomp($dir);
	$dir =~ s/^\s+//;		
	my $absPath=abs_path($dir);
	$FileLogger->info("Absolute Path for mysql data directory $dir is $absPath ");
	my $retStatus = &HA_checkIfDirIsOCFSMountPartition($absPath);
	if ($retStatus==1 ) {
        $FileLogger->info("Mysql data file \"$fileName\" not present in OCFS2 mount partition." );
		return 1;
    }	
	$mysql_installed_data_dir=$dir;
	return 0;
}


#
#  checks whether the mysql data file exists and its size matches the entry. 
#  returns 0 if everything check else returns 1
#
sub checkMysqlDataFileEntry() {

	my($fileName, $size) = @_;
	my $ret=0;
	my $blockChar = substr($size, -1);
 	#print ("my block chahhracte  is $blockChar");
 	$size = substr($size,0,length($size)-1);
 	my $cmd="ls $fileName ";
	$ret=&getOutputFromConsole($cmd);
  	if ($ret ne $fileName) {
		$FileLogger->info("\n Data file : $fileName doesnot exists.");
		return 1;
	}

 	#print (" executed md  is : ls -s --block-size=1$blockChar $filename ");
  	$ret=0;
	$cmd=" ls -l --block-size=1$blockChar $fileName | awk '{print \$5}' ";	
	$ret=&getOutputFromConsole($cmd);
	if ($ret ne $size ) {
		$FileLogger->info("\n The size of data file : $fileName doesnot match the entry in my.cnf : $size.");
		return 1;
	}
	return 0;
}

#
#  checks whether the mysql log direcotry is on the OCFS2 partition
#  returns 0 is the file is on the OCFS2 partition else returns 1	
#

sub checkMysqlLogDirectory() {
	my ($logDir) = @_;	
	my $cnfFile = "/etc/my.cnf";
	my $mysqld_innodb_log_file_path="";
	chomp($logDir);
	
 	if (! -e "$cnfFile" ){
        $FileLogger->info("Unable to find my.cnf for existing installation.\n");
		return 1;
    }

    open (FINPUT, "< $cnfFile")
        or die "Couldn't open file to read ! \n";

	while(my $line  = <FINPUT>)
	{
		if($line !~m/^#/) {
		   if($line =~m/innodb_log_group_home_dir/) {
				$mysqld_innodb_log_file_path=$line;
				last;
		   }
		}
	}

	close (FINPUT);
	chomp($mysqld_innodb_log_file_path);

	my $valIndex = index($mysqld_innodb_log_file_path,"=");
	my $valString = substr($mysqld_innodb_log_file_path,$valIndex+1);
	chomp($valString);
	
	$FileLogger->info("The log file entry line in my.cnf is : $mysqld_innodb_log_file_path.\n");
	$FileLogger->info("The log file entry in my.cnf is : $valString.\n");
	$valString =~ s/^\s+//;
	if ( $valString eq "" ) {
		$FileLogger->info("Mysql logs are not present. It seems its a fresh installation");
		return 2;
	}
	if ( $logDir ne "" && $valString ne $logDir) {
		$FileLogger->info("Mysql logs are not present $valString mount partition.");
		return 1;
	}
	$mysql_installed_log_dir=$valString;
	return 0;
}

#
# returns 0 if log directory is an active OCFS2 mount partition else returns 1
#

sub HA_checkMysqlLogDirectory(){
	my $cnfFile = "/etc/my.cnf";
	my $mysqld_innodb_log_file_path="";
	my $retStatus=0;	
	
 	if (! -e "$cnfFile" ){
        	$FileLogger->info("Unable to find my.cnf for existing installation.\n");
		return 1;
        }

        open (FINPUT, "< $cnfFile")
        or die "Couldn't open file to read ! \n";

        while(my $line  = <FINPUT>)
        {
            if($line !~m/^#/){
               if($line =~m/innodb_log_group_home_dir/){
                 $mysqld_innodb_log_file_path=$line;
                 last;
               }
            }
        }

        close (FINPUT);
	chomp($mysqld_innodb_log_file_path);

	my $valIndex = index($mysqld_innodb_log_file_path,"=");
	my $valString = substr($mysqld_innodb_log_file_path,$valIndex+1);
	chomp($valString);
	
	$FileLogger->info("The log file entry line in my.cnf is : $mysqld_innodb_log_file_path.\n");
	$FileLogger->info("The log file entry in my.cnf is : $valString.\n");
	$valString =~ s/^\s+//;
	
	if ( $valString eq "" ) {
		$FileLogger->info("Mysql logs are not present. It seems its a fresh installation");
		return 2;
	}

	my $absPath=abs_path("$valString");
	
	$retStatus = &HA_checkIfDirIsOCFSMountPartition($absPath);

	if ($retStatus == 1) {
		$FileLogger->info("Mysql log directory is not an active OCFS mount patition");
		return 1;
	}
	$mysql_installed_log_dir=$valString;
	return 0;
}

#
# returns 0 if directory is an active OCFS2 mount partition else returns 1
#

sub HA_checkIfDirIsOCFSMountPartition() {
	my ($dir)=@_;
	my $ret=0;
	my $cmd = " /etc/init.d/ocfs2 status | grep \"Active OCFS2 mountpoints\" ";
	$ret=&getOutputFromConsole($cmd);
	chomp($ret);

    	if (!($ret=~m/$dir/))
    	{
        	$FileLogger->info("Directory $dir is not an active OCFS2 mount partiiton." );
		return 1;
    	}	
	return 0;
}

#
# returns the output printed on console on execution of commmand passed as argument
#

sub getOutputFromConsole() {
	my ($cmd)=@_;
	my $ret=0;
	$FileLogger->info(" command executed is $cmd ");
  	open (CONSOLE, " $cmd | ");
  	while (<CONSOLE>){
 		$ret=$_;
  	} 	
   	chomp($ret);
	$FileLogger->info(" output received is $ret ");
	return $ret;
}

sub is_ipv6 
{ 
  my($ipv6) = @_; 

  return $ipv6 =~ /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/; 
} 

sub installRadiusRPMsForRHEL(){
	my $status;
	my $checkRadius;
	chdir $TmpDir;
	
	system("touch /tmp/.server >/dev/null 2>&1"); # Creating a temporary file required by gb-radius-authconfig utility
	
	$FileLogger->info(" Installing RPM's for Radius Authentication  ");
	
	$checkRadius=`rpm -qa |grep -i libtool-ltdl-2.2.6-15.5.el6 `;
	if($checkRadius ne ''){
		$FileLogger->info(" $DpendentRadiusRPMForRHEL RPM is already installed ");
	}else{
	$status = system ("rpm -i  $DpendentRadiusRPMForRHEL >/dev/null 2>&1");
	$FileLogger->info(" $DpendentRadiusRPMForRHEL RPM is installed with status $status ");
	}
	
	$checkRadius=`rpm -qa |grep -i freeradius-2.1.10-5.el6.x86_64 `;
	if($checkRadius ne ''){
		$FileLogger->info(" $FreeRadiusRPMForRHEL RPM is already installed ");
	}else{
	$status = system ("rpm -i  $FreeRadiusRPMForRHEL >/dev/null 2>&1 ");
	$FileLogger->info(" $FreeRadiusRPMForRHEL RPM is installed with status $status ");
	}
	
	$checkRadius=`rpm -qa |grep -i freeradius-utils-2.1.10-5.el6.x86_64 `;
	if($checkRadius ne ''){
		$FileLogger->info(" $FreeRadiusUtilRPMForRHEL RPM is already installed ");
	}else{
	$status = system ("rpm -i  $FreeRadiusUtilRPMForRHEL  >/dev/null 2>&1");
	$FileLogger->info(" $FreeRadiusUtilRPMForRHEL RPM is installed with status $status ");
	}
	
	$checkRadius=`rpm -qa |grep -i gb-radiusauth-config-1-5.x86_64 `;
	if($checkRadius ne ''){
		$FileLogger->info(" $GBRadiusAuthRPMForRHEL RPM is already installed ");
	}else{
	$status = system ("rpm -i  $GBRadiusAuthRPMForRHEL  >/dev/null 2>&1");
	$FileLogger->info(" $GBRadiusAuthRPMForRHEL RPM is installed with status $status ");
	}
	system("touch /etc/raddb/server >/dev/null 2>&1");
	
}
sub updateMyCnfAndJbossForRHEL{
my $Key;
my $totalMem;
my $mysqlMem;
my $jbossMem;
my $mysqlStringToReplace;

my $Xmskey;
my $XmxKey;
my $jbossStringToReplace;

use POSIX;

$Key=`cat /etc/my.cnf |grep innodb_buffer_pool_size `;
chomp($Key);

$totalMem=`free -m | grep Mem | tr -s ' ' ' ' | cut -d" " -f2`;
chomp ($totalMem);

$mysqlMem = .5  *  $totalMem;
$jbossMem = .39 *  $totalMem;

$mysqlMem=floor($mysqlMem);
$jbossMem=floor($jbossMem);

#Making changes in Jboss
$FileLogger->info(" updating jboss script for RHEL....  ");

$Xmskey=`cat /etc/init.d/jboss |grep Xms |tr -s ' ' ' ' | cut -d" " -f2`;
chomp($Xmskey);
$jbossStringToReplace="-Xms".$jbossMem."M";
`sed -i.bak "s/$Xmskey/$jbossStringToReplace/g" /etc/init.d/jboss`;

$XmxKey=`cat /etc/init.d/jboss |grep Xmx |tr -s ' ' ' ' | cut -d" " -f3`;
chomp($XmxKey);
$jbossStringToReplace="-Xmx".$jbossMem."M";
`sed -i.bak "s/$XmxKey/$jbossStringToReplace/g" /etc/init.d/jboss`;

$FileLogger->info(" updating jboss script for RHEL done....  ");

#Making changes in Mysql
$FileLogger->info(" updating my.cnf for RHEL....  ");

$mysqlStringToReplace="innodb_buffer_pool_size = ".$mysqlMem."M";

`sed -i.bak "s/$Key/$mysqlStringToReplace/g" /etc/my.cnf`;
$FileLogger->info(" updating my.cnf for RHEL done....  ");
}

sub deleteHRTables(){
	
			my $status;
			##mysql does not support the new mysql password algo, so we change the password to the old formats, and change them back after we're done
			open (TMP2,">fix_privileges_old_pwd_tmp.sql");
			print TMP2 "USE mysql;";
			print TMP2 "UPDATE user SET password=OLD_PASSWORD('$ROOT_Password') WHERE user='root';\n";
			print TMP2 "FLUSH PRIVILEGES;";
			close (TMP2);

			open (TMP1,">fix_privileges_new_pwd_tmp.sql");
			print TMP1 "USE mysql;";
			print TMP1 "UPDATE user SET password=PASSWORD('$ROOT_Password') WHERE user='root';\n";
			print TMP1 "FLUSH PRIVILEGES;";
			close (TMP1);
			$status =system("mysql -u root --password=$ROOT_Password  < fix_privileges_old_pwd_tmp.sql");
			if($status)
			{
                 print ("Unable to change root password to old version, cannot continue.");
                 exit 1;
			}

			my $dbh;
			my $sth;
			$dbh = DBI->connect("dbi:mysql:dbname=bn;", "root", $ROOT_Password, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
			my $tabsth = $dbh->table_info(undef, undef, "hrlogs");
			
			if (!($tabsth->fetch)) {
				$FileLogger->info("\n\nHrLogs table does not exists. No need to drop hr tables\n\n");
				$dbh->disconnect;
				return;
			} 
			$sth = $dbh->prepare("select hrSummaryTableName from hrlogs ");			
			$sth->execute;
			my $stmt;
			my $table;
			while($table = $sth->fetchrow_array)
			{
				if($table ne ""){
				my $dropQuery="drop table $table";
				$stmt = $dbh->prepare($dropQuery);
				$stmt->execute;
				my $deleteQuery="delete from hrlogs where hrSummaryTableName = '$table' ";
				$stmt = $dbh->prepare($deleteQuery);
				$stmt->execute;
				}
			}
			
			my $updateQuery="UPDATE cdrlogs set Status = 20";
			$stmt = $dbh->prepare($updateQuery);
			$stmt->execute;
							
            if ($sth)
			{
			   	$sth->finish;
			}
			if ($stmt)
			{
			   	$stmt->finish;
			}
			if ($dbh)
			{
				$dbh->do("commit;");
			   	$dbh->disconnect;
			}
        
}
###################################################

##
## Main
##

$| = 1;

if (! @ARGV)
{
        PrintHelpMessage ();
}


getopts ("dmwuhvngap");

if ($Getopt::Std::opt_d)
{
        if(@ARGV[0] eq "iVMS")
        {
                $typeOfInstall=1;
                $typeOfInstallString = "RSM Server";
        }
        elsif(@ARGV[0] eq "iVMSLite")
        {
                $typeOfInstall=2;
                $typeOfInstallString = "RSMLite";
				
				if ($Getopt::Std::opt_a)
				{
					$SWMF = 1;
					if($Getopt::Std::opt_p) {
						$PRE6 = 1;
					}
				}
        }
        elsif(@ARGV[0] eq "RSMGVU")
        {
                $typeOfInstall=3;
                $typeOfInstallString = "RSMGVU";
        }
        else
        {
                print"Unknown option @ARGV[0]\n";
                shift;
                GetResponse ();
                exit 1;
        }
        shift;
        print "Uninstalling $typeOfInstallString\n";
        UninstallPackage ();
        GetResponse ();


}

if ($Getopt::Std::opt_m)
{
        print "\nInstalling RSM Server.  \n";
        $typeOfInstall=1;
        $typeOfInstallString = "RSM Server";
        GetResponse ();
        InstallPackage ();

}

if ($Getopt::Std::opt_g)
{
        print "\nInstalling RSM Server for GVU.  \n";
        $typeOfInstall=3;
        $typeOfInstallString = "RSMGVU";
        GetResponse ();
        InstallPackage ();

}

if ($Getopt::Std::opt_w)
{
        print "\nInstalling RSMLite.  \n";
        $typeOfInstall=2;
        $typeOfInstallString = "RSMLite";
		
		if ($Getopt::Std::opt_a)
        {
            $SWMF = 1;
			if($Getopt::Std::opt_p) {
		    	$PRE6 = 1;
            }
        }
		GetResponse ();
        InstallPackage ();
}       
		
		
	

if ($Getopt::Std::opt_u)
{
        $upgrade=1;
        if(@ARGV[0] eq "iVMS")
        {
                $typeOfInstall=1;
                $typeOfInstallString = "RSM Server";
        }
        elsif(@ARGV[0] eq "iVMSLite")
        {
                $typeOfInstall=2;
                $typeOfInstallString = "RSMLite";
                if ($Getopt::Std::opt_a)
                {
                    $SWMF = 1;
		    		if($Getopt::Std::opt_p) {
		    			$PRE6 = 1;
                    }
                }
        }
        elsif(@ARGV[0] eq "RSMGVU")
        {
                $typeOfInstall=3;
                $typeOfInstallString = "RSMGVU";
        }
        else
        {
                print"Unknown option @ARGV[0]\n";
                shift;
                GetResponse ();
                exit 1;
        }
        shift;

        print "Upgrading the $typeOfInstallString package \n";
        UpgradePackage ();

}

if ($Getopt::Std::opt_h)
{
        PrintHelpMessage ();
}

if ($Getopt::Std::opt_v)
{
        print "$Self version $SelfVersion\n";
}

if ($Getopt::Std::opt_n)
{
        print "Migrating the NARS Server to RSM Server";
        MigrateNars();
}
exit 0;
