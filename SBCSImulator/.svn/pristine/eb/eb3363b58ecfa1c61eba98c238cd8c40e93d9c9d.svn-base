#!/usr/bin/perl
#getb ipaddress and table name for vnets;
#cat tables.txt | grep "vnet" | tr -d "|" > vnettables.txt
#cat tables.txt | grep "vnet" | cut -d"_" -f2,3,4,5 >  vnetipaddr.txt;
#get mswid to cluster mapping
#cat  msws.txt | cut -d"|" -f3,5 | tee  mswcluster.txt   



use FindBin;
	use lib $FindBin::Bin."/vendor_perl/5.10.0";


use DBI;
use Getopt::Long;
use strict;
my $DB_User;
my $DB_Name;
my $DB_Pwd;
my $HostName;
my $HostPort;
my $dataFile = "/var/tmp/dataMigrationSQLScript.sql";



##
##Takes a table name as parameter and creates scripts for migration from 4.0 to 4.2.
##This is customized function for porting data of vnet,subnet and trigger tables from 4.0 to 4.2
##It also adds default entry for weekdays and weekends in periods table
##
sub generateSQLScriptForTable
{
my $TABLENAME=$_[0];

 my $TABLELIST= $TABLENAME.".txt";#all tables in database
  my $TABLENAME_DATA=$TABLENAME."_data.sql";#keeps data for table
#$TABLENAME will keep tables having supplied string
#
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
                print("Unable to change $DB_User password to old version in generation script using password=$DB_Pwd, cannot continue.");
                exit 1;
        }

my $dbh = DBI->connect("dbi:mysql:dbname=$DB_Name;"."host=$HostName;port=$HostPort", $DB_User, $DB_Pwd,{ RaiseError => 1, AutoCommit => 0, PrintError => 1} );
		my $sth = $dbh->prepare("show tables");
		$sth->execute;
		open (TMP2,"> $TABLELIST");
		while( my($TableList)=$sth->fetchrow_array){
		print  TMP2 "$TableList \n";
		}
		close (TMP2);
#get the table list
system("cat $TABLELIST | grep $TABLENAME | tr -d '|' > $TABLENAME");

my %ClusterToMSWIP=&getClusterIPMap($dbh);

#get  data for table object(vnet/subnet/trigger)
open (DATA,"> $TABLENAME_DATA");#open file for storign data
open (INFILE,$TABLENAME);#open file for getting table names
my $line;
	foreach $line (<INFILE>) {
    		chomp($line);             # remove the newline from $line.
    # do line-by-line processing.

		$sth = $dbh->prepare("SELECT * FROM $line ;");
		$sth->execute;
		#convert vnet_10_10_10_10__1 to 10_10_10_10__1
		$line =~ s/${TABLENAME}_//g;
		#convert 10_10_10_10__1 to 10_10_10_10
		$line =~ s/__[0-9]//g;
		#convert 10_10_10_10 to long
		my $longIP=&ip2long($line);
		if($TABLENAME eq "vnet"){
		#create scripts for vnet
		while( my($NAME,$IFNAME,$ID,$RTGTBLID,$GATEWAY)=$sth->fetchrow_array){
			#File Format
			print  DATA ("INSERT INTO vnet (partitionid , clusterid , name  , ifname , vnetid , rtgtblid , gateway) VALUES (");
			print  DATA "-1,$ClusterToMSWIP{$longIP},'$NAME','$IFNAME', IF($ID>-1, $ID, 4096),$RTGTBLID,'$GATEWAY'); \n";
			}
		}elsif($TABLENAME eq "subnet"){
		#name        | varchar(31) |      | PRI |         |       |
		# ipAddress      | int(11)     | YES  |     | NULL    |       |
		# mask           | int(11)     | YES  |     | NULL    |       |
		# iEdgeGroupName | varchar(31) |      |     |         |       |
		# realmName
		while( my($NAME,$IPADDRESS,$MASK,$IGRPNAME,$REALMNAME)=$sth->fetchrow_array){
		#File Format
		print  DATA ("INSERT INTO subnets (partitionid , clusterid , name  , ipAddress , mask , iEdgeGroupName , realmName) VALUES (");
		print  DATA "1,$ClusterToMSWIP{$longIP},'$NAME',$IPADDRESS,$MASK,'$IGRPNAME','$REALMNAME'); \n";
		}
		}elsif($TABLENAME eq "trigger"){
		#create scripts for TRIGGERS
		#name      | varchar(27) |      | PRI |         |       |
		# event     | int(11)     | YES  |     | NULL    |       |
		# script    | int(11)     | YES  |     | NULL    |       |
		# data      | varchar(27) |      |     |         |       |
		# srcVendor | int(11)     | YES  |     | NULL    |       |
		# dstVendor | int(11)     | YES  |     | NULL    |       |
		# override  | tinyint(4)  | YES  |     | NULL
		while( my($NAME,$EVENT,$SCRIPT,$DATA,$SRCVENDOR,$DSTVENDOR,$OVERRIDE)=$sth->fetchrow_array){
		#File Format
		print  DATA ("INSERT INTO triggers (partitionid , clusterid , name  , event , data , srcvendor , dstvendor, action, actionflags) VALUES (");
		print  DATA "1,$ClusterToMSWIP{$longIP},'$NAME',$EVENT,'$DATA',$SRCVENDOR,$DSTVENDOR,$SCRIPT,$OVERRIDE); \n";

		}
		}elsif($TABLENAME eq "periods"){
			
			print DATA ("INSERT INTO periods (PartitionId, Period, Zone, StartWeekDays, EndWeekDays, StartTime, EndTime, Created, LastModified) VALUES ('-1','Weekday',NULL,62,62,'00:00:00','23:59:59',now(),now()) on duplicate key update lastmodified=now(); \n");

			print DATA ("INSERT INTO periods (PartitionId, Period, Zone, StartWeekDays, EndWeekDays, StartTime, EndTime, Created, LastModified) VALUES ('-1','Weekend',NULL,65,65,'00:00:00','23:59:59',now(),now()) on duplicate key update lastmodified=now(); \n");
		}
	}
		close (DATA);
		close (INFILE);


		#remove temporary files
		system("rm -rf $TABLENAME $TABLELIST");
		if($@)
	        {
        	        print("Upgrade of capabilities data failed.  DBI said :". $dbh->errstr."\n");
	                exit 1;
        	}
                if($sth)
                {
                        $sth->finish();
                }
	        if($dbh)
	        {
	                $dbh->commit;
        	        # somehow the commit function above did not seem to work so adding the statement below
	                $dbh->do("commit;");
        	        $dbh->disconnect;
	        }

		system("mysql -h $HostName --port=$HostPort -u $DB_User --password=$DB_Pwd  < fix_privileges_new_pwd_tmp.sql");
        system("rm -rf fix_privileges_new_pwd_tmp.sql");
        system("rm -rf fix_privileges_old_pwd_tmp.sql");

}

