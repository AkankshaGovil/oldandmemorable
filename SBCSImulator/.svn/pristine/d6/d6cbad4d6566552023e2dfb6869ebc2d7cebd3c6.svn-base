#!/usr/bin/perl

#Utility for generating alters between MySql iVMS databases


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
use Config::Simple;

my $DB_User;
my $DB_Name;
my $DB_Pwd;
my $HostName;
my $HostPort;
my $outfile;
my $version;
my $oldDB;
my $newDB;
my $specials;
my $isupgrade;
my $conversiontype;

my %alters;
my @foreigns=();

my @oldtables=();
my @newtables=();
my %downgradedrops;
my %renamehash ;
my $config;
my $props;
my @partitions = ();
my @dynamic_tables = ();
# read the given config file

# column renamings that apply only for 4.0/4.1 to 4.2 upgrade
my %renamehash40=(
		"default.realms.Id"=>"realms.RealmId",
		"default.realms.RealmId"=>"realms.Id"
	);

sub consolidatealters()
{
# The DBI:mysql does not support the new mysql password algo, so we change the password to the old formats, and change them back after we're done
	open (TMP2,">fix_privileges_old_pwd_tmp.sql");
	print   TMP2 "USE mysql;";
	print TMP2 "UPDATE user SET password=OLD_PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
	print TMP2 "FLUSH PRIVILEGES;";
	close (TMP2);
	
	
	open (TMP1,">fix_privileges_new_pwd_tmp.sql");
	print TMP1 "USE mysql;";
	print TMP1 "UPDATE user SET password=PASSWORD('$DB_Pwd') WHERE user='$DB_User';\n";
	print TMP1 "FLUSH PRIVILEGES;";
	close (TMP1);

	my $status;
	
	$status =system("mysql -h $HostName --port=$HostPort -u $DB_User --password=$DB_Pwd  < fix_privileges_old_pwd_tmp.sql");
	if($status)
	{
		print ("Unable to change $DB_User password to old version, cannot continue.");
		exit 1;
	}
	
	my $dbh;
        my $triggerStatement="";
	
 	eval{
		$dbh = DBI->connect("dbi:mysql:dbname=$oldDB;"."host=$HostName;port=$HostPort", $DB_User, $DB_Pwd, { RaiseError => 1, AutoCommit => 0, PrintError => 1});
		
#get all tables of source and target databases, and put them in separate arrays

		my $sth ;
		if((!($version=~m/4\.0/))  && $isupgrade)
		{
			$sth = $dbh->prepare("SELECT PartitionId FROM $oldDB.groups where PartitionId > 0");
		

		$sth->execute;

	        while( my($PartitionId)=$sth->fetchrow_array)
		{
			push(@partitions,$PartitionId);
# 			print ("arr: @partitions\n var:$PartitionId\n");
		}
		
	
		$dbh->do("use $oldDB");
		$dbh->do("CREATE TABLE IF NOT EXISTS rates_old like rates; ");
		}
#drop all the views from the old database


#get the views from olddatabase
                my $sth1 = $dbh->prepare("SELECT  TABLE_NAME FROM information_schema.tables where table_type = 'VIEW' and TABLE_SCHEMA='bn'");
		$sth1->execute();

                my @oldviews;		
		while(my $view=$sth1->fetchrow_array())
                {
                       $dbh->do(" DROP VIEW IF EXISTS $view");
                }
		$sth1=$dbh->prepare("show tables");
		$sth1->execute();
		while(my $table=$sth1->fetchrow_array())
		{
			#print "old $table\n";
			push (@oldtables, $table);
		}

		$dbh->do("use $newDB");
		$sth1=$dbh->prepare("show tables");
		$sth1->execute();
		
		while(my $table=$sth1->fetchrow_array())
		{
			#print "new $table \n";
			push (@newtables, $table);
		}
# read the properties file, and put them in a hash
		if (-f $props && -T $props )
		{
			$config = new Config::Simple(filename=>$props);
		}
		else
		{
			die("Cannot read config file $props");
		}
		
		%renamehash = $config->param_hash();
		
		my $dyntablesref = $renamehash{'default.tables.dynamic.orig'};
		
		if (ref($dyntablesref) ne "ARRAY")
		{
			@dynamic_tables=($dyntablesref);
		}	
		else
		{
			@dynamic_tables=@$dyntablesref;
		}

	
		if(($version=~m/4\.0/) || ($version=~m/4\.1/))
		{
			%renamehash = (%renamehash,%renamehash40);
		}
		
# for each table in the target database
		foreach(@newtables)
		{
 			my $sth = $dbh->prepare("SHOW create table $newDB.`$_`;");
 			$sth->execute;
 			my($newtable, $newscript)=$sth->fetchrow_array;
			if(existingtable($_))
			{
# if that table is present in the source database
				my $sth = $dbh->prepare("SHOW create table $oldDB.`$_`;");
				$sth->execute;
				my($oldtable, $oldscript)=$sth->fetchrow_array;
				
                                if($oldscript ne $newscript){
#get the diff and add the alter to a hash
				  $alters{$newtable}=&genalter($oldscript,$newscript,$_)."\n\n\n";
				  if((!($version=~m/4\.0/))  && $isupgrade)
				  {
# 					print "\nbefore\n$alters{$newtable}\n";
					getDynTableScr($newtable);
				  }
                                }
			}
			
			else
			{
				if($isupgrade)
				{
#if the table is not in the source database and if it's an upgrade, add the entire table creation script to the hash
					
					$alters{$_}=$newscript.";\n\n\n";
					if((!($version=~m/4\.0/))  && $isupgrade)
					{
						getDynTableScr($_);
					}
				}
			}
		}
		if(!$isupgrade)
		{
			foreach(@oldtables)
			{
# if it is a downgrade, then we drop any tables that are present in source database but not in target db.
				if(existingtablen($_))
				{
					next;
				}
				$downgradedrops{$_}="DROP TABLE IF EXISTS `$_`;\n";
			}
		}
                if($isupgrade)
                {
                   $triggerStatement=&generatetriggers($dbh);
		   
                }
		
 	};
 	if($@)
 	{
 		print ("Generation of database upgrade data failed.  \n");
 		exit 1;
 	}

	if($dbh)
	{
		$dbh->disconnect;
	}
	my $tableorderref = $renamehash{'default.tables.order'};
	my @tableorder = @$tableorderref;


open (OUTPUTFILEHANDLE,">$outfile") or die "\nUnable to open file $outfile for writing\n";
print OUTPUTFILEHANDLE  "use $oldDB;\n";
	foreach(@foreigns)
	{
# print the drop foreign keys first
		print OUTPUTFILEHANDLE  $_;
#		delete $alters{$_};
	}
	if(!$isupgrade)
	{
# for down grade drop the tables in proper order 
		my $downgradedroporderref=$renamehash{'default.tables.drop.order'};
		my @downgradedroporder=@$downgradedroporderref;
		foreach(@downgradedroporder)
		{
			
			if(defined($downgradedrops{$_}))
			{
				print OUTPUTFILEHANDLE $downgradedrops{$_};
				delete $downgradedrops{$_};
			}
	#		delete $alters{$_};
		}
		foreach(keys %downgradedrops)
		{
			print OUTPUTFILEHANDLE $downgradedrops{$_};
		}
	}
	
# print the "special cases"
	#print OUTPUTFILEHANDLE  &getSpecials();
	my $droppedtablesref=$renamehash{'default.tables.todrop'};
	if(defined($droppedtablesref))
	{
#for upgrade, drop the tables, that are to be dropped, we don't simply drop all tables that are present in the source database as some tables might have been created by user/application dynamically
		my @droppedtables=@$droppedtablesref;
		foreach(@droppedtables)
		{
			print OUTPUTFILEHANDLE  "DROP TABLE IF EXISTS `$_`;\n";
		}
	}
	print OUTPUTFILEHANDLE  "\n";
	foreach(@tableorder)
	{
#print the alters in proper order, to take care of foreign key dependencies
		print OUTPUTFILEHANDLE  $alters{$_};
		delete $alters{$_};
	}
	foreach(keys %alters)
	{
# print everything else
		print OUTPUTFILEHANDLE  $alters{$_};
	}
        # print the trigger alter statement
        print OUTPUTFILEHANDLE $triggerStatement;
	#if($isupgrade)
	#{
	#	print OUTPUTFILEHANDLE getDataSqls($config->param_hash());
	#}

	close OUTPUTFILEHANDLE;
	system("mysql -h $HostName --port=$HostPort -u $DB_User --password=$DB_Pwd  < fix_privileges_new_pwd_tmp.sql");
	system("rm fix_privileges_new_pwd_tmp.sql");
	system("rm fix_privileges_old_pwd_tmp.sql");
}

