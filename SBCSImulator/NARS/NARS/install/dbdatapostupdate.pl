#!/usr/bin/perl


use FindBin;

use lib $FindBin::Bin."/site_perl/5.8.0";
use Log::Log4perl qw(:easy);
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
use Config::Simple;
use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);
my $dbUser;
my $dbName;
my $dbPwd;
my $hostName;
my $hostPort;
my $version;
my $oldDB;
my $newDB;
my $dbh;
my $upgradeDataFile;
my $FileLogger;
my $File_Screen_Logger;
my $logFile;

$| = 1;

GetOptions( "user=s" => \$dbUser,
            "password=s" => \$dbPwd,
            "host=s" => \$hostName,
            "port=s" => \$hostPort,
            "source=s" =>\$oldDB,
            "target=s" =>\$newDB,
            "version=s" => \$version,
            "upgradeDataFile=s" => \$upgradeDataFile,
            "log=s" => \$logFile
 );


if(! defined($hostName))
 {
        $hostName="localhost";
 }
 if(! defined($hostPort))
 {
        $hostPort="3306";
 }
# Migrates data from older version to current version

migrateData();
sub migrateData(){
        &CreateLogger($logFile, "DEBUG");
        $FileLogger->info("[DBDataPostUpdate.pl/migrateData] Start\n"); 
        $FileLogger->info("########################################\n");
        open (TMP2,">fix_privileges_old_pwd_tmp.sql");
        print TMP2 "USE mysql;";
        print TMP2 "UPDATE user SET password=OLD_PASSWORD('$dbPwd') WHERE user='$dbUser';\n";
        print TMP2 "FLUSH PRIVILEGES;";
        close (TMP2);


        open (TMP1,">fix_privileges_new_pwd_tmp.sql");
        print TMP1 "USE mysql;";
        print TMP1 "UPDATE user SET password=PASSWORD('$dbPwd') WHERE user='$dbUser';\n";
        print TMP1 "FLUSH PRIVILEGES;";
        close (TMP1);
        my $status =system("mysql -h $hostName --port=$hostPort -u $dbUser --password=$dbPwd  < fix_privileges_old_pwd_tmp.sql");

        if($status)
        {
                print("Unable to change $dbUser password to old version, cannot continue.");
                exit 1;
        }
        eval{
                $dbh = DBI->connect("dbi:mysql:dbname=$dbName;"."host=$hostName;port=$hostPort", $dbUser, $dbPwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});

        $dbh->do("use bn;");
        # migrate 4.0 specific data to 5.1
        if($version=~m/4\.0/){
           # migrate common data
            migrateCommonData($version);
            migrateFrom4_0To5_0();
            migrateFrom5_0To5_1();
        }
        # migrate 4.2 specific data to 5.1
        if($version=~m/4\.2/){
            # migrate common data
            migrateCommonData($version);
            migrateFrom4_2To5_0();
            migrateFrom5_0To5_1();
        }
        # migrate 4.3 specific data to 5.1
        if($version=~m/4\.3/){
            # migrate common data
            migrateCommonData($version);
            migrateFrom4_3To5_0();
            migrateFrom5_0To5_1();
        }
        # migrate 5.0 specific data to 5.1
        if($version=~m/5\.0/){
            # migrate common data
            tdfMigrateFrom5_0To5_1();
            migrateEventAlarmData();
	    migrateSNMPStatsAlarmsToPolledStatsAlarms();	
	    migratePolledData(); 
	    enableSNMPIncidentAlarms();
        }
        if($version=~m/5\.1/){
            migrateEventAlarmData();
	    migrateSNMPStatsAlarmsToPolledStatsAlarms();	
	    migratePolledData(); 	
	    enableSNMPIncidentAlarms();
        }
	if($version=~m/5\.2/){
            migrateSNMPStatsAlarmsToPolledStatsAlarms();
	    migratePolledData(); 	
	    enableSNMPIncidentAlarms();
        }
        if($version=~m/^6\./ || $version=~m/^7\./){
            migrateIPv6Data();
        }
          migrate50Data();
		  migrateCapForCalea();

        };
	if($@)
        {
                print("Post data migration failed.  DBI said :". $dbh->errstr."\n");
                exit 1;
        }
        if($dbh)
        {
                $dbh->commit;
                # somehow the commit function above did not seem to work so adding the statement below
                $dbh->do("commit;");
                $dbh->disconnect;
        }
        system("mysql -h $hostName --port=$hostPort -u $dbUser --password=$dbPwd  < fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_new_pwd_tmp.sql");
        system("rm fix_privileges_old_pwd_tmp.sql");
        $FileLogger->info("########################################\n");
        $FileLogger->info("[DBDataPostUpdate.pl/migrateData] End\n");

}

