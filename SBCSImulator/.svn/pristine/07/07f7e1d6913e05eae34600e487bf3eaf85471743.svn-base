#!/usr/bin/perl

##
## RSM Installer for use with Fast Forward
##

use strict;

# change for Fast Forward
my $ff_task;
my $ff_operation;

##typeofinstall refers to whether it's RSM installation or RSMLite installation, 1 indicates the former, 2 indicates the latter
my $typeOfInstall = 1;
my $typeOfInstallString;
my $Self = "RSMInstall";
my $SelfVersion = "8.1.0.0d0";
my $AdmMediaFile = "rsm.tar";
my $TmpDir = "/var/tmp/ivmsinstall";
my $OptDir = "/opt/nxtn";
my $NextoneOpt = "$OptDir/rsm";
# variable to store current jdk version required to run rsm
my $J2sdkVersion = "jre1.6.0_18";
# variable to point to jdk installation program
my $Unzip = "unzip ";
my $UsrJava = "/usr";
my $OptNxtn = "/opt/nxtn";
my $MemString4G="CONFIG_HIGHMEM4G=y";
my $MemString64G="CONFIG_HIGHMEM4G=y";
my $J2sdkRpm    = "jre1.6.0_18-linux-x64.bin";
my $J2sdk_64    = "jre1.6.0_18-linux-x64.bin";
my $J2sdk_64Version = "jre1.6.0_18";
my $JdkDir = "$OptDir/jdk";
my $JBossDeployDirSuffix = "/server/rsm/deploy";
my $JBossConfDirSuffix = "/server/rsm/conf";
my $JBossLibDirSuffix = "/lib";
my $JBossServerLibDirSuffix = "/server/rsm/lib";
my $MinTmpSpace = 550000;
my $MySQL_root_passwd = "";
my $MySQLServerX86Rpm = "MySQL-server-enterprise-5.0.90-0.sles10.i586.rpm";
my $MySQLClientX86Rpm = "MySQL-client-enterprise-5.0.90-0.sles10.i586.rpm";
# These are currently not included
my $MySQLServerIA64Rpm = "MySQL-server-5.0.21-1.glibc23.ia64.rpm";
my $MySQLClientIA64Rpm  = "MySQL-client-5.0.21-1.glibc23.ia64.rpm";

my $MySQLServerEM64TRpm = "MySQL-server-enterprise-5.0.90-0.sles10.x86_64.rpm";
my $MySQLClientEM64TRpm = "MySQL-client-enterprise-5.0.90-0.sles10.x86_64.rpm";
my $MySQLServerRpm = $MySQLServerX86Rpm;
my $MySQLClientRpm = $MySQLClientX86Rpm;
my $MySqlDir;
my $MySqlLog;
my $MySqlProcStr="mysqld";
my $MySqlWaitTime=5;
my $libmysqlold32="libmysql-32bit.zip";
my $libmysqlold64="libmysql-64bit.zip";
my $DB_Username = "ivms";
my $DB_Password = "ivms";
my $StartDir;
my $IVMSINDEX=".ivmsindex";
my $ManagementIp="127.0.0.1";
my $JBoss = "jboss-eap-4.3.0.GA-1.ep1.8.zip";
my $JBossAS = "jboss-as";
my $JBossVersion = "jboss-eap-4.3";
my $JBossTomcatSar="jboss-web.deployer";
my $JBossDir = "$OptDir/jboss";
my $JBossDeployDir="$OptDir/jboss/server/rsm/deploy";
my $JBossConfDir        =       "$OptDir/jboss/server/rsm/conf";
my $JBossLibDir =       "$OptDir/jboss/lib";
my $JBossServerLibDir = "$OptDir/jboss/server/rsm/lib";
#these are for RSM Lite installation
my $MSWHostName ="localhost";
my $MSWPort="5432";
my $PostgreScriptTrig="rsm_lite_triggers.sql";
my $libdir;
my $unziprpm="unzip-5.50-345.i586.rpm";
my $ziprpm="zip-2.3-732.i586.rpm";

# Script Error codes
my $MYSQL_SHUTDOWN_ERROR="-1";
my $MYSQL_SERVER_RPM_ABSENT="-2";
my $MYSQL_SERVER_DEPENDENCIES_NOT_INSTALLED="-3";
my $MYSQL_CLIENT_RPM_ABSENT="-4";
my $MYSQL_CLIENT_DEPENDENCIES_NOT_INSTALLED="-5";
my $JBOSS_SHUTDOWN_FAILED="-6";
my $JBOSS_INSTALL_FAILED="-7";
my $J2SDK_64INSTALL_FAILED="-8";
my $J2SDK_64RPM_ABSENT="-9";
my $J2SDK_32INSTALL_FAILED="-10";
my $LIBMYSQL0LD64_NOT_FOUND="-11";
my $LIBMYSQL0LD64_NOT_EXTRACTED="-12";
my $LIBMYSQL0LD32_NOT_FOUND="-13";
my $LIBMYSQL0LD32_NOT_EXTRACTED="-14";
my $MYSQL_START_ERROR="-15";
my $JBOSS_START_ERROR="-16";
my $REMOVE_MYSQL_CLIENT_RPM_FAILED="-17";
my $MYSQL_CLIENT_RPM_INSTALL_FAILED="-18";
my $REMOVE_MYSQL_SERVER_RPM_FAILED="-19";
my $MYSQL_SERVER_RPM_INSTALL_FAILED="-20";
my $STATUS_OK="0";

#variables identifing system directly and firewall available 
my $systemConfigDirectory = "/etc/sysconfig" ; 
my $firewallConfigFile = "SuSEfirewall2" ; 
my $SuSE9firewallConfigFile = "SuSEfirewall2.v9" ;
my $SuSE10firewallConfigFile = "SuSEfirewall2.v10" ;
my $SuSEVersion="" ;

#variable identifying directory containing SSH protocol related files
my $SshDir = "/etc/ssh";

#name of script to check whether correct version of RSM Linux is installed
my $checkOSScriptName = "rsm_os_check.sh" ;

#variable to be set 1 by developer to skip OS verification and other checks 
my $isCheckDisabled = 0 ;

#variable to search for in nextoneJboss to include changes for ulimit and core settings 
my $nextoneJbossUlimitString = "#ulimit and core settings to be updated in case of RSM server install" ;



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

sub PrintHelpMessage ()
{
	print "'$Self -s nxi_operation rsm_product' to install RSM\n";

	exit 0;
}

