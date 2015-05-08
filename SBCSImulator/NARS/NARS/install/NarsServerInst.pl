#!/usr/bin/perl
##
## Narsinstall
##
## Version 1.3
## Hello, I am..

use strict;

my $Self = "narsinstall";
my $SelfVersion = "2.06c2";

## This is what I do...
my $Product = "NARS";
my $InstallLogFile = "narsinstall.log";
my $UpgradeLogFile = "narsupgrade.log";
my $AdmMediaFile = "nars.tar";
my $Unpack = "tar xf ";
my $TmpDir = "/tmp";
my $UsrDir = "/usr/local";
my $UsrJava = "/usr";
my $MySQLServerRpm = "MySQL-server-4.0.17-0.i386.rpm";
my $MySQLClientRpm	= "MySQL-client-4.0.17-0.i386.rpm";
my $JakartaVersion = "jakarta-tomcat-5.0.18";
my $JakartaTomcat  = "jakarta-tomcat-5.0.18.tar";
my $J2sdkVersion = "j2sdk1.4.2_02";
my $J2sdkRpm	= "j2sdk-1_4_2_02-linux-i586.bin";
my $MinTmpSpace	= 300000;
my $MinBkSpace	= 10;
my $ROOT_Password = "nars";
my $MySqlDir;
my $MySqlLog;
my $DB_Username;
my $DB_Password;
my $UpgradeBak;
my $StartDir = `pwd`;
my $MemString4G="CONFIG_HIGHMEM4G=y";
my $MemString64G="CONFIG_HIGHMEM4G=y";

use Getopt::Std;
use Data::Dumper;
use XML::Simple;
use Config::Simple;
use IO::Handle;
use Cwd 'abs_path';


chop $StartDir;

sub GetResponse ()
{
	print "Hit <CR> to continue...\n";
	my $resp = <>;
}

sub GetSpecialResponse ()
{
	print "Hit <CR> to continue. (OR) <Ctrl-C> to abort..\n";
	my $resp = <>;
}

sub GetBooleanResponse ()
{
	while (1)
	{
		my ($mess) = @_;
		$mess = $mess." [y\/n] :";
		print "$mess";
		my $resp = <>;
        	$resp =lc($resp);
        	$resp =substr($resp,0,1);
        	if ($resp eq 'n')
		{
			exit 0;
		}
		if ($resp eq 'y')
		{
			return;
		}
	}
}

sub PrintHelpMessage ()
{
	print "$Self version $SelfVersion\n";
	print "$Self -v -h \n";
	print "$Self -i  to install \n";
	print "$Self -d  to uninstall \n";
	print "$Self -u  to upgrade\n";
	
	exit 0;
}

##
## Privilege check.
##
sub CheckForSuperuser ()
{
	###########################
	## Must be root
	###########################
	if ($ENV{'LOGNAME'} ne "root" )
	{
		print "\nYou must be super-user to run this script.\n";
		print "Exiting....\n ";
		exit 2;
	}
}


##
## Set password for MySQL root user
##
sub SetMySQLPasswd ()
{
	my $resp = "";
	my $status;
	while (1)
	{
		print "Type new password for MySQL root user :";
		my $status = system ("stty -echo");
		chop($resp = <>);
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
	print "Credentials of root user modified \n";	
}
##
## Prompts for and creates a temporary directory
##
sub GetTempDir ()
{
	my ($op) = @_;
	my $resp;
	my $tmpspace;
	my $status;
	# Get name of tmp directory to be used during install process

	print "Enter tmp directory to be used during $op [$TmpDir] :";

	# Read..
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$TmpDir = $resp;
	}
	if (!-d $TmpDir)
	{
		print "$TmpDir not found...";
		GetResponse ();
		exit 2;
	}

	# Obtain the size of $TmpDir
        $tmpspace = GetDiskUsage($TmpDir);

	if ($tmpspace < $MinTmpSpace)
	{
		print "Cannot proceed with NARS $op... \n";
		print "Insufficient disk space in $TmpDir.. \n";
		print "At least $MinTmpSpace kb required in $TmpDir.. \n";
		GetResponse ();
		exit 2;
	}
	$TmpDir = $TmpDir."/narsinstall";
	if (!-d $TmpDir)
	{
		mkdir ($TmpDir, 0777);
	}	
	$status = system ("rm -rf $TmpDir/*");
}