#returns tryue if table exists in old db
sub existingtable()
{
	my ($tablename)=@_;
#	print OUTPUTFILEHANDLE  "existin list @oldtables \n\n\n table asked $tablename";
	foreach(@oldtables)
	{
		if($_ eq $tablename)
		{
			return 1;
		}
	}
	return 0;
}
#returns tryue if table exists in new db
sub existingtablen()
{
	my ($tablename)=@_;
	#	print OUTPUTFILEHANDLE  "existin list @oldtables \n\n\n table asked $tablename";
	foreach(@newtables)
	{
		if($_ eq $tablename)
		{
			return 1;
		}
	}
	return 0;
}

sub genalter()
{

	my ($oldscript,$newscript,$table)=@_;
	my %oldhash;
	my %newhash;
	my %namehash;
	my @localFK=();
	my @localKEY=();
#create the hashes contining the columns, keys, foreign keys, and table type, for the hashes, the key would be the all-uppercase converted name of ..., the namehash contains the actual name of the column/key/foreignkey, the oldhash/newhash contains description as the values for keys/unique keys/indexes prepend KEY to the key, for foreign keys prepend FK for table type key is TABLE_TYPE for primary key it's PK

#split at newline, (see the show create table output, it separates the column/key etc by newline)
		my @old=split(/\n/,$oldscript);
		foreach(@old)
		{
			my $curline=$_;
			if($curline=~m/CREATE TABLE/)
			{
				next;
			}
			if($curline=~m/$\,/)
			{
				my $chopped=chop($curline);
				if($chopped ne "\,")
				{
					$curline=$curline.$chopped;
#					print OUTPUTFILEHANDLE  "chopped: $chopped $curline \n";
				}
			}
			if($curline=~m/\) ENGINE=MyISAM/)
			{
				$oldhash{"TABLE_TYPE"}="MyISAM";
				next;
			}
			elsif($curline=~m/\) ENGINE=InnoDB/)
			{
				$oldhash{"TABLE_TYPE"}="InnoDB";
				next;
			}
            elsif($curline=~m/\) ENGINE=MEMORY/)
            {
                $oldhash{"TABLE_TYPE"}="MEMORY";
                next;
            }

