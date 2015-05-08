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


sub upgradealarms
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
		my $sth = $dbh->prepare("SELECT alarmid, event FROM alarms");
		$sth->execute;
		while( my($AlarmId, $Event)=$sth->fetchrow_array)
		{
			my $startPos=index($Event,"<TYPE>");
			my $endPos=index($Event,"</TYPE>");
			my $subsString="";
			if($startPos!=-1 && $endPos!=-1)
			{
				my $SubstitionString="";
				$subsString=substr($Event,$startPos+6, ($endPos-($startPos+6)));
                                if($subsString eq "gw minutes")
                                {
				    $SubstitionString="<TYPE>GW minutes</TYPE>";
				    substr($Event,$startPos, (7+$endPos-($startPos)))=$SubstitionString;
				    $dbh->do("UPDATE alarms SET event='$Event' WHERE alarmid='$AlarmId';");
                                }
                                if($subsString eq "dollar amount")
                                {
                                    $SubstitionString="<TYPE>Dollar Amount</TYPE>";
				    substr($Event,$startPos, (7+$endPos-($startPos)))=$SubstitionString;
				    $dbh->do("UPDATE alarms SET event='$Event' WHERE alarmid='$AlarmId';");
                                }
			}
			$startPos=$endPos=-1;
			$startPos=index($Event,"<ENDPOINT");            #get the start pos of endpoint element from the xml
			$endPos=index($Event,"</ENDPOINT>");            #get the end pos of endpoint element from the xml
			if($startPos!=-1 && $endPos!=-1)
			{
				my $endpointTag=substr($Event,$startPos,($endPos-$startPos));      #get the endpoint element from the xml
				my $startep=index($endpointTag,">");               #since value of src is not known, will try to replace >...</ENDPOINT>
				my $endpointString=substr($endpointTag,$startep+1);
				my @endpoints=split(/,/,$endpointString);          #split to get all the endpoints
				my @newendpoints;
				foreach my $endpoint (@endpoints)
				{
				        my @tokens=split(/\//,$endpoint);          #split to get the different attributes of endpoint
				        my $sth1 = $dbh->prepare("select ClusterId from endpoints where SerialNumber='$tokens[0]' and Port='$tokens[1]'");
			 	                $sth1->execute;
			                my $ClusterId=$sth1->fetchrow_array;
			                $endpoint=$endpoint."/$ClusterId";      #append cluster id with each endpoint
				        push(@newendpoints,$endpoint);		#pushin the endpoint with clusterid on the array
				}
				my $newendpointstring =join ',',@newendpoints;             #generating the endpoint string again to insert it into the Event XML
				my $newstart=$startPos+$startep;
				my $newend=$endPos-$newstart;
				substr($Event,$newstart+1,$newend-1)=$newendpointstring;       #replace the old endpoint string with the new one
				$dbh->do("UPDATE alarms SET event='$Event' WHERE alarmid='$AlarmId';"); #update the Event column in the database
			}
		}
		$dbh->do("update actions set Type='set-route-priority' where Type='route-priority'");
		$dbh->do("update actions set field2=name where Type='set-route-priority' and field2=''");
		$dbh->do("update actions set partitionidforadminuser = partitionid");
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
	    "port=s" => \$HostPort );

if(! defined($DB_User))
{
	print "Usage:\n ./upgradealarms.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";

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

upgradealarms();
exit 0;
