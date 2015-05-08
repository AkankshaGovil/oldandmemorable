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


sub updateErrors
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
		
		$dbh->do("REPLACE INTO errors (ErrorId,ErrDesc,Created,LastModified ) VALUES(5800,'calling-entity-dyn-blacklisted',now(),now());");
		$dbh->do("REPLACE INTO errors (ErrorId,ErrDesc,Created,LastModified ) VALUES(5801,'called-entity-dyn-blacklisted',now(),now());");
		$dbh->do("REPLACE INTO errors (ErrorId,ErrDesc,Created,LastModified ) VALUES(1054,'Media CAC channels exceeded',now(),now());");
		$dbh->do("REPLACE INTO errors (ErrorId,ErrDesc,Created,LastModified ) VALUES(1055,'Media CAC bandwidth exceeded',now(),now());");
		$dbh->do("REPLACE INTO errors (ErrorId,ErrDesc,Created,LastModified ) VALUES(1056,'Media 911 CAC channels exceeded',now(),now());");
		$dbh->do("REPLACE INTO errors (ErrorId,ErrDesc,Created,LastModified ) VALUES(1057,'Media 911 CAC bandwidth exceeded',now(),now());");
        
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,486,'Busy Here',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,487,'Request Terminated-Call Abandoned',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,484,'Address Incomplete-Invalid Phone Number',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,403,'Forbidden-User Blocked',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Network Error',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,404,'Not Found-No Route Found',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-No Ports Available',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-General Error',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-Max Call Duration Exceeded',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Temporarily Unavailable-Destination Unreachable',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Temporarily Unavailable-Resource Unavailable',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-No Bandwidth Available',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-H245 Error',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,484,'Address Incomplete',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Local Disconnect',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-H323 Error',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-H323 Protocol Error',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,481,'Dialog/Transaction Does Not Exist',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Media Gateway resource Unavailable',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-SBC FCE Error',now(),now());");

        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-No Vports Available',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-Hairpin Call Setup Blocked',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-SBC Shutdown',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Temporarily Unavailable-Release Complete Dest Unreachable',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Temporarilily Unavailable',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-SBC Switchover Occurred',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-Destination Release Complete',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-No Media Port Available ',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-H323 Max Calls Exceeded',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Invalid Endpoint ID',now(),now());");

        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Invalid Endpoint ID',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Route Call To GK ',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Not Registered',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,403,'Forbidden-User Blocked At Destination',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,404,'Not Found-No Route At Destination',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Destination Timeout',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,410,'Gone-Destination No Longer Registered',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,404,'Not Found-Reject Route',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-NAT Traversal License Required',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-No Media Bandwidth Available',now(),now());");

        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,401,'Unauthorized',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,403,'Forbidden',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,407,'Proxy Authentication Required',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-Internal SBC Error',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,415,'Unsupported Media Type',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,400,'Bad Request-Invalid DNIS Characters Received',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-SBC CDR Processing Failure',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,482,'Loop Detected-ANI DNIS Loop Detected',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-Call Gapping Limit Exceeded',now(),now());");

        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-PCMMRX License Required',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-PSF License Required',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Rx Media Authorization Subscriber ID Not Found',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-Rx Media Authorization Failed',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Media CAC Channel Limit Exceeded',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Media CAC Bandwidth Limit Exceeded',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Media CAC Emergency Bandwidth Channel Limit Exceeded',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,480,'Temporarily Unavailable-Destination Blacklisted',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,500,'Internal Error-Pre Max Call Duration Exceeded',now(),now());");

        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,418,'Unsupported Request URI Scheme',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,403,'Forbidden-Source Endpoint Lookup Failed',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,503,'Service Unavailable-MSRP License Required',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,488,'Not Acceptable Here-MSRP URI Invalid',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,483,'Too Many Hops',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,482,'Loop detect',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,416,'Unsupported URI Scheme',now(),now());");
        $dbh->do("REPLACE INTO errors (ClusterId,ErrorId,ErrDesc,Created,LastModified ) VALUES(-2,489,'Bad Event-Presence Event Unsupported',now(),now());");
            };
	if($@)
	{
		print("Upgrade of events data failed.  DBI said :". $dbh->errstr."\n");
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
	print "Usage:\n ./updateErrors.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";

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

updateErrors();
exit 0;