sub migrateFrom5_0To5_1()
{
}

sub tdfMigrateFrom5_0To5_1()
{

	$FileLogger->info("mysql -h $hostName --port=$hostPort -u $dbUser --password=$dbPwd  $oldDB < upgradeTDFView50.sql");
	my $status =system("mysql -h $hostName --port=$hostPort -u $dbUser --password=$dbPwd  $oldDB < upgradeTDFView50.sql");
	if($status)
	{
			print("Unable to upgrade TDF View for 5.0.");
			exit 1;
	}
}

sub migrateCommonData(){
    my ($version) = @_;
    $FileLogger->info("[DBDataPostUpdate/migrateCommonData] Start\n ");
    $FileLogger->info("REPLACE INTO $oldDB.TDFDisplayConfig (DisplayConfigId, DisplayConfigName)SELECT DisplayConfigId, DisplayConfigName from $newDB.TDFDisplayConfig ;");
    $dbh->do("REPLACE INTO $oldDB.TDFDisplayConfig (DisplayConfigId, DisplayConfigName)SELECT DisplayConfigId, DisplayConfigName from $newDB.TDFDisplayConfig ;");

    $FileLogger->info("REPLACE INTO $oldDB.TDFRoles (RoleId, RoleName)  SELECT RoleId, RoleName from $newDB.TDFRoles ;");
    $dbh->do("REPLACE INTO $oldDB.TDFRoles (RoleId, RoleName)  SELECT RoleId, RoleName from $newDB.TDFRoles ;");

    $FileLogger->info("REPLACE INTO $oldDB.TDFOperatorGroup (OPERATORGROUPID, DescriptionText)  SELECT OPERATORGROUPID, DescriptionText from $newDB.TDFOperatorGroup ;");
    $dbh->do("REPLACE INTO $oldDB.TDFOperatorGroup (OPERATORGROUPID, DescriptionText)  SELECT OPERATORGROUPID, DescriptionText from $newDB.TDFOperatorGroup ;");

    $FileLogger->info("INSERT INTO $oldDB.TDFDataTypeOperators (OPERATORID, OPERATORGROUPID, OPERATOREXPRESSION, DISPLAYNAME,PREPENDVALUEWITH, APPENDVALUEWITH, ENCLOSEINBRACESANDQUOTES,IsValueExpressionNeeded) SELECT OPERATORID, OPERATORGROUPID, OPERATOREXPRESSION, DISPLAYNAME,PREPENDVALUEWITH, APPENDVALUEWITH, ENCLOSEINBRACESANDQUOTES,IsValueExpressionNeeded from $newDB.TDFDataTypeOperators ;");
    $dbh->do("INSERT INTO $oldDB.TDFDataTypeOperators (OPERATORID, OPERATORGROUPID, OPERATOREXPRESSION, DISPLAYNAME,PREPENDVALUEWITH, APPENDVALUEWITH, ENCLOSEINBRACESANDQUOTES,IsValueExpressionNeeded) SELECT OPERATORID, OPERATORGROUPID, OPERATOREXPRESSION, DISPLAYNAME,PREPENDVALUEWITH, APPENDVALUEWITH, ENCLOSEINBRACESANDQUOTES,IsValueExpressionNeeded from $newDB.TDFDataTypeOperators ;");

    $FileLogger->info("INSERT INTO $oldDB.TDFDataTypeMap (DATATYPEID, DBNAME, OPERATORGROUPID, DBTYPE)  SELECT DATATYPEID, DBNAME, OPERATORGROUPID, DBTYPE from $newDB.TDFDataTypeMap ;");
    $dbh->do("INSERT INTO $oldDB.TDFDataTypeMap (DATATYPEID, DBNAME, OPERATORGROUPID, DBTYPE)  SELECT DATATYPEID, DBNAME, OPERATORGROUPID, DBTYPE from $newDB.TDFDataTypeMap ;");

    $FileLogger->info("INSERT INTO $oldDB.TDFFormatSchemes (SCHEMEID, SCHEMENAME) SELECT SCHEMEID, SCHEMENAME from $newDB.TDFFormatSchemes ;");
    $dbh->do("INSERT INTO $oldDB.TDFFormatSchemes (SCHEMEID, SCHEMENAME) SELECT SCHEMEID, SCHEMENAME from $newDB.TDFFormatSchemes ;");

    $FileLogger->info("INSERT INTO $oldDB.TDFTables (TABLEID, DBNAME, DISPLAYNAME, VIEWID, DBTYPE, MandatoryFilterCondition, DefaultSortId) SELECT TABLEID, DBNAME, DISPLAYNAME, VIEWID, DBTYPE, MandatoryFilterCondition, DefaultSortId from $newDB.TDFTables ;");
    $dbh->do("INSERT INTO $oldDB.TDFTables (TABLEID, DBNAME, DISPLAYNAME, VIEWID, DBTYPE, MandatoryFilterCondition, DefaultSortId) SELECT TABLEID, DBNAME, DISPLAYNAME, VIEWID, DBTYPE, MandatoryFilterCondition, DefaultSortId from $newDB.TDFTables ;");

    $FileLogger->info("INSERT INTO $oldDB.TDFColumns (COLUMNID, TABLEID, DBNAME, DISPLAYNAME, DISPLAYSIZE, SCHEMEID, OPERATORGROUPID, METADATARANDOM,ISSORTABLE, DISPLAYORDER, LINKTARGET, ROLE, TOOLTIP,DISPLAYCONFIG)  SELECT COLUMNID, TABLEID, DBNAME, DISPLAYNAME, DISPLAYSIZE, SCHEMEID, OPERATORGROUPID, METADATARANDOM,ISSORTABLE, DISPLAYORDER, LINKTARGET, ROLE, TOOLTIP,DISPLAYCONFIG from $newDB.TDFColumns ;");
    $dbh->do("INSERT INTO $oldDB.TDFColumns (COLUMNID, TABLEID, DBNAME, DISPLAYNAME, DISPLAYSIZE, SCHEMEID, OPERATORGROUPID, METADATARANDOM,ISSORTABLE, DISPLAYORDER, LINKTARGET, ROLE, TOOLTIP,DISPLAYCONFIG)  SELECT COLUMNID, TABLEID, DBNAME, DISPLAYNAME, DISPLAYSIZE, SCHEMEID, OPERATORGROUPID, METADATARANDOM,ISSORTABLE, DISPLAYORDER, LINKTARGET, ROLE, TOOLTIP,DISPLAYCONFIG from $newDB.TDFColumns ;");

    $FileLogger->info("INSERT INTO $oldDB.TDFEnums (EnumId, ValueId, ValueString, DataTableValueString)  SELECT EnumId, ValueId, ValueString, DataTableValueString from $newDB.TDFEnums ;");
    $dbh->do("INSERT INTO $oldDB.TDFEnums (EnumId, ValueId, ValueString, DataTableValueString)  SELECT EnumId, ValueId, ValueString, DataTableValueString from $newDB.TDFEnums ;");

    $FileLogger->info("REPLACE  INTO periods (PeriodId, PartitionId, Period, Zone, StartWeekDays, EndWeekDays, StartTime, EndTime, Created, LastModified ) VALUES (1,'-1','Weekday',NULL,62,62,'00:00:00','23:59:59',now(),now());");
    $dbh->do("REPLACE  INTO periods (PeriodId, PartitionId, Period, Zone, StartWeekDays, EndWeekDays, StartTime, EndTime, Created, LastModified ) VALUES (1,'-1','Weekday',NULL,62,62,'00:00:00','23:59:59',now(),now());");

    $FileLogger->info("REPLACE INTO periods (PeriodId, PartitionId, Period, Zone, StartWeekDays, EndWeekDays, StartTime, EndTime, Created, LastModified ) VALUES (2,'-1','Weekend',NULL,65,65,'00:00:00','23:59:59',now(),now());");
    $dbh->do("REPLACE INTO periods (PeriodId, PartitionId, Period, Zone, StartWeekDays, EndWeekDays, StartTime, EndTime, Created, LastModified ) VALUES (2,'-1','Weekend',NULL,65,65,'00:00:00','23:59:59',now(),now());");

    $FileLogger->info("INSERT INTO $oldDB.PerformanceAttribute VALUES ('DefaultValue','DefaultValue','DefaultValue','0.0.0.0','DefaultValue','DefaultValue',-1,-1,-1,-1,'DefaultValue','snmp','1','');");
    $dbh->do("INSERT INTO $oldDB.PerformanceAttribute VALUES ('DefaultValue','DefaultValue','DefaultValue','0.0.0.0','DefaultValue','DefaultValue',-1,-1,-1,-1,'DefaultValue','snmp','1','');");

    $FileLogger->info("UPDATE alarms set Type='cdr' where Type='cdrdesc'");
    $dbh->do("UPDATE alarms set Type='cdr' where Type='cdrdesc'");

    $FileLogger->info("UPDATE alarms set Type='log' where Type='logdesc'");
    $dbh->do("UPDATE alarms set Type='log' where Type='logdesc'");

    $FileLogger->info("UPDATE cpbindings SET startyear=-1 WHERE startyear=0");
    $dbh->do("UPDATE cpbindings SET startyear=-1 WHERE startyear=0");

    $FileLogger->info("UPDATE cpbindings SET endyear=-1 WHERE endyear=0");
    $dbh->do("UPDATE cpbindings SET endyear=-1 WHERE endyear=0");

    #migrate Users
    migrateUsers($version);

    $dbh->commit;
    tdfMigrateFrom5_0To5_1();
    $FileLogger->info("[DBDataPostUpdate/migrateCommonData] End\n ");
}