##
## Prompt for and validate the media file
##
sub GetMediaFile ()
{
    my $resp;
    my $mediaFile;
    while (1)
    {
	## Get name of mediafile
	$mediaFile = $AdmMediaFile;
	print "Enter mediafile [$mediaFile] :";

	# Read..
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$mediaFile = $resp;
	}
		

	chdir "$StartDir";

	if ( ! -f $mediaFile)
	{
		print "Unable to find $mediaFile \n";
		GetResponse ();
	}
        else
	{
		last;
	}
    }
}


##
## untar the given media file
##
sub ExtractMediaFile ()
{
	my $status;
	chdir $StartDir;

	print "Extracting the media file..\n";
	$status = system ("cp $AdmMediaFile $TmpDir/.");
	chdir $TmpDir;
	$status = system ("$Unpack $AdmMediaFile");

	if ($status)
	{
		print "/usr/bin/tar : $status \n";
		GetResponse ();
		exit 2;
	}

	print "Extracting the media file..done \n";
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
	open tmp, "<$tmpBuf";
	$space = <tmp>;
	close tmp;
	$status = system ("rm -rf $tmpBuf");

        return $space;
}


##
## Prompt and return a valid directory
##
sub GetDir ()
{
    my ($prompt, $defaultValue) = @_;
    my $resp;

    while (1)
    {
        print "$prompt [$defaultValue] : "; 
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
            $defaultValue = $resp;
	}
	
	if (! -d $defaultValue)
	{
            print "\tUnable to find $defaultValue\n";
	}
        else
        {
            last;
        }
    }

    return $defaultValue;
}


##
## Install tomcat
##
sub InstallTomcat ()
{
	my $status;
	my $installDir;
 	my $status = system ("/etc/init.d/tomcat stop > /dev/null 2>&1");
        print "Preparing to install Tomcat .. \n";

        if ( -d "/usr/local/tomcat")
        {
            my $curJakarta = abs_path("/usr/local/tomcat");
            if ($curJakarta =~ /$JakartaVersion$/)
            {
                print "Current Tomcat is up to date\n";
                return;
            }
        }

        $installDir = &GetDir("Enter the directory for Tomcat installation", $UsrDir);
	my $status = system ("unlink /usr/local/tomcat");

        chdir $installDir;

        # check if it is already there
        if ( ! -d $JakartaVersion )
        {
            print "Extracting Jakarta Tomcat .. \n";
            $status = system ("$Unpack $TmpDir/$JakartaTomcat");
            print "Extracting Jakarta Tomcat ..done \n";
        }

        $status = system ("rm -rf $UsrDir/tomcat");
       	$status = system ("ln -s $installDir/$JakartaVersion $UsrDir/tomcat");

	print "Installing Jakarta Tomcat ..done \n";

        GetResponse ();
}


##
## Install JDK
##

