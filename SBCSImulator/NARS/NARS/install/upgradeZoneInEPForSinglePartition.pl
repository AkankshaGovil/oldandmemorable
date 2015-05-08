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
sub upgradeZoneInEPForSinglePartition
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
                #print $DB_Name."\n".$HostName."\n".$HostPort."\n".$DB_Name."\n".$DB_User."\n".$DB_Pwd."\n";
                $dbh = DBI->connect("dbi:mysql:dbname=$DB_Name;"."host=$HostName;port=$HostPort", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
                my $sth = $dbh->prepare("SELECT File FROM license");
                $sth->execute;
                while( my($File)=$sth->fetchrow_array)
                {
                        my $startPos=index($File,"WIM=");
        		my $endPos=index($File,"BBM=");
                       my $subsString="";
                        if($startPos!=-1 && $endPos!=-1)
                        {
                                my $SubstitionString="";
                                #print $startPos.",".$endPos."\n";
                                $subsString=substr($File,$startPos+4, ($endPos-($startPos+4)));

                                #print "Hello"."  ".$subsString."\n";
                                if($subsString = '1') {
                                                #print "if"."\n";
                                        $dbh->do("UPDATE endpoints SET Zone='' WHERE Zone='1';");
                        }
                        }
                }

        };
        if($@)
        {
                print("Upgrade of Zone failed :".$dbh->errstr."\n");
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

$| = 1;

GetOptions( "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
            "dbname=s" => \$DB_Name,
            "host=s" => \$HostName,
            "port=s" => \$HostPort );

if(! defined($DB_User))
{
        print "Usage:\n ./upgradeZoneInEPForSinglePartition.pl -User=<user name> [-Password=<user password> default=<no-password>] [-dbname=<database name> default=bn] [-host=<hostname> default=localhost] [-port=<port number> default=3306]\n";

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
upgradeZoneInEPForSinglePartition();
exit 0;

