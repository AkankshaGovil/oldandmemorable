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

sub upgradeRSMEvent
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
		$dbh->do("alter table rsmevent add column `TempTimestamp` datetime NOT NULL default '1970-01-01 00:00:00' after FailureObjectId");
		my $sth = $dbh->prepare("SELECT Eventid,Timestamp FROM rsmevent");
		$sth->execute;
		my $SubstitionString="";
		while( my($Eventid,$Timestamp)=$sth->fetchrow_array){
			my $subsString_str1="";
			my $subsString_str2="";
			$subsString_str1=substr($Timestamp,0,20);
			$subsString_str2=substr($Timestamp,24,28);
  	        	$SubstitionString=$subsString_str1.$subsString_str2;
			my $sth1 = $dbh->prepare("Select STR_TO_DATE('$SubstitionString','%a %b %d %H:%i:%s %Y') as result");
			$sth1->execute;
			my $result=$sth1->fetchrow_array;
			$dbh->do("update rsmevent set TempTimestamp='$result' where Eventid='$Eventid'");
		}
		$dbh->do("alter table rsmevent drop Timestamp");
		$dbh->do("alter table rsmevent change TempTimestamp Timestamp datetime NOT NULL default '1970-01-01 00:00:00'");
	};
	if($@)
	{
		print("Upgrade of rsmEvent table failed.  DBI said :". $dbh->errstr."\n");
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


$| = 1;

GetOptions( "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
	    "dbname=s" => \$DB_Name,
	    "host=s" => \$HostName,
	    "port=s" => \$HostPort );

if(! defined($DB_User))
{
	print "Usage:\n ./upgradeRSMEvent.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";

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

upgradeRSMEvent();
exit 0;
