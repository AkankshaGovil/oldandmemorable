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
use Log::Log4perl qw(:easy);
use IO::Handle;
use strict;

my $DB_User;
my $DB_Name;
my $DB_Pwd;
my $HostName;
my $HostPort;
my $FileLogger;
my $File_Screen_Logger;
my $logFile;
my $appender;
my $layout;

sub upgradeCdrAlarmsToMultipleThresholdCdrAlarms
{
	&CreateLogger($logFile, "DEBUG");
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

		#Gather all configured alarms from DB
		my $sth = $dbh->prepare("SELECT AlarmId, ActionId, Event FROM alarms where Type = 'cdr'");
		$sth->execute;
		while( my($AlarmId, $ActionId, $Event)=$sth->fetchrow_array)
		{
			my $startPos=index($Event,"<SEVERITY_THRESHOLDS>");
			my $endPosThreshold=-1;
		
			#Execute only when Multiple Threshold Configuration not present
			if($startPos==-1)
			{
				#Get configured Severity of the alarm from ActionId field
				my $severity=substr($ActionId,0,1);
		
				my $startPosThreshold=index($Event,"<threshold>");
				my $thresValue = "";
				my $startPosGT = index($Event,"<GT>");
				my $startPosGE = index($Event,"<GT_AND_EQUALS>");
				my $startPosLT = index($Event,"<LT>");
				my $startPosLE = index($Event,"<LT_AND_EQUALS>");
                my $startPosLT1 = index($Event,"<LT/>");
                my $startPosLE1 = index($Event,"<LT_AND_EQUALS/>");
				
				#Initialize preparing SEVERITY_THRESHOLDS tag to be inserted into Event XML
				my $SubstitionString="  <SEVERITY_THRESHOLDS>";

				my $startPosType=index($Event,"<TYPE>");
				my $endPosType=index($Event,"</TYPE>");
				my $typeString="";
				$typeString=substr($Event,$startPosType+6, ($endPosType-($startPosType+6)));
				
				if($typeString eq "GW minutes" || $typeString eq "Dollar Amount")
				{
					#Set threshold value to 100%. We need not touch condition tag here.
					$thresValue = 100;
					if($startPosLT!=-1 || $startPosLE!=-1 || $startPosLT1!=-1 || $startPosLE1!=-1 )
					{
						my $startPosName = -1;
						my $endPosName = -1;
						$startPosName=index($Event,"<NAME>");
						$endPosName=index($Event,"</NAME>");
						$thresValue=substr($Event,$startPosName+6,$endPosName-($startPosName+6));
						print "$thresValue alarm has either < or <= condition, which is not supported from 6.0 onwards \n";
						$FileLogger->info("$thresValue alarm has either < or <= condition, which is not supported from 6.0 onwards ");				
					}
					
				}
				else
				{
					#Extract Threshold Value from Condition.
					if($startPosThreshold!=-1)
					{
						#Threshold alarms case
						$endPosThreshold=index($Event,"</threshold>");
						$thresValue=substr($Event,$startPosThreshold+11,$endPosThreshold-($startPosThreshold+11));
						#Remove <Threshold> tag from Event
						substr($Event,$startPosThreshold,26+($endPosThreshold-($startPosThreshold+11)),"");
					}
					elsif($startPosGT!=-1)
					{
						$endPosThreshold=index($Event,"</GT>");
						$thresValue=substr($Event,$startPosGT+4,$endPosThreshold-($startPosGT+4));
						#Remove threshold Value from Condition.	
						substr($Event,$startPosGT+4,$endPosThreshold-($startPosGT+4),"");
					}
					elsif($startPosGE!=-1)
					{
						$endPosThreshold=index($Event,"</GT_AND_EQUALS>");
						$thresValue=substr($Event,$startPosGE+15,$endPosThreshold-($startPosGE+15));	
						#Remove threshold Value from Condition.
						substr($Event,$startPosGE+15,$endPosThreshold-($startPosGE+15),"");
					}
					elsif($startPosLT!=-1)
					{
						$endPosThreshold=index($Event,"</LT>");
						$thresValue=substr($Event,$startPosLT+4,$endPosThreshold-($startPosLT+4));
						#Remove threshold Value from Condition.	
						substr($Event,$startPosLT+4,$endPosThreshold-($startPosLT+4),"");
					}
					elsif($startPosLE!=-1)
					{
						$endPosThreshold=index($Event,"</LT_AND_EQUALS>");
						$thresValue=substr($Event,$startPosLE+15,$endPosThreshold-($startPosLE+15));	
						#Remove threshold Value from Condition.
						substr($Event,$startPosLE+15,$endPosThreshold-($startPosLE+15),"");
					}
					else
					{
						#Should not arrive here in any case
						$thresValue=1;
					}
				}
				#Prepare <SEVERITY_THRESHOLDS> tag using the Threshold value and Severity extracted earlier
				if($severity==1)
				{
					$SubstitionString=$SubstitionString."1:".$thresValue.";-999999999\$2:-999999999;-999999999\$3:-999999999;-999999999\$4:-999999999;-999999999\$6:-999999999;-999999999";
				}
				elsif($severity==2)
				{
					$SubstitionString=$SubstitionString."1:-999999999;-999999999\$2:".$thresValue.";-999999999;-999999999\$3:-999999999;-999999999\$4:-999999999;-999999999\$6:-999999999;-999999999";
				}
				elsif($severity==3)
				{
					$SubstitionString=$SubstitionString."1:-999999999;-999999999\$2:-999999999;-999999999\$3:".$thresValue.";-999999999\$4:-999999999;-999999999\$6:-999999999;-999999999";
				}
				else
				{
					$SubstitionString=$SubstitionString."1:-999999999;-999999999\$2:-999999999;-999999999\$3:-999999999;-999999999\$4:".$thresValue.";-999999999\$6:-999999999;-999999999";
				}
					
				$SubstitionString=$SubstitionString."</SEVERITY_THRESHOLDS>\n";
		
				#Insert <SEVERITY_THRESHOLDS> before <NUMBER_OF_VOILATION> tag
				my $endPos=index($Event,"</EV>");
				substr($Event,$endPos,0,$SubstitionString);

				#Replace Escape Characters (') from Event XML
                                my $c="'";
                                $Event =~ s/$c/\\$c/g;
		
				$dbh->do("UPDATE alarms SET event='$Event' WHERE alarmid='$AlarmId';");
				#print($Event);
				
			}
		}
	};
	if($@)
	{
		print("Upgrade to Multiple Threshold Configuration in CDR Alarms FAILED!!\n");
		if($dbh)
		{
			print("DBI Message: ". $dbh->errstr."\n");
			$dbh->disconnect;
		}
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

$| = 1;

GetOptions( "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
	    "dbname=s" => \$DB_Name,
	    "host=s" => \$HostName,
	    "port=s" => \$HostPort,
	    "log=s" => \$logFile );

if(! defined($DB_User))
{
	print "Usage:\n ./upgradeCdrAlarmsToMultipleThresholdCdrAlarms.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";
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

upgradeCdrAlarmsToMultipleThresholdCdrAlarms();
exit 0;