# data migration script for 4.0 to 5.0
sub migrateFrom4_0To5_0(){
    $FileLogger->info("[DBDataPostUpdate/migrateFrom4_0To5_0] Start\n ");

    &actionIdalarmMigration("alarms","4.0");
    &actionIdalarmMigration("systemalarms","4.0");

    $FileLogger->info("[DBDataPostUpdate/migrateFrom4_0To5_0] End\n ");

}

#data migration script for 4.2 to 5.0
sub migrateFrom4_2To5_0(){
    $FileLogger->info("[DBDataPostUpdate/migrateFrom4_2To5_0] Start\n ");

    &actionIdalarmMigration("alarms","4.2");
    &actionIdalarmMigration("systemalarms","4.2");

    $FileLogger->info("[DBDataPostUpdate/migrateFrom4_2To5_0] End\n ");
}

#data migration script for 4.3 to 5.0
sub migrateFrom4_3To5_0()
{
    $FileLogger->info("[DBDataPostUpdate/migrateFrom4_3To5_0] Start\n ");

    &actionIdalarmMigration("alarms","4.3");
    &actionIdalarmMigration("systemalarms","4.3");

    $FileLogger->info("[DBDataPostUpdate/migrateFrom4_3To5_0] End\n ");
}

sub actionIdalarmMigration()
{
    $FileLogger->info("[DBDataPostUpdate/actionIdalarmMigration] Start\n ");
    my ($tableName,$versionMigratingFrom) = @_;
    $FileLogger->info("Table name = $tableName \n");
    my $replaceStr="\$6:";
    # step 1: replace % with $6:
    # step 2: add severity value + ":" + action id

    $FileLogger->info("SELECT AlarmId,Event,ActionId from $tableName");
    my $sth = $dbh->prepare("SELECT AlarmId,Event,ActionId from $tableName\n");
    $sth->execute;
    while( my($AlarmId,$Event,$ActionId )=$sth->fetchrow_array)
    {
        $ActionId =~ s/%/$replaceStr/;
        # The severity was not defined in 4.0 and 4.2 so by default the severity is made to Critical
        # for trigger on action.
        my $severityValue =  "1";
        if ($versionMigratingFrom eq "4.3")
        {
            # The severity was defined in 4.3 so we get the severity value from event stored in db.
            $severityValue =  &getSeverityValue($Event);
        }
        $ActionId = $severityValue.":".$ActionId;
        $Event = &removeTagFromXML($Event,"severity");
        # 53226: escape single quote
        $Event = &escapeCharForMySQL($Event,"'");
        $updateQuery="UPDATE $tableName set ActionId='$ActionId',Event='$Event' WHERE AlarmId=$AlarmId";
        $FileLogger->info("UPDATE $tableName set ActionId='$ActionId',Event='$Event' WHERE AlarmId=$AlarmId\n");    
        $dbh->do($updateQuery);
    }
    $FileLogger->info("[DBDataPostUpdate/actionIdalarmMigration] End\n ");
}