sub InstallJdk ()
{
	print "Beginning with Java installation  \n"; 
	GetResponse ();

	chdir $TmpDir;
	my $AbsJ2sdkRpm = $TmpDir."\/".$J2sdkRpm;
	if ( ! -f $AbsJ2sdkRpm)
	{
		print "Unable to find $J2sdkRpm in $TmpDir  \n";
		GetResponse ();
		exit 2;	
	}

	print "Installing Java J2SDK ..  \n";

        if ( -d "/usr/local/jdk")
        {
            my $curJava = abs_path("/usr/local/jdk");
            if ($curJava =~ /$J2sdkVersion$/)
            {
                print "Current J2sdk is up to date\n";
                return;
            }
        }

        $UsrJava = &GetDir("Enter the directory for JAVA installation", $UsrJava);
	print "Installing Java in $UsrJava\n"; 
	chdir "$UsrJava";
	my $DstUsrJava=$UsrJava."\/"."j2sdk1.4.2_02";
	my $status = system ("unlink /usr/local/jdk");
	if (-d $DstUsrJava)
	{
		$status = system ("rm -rf $DstUsrJava");
	}
	$status = system ("$AbsJ2sdkRpm");
	$status = system ("ln -s $DstUsrJava /usr/local/jdk");
	print "Installing Java J2SDK in $DstUsrJava..done \n";

}