#create map having mswip to clusterid mapping.
#
sub getClusterIPMap()
{
my $dbh=$_[0];
my %ClusterToMSWIP;#hash for ipaddr to clusterid mapping

 my $sth = $dbh->prepare("SELECT CLUSTERID,MSWIP FROM msws");
		$sth->execute;
	while( my($ClusterId,$MSWIp)=$sth->fetchrow_array){
		$ClusterToMSWIP{$MSWIp}=$ClusterId;
		}
	return %ClusterToMSWIP;
}
#convert supplied ipaddress to long format
#
sub ip2long()
{
    my $ip =$_[0];
    chomp $ip;
    my $n = 256;
    my @sip = split(/\_/,$ip);
    my $fip = (@sip[0]*($n * $n * $n))+(@sip[1]*($n * $n))+(@sip[2] * $n) + (@sip[3]);

	return $fip;
}
##Crate consolidate SQLScripts to port data from 4.0 to 4.2 database.
##The SQL are generated for porting periods, Vnet,subnet and trigger data.
##The functiononly creates a consolidated insert statements for adding data.
##The files name 'dataMigrationSQLScript.sql'
##The files needs to be executed by tbe user of this function
sub generateUpgradeSQLScript()
{
	generateSQLScriptForTable ("vnet");
	generateSQLScriptForTable ("subnet");
	generateSQLScriptForTable ("trigger");
	generateSQLScriptForTable ("periods");
		
	system("echo 'use bn; \n'> $dataFile");
	system("echo 'update bn.endpoints set caps =  (((caps << 8) & 0xFF00) | ((caps >> 8) & 0x00FF)); \n' >> $dataFile");
	system("echo 'update bn.endpoints set version=0; \n' >> $dataFile");
	system("cat vnet_data.sql subnet_data.sql trigger_data.sql periods_data.sql >> $dataFile");
	system("rm -rf vnet_data.sql subnet_data.sql trigger_data.sql periods_data.sql");
}
GetOptions( "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
	    "dbname=s" => \$DB_Name,
	    "host=s" => \$HostName,
	    "port=s" => \$HostPort );

if(! defined($DB_User))
{
	print "Usage:\n ./generateUpgradeSQLScript.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";

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

if(! defined($DB_Pwd))
{
	$DB_Pwd="";
}

generateUpgradeSQLScript();