sub enableSNMPIncidentAlarms()
{
    # From 6.0 user shall not be able to Enable/Disable SNMP Incident alarms, hence enable all.
    $FileLogger->info("[DBDataPostUpdate/enableSNMPIncidentAlarms] Start\n ");
    $FileLogger->info("UPDATE alarms Set Status=1 where Type='snmpIncident'\n");
    $dbh->do("UPDATE alarms Set Status=1 where Type='snmpIncident'");
    $FileLogger->info("[DBDataPostUpdate/enableSNMPIncidentAlarms] End\n ");
}

sub getSeverityValue()
{
   my ($Event) = @_;
   my $severityCritical = "Critical";
   my $severityMajor = "Major";
   my $severityMinor = "Minor";
   my $severityWarning = "Warning";
   my $severityClear = "Clear";
   my $severityNone = "None";

   my $severityStr = &getTagValueFromXML($Event,"severity");
   my $severityValue = 1;
   if($severityCritical eq $severityStr)
   {
       $severityValue=1;
   }
   elsif($severityMajor eq $severityStr)
   {
       $severityValue=2;
   }
   elsif($severityMinor eq $severityStr)
   {
       $severityValue=3;
   }
   elsif($severityWarning eq $severityStr)
   {
       $severityValue=4;
   }
   elsif($severityClear eq $severityStr)
   {
       $severityValue=6;
   }
   elsif($severityNone eq $severityStr)
   {
       $severityValue=4;
   }
  return $severityValue;
}