##
## Install
##
sub InstallPackage ()
{

	# Must be privileged.
	CheckForSuperuser ();
	my $status;
	my $resp;

	#############################################
	## $StartDir for creating install log
	## $StartDir for reading media file by default
	###############################################

	my $InstallLog = $StartDir."\/".$InstallLogFile;
	open (ERROR, "> $InstallLog");
	STDERR->fdopen(\*ERROR, "w");

	print "Proceeding to install NARS Server Package... \n";
	
	# Get name of tmp directory to be used during install process
	&GetTempDir("installation");

	## Get name of mediafile
        &GetMediaFile();

	$UpgradeBak = $TmpDir."\/narsbak";
	$status = system ("mkdir $UpgradeBak");

        ExtractMediaFile();

	$status = system ("cp nars.war $UpgradeBak/.");

	##
	## Go through the steps.
	##

	# Initially clean machine of any old traces...

	#print "Remove traces of any old MySQL installation ? \n";
	#my $testStr = "Remove traces of any old MySQL installation ? ";
	&GetBooleanResponse("Remove traces of any old MySQL installation?");
	$status = system ("/etc/init.d/mysql stop");
	sleep 10;
	$status = system ("mv /etc/my.cnf /etc/my.cnf.old");
	$status = system ("rm -rf /var/lib/mysql");
	$status = system ("rm -rf /var/lib/mysql-bak");

	## 
	## Create Database directory
	##

	print "Enter directory to be used for creating database [\/mysqldata] :";
	$MySqlDir = "\/mysqldata";
	if (! -d $MySqlDir)
	{
		$status = system ("rm -rf $MySqlDir");
		$status = system ("mkdir $MySqlDir");
	}

	# Read..
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$MySqlDir = $resp;

		if (!-d $MySqlDir)
		{
			GetResponse ();
			exit 2;
		}
	}
	if($MySqlDir ne "\/mysqldata")
	{
		$MySqlDir = $MySqlDir."\/mysqldata";
	}

	if (-f $MySqlDir)
	{
		&GetBooleanResponse("Delete file $MySqlDir?");
		$status = system ("rm -rf $MySqlDir");
	}
	if (-d $MySqlDir )
	{
		&GetBooleanResponse ("Delete contents of $MySqlDir?");
		print "Deleting $MySqlDir.. \n";
		print "This may take a long time...\n";
		print "Please do not abort...\n";
		$status = system("rm -rf $MySqlDir/*");
	}
	else
	{
		$status = system ("mkdir $MySqlDir");
	}

	if ($MySqlDir ne "\/mysqldata")
	{
		$status = system ("rm -rf /mysqldata");
		$status = system ("ln -s $MySqlDir /mysqldata");
	}

	## 
	## Create database logs directory
	##

	print "Enter directory to be used for creating database logs [\/mysqllogs] :";
	$MySqlLog = "\/mysqllogs";
	if (! -d $MySqlLog)
	{
		$status = system ("mkdir $MySqlLog");
	}
	# Read..
	my $resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$MySqlLog = $resp;
		if ( !-d $MySqlLog)
		{
			print "$MySqlLog not found... \n";
			GetResponse ();
			exit 2;
		}
	}

	if($MySqlLog ne "\/mysqllogs")
	{
		$MySqlLog = $MySqlLog."/mysqllogs";
	}
	if (-f $MySqlLog)
	{
		&GetBooleanResponse("Delete file $MySqlLog?");
		$status = system ("rm -rf $MySqlLog");
	}
	if (-d $MySqlLog)
	{
		&GetBooleanResponse ("Delete contents of $MySqlLog?");
		print "Deleting $MySqlLog.. \n";
		print "This may take a long time...\n";
		print "Please do not abort...\n";
		$status = system("rm -rf $MySqlLog/*");
	}
	else
	{
		$status = system ("mkdir $MySqlLog");
	}

	if ($MySqlLog ne "\/mysqllogs")
	{
		$status = system ("rm -rf /mysqllogs");
		$status = system ("ln -s $MySqlLog /mysqllogs");
	}

	chdir $TmpDir;
	print "Installing MySQL Server 4.0.17.. \n";
	if ( ! -f $MySQLServerRpm)
	{
		print "Unable to find $MySQLServerRpm \n";	
		GetReponse();
		exit 2;
	}

	$status = system ("rpm -i --force $MySQLServerRpm");

	print "Installing MySQL Server 4.0.17..done \n";

	if ( ! -f $MySQLClientRpm)
	{
		print "Unable to find $MySQLClientRpm \n";	
		GetReponse();
		exit 2;
	}

        print "Installing MySQL Client..   \n";

	$status = system ("rpm -i --force $MySQLClientRpm");

        print "Installing MySQL Client..done   \n";

	SetMySQLPasswd ();

	##
	## Shutdown MySQL Database, copy databse files to $MySQLDir
	## Create /etc/my.cnf
	##
	
	print "Shutting down MySQL Database.. \n";
        $status = system ("/usr/bin/mysqladmin -u root --password=\"$ROOT_Password\" shutdown");
        $status = system ("mv /var/lib/mysql /var/lib/mysql-bak");
       	$status = system ("rm -rf /var/lib/mysql");

        $status = system ("chown mysql:mysql $MySqlDir");
        $status = system ("chown mysql:mysql /mysqldata");
        $status = system ("chown mysql:mysql /mysqllogs");
        $status = system ("chown mysql:mysql $MySqlLog");

        $status = system ("ln -s $MySqlDir /var/lib/mysql");
        $status = system ("chown mysql:mysql /var/lib/mysql");
        $status = system ("mv /var/lib/mysql-bak/mysql /var/lib/mysql");
	$status = system ("rm -rf /var/lib/mysql-bak");

	print "Customizing MySQL configuration file.. \n";

	ModifyMyCnf ();

        $status = system ("mv /etc/my.cnf /etc/my.cnf.bak");
        $status = system ("cp my.cnf /etc/my.cnf");

	print "Customizing MySQL configuration file..done \n";
   
	$status = system ("rm /etc/rc3.d/S99mysql");
        $status = system ("ln -s /etc/init.d/mysql /etc/rc3.d/S99mysql");

	##
	## Start the MySQL database
	##

	print "Creating MySQL Database.. \n";
	print "This will take a long time...\n";
	print "Please do not abort...\n";
        $status = system ("/etc/init.d/mysql start");
	print "MySql Database created in $MySqlDir  \n";


	##
	## Install Java
	##

	InstallJdk ();

        ## Install tomcat

        InstallTomcat();

	## Prepare for web.xml update
	chdir $UpgradeBak;
	$status = system ("cp $TmpDir/nars.war $UpgradeBak/.");
	$status = system ("/usr/local/jdk/bin/jar xvf nars.war WEB-INF\/web.xml");

	

	##
        ## Update the web.xml using user's response
	##

	print "Configuring the parameters for NARS server..\n";
	
	chdir $TmpDir;
	$status = system ("mkdir WEB-INF");

	UpgradeWebXml ();	

	print "Updating the web.xml for NARS server.. \n";

        ## Update the nars.war with new web.xml

        chdir $TmpDir;
	$status = system ("/usr/local/jdk/bin/jar uvf nars.war WEB-INF/web.xml");

	print "Configuring the parameters for NARS server..done \n";

	$status = system ("rm -rf /usr/local/tomcat/webapps/nars");

	$status = system("cp nars.war /usr/local/tomcat/webapps/nars.war");

	print "Configuring the parameters for MySQL Database.. \n";
	print "This may take a long time..\n";
	print "Please do not abort..\n";
	$status = 1;

	while ($status)
	{
		sleep 10;
		$status = system ("/usr/bin/mysqladmin -u root --password=\"$ROOT_Password\" status > /dev/null 2>&1; exit $?" );
	}
	print "\n";

	$status = system ("./db.sh  i /usr/bin/mysql root \"$ROOT_Password\" \"$SelfVersion\" \"$DB_Username\" \"$DB_Password\"");

	print "Configuring the parameters for MySQL Database..done \n";
        $status = system ("cp nextoneTomcat /etc/init.d/tomcat");
        $status = system ("chmod +x /etc/init.d/tomcat");

	print "Starting the Jakarta Tomcat Server..\n";

	$status = system ("/etc/init.d/tomcat start");
	
	UpdateS99local ();

	##
	## Clean up.
	##	

	$status = system ("/bin/rm -rf $TmpDir");

	print "Install Log created in  $InstallLog \n";
	print "Successfully installed NARS Server!! \n";

	GetResponse ();
}