#names are enclosed in backtick (`) in mysql
			my $start=index($curline,"`");
			my $end=index($curline,"`",$start+1);
			my $colkeyname=substr($curline,$start+1,$end-$start-1);
			if($curline=~m/PRIMARY KEY/)
			{
				$oldhash{"PK"}=$curline;
				next;
			}
			my $uppercasename=$colkeyname;
			$uppercasename=~tr/a-z/A-Z/;
			if(($curline =~m/\sKEY\s/ || $curline =~m/\sINDEX\s/) && !($curline=~m/FOREIGN KEY/))
			{
				$uppercasename="{KEY}".$uppercasename;
			}
			if($curline=~m/FOREIGN KEY/)
			{
				$uppercasename="{FK}".$uppercasename;
			}
			
			$namehash{$uppercasename}=$colkeyname;
			$oldhash{$uppercasename}=$curline;
		}

		my @new=split(/\n/,$newscript);
		foreach(@new)
		{
		my $curline=$_;
		if($curline=~m/CREATE TABLE/)
		{	
			next;
		}
		if($curline=~m/$\,/)
		{
			my $chopped=chop($curline);
			if($chopped ne "\,")
			{
				$curline=$curline.$chopped;
#				print OUTPUTFILEHANDLE  "chopped: $chopped $curline \n";
			}
		}
		if($curline=~m/\) ENGINE=MyISAM/)
		{
			$newhash{"TABLE_TYPE"}="MyISAM";
			next;
		}
		elsif($curline=~m/\) ENGINE=InnoDB/)
		{
			$newhash{"TABLE_TYPE"}="InnoDB";
			next;
		}elsif($curline=~m/\) ENGINE=MEMORY/)
		{
			$newhash{"TABLE_TYPE"}="MEMORY";
			next;
		}

		my $start=index($curline,"`");
		my $end=index($curline,"`",$start+1);
		my $colkeyname=substr($curline,$start+1,$end-$start-1);
		if($curline=~m/PRIMARY KEY/)
		{
			$newhash{"PK"}=$curline;
			next;
		}
		my $uppercasename=$colkeyname;
		$uppercasename=~tr/a-z/A-Z/;
		if((($curline =~m/\sKEY\s/) || $curline =~m/\sINDEX\s/) && !($curline =~m/FOREIGN KEY/) )
		{
			$uppercasename="{KEY}".$uppercasename;
		}
		if($curline=~m/FOREIGN KEY/)
		{
			$uppercasename="{FK}".$uppercasename;
		}
		$namehash{$uppercasename}=$colkeyname;
		$newhash{$uppercasename}=$curline;
	}

