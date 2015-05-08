package backup;
#Script for backing up current MySql data and table structures


sub BackupOneDB
{
	my ($ROOT_Password,$dbToBackup,$DataBackUpFile)=@_;
	print "This might take a long time, depending on the size of your database, please do not abort....\n";
	my $status = system(" mysqldump -u root --password=$ROOT_Password $dbToBackup > $DataBackUpFile ");
	if($status)
	{
		print "Unable to backup data for database $dbToBackup, continue only if you're sure that you do not want the existing data\n";
		return 1;
	}
	else
	{
		open (FILEHANDLE, "<$DataBackUpFile") or die "Can't backup data: $!";
		open (TMP, "+>>$DataBackUpFile.tmp")or die "Can't backup data: $!";
		seek FILEHANDLE, 0, 0;
		print TMP "CREATE DATABASE /*!32312 IF NOT EXISTS*/ \`$dbToBackup\` /*!40100 DEFAULT CHARACTER SET latin1 */;\n";
		print TMP "use $dbToBackup ;\n";
		while(<FILEHANDLE>)
		{
			print TMP "$_";
		}
		close(FILEHANDLE);
		close(TMP);
		system ("mv $DataBackUpFile.tmp $DataBackUpFile");
		return 0;
	}
}


sub BackupAllDatabases
{
	my ($ROOT_Password,$TotalBackUpFile)=@_;
	print "This might take a long time, depending on the size of your database, please do not abort....\n";
	my $status = system(" mysqldump -u root --password=$ROOT_Password --all-databases > $TotalBackUpFile ");
	if($status)
	{
		print "Unable to backup data, continue only if you're sure that you do not want the existing data\n";
		return 1;
	}
	print "Successfully backed up data.\n";
	return 0;
}

return 1;
 