##
## Upgrade package.
##
sub UpgradePackage ()
{
	my $TomDir;
	my $resp;
	my $bkspace;
	my $status;
        my $NarsBakDir;
	my $tabUpgradeFile;
	# Must be privileged.
	CheckForSuperuser ();

	my $UpgradeLog = $StartDir."\/".$UpgradeLogFile;
	open (ERROR, "> $UpgradeLog");
	STDERR->fdopen(\*ERROR, "w");
	
	print "Proceeding to upgrade NARS Server Package... \n";
	print "This would restart the NARS WEB Server...\n";
	&GetBooleanResponse ("Do you want to continue?");

	## Get name of tmp directory to be used during upgrade process
	&GetTempDir("upgrade");
	
	## Get name of mediafile
        &GetMediaFile();

	##
	## Get directory for nars.war  backup
	##
        while (1)
        {
		$NarsBakDir = $StartDir;
		print "Enter directory to be used for backing up the old nars.war [$NarsBakDir] :";
		# Read..
		$resp = <>; 
		chop $resp;
		print "\n";
		if ($resp ne "")
		{
			$NarsBakDir = $resp;
		}
       		if ( ! -d $NarsBakDir)
        	{
			print "\t$NarsBakDir not found, please enter a valid directory \n";
			GetResponse();
        	}
        	else
        	{
			last;
        	}
        }

        $bkspace = &GetDiskUsage($NarsBakDir);

	if ($bkspace < $MinBkSpace)
	{
		print "Cannot proceed with NARS upgrade... \n";
		print "Insufficient disk space in $NarsBakDir.. \n";
		print "At least $MinBkSpace kb required in $NarsBakDir.. \n";
		GetResponse ();
		exit 2;
	}
		
	$NarsBakDir = $NarsBakDir."/narsbackup-".time;	

	&ExtractMediaFile();

	##
	## Upgrade tomcat
	##

	$UpgradeBak = $TmpDir."\/narsbak";
	$status = system ("rm -rf $UpgradeBak");
	$status = system ("mkdir $UpgradeBak");
	$status = system ("mkdir $UpgradeBak\/WEB-INF\/");

	chdir $TmpDir;
	$status = system ("mkdir WEB-INF");

	while (1)
	{
		$TomDir = "\/usr\/local\/tomcat";
		print "Enter tomcat root directory [$TomDir] :";
		chop(my $resp = <>);
		print " \n";
		if ($resp ne "") 
		{
			$TomDir = $resp;
		}
		if ( ! -d $TomDir)
		{
			print "Unable to find $TomDir, please enter a valid directory\n";	
			GetResponse ();
			
		}
		else
		{
			last;
		}
	}

	print "Attempting to shutdown Jakarta Tomcat..\n";
	#&GetBooleanResponse ("Shutting down Jakarta Tomcat..");
	$status = system ("rm -rf $NarsBakDir");
	$status = system ("mkdir $NarsBakDir");
	
        $status = system ("cd $TomDir\/webapps/nars; /usr/local/jdk/bin/jar uvf ../nars.war WEB-INF/web.xml");
	$status = system ("/bin/cp -p $TomDir\/webapps/nars.war $NarsBakDir/.");
	$status = system ("/bin/cp -p $TomDir\/webapps/nars/WEB-INF/web.xml $NarsBakDir/.");
	$status = system ("/bin/cp -p $TomDir\/webapps\/nars.war $UpgradeBak\/.");

        InstallTomcat();

	chdir $UpgradeBak;
	$status = system ("/usr/local/jdk/bin/jar xvf nars.war WEB-INF/web.xml");
	
	if (! -f "WEB-INF/web.xml")
	{
		print "Cannot find web.xml in nars.war..\n";
		print "Exiting..\n";
		GetResponse ();
		exit 2;
	}

	##
	## Upgrade web.xml 
	##

	UpgradeWebXml ();	

	chdir $TmpDir;

	print "Updating the web.xml for NARS server.. \n";
	$status = system ("/usr/local/jdk/bin/jar uvf nars.war WEB-INF\/web.xml");
	$status = system ("/bin/cp -p nars.war $TomDir\/webapps\/nars.war");
	print "Updating the web.xml for NARS server..done \n";
	
	##
	## Verify if mysql process is running
	##

	my $status = system('pgrep mysqld > /dev/null 2>&1');
	$status = $?>>8;
	if($status)
	{
		print "MySQL not running, cannot upgrade database..\n";
		print  "Exiting NARS upgrade ...\n";
		print  "All settings reverted to earlier version..\n";
		$status = system ("cp $NarsBakDir/nars.war $TomDir\/webapps\/nars.war");
		print "Starting Tomcat Server..\n";
		$status = system ("/etc/init.d/tomcat start");
		print "Upgrade Log created in  $UpgradeLog \n";
		GetResponse ();
		exit 2;
	}

	##
	## Upgrade database
	##

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
	if ($status)
	{
		print  "Exiting upgrade ...\n";
		print "All settings reverted to earlier version..\n";
		$status = system ("cp $NarsBakDir/nars.war $TomDir\/webapps\/nars.war");
		print "Starting Tomcat Server..\n";
		$status = system ("/etc/init.d/tomcat start");
		print "Upgrade Log created in  $UpgradeLog \n";
		GetResponse ();
		exit 2;
	}
	
	## GetNarsVersion ();

	my $curNarsVersion="2.00d6";	
	print "Enter currently installed NARS version [$curNarsVersion]:";

	# Read..
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$curNarsVersion=$resp;
	}	

	$tabUpgradeFile="nars-tables-upgrade-"."$curNarsVersion"."-"."$SelfVersion".".sql";
	if ( ! -f $tabUpgradeFile)
	{
		print "Upgrade from $curNarsVersion to $SelfVersion is not supported \n";
		print "All settings reverted to earlier version..\n";
		$status = system ("cp $NarsBakDir/nars.war $TomDir\/webapps\/nars.war");
		print "Starting Tomcat Server..\n";
		$status = system ("/etc/init.d/tomcat start");
		print "Upgrade Log created in  $UpgradeLog \n";
		GetResponse ();
		exit 2;
	}

	print "Upgrading Database...\n";
	chdir $TmpDir;
	$status = system ("./db.sh  u /usr/bin/mysql root \"$ROOT_Password\" \"$SelfVersion\" \"$DB_Username\" \"$DB_Password\" \"$curNarsVersion\" ");

        $status = system ("cp nextoneTomcat /etc/init.d/tomcat");
        $status = system ("chmod +x /etc/init.d/tomcat");
	$status = system ("rm -rf $TomDir\/webapps\/nars");
	print "Starting Tomcat Server..\n";
	$status = system ("/etc/init.d/tomcat start");

	UpdateS99local ();
	#Clean up...
	
	$status = system ("rm -rf $TmpDir");
	print "Successfully upgraded NARS Server from $curNarsVersion to $SelfVersion !! \n";
	print "Upgrade Log created in  $UpgradeLog \n";
	print "$curNarsVersion nars.war backed up in $NarsBakDir \n";
	GetResponse ();

}

