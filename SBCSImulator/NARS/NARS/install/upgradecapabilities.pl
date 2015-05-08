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
my $OldVersion;
my $NewVersion;
my $SubString;

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


sub upgradecapabilities
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
		my $sth = $dbh->prepare("SELECT PartitionId, Cap FROM groups");
		$sth->execute;
		while( my($PartitionId, $Cap)=$sth->fetchrow_array)
		{
			my $startPos=index($Cap,"<MSWs>");
			my $endPos=index($Cap,"</MSWs>");
			my $subsString="";
			if($startPos!=-1 && $endPos!=-1)
			{
				my $SubstitionString="";
				$subsString=substr($Cap,$startPos+6, ($endPos-($startPos+6)));
				my @MSWs=parse_csv($subsString);
				my $mswliststr="";	
				my $mswcnt=0;
				my $stmnt="SELECT distinct(ClusterId) from `msws` ";

                                # Admin partition should have access to all the MSWs
				if ($PartitionId != 1)
				{
					$stmnt=$stmnt." where ";
				foreach my $MSWid (@MSWs)
				{	
					if($mswcnt)
					{	
						$stmnt=$stmnt." OR ";
					}
					$stmnt=$stmnt." MSWId='$MSWid' ";	
					$mswcnt++;
				}
				} 
				else 
				{
					$mswcnt++;
				}
				if($mswcnt)
				{
					my $sth1=$dbh->prepare("$stmnt;");
					$sth1->execute();
					while( my($ClusterId)=$sth1->fetchrow_array)
					{
						$SubstitionString=$SubstitionString."$ClusterId,";
					}
				}
				$SubstitionString="<clusterIds>".$SubstitionString."</clusterIds>";
				substr($Cap,$startPos, (7+$endPos-($startPos)))=$SubstitionString;
				$startPos=index($Cap,"</TimeZone>");
				my $beforeTimeZone=substr($Cap,0,$startPos+11);	#here 12 is the length of </TimeZone>
				my $afterTimeZone=substr($Cap,$startPos+11);
				my $xml=&upgradecacLimits($PartitionId,$dbh);
				$Cap=$beforeTimeZone.$xml.$afterTimeZone;
				$dbh->do("UPDATE groups SET Cap='$Cap' WHERE PartitionId='$PartitionId';");
			}
		}

		my $sth = $dbh->prepare("SELECT UserId, Cap FROM users");
		$sth->execute;
		while( my($UserId, $Cap)=$sth->fetchrow_array)
		{
			my $startPos=index($Cap,"<MSWs>");
			my $endPos=index($Cap,"</MSWs>");
			my $subsString="";
			if($startPos!=-1 && $endPos!=-1)
			{
				my $SubstitionString="";
				$subsString=substr($Cap,$startPos+6, ($endPos-($startPos+6)));
				my @MSWs=parse_csv($subsString);
				my $mswcnt=0;
				my $stmnt="SELECT distinct(ClusterId) from `msws` ";
			       	
				# Root user should have access to all the MSWs
				if ($UserId != 1)
				{
					$stmnt=$stmnt." where ";
				foreach my $MSWid (@MSWs)
				{	
					if($mswcnt)
					{	
						$stmnt=$stmnt." OR ";
					}
					$stmnt=$stmnt." MSWId='$MSWid' ";	
					$mswcnt++;
				}
				}
                                else
				{
					$mswcnt++;
				}
					
				if($mswcnt)
				{
					my $sth1=$dbh->prepare("$stmnt;");
					$sth1->execute();
					while( my($ClusterId)=$sth1->fetchrow_array)
					{
						$SubstitionString=$SubstitionString."$ClusterId,";
					}
				}
				$SubstitionString="<clusterIds>".$SubstitionString."</clusterIds>";
				substr($Cap,$startPos, (7+$endPos-($startPos)))=$SubstitionString;
				$dbh->do("UPDATE users SET Cap='$Cap' WHERE UserId='$UserId';");
			}
		}
                #Start Modification 23329
                $dbh->do("UPDATE bn.groups SET Cap = replace(Cap, '</Report>','<Custom/></Report>');");
                $dbh->do("UPDATE bn.users SET Cap = replace(Cap, '</Report>','<Custom/></Report>');");
                $dbh->do("UPDATE bn.groups SET GroupName='<global>' where PartitionId='-1';");
                # End modification bug 23329
	};
	if($@)
	{
		print("Upgrade of capabilities data failed.  DBI said :". $dbh->errstr."\n");
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

sub upgradecacLimits
{
	
	my $dbh=$_[1];
	my $Partition=$_[0];
	eval{
		my $sth = $dbh->prepare("SELECT  MaxTotal,MaxIn,MaxOut,MaxBwTotal, MaxBwIn,MaxBwOut FROM iedgegroups where PartitionId='$Partition'");
		$sth->execute;
		while( my($maxTotal,$maxIn,$maxOut,$maxBwTotal,$maxBwIn,$maxBwOut)=$sth->fetchrow_array)
		{
			# The cac limits are stored as call legs in iedggroups table which are double the number of actual calls allowed.
			$maxTotal = int($maxTotal/2);
			$maxOut = int($maxOut/2);
			$maxIn = int($maxIn/2);

			my $xmlString="<MaxCallsTotal>" .$maxTotal."</MaxCallsTotal><MaxCallsIn>".$maxIn."</MaxCallsIn><MaxCallsOut>".$maxOut."</MaxCallsOut><MaxBandwidthTotal>".$maxBwTotal."</MaxBandwidthTotal><MaxBandwidthIn>".$maxBwIn."</MaxBandwidthIn><MaxBandwidthOut>".$maxBwOut."</MaxBandwidthOut>";
			return $xmlString;
		}
	}
}

sub upgradecapabilitiesreports
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
		$dbh->do("UPDATE bn.groups SET Cap = replace(Cap, '</Asr>','</Asr>\n  <Ner>\n      <Chromocode normal=\\'80\\' questionable=\\'60\\' />\n    </Ner>\n  <Qos>\n      <Chromocode normal=\\'80\\' questionable=\\'70\\' />\n    </Qos>') where partitionid=1 or partitionid=-1 or partitionid=-2");
		$dbh->do("UPDATE bn.groups SET Cap = replace(Cap, '</Asr>','</Asr>\n  <Ner>\n      <Chromocode normal=\\'50\\' questionable=\\'40\\' />\n    </Ner>\n  <Qos>\n      <Chromocode normal=\\'50\\' questionable=\\'40\\' />\n    </Qos>') where !(partitionid=1 or partitionid=-1 or partitionid=-2)");
                $dbh->do("UPDATE bn.users SET Cap = replace(Cap, '</Asr>','</Asr>\n  <Ner>\n      <Chromocode normal=\\'80\\' questionable=\\'60\\' />\n    </Ner>\n  <Qos>\n      <Chromocode normal=\\'80\\' questionable=\\'70\\' />\n    </Qos>') where partitionid=1;");
                $dbh->do("UPDATE bn.users SET Cap = replace(Cap, '</Asr>','</Asr>\n  <Ner>\n      <Chromocode normal=\\'50\\' questionable=\\'40\\' />\n    </Ner>\n  <Qos>\n      <Chromocode normal=\\'50\\' questionable=\\'40\\' />\n    </Qos>') where !(partitionid=1);");
	};
	if($@)
	{
		print("Upgrade of capabilities data for 4.3 failed.  DBI said :". $dbh->errstr."\n");
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

sub upgradecapabilitiesroutestatisticsreports
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
                my $sth = $dbh->prepare("SELECT PartitionId, Cap FROM groups where partitionid=1 or partitionid=-1 or partitionid=-2");
		$sth->execute;
		while( my($PartitionId, $Cap)=$sth->fetchrow_array)
		{
			my $Pos=index($Cap,"<Statistics />");
			if($Pos==-1)
			{
		        $dbh->do("UPDATE bn.groups SET Cap = replace(Cap, '</Business>','</Business>\n <Statistics />') where PartitionId='$PartitionId';");
                        }
               }
               
               my $sth = $dbh->prepare("SELECT UserId, Cap FROM users where partitionid=1");
	       $sth->execute;
		while( my($UserId, $Cap)=$sth->fetchrow_array)
		{
			my $Pos=index($Cap,"<Statistics />");
			if($Pos==-1)
			{
                        $dbh->do("UPDATE bn.users SET Cap = replace(Cap, '</Business>','</Business>\n <Statistics />') WHERE UserId='$UserId' ;");
                        }
               }
	};
	if($@)
	{
		print("Upgrade of capabilities data failed.  DBI said :". $dbh->errstr."\n");
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
	    "port=s" => \$HostPort,
	    "oldversion=s" => \$OldVersion,
	    "newversion=s" => \$NewVersion);

if(! defined($DB_User))
{
	print "Usage:\n ./upgradecapabilities.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";
	
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

$SubString=substr($NewVersion,0,3);

if($OldVersion =~m/4\.0/)
{
	upgradecapabilities();
    upgradecapabilitiesroutestatisticsreports();
}
if(($OldVersion =~m/4\.0/ && $SubString >= 4.3) || ($OldVersion =~m/4\.2/ && $SubString >= 4.3))
{
       upgradecapabilitiesreports();
}
exit 0;