sub getStringFrmFile()
{
	my ($filename) = @_;
	open FIN, "<$filename";
	my $line = <FIN>;
	return $line;
}
##
## Display an error message, clean up the temp directory, and exit.
##
sub FailedInstall()
{
        my ($failureMessage) = @_;
        &ff_log_error("Installation failed due to ".$failureMessage." Please see log for details.");
}
##
## Selects the MySql package corresponding to the processor, detect the type of processor, and select the appropriate MySql rpm, exit installation if the said version is not found
##
sub SelectMySqlPackage ()
{
        my $processortype = &GetProcessorType();
        if($processortype=~m/x86_64/)
        {
                $MySQLServerRpm =     $MySQLServerEM64TRpm ;
                $MySQLClientRpm =     $MySQLClientEM64TRpm ;
                return;
        }
        if($processortype=~m/ia64/)
        {
                &ff_log_info("64-bit processor detected, selected MySql-IA64 for better performance\n");
                $MySQLServerRpm =    $MySQLServerIA64Rpm;
                $MySQLClientRpm =    $MySQLClientIA64Rpm;
                return;
        }
        if($processortype=~m/i386/)
        {
                &ff_log_info("32-bit processor detected, selecting x86 package\n");
                $MySQLServerRpm =    $MySQLServerX86Rpm ;
                $MySQLClientRpm =    $MySQLClientX86Rpm ;
                return;
        }
        &ff_log_info("Unable to determine processor type, installing default (x86) MySql package \n");
        $MySQLServerRpm =    $MySQLServerX86Rpm;
        $MySQLClientRpm =    $MySQLClientX86Rpm;
        return;
}
##
## Install MySql server. Cleans up the existing mysql data directories
##
sub InstallMySqlServer()
{
        chdir $StartDir;
        my $status=1;
        my $procName = "$MySqlProcStr";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ff_ProcExist($procName))
        {
            &ff_log_info("MySql is running, attempting to stop MySql\n");
            $status =  system ("/etc/init.d/mysql stop");
            my $procExists=&ff_WaitProcExit($procName,4);
            if($procExists)
            {
                &FailedInstall("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");
		return $MYSQL_SHUTDOWN_ERROR;
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
        if (-d $MySqlDir) 
        {
           $status = system ("rm -rf $MySqlDir/*");
        }

        ## Create database logs directory
        ##
        $MySqlLog = "$OptNxtn/mysql/log";
        if (-d $MySqlLog) 
        {
            $status = system ("rm -rf $MySqlLog/*");
        }
        chdir $TmpDir;
        &ff_log_info("Installing $MySQLServerRpm ..");
        if ( ! -f $MySQLServerRpm)
        {
           &FailedInstall("Unable to find $MySQLServerRpm \n");
	   return $MYSQL_SERVER_RPM_ABSENT;	
		
        }
	# Remove RPMs (if existing) before installing fresh version.
        my $mysqlCurrentVersion = &getMySqlVersion();
        if(!($mysqlCurrentVersion=~m/0\.0/)){
	    #Get name of existing RPM
	    my $existingRPM = `rpm -qa | grep MySQL-server`;
	    chomp($existingRPM);
	    my $status = system ("rpm -e $existingRPM");
            if($status != $STATUS_OK){
	        	&ff_log_error("Could not Remove MYSQL server RPM");
			return $REMOVE_MYSQL_SERVER_RPM_FAILED;
            }
	}
        $status = system ("rpm -i --force $MySQLServerRpm");
        if($status != $STATUS_OK){
	        &ff_log_error("Could not Install MYSQL server RPM");
		return $MYSQL_SERVER_RPM_INSTALL_FAILED;
        }
	my $rpmIns = `rpm -qa | grep MySQL-server`;
	chomp($rpmIns);
	if(!($MySQLServerRpm=~m/$rpmIns/))
        {
            &FailedInstall("Unable to install MySql server. Are all dependencies installed?\n ".$!);
	    return $MYSQL_SERVER_DEPENDENCIES_NOT_INSTALLED;
        }
        &ff_log_info("Installing $MySQLServerRpm ..done");
        chdir $TmpDir;
	return $STATUS_OK;
}
##
##Change owner of mysql directories to user mysql
##
sub ConfigureMySqlServer()
{
	ff_SetMySQLPasswd ();
        ##
        ## Shutdown MySQL Database, copy databse files to $MySQLDir
        ## Create /etc/my.cnf
        ##
        &ff_log_info("Shutting down MySQL Database.. \n");
        my $status = system ("/usr/bin/mysqladmin -u root --password=\"$MySQL_root_passwd\" shutdown");
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
        &ff_log_info("Customizing MySQL configuration file..");
        ModifyMyCnf ();
        # Changed to remove the warning if my.cnf is not present
        if (-f "/etc/my.cnf")
        {
           $status = system ("mv /etc/my.cnf /etc/my.cnf.bak");
        }
        $status = system ("cp my.cnf /etc/my.cnf");
        &ff_log_info("Customizing MySQL configuration file..done");
        if(-f "/etc/rc.d/rc3.d/S99mysql")
        {
             $status = system ("rm /etc/rc.d/rc3.d/S99mysql");
        }
        $status = system ("ln -s /etc/init.d/mysql /etc/rc.d/rc3.d/S99mysql");
        $status = system ("cp $TmpDir\/nextoneMySQL /etc/init.d/mysql");
	$status = system ("chmod +x /etc/init.d/mysql");	
	##
	## Start the MySQL database
	##
	&ff_log_info("Creating MySQL Database.. ");
	$status = system ("/etc/init.d/mysql start >/dev/null 2>&1");
        if($status != $STATUS_OK)
        {
	       	&ff_log_error("Could not start Mysql");
		return $MYSQL_START_ERROR;
        }
	&ff_log_info("MySql Database created in $MySqlDir ");
	chdir $StartDir;
	&ff_log_info("returning from ConfigureMySqlServer");
	return $STATUS_OK;

}
##
##Modify the mysql configuration file /etc/my.cnf
##
sub ModifyMyCnf()
{
        my $cfg = new Config::Simple("/proc/meminfo");
        my $mem =   $cfg->param("MemTotal");
        my $rem_data_file;
        $mem=~s/kB//;
        my $innodb_buffer_pool_size = $mem/2;
        $mem = $mem * 1024;
        $innodb_buffer_pool_size = $innodb_buffer_pool_size/1024;
        $innodb_buffer_pool_size = sprintf("%.0f",$innodb_buffer_pool_size);
        my $kernel_config = &VerifyHighMem();
        if (($innodb_buffer_pool_size > 2047) && ($kernel_config == 0))
        {
                $innodb_buffer_pool_size=2047;
        }
        if (($innodb_buffer_pool_size > 2047) && ($kernel_config == 1))
        {
                $innodb_buffer_pool_size=1023;
        }
        my $mysqld_innodb_buffer_pool_size = "set_variable = innodb_buffer_pool_size=".$innodb_buffer_pool_size."M";
        ReplaceStr("mysqld_innodb_buffer_pool_size",$mysqld_innodb_buffer_pool_size);
        ReplaceStr("mysqld_key_buffer","set_variable    = key_buffer=64M");
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
        my $mysqld_innodb_data_file_path="innodb_data_file_path =";
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
        ReplaceStr("mysqld_innodb_data_file_path",$mysqld_innodb_data_file_path);
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
sub ReplaceStr()
{
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
}
##
##Install MySql client
##
sub InstallMySqlClient()
{
        if ( ! -f $MySQLClientRpm)
        {
                &FailedInstall("Unable to find $MySQLClientRpm \n");
		return $MYSQL_CLIENT_RPM_ABSENT;
        }
        &ff_log_info("Installing MySQL Client..");
        my $existingRPM = `rpm -qa | grep MySQL-client`;
        chomp($existingRPM);
	if ($existingRPM ne '')
	{
	    my $status = system ("rpm -e $existingRPM");
            if($status != $STATUS_OK){
	        	&ff_log_error("Could not Remove MYSQL client RPM");
			return $REMOVE_MYSQL_CLIENT_RPM_FAILED;
            }
	}
        my $status = system ("rpm -i --force $MySQLClientRpm");
        if($status != $STATUS_OK){
	        &ff_log_error("Could not Install MYSQL client RPM");
		return $MYSQL_CLIENT_RPM_INSTALL_FAILED;
        }
	my $rpmIns = `rpm -qa | grep MySQL-client`;
	chomp($rpmIns);
	if(!($MySQLClientRpm=~m/$rpmIns/))
        {
                &FailedInstall("Unable to install MySql client.Are all dependencies installed?\n ".$!);
		return $MYSQL_CLIENT_DEPENDENCIES_NOT_INSTALLED;
        }
        &ff_log_info("Installing MySQL Client..done ");
	return $STATUS_OK;
}
##
## Install jboss, in this function we first check if JBoss is running, if so we try to stop it. Then we check the currently installed version of JBoss, if it is not same as current JBoss version (the directory name contains the version), we go on to install JBoss. The user can specify any directory to install JBoss, the default is /op/nextone/jboss-<version>), in both cases we create a softlink /opt/nxtn/jboss pointing to the actual jboss directory
##
sub InstallJBoss ()
{
        my $status;
        my $installDir;
        my $procName = "run.jar";
        my $outFile = $TmpDir."/".$procName.".proc";
        if(&ff_ProcExist($procName))
        {
                &ff_log_info("JBoss is running, attempting to stop JBoss\n");
                my $status = system ("/etc/init.d/jboss stop > /dev/null 2>&1");
                my $procExists=&ff_WaitProcExit($procName,10);
                if($procExists)
                {
                        my $status = system("kill -9 `ps -ef | grep run.jar | grep -v grep | tr -s ' ' | cut -d ' ' -f2` >/dev/null 2>&1 ");
                        my $procExists=&ff_WaitProcExit($procName,10);
                        if($procExists)
                        {
                                &FailedInstall("Couldn't shutdown JBoss ...\nShutdown JBoss and try again ...\n");
				return $JBOSS_SHUTDOWN_FAILED;
                        }
                }
        }
        &ff_log_info("Preparing to install JBoss .. \n");
        if ( -d "$OptDir/jboss")
        {
            my $curJBoss = abs_path("$OptDir/jboss");
            if ($curJBoss =~ /$JBossVersion/)
            {
                &ff_log_info( "Current JBoss is up to date\n");
                return;
            }
			# check if jboss RPM is installed by Fast Forward
			my $ff_jbossversion = $JBossVersion;
			my $buf = `rpm -qa`;
			chomp($buf);
			if (($buf=~m/$ff_jbossversion/)) {
				&ff_log_info( "Current JBoss is up to date\n");
				return;
			}
        }
        $installDir = $OptDir;
        my $status;
        if ( -d "$OptDir/jboss")
        {
            $status = system ("unlink $OptDir/jboss");
        }
        chdir $installDir;
        # check if it is already there
        if ( ! -d $JBossVersion )
        {
            &ff_log_info("Extracting JBoss  .. \n");
            $status = system ("$Unzip $TmpDir/$JBoss");
            if($status != $STATUS_OK)
            {
                &FailedInstall("Unable to install JBoss $TmpDir/$JBoss ".$!);
		return $JBOSS_INSTALL_FAILED;
            }
           &ff_log_info("Extracting JBoss ..done \n");
        }
        $status = system ("rm -rf $OptDir/jboss");
        $status = system ("ln -s $installDir/$JBossVersion/$JBossAS $OptDir/jboss");
        &ff_log_info( "Installing JBoss ..done \n");
	return $STATUS_OK;
}
sub InstallJdk_64()
{
	chdir $TmpDir;
	my $AbsJ2sdk_64Rpm = $TmpDir."\/".$J2sdk_64;
	my $jdkversion = "1.6.0_18";
	&ff_log_info("Installing Java J2SDK ..  \n");
	if ( -d "$OptDir/jdk")
	{
		system("$OptDir/jdk/bin/java -version 2> jdk.version");
		my $versionString = `cat jdk.version`;
		chomp($versionString);
		if ($versionString =~ /$jdkversion/) {
			if ($versionString =~ /64-Bit/) {
				&ff_log_info( "Current J2sdk is up to date\n");
				return;
			}
		}
		# check if the JDK is installed by Fast Forward
		my $ff_jdkversion = "1.6.0_18";
		if ($versionString =~ /$ff_jdkversion/) {
			if ($versionString =~ /64-Bit/) {
				&ff_log_info( "Current J2sdk is up to date\n");
				return;
			}
		}
	}
	&ff_log_info( "Installing Java $jdkversion in $OptDir...\n");
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
        $status = system ("echo \"yes\" | $AbsJ2sdk_64Rpm 1>/dev/null");
        if($status != $STATUS_OK)
        {
                &FailedInstall("Unable to install JDK".$!);
		return $J2SDK_64INSTALL_FAILED;
		
        }
        if  (-l "$OptDir/jdk")
        {
           $status = system ("unlink $OptDir/jdk");
        }
        $status = system ("ln -s $DstUsrJava $OptDir/jdk");
        &ff_log_info( "Installing Java J2SDK in $DstUsrJava..done \n");
	return $STATUS_OK;
}
##
## Install JDK, if the currently installed version is not up-to-date.s
##
sub InstallJdk ()
{
        &ff_log_info( "Beginning with Java installation  \n");
	if ( -f $TmpDir."\/".$J2sdk_64 ) {
        	my $status= InstallJdk_64 ();
        	if ($status != $STATUS_OK)
		{
			&ff_log_error(" InstallJdk_64 returned with error code : $status. Halting installtion");
			return $status;
		}
		else
		{
			&ff_log_info("InstallJdk_64 done..\n");
			return $STATUS_OK;
		}
	}
        chdir $TmpDir;
        my $AbsJ2sdkRpm = $TmpDir."\/".$J2sdkRpm;
        if ( ! -f $AbsJ2sdkRpm)
        {
                &FailedInstall("Unable to find $J2sdkRpm in $TmpDir  \n");
		return $J2SDK_64RPM_ABSENT;
		
        }
        &ff_log_info("Installing Java J2SDK ..  \n");
        if ( -d "$OptDir/jdk")
        {
			my $jdkversion = "1.6.0_18";
			system("$OptDir/jdk/bin/java -version 2> jdk.version");
			my $versionString = `cat jdk.version`;
			chomp($versionString);
			if ($versionString =~ /$jdkversion/) {
                	&ff_log_info( "Current J2sdk is up to date\n");
                	return;
            }
        }
        $UsrJava = $OptDir;
        &ff_log_info( "Installing Java in $UsrJava\n");
        chdir "$UsrJava";
        my $DstUsrJava=$UsrJava."\/".$J2sdkVersion;
        my $status;
        if (-d $DstUsrJava)
        {
                $status = system ("unlink $OptDir/jdk");
                $status = system ("rm -rf $DstUsrJava");
        }
        $status = system ("chmod +x $AbsJ2sdkRpm");
        $status = system ("echo \"yes\" | $AbsJ2sdkRpm 1>/dev/null");
        if($status != $STATUS_OK)
        {
                &FailedInstall("Unable to install JDK".$!);
		return $J2SDK_32INSTALL_FAILED;
        }
        # remove the symbolic link jdk if exist and then link it to new java version
        if  (-l "$OptDir/jdk")
        {
           $status = system ("unlink $OptDir/jdk");
        }
        $status = system ("ln -s $DstUsrJava $OptDir/jdk");
        &ff_log_info( "Installing Java J2SDK in $DstUsrJava..done \n");
	return $STATUS_OK;
}
##
## Get the processor type of the system
##
sub GetProcessorType()
{
	my $filetmp = "/tmp/processortype";
	my $status = system("uname -pi > $filetmp");
	my $processortype = &getStringFrmFile($filetmp);
	system("rm $filetmp");
	return $processortype;
}

# change for Fast Forward
sub ff_log()
{
	my($severity, $msg) = @_;
	system("$StartDir/nxi_log $ff_task $severity \"$msg\"");
}

sub ff_log_warn()
{
	my($msg) = @_;
	&ff_log("warn", $msg);
}
sub ff_log_info()
{
	my($msg) = @_;
	&ff_log("info", $msg);
}
sub ff_log_error()
{
	my($msg) = @_;
	&ff_log("error", $msg);
}
sub ff_log_fatal()
{
	my($msg) = @_;
	&ff_log("fatal", $msg);
}
sub ff_log_debug()
{
	my($msg) = @_;
	&ff_log("debug", $msg);
}

##
##Create the .ivmsindex file
##
sub setiVMSVersion()
{
	my ($ivmsversion)=@_;
	my $versionfile=$NextoneOpt."/".$IVMSINDEX;
	my $oldversionfile=$versionfile."old";

	if(-f $versionfile) {
		system("mv $versionfile $oldversionfile");
	}
	chdir $NextoneOpt;
	system("echo $ivmsversion > $versionfile");
}

##
## Get the disk usage of the partition where the given directory resides
##
sub GetDiskUsage ()
{
	my ($givenDir) = @_;
	my $tmpBuf;
	my $status;
	my $space;

	$tmpBuf = $StartDir."/tmp00";
	$status = system ("df -k $givenDir | grep \/ | tr -s ' ' ' ' | cut -d\" \" -f4 > $tmpBuf");
	open (tmp, "<$tmpBuf");
	$space = <tmp>;
	close tmp;
	$status = system ("rm -rf $tmpBuf");
	return $space;
}

sub ff_GetTempDir()
{
	my $tmpspace;

	if (!-d $TmpDir) {
		system("umask 0000; mkdir $TmpDir");
	}
	system ("rm -rf $TmpDir/*");

# Obtain the size of $TmpDir
	$tmpspace = &GetDiskUsage($TmpDir);
	chomp($tmpspace);
	&ff_log_debug("Disk space in $TmpDir: $tmpspace KB");
	if ($tmpspace < $MinTmpSpace) {
		&ff_log_error("Insufficient disk space in $TmpDir: need more than $MinTmpSpace KB");
		return 0;
	}

	return 1;
}

sub ff_CreateHomeDir()
{
	system("mkdir -p $NextoneOpt");
	&ff_log_info("Product directory '$NextoneOpt' created");
}

sub ff_CreateOptLinks()
{
	if (! -d $JBossDir) {
		system("ln -s /usr/share/jboss $JBossDir");
	}
	if (! -d $JdkDir) {
		system("ln -s /etc/alternatives/java_sdk $JdkDir");
	}
}

sub ff_CheckMediaFile ()
{
	my $mediaFile = $StartDir . "/" . $AdmMediaFile;
	if ( ! -f $mediaFile) {
		&ff_log_error("Unable to find $mediaFile");
		return 0;
	}
	&ff_log_debug("Found media file: $mediaFile");

	return 1;
}

sub ff_ExtractMediaFile ()
{
	my $status;

	my $mediaFile = $StartDir . "/" . $AdmMediaFile;
	system ("cp $mediaFile $TmpDir/.");
	chdir $TmpDir;
	&ff_log_debug("Unpack $mediaFile");
	$status = system("tar xf $mediaFile >/dev/null 2>&1");
	if ($status != $STATUS_OK) {
		&ff_log_error("Unable to unpack $mediaFile");
		return 0;
	}

	return 1;
}

#This function replaces TestHostNameConsistency()
#  In case of RSM Server installation, remove mgmt IP token from jboss script
#  In case of RSM Lite installation, populate $ManagementIp into jboss script
sub ff_ConfigJBossIP()
{
	&ff_log_info("Configuring JBoss IP for $typeOfInstallString...");
        my $JbossBindIp="0.0.0.0";
        my $JbossBindShutDownIp="0.0.0.0";
        my $JvmIPv4Parameter="java.net.preferIPv4Stack";
        my $JvmIPv6Parameter="java.net.preferIPv6Stack";
	open(JBossScrIn,"<$TmpDir/nextoneJBoss");
	open(JBossScrOut,">$TmpDir/nextoneJBoss.tmp");
	while(my $line=<JBossScrIn>) {
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
				$line="\n";
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
	&ff_log_info("JBoss IP for $typeOfInstallString configured");
}

sub ff_setupBNPropForRSM() {
	&ff_log_info("Configuring properties for $typeOfInstallString...");
	chdir $TmpDir;
	system ("chmod +x createIvmsCfg.act");
	if($typeOfInstall==1) {
		system ("./createIvmsCfg.act -f bn.properties -d . -x");
	}
	&ff_log_info("Properties for $typeOfInstallString configured");
}

sub ff_configureMySQLDatabase() {
	&ff_log_info("Configuring RSM database...");
	my $status;
	chdir $TmpDir;
	system("chmod +x db-ivms.sh");
	$status = system("./db-ivms.sh  i /usr/bin/mysql root \"$MySQL_root_passwd\" \"$SelfVersion\" \"$DB_Username\" \"$DB_Password\" >/dev/null 2>&1");
	if($status != $STATUS_OK) {
		&ff_log_error("Unable to configure RSM database");
		return 0;
	}

	&ff_log_info("RSM database configured");
	return 1;
}

sub ff_updateMySqlXml()
{
	&ff_log_info("Configuring data source...");
	my($username, $password) = @_;
	my $mysqldsxmlfile = "$TmpDir/mysql-ds.xml";
	my $mysqldsxmlfiletmp = $TmpDir."/mysql-ds.tmp";
	if($typeOfInstall== 2) {
		return;
	}
	open SIN, "<$mysqldsxmlfile";
	open SOUT, ">$mysqldsxmlfiletmp";
	my $line;
	my $username_string = "USERNAME";
	my $password_string = "PASSWORD";
	while($line = <SIN>) {
		$line =~s/$username_string/$DB_Username/;
		$line =~s/$password_string/$DB_Password/;
		print SOUT "$line";
	}
	close SIN;
	close SOUT;
	system("cp $mysqldsxmlfiletmp $mysqldsxmlfile");

	&ff_log_info("Data source configured");
}

sub ff_CreateAlarmScriptsDir()
{
	&ff_log_info("Creating alarm script directory...");
	system("mkdir -p $NextoneOpt/alarmscripts");
	&ff_log_info("Alarm script directory created");
}

sub ff_CreateUIDir()
{
	&ff_log_info("Creating UI directory...");
	system("mkdir -p $NextoneOpt/ui/svg");
	&ff_log_info("UI directory created");
}

sub ff_CreateStreamDir()
{
	&ff_log_info("Creating CDR stream directory...");
	system("mkdir -p $NextoneOpt/CDRStream/log");
	system("mkdir -p $NextoneOpt/CDRStream/transform");
	&ff_log_info("CDR stream directory created");
}

sub ff_CreateArchiveDir()
{
	if ($typeOfInstall == 1) {
		&ff_log_info("Creating archive directory...");
		system("mkdir -p $NextoneOpt/provBkup");
		system("chown mysql:mysql $NextoneOpt/provBkup");
		&ff_log_info("archive directory created");
	}
}
#---------- SWM changes ------------#
sub ff_CreateSWMDir()
{
        &ff_log_info("entering to create SWM directory");
        my $home=$NextoneOpt;
        my $swmdir = "swm";
        my $installablesDir = "installables";
        my $licenseDir = "license";
        my $reconizedPackageDir = "reconizedPackage";
        my $deviceBackupDir = "deviceBackup";

        mkdir "$home/$swmdir";
        mkdir "$home/$swmdir/$installablesDir";
        mkdir "$home/$swmdir/$licenseDir";
        mkdir "$home/$swmdir/$reconizedPackageDir";
        mkdir "$home/$swmdir/$deviceBackupDir";

        &ff_log_info("exiting after create SWM directory");
}
#---------- SWM changes ------------#

sub ff_UpdateS99local()
{
	&ff_log_info("Updating /etc/rc.d/rc2.d/S99local...");
	my $S99file = "/etc/rc.d/rc2.d/S99local";
	my $S99filetmp = $TmpDir."/S99local.tmp";
	open SIN, "<$S99file";
	open SOUT, ">$S99filetmp";
	my $line;
	my $old_string = "tomcat";
	my $new_string = "jboss";
	my $lineMatch = "0";
	while($line = <SIN>) {
		if(($line !~m/$old_string/) && ($line !~m/$new_string/)) {
			print SOUT "$line";
		}
		if($line =~m/$new_string/) {
			print SOUT "$line";
			$lineMatch = "1";
		}
	}
	close SIN;
	close SOUT;
	if ($lineMatch eq "0" ) {
		system("echo \"/etc/init.d/jboss start \" >> $S99filetmp");
	}
	system("cp $S99filetmp $S99file");
	&ff_log_info("/etc/rc.d/rc2.d/S99local updated");
}

sub ff_CopyConfFiles()
{
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
        #importing the certificate
        chdir $StartDir;
        my $certfile="server.crt.der";
        my $alias="postgres";
        $status = system("./importcert.sh $certfile $alias");
	if($status) {
		&ff_log_error("Unable to import certificate $certfile");
		return 0;
	}
        chdir $TmpDir;
        if($typeOfInstall ==2)
        {
                system("mkdir -p bn");
                system("mv bn.ear bn/");
                if(! -f "web_iview_only.xml")
                {
			&ff_log_error("web_iview_only.xml not found");
			return 0;
                }
                chdir $TmpDir."/bn";
                system("unzip -qq bn.ear");
                system("mkdir bnweb");
                system("mv bnweb.war bnweb/");
                chdir $TmpDir."/bn/bnweb";
                system("unzip -qq bnweb.war");
                system("cp $TmpDir/web_iview_only.xml $TmpDir/bn/bnweb/WEB-INF/web.xml");
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
			&ff_log_error("Unable to copy bn.ear");
			return 0;
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
        $status = system ("cp $TmpDir/jboss-service.xml $JBossConfDir/jboss-service.xml");
        $status = system ("cp $TmpDir/jboss-login-config.xml $JBossConfDir/login-config.xml");
        $status = system ("cp $TmpDir/tomcat-server.xml $JBossDeployDir/$JBossTomcatSar/server.xml");
        $status = system ("cp $TmpDir/tomcat-web.xml $JBossDeployDir/$JBossTomcatSar/conf/web.xml");
        $status = system ("cp $TmpDir/tomcat-jboss-service.xml $JBossDeployDir/$JBossTomcatSar/META-INF/jboss-service.xml");
        # Copying index.html to JBoss ROOT.war directory
        $status = system ("cp $TmpDir/index.html $JBossDeployDir/$JBossTomcatSar/ROOT.war/index.html");
        # Modifying web.xml of JBoss ROOT.war to include index.html as the welcome page
        $status = system ("cp $TmpDir/web.xml $JBossDeployDir/$JBossTomcatSar/ROOT.war/WEB-INF/web.xml");
        $status = system ("cp $TmpDir/index.html $JBossDeployDir/ivms.war/index.html");
	$status = system ("cp $JBossDir/server/all/lib/jgroups.jar $JBossDir/server/rsm/lib/jgroups.jar");
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
        $status = system ("cp $TmpDir/jdom.jar $JBossLibDir/.");
        $status = system ("rm -rf $JBossDeployDir/iview.war");
        $status = system ("mkdir $JBossDeployDir/iview.war");
        $status = system ("unzip -qq $TmpDir/iview.war -d $JBossDeployDir/iview.war");
	$status = system ("cp $TmpDir/installer-jre1_5.jar $JBossDeployDir/iview.war/installer-jre1_5.jar");
	$status = system ("cp $TmpDir/jre-6u18-linux-i586.bin $JBossDeployDir/iview.war/jre-6u18-linux-i586.bin");
	$status = system ("cp $TmpDir/jre-6u18-windows-i586-s.exe $JBossDeployDir/iview.war/jre-6u18-windows-i586-s.exe");
	$status = system ("cp $TmpDir/jrenative-windows1_5.jar $JBossDeployDir/iview.war/jrenative-windows1_5.jar");

	# copy jmx-console and web-console to deploy if any
	&ff_log_info("Moving jmx-console and web-console archive files to JBoss deploy directory if any...\n");
	if (-d $JBossConfDir."/jmx-console.war") 
	{
		$status = system ("mv $JBossConfDir/jmx-console.war $JBossDeployDir");
		&ff_log_info("Moved jmx-console.war to deploy directory\n");
	}
	if (-d $JBossConfDir."/console-mgr.sar") {
		$status = system ("mv $JBossConfDir/console-mgr.sar $JBossDeployDir/management");
		&ff_log_info("Moved console-mgr.sar to deploy directory\n");
	}
        $status = system ("cp $TmpDir/jboss-run.sh $JBossDir/bin/run.sh");
        # disable jmx-console authentication
	$status = system ("cp $TmpDir/jmx-invoker-service.xml $JBossDeployDir/.");
	# disable access to jmx-console and web-console by moving the archive to conf dir
	&ff_log_info("Disabling JBoss jmx-console and web-console services if any...\n");
	if (-d $JBossDeployDir."/jmx-console.war") 
	{
		&ff_log_info("Disabled JBoss jmx-console service\n");
 		$status = system ("mv $JBossDeployDir/jmx-console.war $JBossConfDir");
 	}
 	if (-d $JBossDeployDir."/management/console-mgr.sar") 
 	{
 		&ff_log_info("Disabled JBoss web-console service\n");
 		$status = system ("mv $JBossDeployDir/management/console-mgr.sar $JBossConfDir");
 	}
	# Added the file to copt the run.conf to set the JAVA_HOME
        $status = system ("cp $TmpDir/jboss-run.conf $JBossDir/bin/run.conf");
        $status = system ("cp $TmpDir/SVGView.exe $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/Generics.xsl $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/DeviceHardWareDetail.xsl $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/DeviceSoftWareDetail.xsl $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/.truststore $NextoneOpt/.");
        system("mkdir -p $NextoneOpt/ui");
        $status = system ("cp $TmpDir/SVGViewCarbon.bin $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/adobesvg-3.01x88-linux-i386.tar.gz $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/SVGend.svginc $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/SVGstart.svginc $NextoneOpt/ui/.");
        $status = system ("cp $TmpDir/logger.properties $NextoneOpt/.");
        if($typeOfInstall==1)
        {
                $status = system ("cp $TmpDir/example-mapping.xml $NextoneOpt/CDRStream/transform/.");
                $status = system ("cp $TmpDir/export-mapping.xml $NextoneOpt/CDRStream/transform/.");
                if($status)
                {
                        &ff_log_info("Unable to copy mapping files some features may not work correctly");
                }
		$status = system ("cp -r $TmpDir/mibs $NextoneOpt/.");
        }
        $status = system ("cp $TmpDir/rsmWSDL.tar $NextoneOpt/.");
        &UpdateWebserivcePort();
	&ff_log_info("Configuration files copied");
	return 1;
}

sub UpdateWebserivcePort()
{
	my $file = "$OptDir/jboss/server/rsm/deploy/jboss-ws4ee.sar/META-INF/jboss-service.xml";
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

sub ff_copyPAM() {
	&ff_log_info("Configure PAM lib for Java...");
	if(&GetProcessorType()=~m/x86_64/) {
	  system("cp $TmpDir\/libjpam_64.so $OptDir/jdk/jre/lib/amd64/libjpam.so");
	  system("unlink /lib64/libpam.so >/dev/null 2>&1");
	  system("ln -s /lib64/libpam.so.0 /lib64/libpam.so");
	} else {
	  system("cp $TmpDir\/libjpam_32.so $OptDir/jdk/jre/lib/i386/libjpam.so");
	  system("unlink /lib/libpam.so >/dev/null 2>&1");
	  system("ln -s /lib/libpam.so.0 /lib/libpam.so");
	}
	system("cp $TmpDir\/jpam /etc/pam.d/jpam");
	&ff_log_info("Configure PAM lib for Java...Done");
}

# function to copy new configuration file for SuSEfirewall
sub copyFirewallConfigFile () {

	&ff_log_info("\nCopying firewall configuration files ...  \n  ") ;  
	&getSuSEVersionForFirewall();
	if ($SuSEVersion < 9 ) {
		# not supported for version less than 9.x 
		&ff_log_error(" SuSE firewall not supported  ") ;

	} elsif ( $SuSEVersion < 10 ){
	
		&ff_log_info(" SuSE version 9.x found. Going ahead with 9.x installation.  ") ;
		my $file = "$systemConfigDirectory/$firewallConfigFile" ;

		if  ( -f $file ) {
			&ff_log_info ("\n Firewall Config File $file exists. " ) ;
			&ff_log_info ("\n Taking backup.. ")  ;
			system (" mv -f  $systemConfigDirectory/$firewallConfigFile $systemConfigDirectory/$firewallConfigFile.orig") ;
		}
		else {
			&ff_log_info ("\n Firewall Config file $file does not exists. ") ;
		}	
		&ff_log_info(" Copying new firewall config file .. ") ;
		system (" cp -f  $TmpDir/$SuSE9firewallConfigFile $systemConfigDirectory/$firewallConfigFile ") ;

	} else {

		&ff_log_info(" SuSE version 10.x or higher found. Going ahead with 10.x installation ") ;
		my $file = "$systemConfigDirectory/$firewallConfigFile" ;

		if  ( -f $file ) {
			&ff_log_info ("\n Firewall Config File $file exists. " ) ;
			&ff_log_info ("\n Taking backup.. ")  ;
			system (" mv -f  $systemConfigDirectory/$firewallConfigFile $systemConfigDirectory/$firewallConfigFile.orig") ;
		}
		else {
			&ff_log_info("\n Firewall Config file $file does not exists.") ;
		}	
		&ff_log_info(" Copying new firewall config file .. ") ;
		system (" cp -f  $TmpDir/$SuSE10firewallConfigFile $systemConfigDirectory/$firewallConfigFile ") ;
	} 
	
	&ff_log_info("\nFirewall configuration files copied. \n  ") ;  
}

#function to enable the SuSEfirewall 
sub deployFirewall () {

	#warning the user of break in ssh connection 
	&ff_log_info("Installation successful, now configuring firewall for security purposes... ") ;
	&ff_log_info("\n\nWARNING : During these configuration changes the ssh connection may expire for this session. Please note that this will not affect the RSM installation.\n\n") ;
	# a small pause 
	sleep(2) ;

	&getSuSEVersionForFirewall();

	if ($SuSEVersion < 9 ) {
		# not supported for version less than 9.x 
		&ff_log_info(" SuSE firewall not supported  ") ;

	} elsif ( $SuSEVersion < 10 ){
	
		&ff_log_info(" SuSE version 9.x found. Going ahead with 9.x installation.  ") ;
		&ff_log_info("Establishing firewall... ") ;
		system (" chkconfig -a SuSEfirewall2_init ");
		system (" chkconfig -a SuSEfirewall2_setup ");
		system (" chkconfig -a SuSEfirewall2_final ");
		#firewall starting commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_init restart > firewall.tmp ; /etc/init.d/SuSEfirewall2_setup restart > firewall.tmp ; etc/init.d/SuSEfirewall2_final restart > firewall.tmp ; rm -f firewall.tmp ") ;
		&ff_log_info("\n Firewall has been successfully deployed \n  ") ; 

	} else {

		&ff_log_info(" SuSE version 10.x or higher found. Going ahead with 10.x installation ") ;
		&ff_log_info(" Establishing firewall  .. ") ;
		system (" chkconfig -a SuSEfirewall2_init ");
		system (" chkconfig -a SuSEfirewall2_setup ");
		#firewall starting commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_init restart > firewall.tmp ; /etc/init.d/SuSEfirewall2_setup restart > tempFirewall.txt ; rm -f firewall.tmp ");
		&ff_log_info("\n Firewall has been successfully deployed \n  ") ; 

	} 
	
	&ff_log_info("\n Done \n  ") ;  
	
}

sub removeFirewall () {

	&ff_log_info ("\n\nRestoring original firewall changes ... \n") ;
 	sleep(2);

	&getSuSEVersionForFirewall() ;
	if ($SuSEVersion < 9 ) {

		&ff_log_info(" SuSE firewall not installed  ") ;

	} elsif ( $SuSEVersion < 10 ){

		&ff_log_info(" SuSE version 9.x found. Going ahead with 9.x uninstallation.") ;
		my $file = "$systemConfigDirectory/$firewallConfigFile.orig" ;
		if ( -f $file ) {
			&ff_log_info(" Removing present configuration file and restoring original .. ") ;
			system (" rm -f $systemConfigDirectory/$firewallConfigFile") ;
			system (" mv -f $systemConfigDirectory/$firewallConfigFile.orig $systemConfigDirectory/$firewallConfigFile ") ;
		}
		&ff_log_info("Removing  firewall  .. ") ;
		system (" chkconfig -d SuSEfirewall2_final ");
		system (" chkconfig -d SuSEfirewall2_setup ");
		system (" chkconfig -d SuSEfirewall2_init ");
		#firewall stopping commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_final stop ; /etc/init.d/SuSEfirewall2_setup stop ; /etc/init.d/SuSEfirewall2_init stop ");

	} else {

		&ff_log_info(" SuSE version 10.x or higher found. Going ahead with 10.x uninstallation ") ;
		my $file = "$systemConfigDirectory/$firewallConfigFile.orig" ;
		if ( -f $file ) {
			&ff_log_info(" Removing present configuration file and restoring original .. ") ;
			system (" rm -f $systemConfigDirectory/$firewallConfigFile") ;
			system (" mv -f $systemConfigDirectory/$firewallConfigFile.orig $systemConfigDirectory/$firewallConfigFile ") ;
		}
		&ff_log_info(" Removing firewall  .. ") ;
		system (" chkconfig -d SuSEfirewall2_setup ");
		system (" chkconfig -d SuSEfirewall2_init ");
		#firewall stopping commands to be executed in a single step 
		system (" /etc/init.d/SuSEfirewall2_setup stop ; /etc/init.d/SuSEfirewall2_init stop ");
		
	} 

	&ff_log_info("\n Done \n  ") ; 
	

}

#function to find out SuSE release version for use in deploying firewall 
sub getSuSEVersionForFirewall() {

	# checking version of suse installed 
	open (CONSOLE, " cat /etc/SuSE-release  | grep VERSION | ");
	while (<CONSOLE>){
 		$SuSEVersion=$_;
	} 
	$SuSEVersion = substr($SuSEVersion,10) ;
	chomp($SuSEVersion) ;

}

sub ff_CreateSSLCert() {
	&ff_log_info("Creating SSL certificate...");
	my $hostIP = $ManagementIp;
	#fix me: read  password from profile
	my $keyPassword = &ff_getFromProfile('product.rsm.ssl_pass');

	chdir "$StartDir";
	system("chmod +x ./ssl_cert.pl");
	system("./ssl_cert.pl '$hostIP' '$keyPassword'");
	&ff_log_info("SSL certificate created");
}

sub ff_prepare()
{
	&ff_log_info("Prepare for installation");

	if (&ff_GetTempDir() == 0) {
		return 0;
	}
	ff_CreateHomeDir();
	ff_CreateOptLinks();
	if (&ff_CheckMediaFile() == 0) {
		return 0;
	}
	if (&ff_ExtractMediaFile() == 0) {
		return 0;
	}

	return 1;
}

sub ff_SetMySQLPasswd() {
	my $status;
	if(!&ff_ProcExist("mysqld")) {
		system("/etc/init.d/mysql start >/dev/null 2>&1");
	}

	# first check if the password is already set
	$status = system ("/usr/bin/mysqladmin -u root --password=\"$MySQL_root_passwd\" status > /dev/null 2>&1" );
	$status=($? >> 8);
	if (!$status) {
		&ff_log_info("MySQL root password is OK.");
		return 1;
	}

	# assume password is empty, and set new password
	&ff_log_info("Setting MySQL root password...");

	$status = system ("/usr/bin/mysqladmin -u root password '$MySQL_root_passwd'");
	if($status != $STATUS_OK) {
		&ff_log_error("Unable to set mysql root password. Please check if you input the correct password for root.");
		return 0;
	}
	&ff_log_info("MySQL root password is set.");
	return 1;
}

sub ff_stopJBoss() {
	my $procName = "run.jar";
	if(&ff_ProcExist($procName)) {
		&ff_log_info("Stopping JBoss...");
		system("/etc/init.d/jboss stop > /dev/null 2>&1");
		my $procExists=&ff_WaitProcExit($procName,4);
		if($procExists) {
			system("kill -9 `ps -ef | grep run.jar | grep -v grep | tr -s ' ' | cut -d ' ' -f2` >/dev/null 2>&1 ");
			$procExists=&ff_WaitProcExit($procName,4);
			if($procExists) {
				&ff_log_error("Couldn't stop JBoss");
				return 0;
			}
		}
	}
	return 1;
}

sub ff_InstallZip()
{
	my $status;
	&ff_log_info("Installing $ziprpm and $unziprpm...");
	chdir $TmpDir;
	if(! -f $ziprpm || !-f $unziprpm) {
		&ff_log_error("Couldn't find $ziprpm or $unziprpm");
		return 0;
	}
	my $status = system("rpm -i --force --nodeps $ziprpm");
	if($status != $STATUS_OK) {
		&ff_log_error("Cannot install $ziprpm");
		return 0;
	}
	$status = system("rpm -i --force --nodeps $unziprpm");
	if($status != $STATUS_OK) {
		&ff_log_error("Cannot install $unziprpm");
		return 0;
	}
	&ff_log_info("$ziprpm and $unziprpm installed...");
}

sub ff_ProcExist()
{
	my ($procName) = @_;
	my $outFile = "/tmp/".$procName.".proc";

	system("ps -ef | grep $procName | grep -v grep > $outFile");
	my $size = -s $outFile;
	system("rm -f $outFile");
	if ($size > 0) {
		return 1;
	}
	return 0;
}

sub ff_WaitProcExit()
{
	my ($procName, $numTimes) = @_;
	my  $i=0;
	while ($i != $numTimes) {
		if (!&ff_ProcExist($procName)) {
			return 0;
		}
		else {
			sleep 10;
			$i++;
		}
	}
	return 1;
}

sub ff_preinstall_add()
{
	
	if ( $typeOfInstall==1 && $isCheckDisabled != 1 ) {
		if (!&ff_checkIfCorrectRSMOSInstalled()) {
			return 0 ;
		}
	}

	if (!&ff_prepare()) {
		return 0;
	}

	if (!&ff_stopJBoss()) {
		return 0;
	}

	return 1;
}

sub ff_install_add()
{
	my $status;
	&ff_ConfigJBossIP();
	if($typeOfInstall == 1)
	{ 
	  #RSM Server
          # Check for currently installed vsersion of mysql
		chdir $TmpDir;
                my $mysqlCurrentVersion = &getMySqlVersion();
                if($mysqlCurrentVersion=~m/5\.0\.51/)
                {
                    &ff_log_info("Detected: $mysqlCurrentVersion");
                    &ff_log_info("Current MySql is up to date");
                }
                if(&GetProcessorType()=~m/x86_64/)
                {
                        if(! -f $libmysqlold64)
                        {
                                &FailedInstall($libmysqlold64." was not found");
				return 0;
                        }
                        $status=system("unzip -n -qq $libmysqlold64 -d /");
                        if($status != $STATUS_OK)
                        {
                                &ff_log_error("Unable to extract $libmysqlold64 , some functionalities, eg upgraderatingdata, upgradecapabilities might not work");
				return 0;
                        }

                }
                else
                {
                        if(! -f $libmysqlold32)
                        {
                                &FailedInstall($libmysqlold32." was not found");
				return 0;
                        }
                        $status=system("unzip -n -qq $libmysqlold32 -d /");
                        if($status != $STATUS_OK)
                        {
                                &ff_log_error("Unable to extract $libmysqlold32 , some functionalities, eg upgraderatingdata, upgradecapabilities might not work");
				return 0;
                        }

                }
                SelectMySqlPackage();
                $status = InstallMySqlServer();
	        if ($status != $STATUS_OK)
		{
			&ff_log_error("InstallMySQL returned with error code : $status. Halting installtion");
			return 0;
		}
                $status = InstallMySqlClient();
	        if ($status != $STATUS_OK)
		{
			&ff_log_error("InstallMySqlClient returned with error code : $status. Halting installtion");
			return 0;
		}
                $status = ConfigureMySqlServer();
	        if ($status != $STATUS_OK)
		{
			&ff_log_error("ConfigureMySqlServer returned with error code : $status. Halting installtion");
			return 0;
		}
	}
	else 
	{ 
		#RSM Lite
	}
	&ff_setupBNPropForRSM(); 
        if($typeOfInstall==1)
        {      
	        my $status= InstallJdk ();
	        if ($status != $STATUS_OK)
		{
			&ff_log_error(" InstallJdk returned with error code : $status. Halting installtion");
			return 0;
		}
	}
        if($typeOfInstall!=1) {
	     &ff_InstallZip();
	}
        ## Install JBoss
        my $status=InstallJBoss();
	if ($status != $STATUS_OK)
	{
		&ff_log_error("InstallJboss returned with error code : $status. Halting installtion");
		return 0;
	}
        if($typeOfInstall==1)
        {

                &ff_log_info("Configuring the parameters for MySQL Database.. ");
                $status = 1;
                my $counter = $MySqlWaitTime;
		my $past_ibdata=0;
		my $past_ibdata_size=0;
		my $curr_ibdata=1;
		my $curr_ibdata_size=0;
		&ff_log_info("This will take a long time (approx. 30 minutes). Please do not abort..");
                while ($status)
                {
			sleep 20;
                        $status = system ("/usr/bin/mysqladmin -u root --password=\"$MySQL_root_passwd\" status > /dev/null 2>&1" );
                        if($status ==0)
                        {
                                last;
                        }
                        print "..";
			$counter =$counter -1;
			$past_ibdata=$curr_ibdata;
			$past_ibdata_size=$curr_ibdata_size;
			$curr_ibdata =`/bin/ls -lrt /opt/nxtn/mysql/data/ibdata* 2>/dev/null | /usr/bin/tail -n 1 | /usr/bin/cut -f6 -d'/' | sed -e "s/ibdata//"`;
			$curr_ibdata_size = `/bin/ls -lrt /opt/nxtn/mysql/data/ibdata* 2>/dev/null | /usr/bin/tail -n 1 | tr -s ' ' | /usr/bin/cut -f5 -d' '`;
			if($counter<=0)
			{
		    	        if (($curr_ibdata != "") && ($past_ibdata != "")) {
					if( ($curr_ibdata > $past_ibdata) || (($curr_ibdata == $past_ibdata) && ($curr_ibdata_size > $past_ibdata_size) )||($curr_ibdata==1))  {
						&ff_log_info("MySql seems to be taking a longer time than expected");
						&ff_log_info("Please wait. Do not abort.");
						next ;
					}
					else {
						&FailedInstall("MySql failed to start within stipulated time");
						return 0;	
					}
				}
				else {
					&FailedInstall("MySql failed to start within stipulated time");
					return 0;	
				}
			}                    
                }
                $DB_Password = "";
                chdir $TmpDir;
		if (!&ff_configureMySQLDatabase()) {
			return 0;
		}
        }
        else
        {
                &ff_log_info("Configuring $typeOfInstallString properties ");
                if(!(-f $libdir."/libpq.so.3") && (-f $libdir."/libpq.so.4"))
                {
                        chdir $libdir;
                        system("ln -s libpq.so.4 libpq.so.3");
                }
                chdir $TmpDir;
              	system ("./createIvmsCfg.act -f bn.properties -d . -i . -u msw -t $MSWHostName -w $MSWPort -m $ManagementIp -x");
                ## Added the changed scripts for the fixing the error during sloan startup
                $status = system ("cp $TmpDir/bn.properties $NextoneOpt/.");
        }
	chdir $TmpDir;
        if($typeOfInstall==1)
        {
                &ff_updateMySqlXml();
		SNMPConfiguration();
        }
	&ff_CreateAlarmScriptsDir();
	&ff_CreateUIDir();
	&ff_UpdateS99local();
	&ff_CreateStreamDir();
	&ff_CreateArchiveDir();
    #---------- SWM changes ------------#
	&ff_CreateSWMDir();
	#---------- SWM changes ------------#
	if (!&ff_CopyConfFiles($TmpDir,$JBossDir)) {
		return 0;
	}
        chdir $TmpDir;
        $status = system ("cp $TmpDir\/nextoneJBoss /etc/init.d/jboss");
        $status = system ("chmod +x /etc/init.d/jboss");
        $status = system ("cp $TmpDir\/nextoneMySQL /etc/init.d/mysql");
	$status = system ("chmod +x /etc/init.d/mysql");
	&ff_copyPAM();
	&ff_CreateSSLCert();
	&ff_log_info("Starting the JBoss Server..");
        $status = system ("/etc/init.d/jboss start  > /dev/null &");
        if($status != $STATUS_OK)
        {
	        &ff_log_error("Could not start JBoss");
		return 0;
        }
        if($typeOfInstall==2)
        {
           &ff_log_info("Please start msx manually..");
        }
	if ($typeOfInstall == 1)
	{
		&copyFirewallConfigFile() ;
		#Limiting ssh access to protocol version 2.
		modifySshProtocol();
	}
	&setiVMSVersion($SelfVersion);
	# Manage RSM System ports.Called at last to prevent any ssh disconnection
	if ($typeOfInstall == 1)
	{
		&deployFirewall() ;
	}
	return 1;
}
##
##Get currently installed version of MySql
##
sub getMySqlVersion()
{
        my $filetmp = $TmpDir."\/mysqlversion";
	my $mysqlversion= "0.0";
	if ( -f "/usr/bin/mysqladmin")
	{
           my $status = system("mysqladmin -V > $filetmp");
           $mysqlversion = &getStringFrmFile($filetmp);
	}
        return $mysqlversion;
}
sub ff_install_remove()
{
	my $status;
	my $jdk=abs_path("$OptNxtn/jdk");
        my $mysqldata=abs_path("$OptNxtn/mysql/data");
	my $jboss=abs_path("$OptNxtn/jboss");
        my $mysqllog=abs_path("$OptNxtn/mysql/log");
	my $procName = "run.jar";
	my $curversion="Unknown version";
	if (-f "$OptDir/rsm/.ivmsindex") {
		$curversion=`cat $NextoneOpt/.ivmsindex`;
		chomp($curversion);
	}
	&ff_log_info("Uninstalling RSM package, version: $curversion");

	if (!&ff_stopJBoss()) {
		return 0;
	}
        if(&ff_ProcExist($procName))
        {
                &ff_log_info("JBoss is running, attempting to stop JBoss\n");
                my $status = system ("/etc/init.d/jboss stop > /dev/null 2>&1");
                my $procExists=&ff_WaitProcExit($procName,10);
                if($procExists)
                {
                        my $status = system("kill -9 `ps -ef | grep run.jar | grep -v grep | tr -s ' ' | cut -d ' ' -f2` >/dev/null 2>&1 ");
                        my $procExists=&ff_WaitProcExit($procName,10);
                        if($procExists)
                        {
                        	&ff_log_error("Couldn't shutdown JBoss ...\nShutdown JBoss and try again ...\n");
                                return 0;
			}
                }
        }
	if($typeOfInstall == 1) { #RSM Server
		if (!remove_user_from_system()) {
			return 0;
		}
                $status=system("mysql -uroot --password=$MySQL_root_passwd -e'drop database bn'");
                if($status != $STATUS_OK)
                {
                        &ff_log_error("Unable to drop database bn unable to continue uninstall");
                        return 0;
                }
	}
	else { #RSM Lite
	}
        if((-f $mysqldata || -d $mysqldata) && (-f $mysqllog || -d $mysqllog) && $typeOfInstall==1)
        {
                        my $procName = "$MySqlProcStr";
                        my $outFile = $TmpDir."/".$procName.".proc";
                        if(&ff_ProcExist($procName))
                        {
                                &ff_log_info("MySql is running, attempting to stop MySql\n");
                                my $status = system ("/etc/init.d/mysql stop");
                                my $procExists=&ff_WaitProcExit($procName,4);
                                if($procExists)
                                {
                                        &ff_log_error("Couldn't shutdown MySql ...\nShutdown MySql and try again ...\n");
                                        return 0;
                                }
                        }
                        system("rm -rf $OptNxtn/mysql/data");
                        system("rm -rf $OptNxtn/mysql/log");
			if(-f "/etc/rc.d/rc3.d/S99mysql")
			{
				system ("rm /etc/rc.d/rc3.d/S99mysql");
			}
                        system("rm /etc/init.d/mysql");
                        system("rm /etc/my.cnf");
        }
        if(-f $jdk || -d $jdk)
        {
			if($typeOfInstall==1){
                        	system("rm -rf $jdk");
	                        system("rm -rf $OptNxtn/jdk");
			}
        }
        if(-f $jboss || -d $jboss)
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
	system ("rm -rf $NextoneOpt");

	my $JBossDeployDir = $JBossDir.$JBossDeployDirSuffix;
	system ("rm -rf $JBossDeployDir/iview.war");
	system ("rm -rf $JBossDeployDir/bn.ear");
	system("unlink $JBossDir");
	system("unlink $JdkDir");

	&ff_log_info("RSM package uninstalled successfully");
	# undoing firewall changes. Called at last to prevent any ssh disconnection  
	if ($typeOfInstall == 1)
	{
		&removeFirewall() ;
	}
	return 1;
}

sub ff_postinstall_add()
{
	if($typeOfInstall == 1) { #RSM Server
		if(!&ff_ProcExist("mysqld")) {
			&ff_log_info("Starting MySQL Server...");
			system("/etc/init.d/mysql start >/dev/null 2>&1");
		}
	}
	if(!&ff_ProcExist("run.jar")) {
		&ff_log_info("Starting JBoss Server...");
		system ("/etc/init.d/jboss start >/dev/null 2>&1");
	}
	return 1;
}

sub ff_getFromProfile() {
	my ($attrName) = @_;
	my $attrValue = `nxprofile get $attrName`;
	chomp($attrValue);
	return $attrValue;
}

sub remove_user_from_system()
{
	my $status;
##mysql does not support the new mysql password algo, so we change the password to the old formats, and change them back after we're done
	open (TMP2,">fix_privileges_old_pwd_tmp.sql");
	print TMP2 "USE mysql;";
	print TMP2 "UPDATE user SET password=OLD_PASSWORD('$MySQL_root_passwd') WHERE user='root';\n";
	print TMP2 "FLUSH PRIVILEGES;";
	close (TMP2);

	open (TMP1,">fix_privileges_new_pwd_tmp.sql");
	print TMP1 "USE mysql;";
	print TMP1 "UPDATE user SET password=PASSWORD('$MySQL_root_passwd') WHERE user='root';\n";
	print TMP1 "FLUSH PRIVILEGES;";
	close (TMP1);
	$status =system("mysql -u root --password=$MySQL_root_passwd  < fix_privileges_old_pwd_tmp.sql");
	if($status != $STATUS_OK) {
		print ("Unable to change root password to old version, cannot continue.");
		system("rm -f fix_privileges_old_pwd_tmp.sql");
		system("rm -f fix_privileges_new_pwd_tmp.sql");
		return 0;
	}
	system("rm -f fix_privileges_old_pwd_tmp.sql");
	system("rm -f fix_privileges_new_pwd_tmp.sql");

	my $dbh;
	my $sth;
	$dbh = DBI->connect("dbi:mysql:dbname=bn;", "root", $MySQL_root_passwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
	$sth = $dbh->prepare("select username from users where userid != 1");
	$sth->execute;
	$status=system("mkdir -p /home/.backup");
	if($status != $STATUS_OK) {
		print("Unable to backup users data");
		return 0;
	}
	my $date = `date '+%m-%d-%y-%H%M%S'`;
	$status=system("mkdir -p /home/.backup/$date");
	if($status != $STATUS_OK) {
		print("Unable to backup users data");
		return 0;
	}

	while (my($username)=$sth->fetchrow_array) {
		system("mv -f /home/$username /home/.backup/$date/ >/dev/null 2>&1");
		$status=system("userdel -r $username >/dev/null 2>&1");
		if($status != $STATUS_OK) {
			print("Unable to remove users from system");
			return 0;
		}
	}
	if ($sth) {
		$sth->finish;
	}
	if ($dbh)
	{
		$dbh->disconnect;
	}
	
	return 1;
}

sub SNMPConfiguration()
{

        &ff_log_info("Configuring SNMPd");

        `cat /etc/snmp/snmpd.conf | grep 'agentXSocket tcp:127.0.0.1:705'`;
		if($? == 0 )
		{
			&ff_log_info("Configuration already present... Not doing any thing");
		}
		else
		{
			&ff_log_info("Configuration not present... adding");
			`/usr/bin/sed --in-place '/^agentxtimeout.*5/{
			aagentXSocket tcp:127.0.0.1:705
			}' /etc/snmp/snmpd.conf`;
			&ff_log_info("Configuration added");
			&ff_log_info("Restarting snmpd .... ");
			`/etc/init.d/snmpd restart`;
			&ff_log_info("Restarted snmpd .... ");

		}
		&ff_log_info("Configuring SNMPd done");
}

sub ff_checkIfCorrectRSMOSInstalled() {

	# intialized with value 2 which is the value returned by the script if OS check fails 
	my $isCorrectOS = 2 ; 

	if( -f "$StartDir/$checkOSScriptName") {
	
		system ("chmod +x $StartDir/$checkOSScriptName") ;
		$isCorrectOS = system ("$StartDir/$checkOSScriptName") ;

		if ($isCorrectOS != 0 ) {
			&ff_log_error("correct RSM OS version not found.\n\n");
			return 0;
		}
		&ff_log_info("correct RSM OS version found.\n\n");
		return 1 ;
	} else {
		&ff_log_error("Script to check RSM OS version not found.Exiting\n\n");
		return 0;
	}
}

#function to control the ssh access to protocol version 2
sub modifySshProtocol() {
     print "\nUpdating SSH configuration to control its access to protocol version 2 only ...  \n" ;
     my @arrayOfCorrectPros = () ;
     my $status;
     my $ProtocolString = "Protocol";
     open(SshIn,"<$SshDir/sshd_config");
     open(SshOut,">$SshDir/sshd_config.tmp");
     while (my $line = <SshIn>) {
        $status = index($line, $ProtocolString);

        if ($status ge 0) {
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
	$status = system("/etc/init.d/sshd restart");  


}


###################################################

##
## Main
##

$| = 1;

if (! @ARGV) {
	PrintHelpMessage ();
}

open(STDOUT, ">>/var/log/rsm_install.log");
open(STDERR, ">>/var/log/rsm_install.log");

my $status = 1;
$StartDir = $ENV{'nxi_tempinst'};
system("chmod +x $StartDir/nxi_log");

$ff_task = $ARGV[0];

my $product = $ARGV[1];
if ($product eq 'RSM_SERVER') {
	$typeOfInstall=1;
	$typeOfInstallString = "RSM Server";
}
elsif ($product eq 'RSM_LITE') {
	$typeOfInstall=2;
	$typeOfInstallString = "RSM Lite";
}
else {
	&ff_log_error("Unsupported product: $product");
	exit 1;
}

#get install.operation from profile
$ff_operation = &ff_getFromProfile('install.operation');
if ($ff_operation eq "add") { #install RSM
	#get management IP from profile
	$ManagementIp = &ff_getFromProfile('os.local.mgmt_ip');
	#&ff_log_debug("Management IP: $ManagementIp");

	if($typeOfInstall == 1) { #RSM Server
		$MySQL_root_passwd = &ff_getFromProfile('product.rsm.mysql_root_pass');
	}

	if ($ff_task eq "nxi_preinstall") {
		$status = ff_preinstall_add();
	}
	elsif ($ff_task eq "nxi_install") {
		$status = ff_install_add();
	}
	elsif ($ff_task eq "nxi_postinstall") {
		$status = ff_postinstall_add();
	}
	elsif ($ff_task eq "nxi_finalize") {
		system ("/bin/rm -rf $TmpDir");
	}
	else {
		&ff_log_error("Unsupported task: $ff_task");
		exit 1;
	}

	if (!$status) {
		exit 1;
	}
}
elsif ($ff_operation eq "remove") { #uninstall RSM
	if($typeOfInstall == 1) { #RSM Server
		$MySQL_root_passwd = &ff_getFromProfile('product.rsm.mysql_root_pass');
	}

	if ($ff_task eq "nxi_preinstall") {
	}
	elsif ($ff_task eq "nxi_install") {
		$status = ff_install_remove();
	}
	elsif ($ff_task eq "nxi_postinstall") {
	}
	elsif ($ff_task eq "nxi_finalize") {
	}
	else {
		&ff_log_error("Unsupported task: $ff_task");
		exit 1;
	}

	if (!$status) {
		exit 1;
	}
}
else {
	&ff_log_error("Unsupported operation: $ff_operation");
	exit 1;
}

exit 0;