##
## Uninstall's package.
##
sub UninstallPackage ()
{
	# Must be privileged.
	CheckForSuperuser ();
	print "UninstallPackage still to be implemented \n";
}

##
##Using user response and /tmp/nars/web-sample.xml creates /tmp/nars/web.xml
##
sub UpgradeWebXml () 
{
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
		print "nars.war is missing web.xml !! \n";
		print "Cannot Proceeed ....\n";
		GetResponse();
		exit 2;
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
	print "Enter MSW IP Address[$MSW_Address] :";
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
}

##
## Updates the $ref XML hash with param-value obtained from user
##
sub updateXMLHash 
{

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

}

##
## Returns the param-value from the $ref XML hash
##
sub readXMLHash 
{

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
}


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

	ReplaceStr("mysqld_key_buffer","set_variable	= key_buffer=64M");

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
	while($i<=$num_data_files)
	{
		$mysqld_innodb_data_file_path=$mysqld_innodb_data_file_path."/mysqldata/ibdata".$i.":4000M;";
		$i+=1;
	}
	if($rem_data_file > 0)
	{
		$mysqld_innodb_data_file_path=$mysqld_innodb_data_file_path."/mysqldata/ibdata".$i.":".$rem_data_file."M".":autoextend";
	}

	ReplaceStr("mysqld_innodb_data_file_path",$mysqld_innodb_data_file_path);

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

