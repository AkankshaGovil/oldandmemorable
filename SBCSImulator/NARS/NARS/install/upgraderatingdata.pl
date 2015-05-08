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

# Removes the duplicate rows from given table and pushes them in a separate table. The new table name with
#  duplicate rows is returned back to the caller.
#  
#  Parameter details:
#  
#  1. Database connection
#  2. Table name having duplicate rows
#  3. An existing unique key/primary key/ or any other column name haveing non null value for the table, 
#  which will be used for saving one row and removing all its duplicates.
#  4. Array of unique keys for which the duplicates need to be determined.

sub cleanduplicatedata
{
	# Get mandatory values from parameters
	my ($dbh, $tablename, $key, @uniquekeycols) = @_;

	if(!defined($tablename))
	{
	    print("Specify the table for cleaning up the data \n");
	    return;
	}
	if(!defined(@uniquekeycols))
	{
	    print("Specify the unique key criteria for checking duplicate rows \n");
	    return;
	}

       if(!defined($key))
        {
            print("Specify an existing unique key/primary key/ or any other column name haveing non null value for the table \n");
            return;
        }
						       
	$key = " ".$key." ";

	# Create temporary tables
	$dbh->do("DROP TABLE IF EXISTS `".$tablename."_todelete`;");
	$dbh->do("DROP TABLE IF EXISTS `".$tablename."_duplicatedata`;");

	$dbh->do("CREATE TABLE `".$tablename."_todelete` like $tablename;");
	$dbh->do("CREATE TABLE `".$tablename."_duplicatedata` SELECT * from $tablename;");

	my $keystring = "";
	my $duplicatewhereclause = "";
	my $deletewhereclause = "";

	# Iterate over the unique key columns and create where clauses.
	foreach(@uniquekeycols)
	{
	    my $uniquekey=$_;
	    $keystring = $keystring . "$uniquekey, ";
	    $duplicatewhereclause = $duplicatewhereclause.$tablename."_todelete.".$uniquekey." = " .$tablename."_duplicatedata.".$uniquekey." AND ";
	    $deletewhereclause = $deletewhereclause.$tablename."_todelete.".$uniquekey." = " .$tablename.".".$uniquekey." AND ";
    	}

	# Cleanup the string from unwanted characters
	$keystring = substr($keystring, 0, -2);
        $duplicatewhereclause = substr($duplicatewhereclause, 0, -5);
        $deletewhereclause = substr($deletewhereclause, 0, -5);

	# Get rows having duplicate keys and push it in temp table.
	# The row having minimum value of $key is to be remained in the original table. This is done to allow one 
	# row (which is randomly chosen as MIN value for the given $key) in table and push all its duplicates 
	# in the _duplicatedata table.

	$dbh->do("INSERT INTO `".$tablename."_todelete` ($keystring, $key) SELECT $keystring, 
		MIN($key) from $tablename GROUP BY $keystring HAVING count(*)>1;");

	# Remove all but one duplicate rows from table
	$dbh->do("DELETE FROM $tablename WHERE exists (SELECT * from `".$tablename."_todelete` 
		WHERE $deletewhereclause AND `".$tablename."_todelete`.$key <> $tablename.$key);");

	# Put all but one duplicate rows in new 
	$dbh->do("DELETE FROM `".$tablename."_duplicatedata` WHERE not exists (SELECT * from `".$tablename."_todelete`
	        WHERE $duplicatewhereclause AND `".$tablename."_todelete`.$key <> `".$tablename."_duplicatedata`.$key);");
		
	
	# Cleanup temporary tables
	$dbh->do("DROP TABLE IF EXISTS `".$tablename."_todelete`;");

	# Return duplicate table name ack to the caller	
	return $tablename."_duplicatedata";
}

sub upgraderating
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
		$dbh = DBI->connect("dbi:mysql:dbname=$DB_Name;"."host=$HostName;port=$HostPort", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 1, PrintError => 1});

		my $sth = $dbh->prepare("SELECT GroupId FROM groups where groupId > 0");

		$sth->execute;

        # Creating a table which will contain all the unbound plans
		$dbh->do("DROP TABLE IF EXISTS plans_unbound;");
		$dbh->do("Create table plans_unbound (select * from plans);");

	        while( my($PartitionId)=$sth->fetchrow_array)
		{
			# Create Carriers_partitionId tables.
			$dbh->do("DROP TABLE IF EXISTS carriers_".$PartitionId.";");
 			$dbh->do("CREATE TABLE carriers_".$PartitionId." SELECT carrierplans.Carrier, routes.RegionCode,carrierplans.EndpointId,carrierplans.BuySell from carrierplans, routes where carrierplans.RouteGroup=routes.RouteGroup and carrierplans.GroupId=routes.GroupId and carrierplans.GroupId=".$PartitionId.";");
			$dbh->do("ALTER TABLE carriers_".$PartitionId." CHANGE EndpointId ServiceType varchar(32) NOT NULL default '';");
			$dbh->do("UPDATE carriers_".$PartitionId." set BuySell='2' where BuySell='S';");
			$dbh->do("UPDATE carriers_".$PartitionId." set BuySell='1' where BuySell='B';");
		    $dbh->do("ALTER TABLE carriers_".$PartitionId." ADD CarrierId bigint(20) NOT NULL auto_increment,  CHANGE BuySell BuySell tinyint(2) NOT NULL default 0, ADD UNIQUE KEY UniqueCarrier (Carrier,RegionCode,ServiceType,BuySell), ADD CONSTRAINT PRIMARY KEY  (CarrierId); ");

			# Create Carriers_partitionId tables.
			$dbh->do("DROP TABLE IF EXISTS rates_".$PartitionId.";");
			$dbh->do("CREATE TABLE rates_".$PartitionId." SELECT carrierplans.CarrierplanId as CarrierId, carrierplans.Carrier,routes.RegionCode, carrierplans.EndpointId,carrierplans.BuySell, plans.DurMin, plans.DurIncr, plans.Rate, plans.Country, plans.ConnectionCharge, plans.EffectiveStartDate as OLDEffectiveStartDate, plans.EffectiveEndDate as OLDEffectiveEndDate, plans.PeriodId , plans.Created, plans.LastModified,periods.Zone from carrierplans, routes, plans,periods where carrierplans.RouteGroup=routes.RouteGroup and carrierplans.Plan = plans.Plan and routes.CostCode = plans.CostCode and carrierplans.GroupId=routes.GroupId and plans.periodid= periods.periodid  and carrierplans.GroupId=".$PartitionId." and routes.GroupId=".$PartitionId." and plans.GroupId=".$PartitionId." and (periods.GroupId=".$PartitionId." or periods.GroupId=-1);");
	
		    # Delete all the plans from plans_unbound which were shifted to rates table in previous step
		    $dbh->do("DELETE plans_unbound from plans_unbound, carrierplans, routes, periods where carrierplans.RouteGroup=routes.RouteGroup and carrierplans.Plan = plans_unbound.Plan and routes.CostCode = plans_unbound.CostCode and carrierplans.GroupId=routes.GroupId and plans_unbound.periodid= periods.periodid and carrierplans.GroupId=".$PartitionId.";");

			$dbh->do("UPDATE rates_".$PartitionId." set BuySell='2' where BuySell='S';");
			$dbh->do("UPDATE rates_".$PartitionId." set BuySell='1' where BuySell='B';");
			$dbh->do("ALTER TABLE rates_".$PartitionId." CHANGE EndpointId ServiceType varchar(32) NOT NULL default ''");
			$dbh->do("ALTER TABLE rates_".$PartitionId." ADD EffectiveStartDate int(11) NOT NULL  default '0' , ADD EffectiveEndDate int(11) NOT NULL  default '0' ");
			$dbh->do("UPDATE rates_".$PartitionId." set EffectiveStartDate= unix_timestamp((CONVERT_TZ(OLDEffectiveStartDate, GETTIME(Zone),'+00:00')));");
			$dbh->do("UPDATE rates_".$PartitionId." set EffectiveEndDate= unix_timestamp((CONVERT_TZ(OLDEffectiveEndDate, GETTIME(Zone),'+00:00')));");
			$dbh->do("ALTER TABLE rates_".$PartitionId." DROP COLUMN Zone, DROP COLUMN OLDEffectiveStartDate, DROP COLUMN OLDEffectiveEndDate ;");
			$dbh->do("update rates_".$PartitionId." , carriers_".$PartitionId." set rates_".$PartitionId.".CarrierId=carriers_".$PartitionId.". CarrierId where carriers_".$PartitionId.".Carrier = rates_".$PartitionId.".Carrier and carriers_".$PartitionId.".RegionCode = rates_".$PartitionId.".RegionCode and carriers_".$PartitionId.".ServiceType = rates_".$PartitionId.".ServiceType and carriers_".$PartitionId.".BuySell= rates_".$PartitionId.".BuySell;");
            
		    # Alter table partition for required columns
		    $dbh->do("ALTER TABLE rates_".$PartitionId." ADD RateId bigint(20) NOT NULL auto_increment, CHANGE BuySell BuySell tinyint(2) NOT NULL default 0, ADD INDEX CarrierId (CarrierId), ADD CONSTRAINT PRIMARY KEY  (RateId), ADD Priority int NOT NULL default 0, ADD status tinyint(2) NOT NULL default '0';");

		    # Remove the duplicates from the rates table (based upon the unique keys to be added) and push them in a separate table.
		    # This is done to avoid loss of duplicate data from rates table which may happen when the table is altered with unique key.
		    my @keys = ("CarrierId", "EffectiveStartDate", "EffectiveEndDate", "PeriodId");
		    my $duplicaterates= &cleanduplicatedata($dbh, "rates_".$PartitionId, "RateId", @keys);
		    print ("The duplicate rows for rates table are saved in $duplicaterates\n");
	
		    # Now adding the unique keys
		    $dbh->do("ALTER TABLE rates_".$PartitionId." ADD UNIQUE KEY rate (CarrierId,EffectiveStartDate,EffectiveEndDate,PeriodId);");
	                                                                             
            $dbh->do("DROP TABLE IF EXISTS routes_".$PartitionId.";");
            $dbh->do("CREATE TABLE routes_".$PartitionId." SELECT carrierplans.CarrierplanId as CarrierId,carrierplans.Carrier, routes.RegionCode,carrierplans.EndpointId as ServiceType, carrierplans.BuySell, carrierplans.ANI, carrierplans.StripPrefix,carrierplans.PrefixDigits,carrierplans.AddbackDigits,carrierplans.RatingAddback,carrierplans.EndpointId,carrierplans.Created,carrierplans.LastModified from carrierplans, routes where carrierplans.RouteGroup=routes.RouteGroup and carrierplans.GroupId=routes.GroupId  and carrierplans.GroupId=".$PartitionId.";");

            $dbh->do("UPDATE routes_".$PartitionId." set BuySell='2' where BuySell='S';");
            $dbh->do("UPDATE routes_".$PartitionId." set BuySell='1' where BuySell='B';");
            $dbh->do("ALTER TABLE routes_".$PartitionId." CHANGE ServiceType ServiceType varchar(32) NOT NULL default '';");
            $dbh->do("update routes_".$PartitionId.", carriers_".$PartitionId." set routes_".$PartitionId.".CarrierId=carriers_".$PartitionId.".CarrierId where carriers_".$PartitionId.".Carrier = routes_".$PartitionId.".Carrier and carriers_".$PartitionId.".RegionCode = routes_".$PartitionId.".RegionCode and carriers_".$PartitionId.".ServiceType = routes_".$PartitionId.".ServiceType and carriers_".$PartitionId.".BuySell= routes_".$PartitionId.".BuySell;");

		    # Alter table partition for required columns
		    $dbh->do("ALTER TABLE routes_".$PartitionId." ADD RouteId bigint(20) NOT NULL auto_increment, CHANGE ServiceType ServiceType varchar(32) NOT NULL  default '', CHANGE BuySell BuySell tinyint(2) NOT NULL default 0, ADD INDEX ANI (ANI),  ADD INDEX CarrierId (CarrierId), ADD INDEX Endpoint (EndpointId), ADD CONSTRAINT PRIMARY KEY  (RouteId), ADD FOREIGN KEY (EndpointId) REFERENCES endpoints(EndpointId), ADD status tinyint(2) NOT NULL default '0', ADD ClusterId smallint(6) NOT NULL default '-1',  ADD flag tinyint(2) NOT NULL default '0';");
	
		    # Remove the duplicates from the routes table (based upon the unique keys to be added) and push them in a separate table.
		    # This is done to avoid loss of duplicate data from routes table which may happen when the table is altered with unique key.
		    my @keys = ("CarrierId", "endpointid", "ANI", "StripPrefix", "PrefixDigits", "AddbackDigits", "RatingAddback");
		    my $duplicateroutes = &cleanduplicatedata($dbh, "routes_".$PartitionId, "RouteId", @keys);
		    print ("The duplicate rows for routes table are saved in $duplicateroutes\n");
	
	    	# Now adding the unique keys
            $dbh->do("ALTER TABLE routes_".$PartitionId." ADD UNIQUE KEY route(CarrierId,EndpointId,ANI,StripPrefix,PrefixDigits,AddbackDigits,RatingAddback);");

	        $dbh->do("update routes_".$PartitionId.",endpoints set routes_".$PartitionId.".ClusterId=endpoints.ClusterId where routes_".$PartitionId.".EndpointId = endpoints.EndpointId;");
	        $dbh->do("update routes_".$PartitionId." set flag=1 where ClusterId > 0;");
		}
            print ("The unbounded plans are saved in plans_unbound table\n");
	};
	if($@)
	{
		if($dbh)
		{
			$dbh->rollback;
		}
		print("Upgrade of rating data failed.");
		exit 1;
	}
	if($dbh)
	{
	        $dbh->do("truncate table routes;");
		$dbh->disconnect;
	}

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

GetOptions( "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
	    "dbname=s" => \$DB_Name,
	    "host=s" => \$HostName,
	    "port=s" => \$HostPort,
	    "newdb=s" => \$Newdb);

if(! defined($DB_User))
{
	print "Usage:\n ./upgraderatingdata.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306] \n";
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
upgraderating();
exit 0;