#now we actually create the alter for this table

	my $alterscript="";
#for cdr table, table name is ivms-cdr-table, coz there are several cdr tables, this is used in ivmsServerInst.pl script
	if($table ne "cdr")
 	{
#		$alterscript=$alterscript."ALTER TABLE `$table` \n";
		$alterscript=$alterscript."ALTER TABLE `$table` ";
 	}
 	else
 	{
# 		$alterscript=$alterscript."ALTER TABLE ivms-cdr-table\n";
 		$alterscript=$alterscript."ALTER TABLE ivms-cdr-table ";
 	}
	my $addComma=0;
	my $alterCnt=0;
	if($oldhash{"PK"} ne "")
	{
		if($oldhash{"PK"} ne $newhash{"PK"})
		{
			$alterscript=$alterscript."DROP PRIMARY KEY";
			$addComma=1;
		}
	}


	foreach(keys %oldhash)
	{	
# for each column/key in the old table, if it's not defined as renamed according to the upgrade.propertiers file, we drop them, if they're defined there we do a change
		my $oldkey=$_;
		if($oldkey eq "PK" ||($oldkey=~m/TABLE_TYPE/))
		{
			next;
		}
		my $rencheck="default.".$table.".".$namehash{$oldkey};
		if(defined($renamehash{$rencheck}) && !($oldkey =~m/^{KEY}/ || $oldkey =~m/^{FK}/ ))
		{
			my $var=$renamehash{$rencheck};
			my @var2=split(/\./,$var);
			my $newName=@var2[$#var2];
#add comma if...
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
			my $expectedNewKey=$newName;
			$expectedNewKey=~tr/a-z/A-Z/;
			if(!defined($newhash{$expectedNewKey}))
			{
				next;
			}
			$alterscript=$alterscript."CHANGE `".$namehash{$oldkey}."` ".$newhash{$expectedNewKey};
			$addComma=1;
			$alterCnt++;
			delete $newhash{$expectedNewKey};
			delete $oldhash{$oldkey};
			next;
			
		}
		if(!exists $newhash{$oldkey})
		{
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
			if($oldkey =~m/^{KEY}/)
			{
				$alterscript=$alterscript."DROP INDEX `".$namehash{$oldkey}."`";
			}
			elsif($oldkey=~m/^{FK}/)
			{
				push(@foreigns,"ALTER TABLE `$table` DROP FOREIGN KEY `$namehash{$oldkey}`;\n");
				next;
			}
			else
			{
				$alterscript=$alterscript."DROP `".$namehash{$oldkey}."`";
			}
			$addComma=1;
			$alterCnt++;
			next;
		}
	}
	my $lastcolname="";
	foreach(keys %newhash)
	{
# for each of the new keys/columns, if it's not present in oldhash, we add it, if present, we change it. Foreign Keys and Keys are treated separately. Foreign keys cannot be dropped and created and created in the same statement, so foreign keys, if needed are dropped separately, while creating the alter, the structure is such that keys are dropped first, then columns are added/changed, then keys are added, and then foreign keys are added
		my $newkey=$_;
		if($newkey eq "PK"  ||($newkey=~m/TABLE_TYPE/))
		{
			next;
		}
		if(!exists $oldhash{$newkey})
		{
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
			if($newkey=~m/^{FK}/)
			{
			push (@localFK,$newhash{$newkey});
				#$alterscript=$alterscript."ADD ".$newhash{$_};
				$addComma=0;
				$alterCnt++;
				next;
			}
                        if($newkey =~m/^{KEY}/) 
			{
				push (@localKEY,$newhash{$newkey});
				#$alterscript=$alterscript."ADD ".$newhash{$_};
				$addComma=0;
				$alterCnt++;
				next;
			}

			$alterscript=$alterscript."ADD ".$newhash{$newkey};
			if($lastcolname ne "")
			{
				$alterscript=$alterscript." AFTER $lastcolname";
			}
			
			if(!($newkey=~m/^{FK}/) && !($newkey =~m/^{KEY}/))
			{
				$lastcolname=$namehash{$newkey};
			}
			
			$addComma=1;
			$alterCnt++;
			next;
		}
		elsif($oldhash{$newkey} ne $newhash{$newkey})
		{
		
			
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
                        if($newkey =~m/^{KEY}/)
			{
				$alterscript=$alterscript."DROP INDEX `$namehash{$newkey}`";
				push (@localKEY,$newhash{$newkey});
				#$alterscript=$alterscript."ADD ".$newhash{$_};
				$addComma=1;
				$alterCnt++;
				next;
			}

			if($newkey=~m/^{FK}/)
			{
				push(@foreigns,"ALTER TABLE `$table` DROP FOREIGN KEY `$namehash{$newkey}`;\n");
				push (@localFK,$newhash{$newkey});
				#$alterscript=$alterscript."ADD ".$newhash{$_};
				#$addComma=1;
				$alterCnt++;
				next;
			}
			
			$alterscript=$alterscript."CHANGE  `$namehash{$newkey}` ".$newhash{$newkey};
			$addComma=1;
			$alterCnt++;
			if(!($newkey=~m/^{FK}/) && !($newkey =~m/^{KEY}/))
			{
				$lastcolname=$namehash{$newkey};
			}
			
			next;
		}
		
	}
		
		if($oldhash{"PK"} ne $newhash{"PK"})
		{
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
			my $newpk=$newhash{"PK"};
			if(defined($newpk))
			{
				$alterscript=$alterscript."ADD $newpk";
				$addComma=1;
			}
		}
		foreach(@localKEY)
		{
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
			if(defined($_))
			{
				$alterscript=$alterscript."ADD $_ ";
				$addComma=1;
			}
			
		}
		foreach(@localFK)
		{
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
			if(defined($_))
			{
				$alterscript=$alterscript."ADD $_ ";
				$addComma=1;
			}
		
		}
		
		if($oldhash{"TABLE_TYPE"} ne $newhash{"TABLE_TYPE"})
		{
			
#		print OUTPUTFILEHANDLE  "\n\n Table:$table \nold: ".$oldhash{"TABLE_TYPE"}."\n new: ".$newhash{"TABLE_TYPE"};
			
			if($addComma)
			{
#				$alterscript=$alterscript.",\n";
				$alterscript=$alterscript.", ";
				$addComma=0;
			}
			my $engine=$newhash{"TABLE_TYPE"};
			$alterscript=$alterscript."ENGINE = $engine";
			$addComma=1;
			$alterCnt++;
		}

		$alterscript=$alterscript.";\n";
		if($alterCnt ==0)
		{
			$alterscript="";
#			print OUTPUTFILEHANDLE ("# No alters for the table \"$table\"! \n");
		}
# 		system ("rm tempold");
# 		system ("rm tempnew");
		$alterscript=~s/\,\,/\,/g;
		return $alterscript;
}