sub UpdateS99local()
                                                                                                          
{
        my $S99file = "/etc/rc2.d/S99local";
        my $S99filetmp = $TmpDir."/S99local.tmp";
	my $status;
        open SIN, "<$S99file";
        open SOUT, ">$S99filetmp";
        my $line;
        my $old_string = "tomcat";
        my $lineMatch = "0";
        while($line = <SIN>)
        {
                if($line !~m/$old_string/)
                {
                        print SOUT "$line";
                }
                if($line =~m/$old_string/)
                {
                        print SOUT "$line";
                        $lineMatch = "1";
                }
        }
        close SIN;
        close SOUT;
        if ($lineMatch eq "0" )
        {
                $status = system ("echo \"/etc/init.d/tomcat start \" >> $S99filetmp");
        }
        $status = system("cp $S99filetmp $S99file");
                                                                                                          
}

##
## Main
##

$| = 1;

if (! @ARGV)
{
	PrintHelpMessage ();
}

getopts ("diuhv");

if ($Getopt::Std::opt_d)
{
	print "Uninstalling  NARS Server \n";

	GetResponse ();

	UninstallPackage ();
}

if ($Getopt::Std::opt_i)
{
	print "\nInstalling NARS Server.  \n";
	GetResponse ();

	InstallPackage ();

}

if ($Getopt::Std::opt_u)
{
	print <<eEOF

Upgrading the NARS Server involves upgrading
the existing nars.war and updating the database.

eEOF
;
	GetSpecialResponse ();

	print "Upgrading the NARS Server package \n";
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


exit 0;

