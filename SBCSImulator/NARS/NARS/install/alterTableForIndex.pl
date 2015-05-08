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
my $Newdb;
my $indexname;
my $colname; 
my $tablename;
my $addindextomaintable;

sub altertable(){
	# Get mandatory values from parameters
	my ($dbh, $tablename, $colname, $indexname, $addindex) = @_;
	my $sth = $dbh->prepare("show index from ".$tablename." where key_name like '".$indexname."' and column_name like '".$colname."';") or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth->execute();
	if ($sth->rows == 0) {
		print"\nIndex '".$indexname."' not found on table ".$tablename."(".$colname.")\n";
		#print"\n\nAddIndex=".lc($addindex)."\n\n";
		if(lc($addindex) eq "true"){			
			print"Adding index to table ".$tablename."\n";
			$dbh->do("ALTER TABLE ".$tablename." ADD INDEX ".$indexname."(".$colname.");") or die "Couldn't alter table: " . $dbh->errstr;
			print"Index added to table ".$tablename."\n";			
		} else {
			return 1;	
		}
	} else {
		#print"\nIndex '".$indexname."' found on table ".$tablename."(".$colname.").\n";
		return 0;
	}
	$sth->finish;
	return 0;
}

sub addIndexTotable(){
	my $dbh;

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

	$dbh = DBI->connect("dbi:mysql:dbname=$DB_Name;"."host=$HostName;port=$HostPort", $DB_User, $DB_Pwd, { RaiseError => 1, PrintError => 1}) or die "Couldn't connect to database: " . DBI->errstr;
	my $result = &altertable($dbh, $tablename, $colname, $indexname, $addindextomaintable);	
	if ($result == 1) {
		#print"Result=".$result."Index '".$indexname."' not found on table ".$tablename."(".$colname.")\n";
		exit 1;
	} else {
		print"Index '".$indexname."' found on table ".$tablename."(".$colname."). Adding index to partition tables\n";
	}
	my $sth = $dbh->prepare("SELECT PartitionId FROM groups where PartitionId > 0") or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth->execute();
	while( my($PartitionId)=$sth->fetchrow_array)
	{
		$result = &altertable($dbh, $tablename."_".$PartitionId, $colname, $indexname, "true");		
		if ($result == 0) {
			
		} else {
			#print "Result=".$result."Index '".$indexname."' found on table ".$tablename."_".$PartitionId."(".$colname.").\n";
		}
	}
	$sth->finish;
	$dbh->disconnect;

	system("mysql -h $HostName --port=$HostPort -u $DB_User --password=$DB_Pwd < fix_privileges_new_pwd_tmp.sql");
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

GetOptions( "Table=s" => \$tablename,
	    "Column=s" => \$colname,
	    "Indexname=s" => \$indexname,
	    "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
	    "dbname=s" => \$DB_Name,
	    "host=s" => \$HostName,
	    "port=s" => \$HostPort,
	    "newdb=s" => \$Newdb,
	    "addindextomaintable=s" => \$addindextomaintable);
#print "\n-----------------------------------\n";
print "\nTableName(column): ".$tablename."(".$colname.")\n";
#print "DBUser: ".$DB_User."\n\n";

if(! defined($DB_User))
{
	print "Usage:\n ./alterTableForIndex.pl -table=<tablename> -column=<columnname> [-index=<indexname> default=<columnname>] -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306] [-addindextomaintable=<true|false> default=false]\n";
	exit 1;
}

if(! defined($indexname))
{
	$indexname=$colname;
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
if(! defined($addindextomaintable))
{
	$addindextomaintable="false";
}
addIndexTotable();
exit 0;