sub getTagValueFromXML()
{
	my ($xml, $tag) = @_;
	my $value;

	if ($xml =~ m/<$tag>(.*)<\/$tag>/i)
	{
		$value = $1;
	}
	else {
		$value = "";
	}
	return $value;
}

sub removeTagFromXML()
{
	my ($xml, $tag) = @_;
	$xml =~ s/<$tag>(.*)<\/$tag>//i;
	return $xml;
}

sub escapeCharForMySQL()
{
	my ($str, $c) = @_;

	$str =~ s/$c/\\$c/g;
	return $str;
}

# migrates earlier 5.0 versions data to  current 5.0 version
# if the script couldn't find the base version, it executes all the sql statements from
# the beginning of the file.
# This function has it's own limitions that it expects all the sql staments to be in one line and
# there should not be any select statements.
sub migrate50Data(){
    $FileLogger->info("[DBDataPostUpdate/migrate50Data] Start\n ");
    open UPGRADEFIN, "<$upgradeDataFile";
    my $oldVersionCnt=0;
    my $newVersionCnt=0;
    my $line="";
    label1: while($oldVersionCnt ne 2)
        {
            $line = <UPGRADEFIN>;
            if (! defined($line)) {last label1;}
            if($line =~m/$curiVMSVersion/)
            {
                $oldVersionCnt = $oldVersionCnt + 1;
            }
        }
    #read the file from the beginning
    if($oldVersionCnt != 2){
        close (UPGRADEFIN);
        open UPGRADEFIN, "<$upgradeDataFile";

    }
    label2: while ($newVersionCnt ne 2)
    {
        $line = <UPGRADEFIN>;
        if (! defined($line)) {last label2;}
        if($line !~ m/^#/)
        {
            $FileLogger->info("$line");
            $dbh->do($line);
        }
        if($line =~m/$SelfVersion/)
        {
            $newVersionCnt = $newVersionCnt + 1;
        }
    }
    close (UPGRADEFIN);
    $FileLogger->info("[DBDataPostUpdate/migrate50Data] End\n ");
}

sub migrateUsers() {
    my ($version) = @_;
    $FileLogger->info("[DBDataPostUpdate/migrateUsers] Start\n ");
    my $user_password = "";
    my $nonRootUsersExist = "false";	
    $sth = $dbh->prepare("select count(*) as count from users where userid != 1 ;");
    $sth->execute;
    while (my($count)=$sth->fetchrow_array) {
	if($count>0){
		$nonRootUsersExist = "true";
	}
    }
    if(($version=~m/4\.3/ ||$version=~m/4\.2/ || $version=~m/4\.1/) && $nonRootUsersExist eq "true"){    
	    my $resp = "";
	    my $status;
	    print "\n**** A common login password has to be set for all the users (except for the root user) ****\n";
	    while (1){
			print "Type a login password for all the users (except for the root user):\n";
			my $status = system ("stty -echo");
			chop($resp = <>);
			my $Password1 = $resp;
			print " \n";
			$status = system ("stty echo");
			print "Retype the login password for all the users (except for the root user):\n";
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
	    $user_password = $resp;
	    my $encoded_pwd=sha1_base64($user_password);
	    $dbh->do("update users set passwordid='$encoded_pwd=' where userid != 1");
    }
    my $encrypted_pwd=crypt($user_password, "salt");
    $FileLogger->info("select If(count(UserName) >1,'',UserName) from users  where userid != 1 group by userName order by UserName;\n");
    $sth = $dbh->prepare("select UserId,If(count(UserName) >1,'',UserName) from users  where userid != 1 group by userName order by UserName;");
    $sth->execute;
    # get users with unique name from database and add them as system user
    my $userIds="1";
    while (my($userId,$username)=$sth->fetchrow_array) {
        if(!($username eq ""))
        {
            $status=system("useradd -p $encrypted_pwd -m $username");
            $FileLogger->info("system(\"useradd -p $encrypted_pwd -m $username\")\n");
            $userIds =$userIds.",".$userId;
            if($status )
            {
                $File_Screen_Logger->error("*** WARNING *** Cannot add user : [$username]. Please fix it manually\n ");
            }
        }
    }
    $FileLogger->info("select concat(UserName,'_',PartitionId), UserName,PartitionId from users where userid not in($userIds);");    
    $sth = $dbh->prepare("select concat(UserName,'_',PartitionId), UserName, PartitionId from users where userid not in($userIds);");
    $sth->execute;
    # get users with duplicatename from database. update the username with partition id (username_paritionid).
    # Update the database with new name and add the new user in system level
    while (my($newUsername,$username,$partitionId)=$sth->fetchrow_array) {
        # update the name in the database
        $FileLogger->info("update users set userName='$newUsername' where userName='$username' AND PartitionId='$partitionId' ;");
        $dbh->do("update users set userName='$newUsername' where userName='$username' AND PartitionId='$partitionId' ;");
        $File_Screen_Logger->info("*** WARNING ***  User '$username' is updated to '$newUsername'.");
        $status=system("useradd -p $encrypted_pwd -m $newUsername");
        $FileLogger->info("system('useradd -p $encrypted_pwd -m $newUsername')\n");
        if($status )
        {
            $File_Screen_Logger->error("*** WARNING *** Cannot add user : [$newUsername]. Please fix it manually\n ");
        }
    }
    if ($sth)
    {
        $sth->finish;
    }
    $FileLogger->info("[DBDataPostUpdate/migrateUsers] End\n ");
}

#migrate capability for CALEA
sub migrateCapForCalea() {
    $FileLogger->info("[DBDataPostUpdate/migrateCapForCalea] Start\n ");
    #add CALEA capability to admin partition
    $FileLogger->info("UPDATE groups SET Cap = replace(Cap, '</CAPABILITIES>','<Calea>true</Calea></CAPABILITIES>') WHERE PartitionId=1;\n");
    $dbh->do("UPDATE groups SET Cap = replace(Cap, '</CAPABILITIES>','<Calea>true</Calea></CAPABILITIES>') WHERE PartitionId=1;");

    #add CALEA capability to root user
    $FileLogger->info("UPDATE users SET Cap = replace(Cap, '</CAPABILITIES>','<Calea>true</Calea></CAPABILITIES>') WHERE UserId=1;\n");
    $dbh->do("UPDATE users SET Cap = replace(Cap, '</CAPABILITIES>','<Calea>true</Calea></CAPABILITIES>') WHERE UserId=1;");

    $FileLogger->info("[DBDataPostUpdate/migrateCapForCalea] End\n ");
}


sub migrateEventAlarmData(){
    # Following ensures that the data (Timestamp field of rsmevent table) does not get lost while changing
	# the datatype in upgradation.
	# While upgrading , we are taking a backup (in a desired format) of 'Timestamp' column in a temporary column
	# then removing the original column and in the last , renaming the temporary column.

    $FileLogger->info("[DBDataPostUpdate/migrateEventAlarmData] Start\n ");
    $dbh->do("alter table rsmevent add column `TempTimestamp` datetime NOT NULL default '1970-01-01 00:00:00' after FailureObjectId");
    my $sth = $dbh->prepare("SELECT Eventid,created FROM rsmevent");
    $sth->execute;
    my $SubstitionString="";
    while( my($Eventid,$Created)=$sth->fetchrow_array){
            $dbh->do("update rsmevent set TempTimestamp='$Created' where Eventid='$Eventid'");
            print "########### update  TempTimestamp = $TempTimestamp, Eventid=$Eventid\n";
    }
    $dbh->do("alter table rsmevent drop Timestamp");
    $dbh->do("alter table rsmevent change TempTimestamp Timestamp datetime NOT NULL default '1970-01-01 00:00:00'");

    my $sth = $dbh->prepare("SELECT AlarmId,created FROM rsmalarm");
    $sth->execute;
    my $SubstitionString="";
    while( my($Alarmid,$AlarmCreated)=$sth->fetchrow_array){
            $dbh->do("update rsmalarm set DateOfFirstOccurence='$AlarmCreated' where AlarmId='$Alarmid'");
            print "########## update  AlarmCreated = $AlarmCreated, AlarmId=$Alarmid\n";
    }

    $FileLogger->info("[DBDataPostUpdate/migrateEventAlarmData] End\n ");


}


sub migrateSNMPStatsAlarmsToPolledStatsAlarms () {
	# Following method ensures that all enteries of SNMP Stats alarm are converted to Polled Stats alarm 
	# when upgrading from 5.0,5.1 and 5.2 to 5.2.1
	# changes EventType from snmpStats to polledStats
	# changes AlarmType from snmpStats to polledStats
	# changes AlarmSubType from snmpStatDefault to polledStatsDefault
	# changes Type from snmpStats to polledStats
	my $snmpStatString = "snmpStats";
	my $polledStatString = "polledStats";
	my $snmpStatDefaultString = "snmpStatDefault";
	my $polledStatDefaultString = "polledStatsDefault";
	my $snmpStatEventString = "<TYPE>SNMP Threshold</TYPE>";
	my $polledStatEventString = "<TYPE>Polled Stats Threshold</TYPE>";
	$FileLogger->info("[DBDataPostUpdate/migrateSNMPStatsAlarmsToPolledStatsAlarms] Start\n ");	
	$dbh->do("update rsmevent set EventType='$polledStatString' where EventType='$snmpStatString'");
	$dbh->do("update rsmevent set AlarmSubType='$polledStatDefaultString' where AlarmSubType='$snmpStatDefaultString'");
	$dbh->do("update rsmalarm set AlarmType='$polledStatString' where AlarmType='$snmpStatString'");
	$dbh->do("update rsmalarm set AlarmSubType='$polledStatDefaultString' where AlarmSubType='$snmpStatDefaultString'");
	$dbh->do("update rsmalarm_memory set AlarmType='$polledStatString' where AlarmType='$snmpStatString'");
	$dbh->do("update rsmalarm_memory set AlarmSubType='$polledStatDefaultString' where AlarmSubType='$snmpStatDefaultString'");
	$dbh->do("update alarms set Type='$polledStatString' where Type='$snmpStatString'");
	my $sth = $dbh->prepare("SELECT AlarmId,Event FROM alarms where Type='$polledStatString'");
	$sth->execute;
    	my $SubstitionString="";
    	while( my($alarmId,$event)=$sth->fetchrow_array){
	 	$event=~s/$snmpStatEventString/$polledStatEventString/;		
            $dbh->do("update alarms set Event='$event' where AlarmId='$alarmId'");
            print "########## updated Alarm with AlarmId=$alarmId\n";
    	}

	#Update TDF Colums Names from SNMP specific values to generic polling values
	$dbh->do("update TDFColumns set DisplayName ='Managed Object' where ColumnId='pconfigview.PerformanceConfigView.MibNodeName'"); 
	$dbh->do("update TDFColumns set DisplayName ='Managed Object Group' where ColumnId='pconfigview.PerformanceConfigView.MibName'");
	$dbh->do("update TDFColumns set DisplayName ='Polling' where ColumnId='mswsListView.msws.dataCollectionEnabled'");

	$FileLogger->info("[DBDataPostUpdate/migrateSNMPStatsAlarmsToPolledStatsAlarms] End\n ");
}


sub migratePolledData() {
	# Following method ensures that the Instance column of all PerformanceStatsData table are 
	# altered to collate according to the latin1_bin to all case sensitive insertions into the table.
	# This is to be dome when upgrading from 5.0,5.1 and 5.2 to 5.2.1 onwards
	 $FileLogger->info("[DBDataPostUpdate/migratePolledData] Start\n ");
	my $performanceLogTable= "PerformanceStatsDataLogs";
	my $perfTableColumnName= "PerfStatTableName";
	my $modifyColumnClause="Instance varchar(254) collate latin1_bin NOT NULL ";
	my $sth = $dbh->prepare("SELECT $perfTableColumnName FROM $performanceLogTable");
	$sth->execute;
	while( my($perfTableName)=$sth->fetchrow_array){
		#Checking whether the table exists or not before altering it
		my $exist=$dbh->prepare("show tables like '$perfTableName'");
		my $rs=$exist->execute;
		if (!($rs eq "0E0" )) {		
	    		$dbh->do("alter table $perfTableName modify column  $modifyColumnClause");
            		$FileLogger->info ("\n########## updated PerformanceTable $perfTableName ");	
		}else {
			$FileLogger->info("\n########## PerformanceTable $perfTableName doesnot exists");	
		}
	}
	 $FileLogger->info("[DBDataPostUpdate/migratePolledData] Start\n ");
	
} 	

sub migrateIPv6Data() {
    print("Begin to alter IPv6 table\n");
    $FileLogger->info("mysql -h $hostName --port=$hostPort -u $dbUser --password=\"$dbPwd\"  $oldDB < alterIPv6Table.sql");
    my $status =system("mysql -h $hostName --port=$hostPort -u $dbUser --password=\"$dbPwd\"  $oldDB < alterIPv6Table.sql");
    if($status)
    {
            print("Unable to alter IPv6 table\n");
            exit 1;
    }
    print("End to alter IPv6 table\n");
    
    print("Begin to update IPv6 table\n");
    $FileLogger->info("mysql -h $hostName --port=$hostPort -u $dbUser --password=\"$dbPwd\"  $oldDB < updateIPv6Table.sql");
    my $status =system("mysql -h $hostName --port=$hostPort -u $dbUser --password=\"$dbPwd\"  $oldDB < updateIPv6Table.sql");
    if($status)
    {
            print("Unable to update IPv6 table\n");
            exit 1;
    }
    print("End to update IPv6 table\n");
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



exit 0;
