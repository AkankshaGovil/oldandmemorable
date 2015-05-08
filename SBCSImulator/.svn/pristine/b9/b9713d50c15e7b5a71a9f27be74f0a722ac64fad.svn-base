#!/usr/bin/perl

use FindBin;
use lib $FindBin::Bin."/site_perl/5.8.0";
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
use Log::Log4perl qw(:easy);
use Config::Simple;
use IO::Handle;

my $cn;
my $ct;
my $qry;
my $tmp;
my $sth;
my $aaa;
my $bbb;
my $ccc;
my $q1;
my $q3;
my $start;
my $end;

my @temp;
my $LogFile;
my $UpgradeLogFile = "rsmupgrade.log";
my $InstallLogFile = "rsminstall.log";
my $StartDir = `pwd`;
my $UpgradeLog="";
my $appender;
my $FileLogger;
my $File_Screen_Logger;
my $layout;
my $DB_User;
my $DB_Name;
my $DB_Pwd;
my $HostName;
my $HostPort;

my $query;
my $stmt;
my $tmpResult;





sub parse_csv {
    my $text = shift;
    my @new  = ();
    push(@new, $+) while $text =~ m{
        "([^\"\\]*(?:\\.[^\"\\]*)*)",?
           |  ([^,]+),?
           | ,
       }gx;
       push(@new, undef) if substr($text, -1,1) eq ',';
       return @new;      # list of values that were comma-separated
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


sub migrateCdrToHrData
{
	my $current = system("pwd");
	#print $current;
	$LogFile = $UpgradeLogFile;
	$UpgradeLog = $UpgradeLogFile;
	open (ERROR, "> $UpgradeLog");
	STDERR->fdopen(\*ERROR, "w");
	&CreateLogger("$UpgradeLog", "DEBUG");
	
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

       print ("\nStarting step 1 ....");

	print ("\nGetting DB connection ... ");
	eval{
		$dbh = DBI->connect("dbi:mysql:dbname=$DB_Name;"."host=$HostName;port=$HostPort", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
$File_Screen_Logger->info("Credentials of MySql root user modified \n");            
print ("\nGetting DB connection successful");

my $tabsth = $dbh->table_info(undef, undef, "hrlogs");
if ($tabsth->fetch) {
   	$File_Screen_Logger->info("\n\nHrLogs table exists. No need to execute migratecdrtohrdata.pl\n\n");
	$dbh->disconnect;
	exit;
} else {
	print "doe\n\n";
}

$aaa="CREATE TABLE hrlogs (
                hrLogId int(11) NOT NULL auto_increment,
                hrSummaryTableName varchar(32) NOT NULL default '',
                StartDateInt int(11)  default '0',
                EndDateInt int(11) default '0',
                Status int(11) NOT NULL default '-1',
                DayStatus int(11) NOT NULL default '-1',
				CreatedInt datetime NOT NULL default '1970-01-01 00:00:00',
  				LastModifiedInt datetime NOT NULL default '1970-01-01 00:00:00',
                PRIMARY KEY  (hrLogId),
                UNIQUE KEY hrTableName (hrSummaryTableName)
        ) TYPE=INNODB PACK_KEYS=DEFAULT;";

        $bbb = $dbh->prepare($aaa);
$File_Screen_Logger->info ("\nCreating Hrlogs table ...");
        $bbb->execute;
$File_Screen_Logger->info ("\nCreating Hrlogs table successful.");


       $File_Screen_Logger->info ("\nStep 1 completed successfully.");
      $File_Screen_Logger->info ("\nStarting Step 2 ...");

  $query="select unix_timestamp(DATE_SUB(now(),INTERVAL 6 MONTH))";
  $stmt=$dbh->prepare($query);
  $stmt->execute;
  $tmpResult=$stmt->fetchrow_array;

  $query="update cdrlogs set status =20 where enddateint < $tmpResult";
  $stmt=$dbh->prepare($query);
  $stmt->execute;

  $query="select max(enddateint) from cdrlogs where status =20";
  $stmt=$dbh->prepare($query);
  $stmt->execute;
  $tmpResult=$stmt->fetchrow_array;

  if($tmpResult eq ''){
      $tmpResult=0;
    }
  
        $tmp="select distinct from_unixtime(datetimeint,'%c%Y') from  cdrsummary where datetimeint >= $tmpResult  order by datetimeint desc" ;
        $sth = $dbh->prepare($tmp);


print ("\nGetting data from cdrsummary table ...");
        $sth->execute;
print ("\nGetting data from cdrsummary table successful.");

        $cn=1;
        while($ct=$sth->fetchrow_array)
        {
                $qry=" create table hrsum_".$ct." select * from cdrsummary where from_unixtime(datetimeint,'%c%Y') = $ct and datetimeint >= $tmpResult ";
                my $sth1 = $dbh->prepare($qry);

print ("\nCreating hrsum_$ct table ...");
                        $sth1->execute;
print ("\nCreating hrsum_$ct table successful.");

                $tmp=("select min(mindatetimeint), max(maxdatetimeint) from hrsum_".$ct." ");
                my $q2=$dbh->prepare($tmp);

print ("\nGetting data from hrsum_$ct table ...");

                $q2->execute;
print ("\nGetting data from hrsum_$ct table successful.");

                while (@temp=$q2->fetchrow_array)
                {
                        $start=$temp[0];
                         $end=$temp[1];
                }


                $q3="insert into hrlogs(hrLogId,hrSummaryTableName,StartDateInt,EndDateInt,Status,DayStatus,CreatedInt,LastModifiedInt) values($cn,'hrsum_$ct','$start','$end', '20', '0', now(),now() )";
                my $q4=$dbh->prepare($q3);

print ("\nInserting  a row into hrlogs count= $cn for hrsum_$ct table ...");
                $q4-> execute;

print ("\nInserting  a row into hrlogs count= $cn for hrsum_$ct table successful");
                $cn=$cn+1;
        }


$File_Screen_Logger->info ("\nStep 2 completed successfully.");
$File_Screen_Logger->info ("\nStarting step 3 ...");

        $tmp=" select distinct from_unixtime(datetimeint,'%c%Y') from  buysummary where datetimeint >= $tmpResult order by datetimeint desc " ;

        $sth = $dbh->prepare($tmp);
print ("\nGetting data from buysummary table ...");
        $sth->execute;
print ("\nGetting data from buysummary table successful.");

        while($ct=$sth->fetchrow_array)
        {
                $qry=" create table hrbuy_".$ct." select * from buysummary where from_unixtime(datetimeint,'%c%Y') = $ct and datetimeint >= $tmpResult";
                my $sth1 = $dbh->prepare($qry);

print ("\nCreating hrbuy_$ct table ...");
                $sth1->execute;
print ("\nCreating hrbuy_$ct table successful.");

                $tmp=("select min(mindatetimeint), max(maxdatetimeint) from hrbuy_".$ct." ");
                my $q2=$dbh->prepare($tmp);

print ("\nGetting data from hrbuy_$ct table ...");
                $q2->execute;
print ("\nGetting data from hrbuy_$ct table successful.");


                while (@temp=$q2->fetchrow_array)
                {
                        $start=$temp[0];
                         $end=$temp[1];
                }

                $q3="insert into hrlogs(hrLogId,hrSummaryTableName,StartDateInt,EndDateInt,Status,DayStatus,CreatedInt,LastModifiedInt) values($cn,'hrbuy_$ct','$start','$end', '20', '0',now(),now() )";

                my $q4=$dbh->prepare($q3);
print ("\nInserting  a row into hrlogs count= $cn for hrbuy_$ct table ...");
                $q4-> execute;
print ("\nInserting  a row into hrlogs count= $cn for hrbuy_$ct table successful.");
                $cn=$cn+1;
        }


$File_Screen_Logger->info ("\nStep 3 completed successfully.");
$File_Screen_Logger->info ("\nStarting step 4 ...");

        $tmp=" select distinct from_unixtime(datetimeint,'%c%Y') from  sellsummary where datetimeint >= $tmpResult order by datetimeint desc" ;
        $sth = $dbh->prepare($tmp);
print ("\nGetting data from sellsummary table ...");
        $sth->execute;
print ("\nGetting data from sellsummary table successful.");

        while($ct=$sth->fetchrow_array)
        {
                $qry=" create table hrsell_".$ct." select * from sellsummary where from_unixtime(datetimeint,'%c%Y') = $ct and datetimeint >= $tmpResult";
                my $sth1 = $dbh->prepare($qry);

	      print ("\nCreating hrsell_$ct table ...");
                $sth1->execute;
print ("\nCreating hrsell_$ct table successful.");

                $tmp=("select min(mindatetimeint),max(maxdatetimeint) from hrsell_".$ct." ");
                my $q2=$dbh->prepare($tmp);
print ("\nGetting data from hrsell_$ct table ...");
                $q2->execute;
print ("\nGetting data from hrsell_$ct ... ");

                while (@temp=$q2->fetchrow_array)
                {
                        $start=$temp[0];
                        $end=$temp[1];
                }

                $q3="insert into hrlogs(hrLogId,hrSummaryTableName,StartDateInt,EndDateInt,Status,DayStatus,CreatedInt,LastModifiedInt) values($cn,'hrsell_$ct','$start','$end', '20', '0',now(),now() )";
                my $q4=$dbh->prepare($q3);
print ("\nInserting  a row into hrlogs count= $cn for hrsell_$ct table ...");
                $q4-> execute;
print ("\nInserting  a row into hrlogs count= $cn for hrsell_$ct table successful.");


                $cn=$cn+1;

        }

print ("\nStep 4 completed successfully.");

        #while( my($TableName)=$sth->fetchrow_array){
        #       print("TableName = ".$TableName);
        #}
        print ("\nData Migration succesful. \n");
	$stmt->finish



};

	if($@)
	{
		print "\nData Migration failed please check the error logs:". $dbh->errstr."\n";
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
	print "Usage:\n ./migratecdrtohrdata.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";

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
print ("\nStarting Data Migration script ... \n");
migrateCdrToHrData();
exit 0;