#some "special cases" that cannot be detected by the script have to be written to a file after testing with the db. As of now this includes only the cases of foreign keys on MyISAM tables, this file contains sqls to drop those foriegn keys, these are written to the start of the alter script. The file is /bn/ivmsinstall/upgrade-specials.inf. However the filename can be specified as a parameter. Read the parameter details for proper argument.

sub getSpecials()
{
	open(FIN,"<$specials");
# 	print "\n Specials called \"$version\"\n";
	  my $spe="";
	  while(my $line=<FIN>)
	  {
		  chomp ($line);	
		  $line=~s/#VERSION //;
# 		  if($line=~m/VERSION/)
# 		  {
# 			  
# 			  $line=~s/#VERSION //;
# 			  $line="/home/saugata/alltablesalter/sql/bn.sql.#.ivms_server_".$line."\.sql";
# #			  print OUTPUTFILEHANDLE  "\n#got version \"$version\" and line \"$line\"\n";
# 		  }
  
 
		  if($version eq $line)
		  {
# 		  	print "matched to \"$line\"\n";
#		  	print OUTPUTFILEHANDLE  "\n#got a match \"$version\" and line \"$line\"\n";
			  while($line=<FIN>)
			  {
			  	chomp ($line);
			  	$line=~s/#VERSION //;
				  if($line eq $version)
				  {
# 				  	print "again matched to \"$line\"\n";
					  last;
				  }
				  $line=$line."\n";
				  $spe=$spe.$line;
			  }
		  }
	  }
	  close FIN;
# 	  print "spe returning with $spe";
	  return $spe;
}

