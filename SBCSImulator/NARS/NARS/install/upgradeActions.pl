#!/usr/bin/perl


use FindBin;
if(&GetProcessorType()=~m/x86_64/)
{
	use lib $FindBin::Bin."/vendor_perl/5.10.0/x86_64-linux-thread-multi";
}
else
{
	use lib $FindBin::Bin."/vendor_perl/5.10.0";
}

use DBI;
use Getopt::Long;
use strict;

my $DB_User;
my $DB_Name;
my $DB_Pwd;
my $HostName;
my $HostPort;
my $Version="4.2";
my $NextoneHome="/opt/nxtn/rsm";



sub upgradeactions
{
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
	my $status =system("mysql -h $HostName --port=$HostPort -u $DB_User --password=$DB_Pwd  < fix_privileges_old_pwd_tmp.sql");
	if($status)
	{
		print("Unable to change $DB_User password to old version, cannot continue.");
		exit 1;
	}
	my $dbh;
	
	eval{
		$dbh = DBI->connect("dbi:mysql:dbname=$DB_Name;"."host=$HostName;port=$HostPort", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
		my $sth = $dbh->prepare("SELECT actionId, field1 FROM actions a where a.Type='exe-script'");
		$sth->execute;
		while( my($actionId, $field1)=$sth->fetchrow_array)
		{
			$field1=~s/\\/\//g;
		
			if(($field1 =~m/\//) && (-f $field1))
			{
				
				my $nameindex;
				my $filename;
				$nameindex=rindex($field1,"/");
				$filename=substr($field1,$nameindex+1);
				my $alrmscrptdir=$NextoneHome."/alarmscripts";
				if(! (-d $alrmscrptdir))
				{
					system("mkdir -p $alrmscrptdir");
				}
				my $resp='y';
				my $newfilepath=$alrmscrptdir."/".$filename;
				if(-f $newfilepath)
				{
					$resp=&GetBooleanCharResponse("The file $newfilepath already exists, do you want to replace it?");
				}

				if($resp eq "y")
				{
					system("cp $field1 $newfilepath");
				}
				$dbh->do("UPDATE actions set field1='$filename' where actionId = '$actionId'");
			}
                        if($field1 !~m/\//)
                        {
                                print "Path for $field1 could not be resolved, ignoring and moving ahead\n";
                        }
			elsif(!(-f $field1))
			{
				print "File $field1 not found, ignoring and moving ahead\n";
			}
		}
	
                $sth = $dbh->prepare("select alarmid,groupid from alarms where alarms.type='cdrdesc'");
                $sth->execute;
                while (my($alarmid,$groupid)=$sth->fetchrow_array)
                {
                       my $ReplacementString="<GROUPID_FOR_AU>".$groupid."</GROUPID_FOR_AU></EV>";
		       $dbh->do("update alarms set Event=replace(Event,'</EV>','$ReplacementString') where alarmid='$alarmid'");
                }
	};
	if($@)
	{
		my $err;
		if($dbh)
		{
			$err=  "DBI said :".$dbh->errstr."\n";
		}
		print("Upgrade of actions data failed.\n".$err);
		exit 1;
	}
	if($dbh)
	{
		$dbh->commit;
		# somehow the commit function above did not seem to work so adding the statement below
		$dbh->do("commit;");
		$dbh->disconnect;
	}
	system("mysql -h $HostName --port=$HostPort -u $DB_User --password=$DB_Pwd  < fix_privileges_new_pwd_tmp.sql");
	system("rm fix_privileges_new_pwd_tmp.sql");
	system("rm fix_privileges_old_pwd_tmp.sql");
}

sub GetProcessorType()
{
        my $filetmp = "processortype";
        my $status = system("uname -pi > $filetmp"); 
        my $processortype = &getStringFrmFile($filetmp);
	system("rm $filetmp");
        return $processortype;
}

sub getStringFrmFile()
{
        my ($filename) = @_;
        open FIN, "<$filename";
        my $line = <FIN>;
        return $line;
}

sub GetBooleanCharResponse ()
{
        while(1)
        {
                my ($mess) = @_;
                $mess = $mess." [y\/n] :";
                print("$mess");
                my $resp = <>;
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

$| = 1;

GetOptions( "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
	    "dbname=s" => \$DB_Name,
	    "host=s" => \$HostName,
	    "port=s" => \$HostPort,
	    "ver=s" => \$Version );

if(! defined($DB_User))
{
	print "Usage:\n ./upgradeActions.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306] [-ver=<current ivms version> default=4.2]\n";
	
	exit 1;
}

if(! defined($HostName))
{
	$HostName="localhost";
}
if(! defined($HostPort))
{
	$HostPort="3306";
}
if(! defined($DB_Name))
{
	$DB_Name="bn";
}
if(defined($Version))
{
	if($Version =~m/4\.0/ || $Version =~m/4\.1/)
	{
		$NextoneHome="/home/nextone";
	}
}
upgradeactions();
exit 0;