###
### Generates the SQL statements to copy data from a table in newDB to the same table in oldDB
### this uses the upgrade.properties properties 
### tables.tocopy =<tablename1>,<tablename2>,<tablename3>, etc which is the list of tables for 
### which data is to be copied
### and
### columns.tocopy.<tablename>=<column1>,<column2>,<column3>,<column4> which is the list of 
### columns to be copied.
### The statement returned should look like a newline separated list of: 
### REPLACE INTO <oldDB>.<tablename>(<column1>,<column2>,<column3>,<column4>) SELECT
### <column1>,<column2>,<column3>,<column4> FROM <newDB>.<tablename>
### (The newDB database should not be dropped until after the upgrade is complete)
###

sub getDataSqls()
{
	
	my (%properties) = @_;
	
	my $tablestocopyref = $properties{'default.tables.tocopy'};
	my @tablestocopy ;
	if (ref($tablestocopyref) ne "ARRAY")
	{
		@tablestocopy=($tablestocopyref);
	}
	else
	{
		@tablestocopy=@$tablestocopyref;
	}
	
	my $sql="";
	foreach(@tablestocopy)
	{
		my $tablename=$_;
		my $columnsref = $properties{'default.columns.tocopy.'.$tablename};
		my @columnstocopy=();
		if (ref($columnsref) ne "ARRAY")
		{
			@columnstocopy=($columnsref);
		}
		else
		{
			@columnstocopy=@$columnsref;
		}
		
		my $columncnt = 0;
		my $columnlist = "";
		foreach(@columnstocopy)
		{
			if($columncnt>0)
			{
				$columnlist = $columnlist.",";
			}
			$columnlist = $columnlist.$_;
			$columncnt++;
			
		}

		
		$sql = $sql."REPLACE INTO $oldDB.$tablename (".$columnlist.") SELECT $columnlist from $newDB.$tablename ;\n";
	}
	return $sql;
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

sub getDynTableScr()
{
	my ($table)=@_;

	my $isDyn =0;
	foreach(@dynamic_tables)
	{
		
		if($table eq $_)
		{
			$isDyn = 1;
			last;
		}
	}
	


	
	if(!$isDyn)
	{
#  		print "return $table\n";
		return;
	}
	

		
	
		my $dyntableref = $renamehash{"default.dynamic.$table"};
		my @tables_new;
		if (ref($dyntableref) ne "ARRAY")
		{
			@tables_new=($dyntableref);
		}	
		else
		{
			@tables_new=@$dyntableref;
		}
		
		foreach(@tables_new)
		{
			my $curtable1 = $_;
			foreach(@partitions)
			{
# 				print "---\n";
				my $curPart = $_;
				my $newtable = 1;
				my $table_tmp = $curtable1."_$curPart";
# 				print "$table_tmp\n";
# 				print "$table_tmp   @oldtables\n\n"; 
				foreach(@oldtables)
				{	
					if($table_tmp eq $_)
					{
						$newtable = 0;
						last;
					}
				}
			
				my $curPart = $_;
				if($newtable)
				{
					
					my $scr="CREATE TABLE `$table_tmp` like $newDB.$table;\n";
# 					print "Created:: $scr\n\n\n";
					%alters=(%alters,($table_tmp=>$scr));
#  					print "CREATE\n$table_tmp\n\n$scr\n\n\n----\n";
				}
				else
				{
					my $scr = $alters{$table};
# 					print"$table\nORIGINAL\n$scr\n";
					$scr=~s/ALTER TABLE `$table` /ALTER TABLE `$table_tmp` /;
# 					print "Created::::::::: $scr\n\n\n";

					%alters=(%alters,($table_tmp=>$scr));
# 					print "ALTER\n$table_tmp\n\n$scr\n\n\n----\n";
				}
				
			}
		}		
	
	

}

$| = 1;

GetOptions( "User=s" => \$DB_User,
            "Password=s" => \$DB_Pwd,
	    "host=s" => \$HostName,
	    "port=s" => \$HostPort,
		"props=s" => \$props,
		"spe=s" => \$specials,
		"source=s" =>\$oldDB,
		"target=s" =>\$newDB,
		"outfile=s" =>\$outfile,
	    "version=s" => \$version,
		"conversiontype=s" => \$conversiontype
 );

sub help()
{
	
print "Utility for generating alter scripts between different versions of MySql iVMS databases
Version: 0.6

Usage:
./consolidatedalter.pl -User=<user name> -Password=<user password>  [-host=<hostname> default=localhost] [-port=<port number> default=3306] -props=<properties file> -spe=specialcasesfile -source=<old DB name> -target=<new DB name> -outfile=<outputfilename> -version=<source database version> -conversiontype=upgrade|downgrade\n";
	exit 1;
}

##
## Added the function generate triggers to generate the triggers in case of upgrade
##
sub generatetriggers()
{
   my ($dbh)=@_;
   my $trigger;
   my $event;
   my $table;
   my $statement;
   my $timing;
   my $created;
   my $sqlmode;
   my $definer;
   my $outputString;
   my $triggerOld;
   my $eventOld;
   my $tableOld;
   my $statementOld;
   my $timingOld;
   my $createdOld;
   my $sqlmodeOld;
   my $definerOld;
   my $outputStringOld;
   my @oldTriggers;

   if($isupgrade)
   {
      eval
      {
                  $dbh->do("use $oldDB");
         my $sth2=$dbh->prepare("show triggers");
         $sth2->execute();
         while(my ($triggerOld,$eventOld,$tableOld,$statementOld, $timingOld, $createdOld,$sqlmodeOld,$definerOld)=$sth2->fetchrow_array())
         {
           push(@oldTriggers,$triggerOld);
         }
         $dbh->do("use $newDB");
         my $sth1=$dbh->prepare("show triggers");
         $sth1->execute();
         $outputString=$outputString."delimiter // \n";
         while(my ($trigger,$event,$table,$statement, $timing, $created,$sqlmode,$definer)=$sth1->fetchrow_array())
         {
             # Check for the existance of the field trigger in array
             foreach(@oldTriggers)
             {
                if($trigger eq $_)
                {
                   $outputString=$outputString."drop trigger $trigger; \n";
                }
             }
             $outputString=$outputString."create trigger $trigger $timing $event on $table \n for each row $statement;// \n";
         }
         $outputString=$outputString."delimiter ; \n";
      };
      if($@)
      {
            print ("Generation of database triggers failed.  \n");
            exit 1;
      }
    }
   return $outputString;
}

if(! defined($HostName))
{
	$HostName="localhost";
}
if(! defined($HostPort))
{
	$HostPort="3306";
}
if(! defined($props) ||! defined($DB_User) ||! defined($oldDB)||! defined($newDB)||! defined($outfile)||! defined($version) ||! defined($conversiontype))
{
	help();
}
if(($conversiontype ne "upgrade") &&($conversiontype ne "downgrade"))
{
	print "Conversion type should be upgrade or downgrade";
	help();
}
if($conversiontype eq "upgrade")
{
	$isupgrade=1;
}

consolidatealters();
exit 0;
