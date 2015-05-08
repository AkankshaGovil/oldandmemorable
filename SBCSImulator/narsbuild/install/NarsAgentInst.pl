#!/usr/bin/perl

##
## NarsAgentInstall
##

## Hello, I am..
$Self = "NarsAgentInst";
$SelfVersion = "v0.1, 10/20/02";

## This is what I do...
$Product = "NARS";
$BaseDir = "narsagent";
$RootDir = "/opt/$BaseDir";
$LocalPkg = "$RootDir/NexTone";
$RootDirLib = "$RootDir/lib";
$ISRootDir = "/usr/local/nextone";
$ISRootDirEtc = "$ISRootDir/etc";
$ISRootDirBin = "$ISRootDir/bin";
$ISRootDirLib = "$ISRootDir/lib";

# name of shell script to restart narsagent in case of unexpected termination 
my $NarsCheckScript = "narspm" ;

my $ff_install = 0;

my $MC = `uname`;
chomp($MC);
$NAMediaFile = `arch`;
chomp($NAMediaFile);
#if ($MC eq "Linux")
#{
#	$NAMediaFile=`rpm -q glibc|cut -d- -f2|cut -d. -f1,2`;
#	if ($NAMediaFile eq "2.0")
#	{
#		$NAMediaFile = "libc20";
#	} elsif ($NAMediaFile eq "2.1")
#	{
#		$NAMediaFile = "libc21";
#	} else
#	{
#		$NAMediaFile = "libc22";
#	}
#}
$NAMediaFile .= ".rsmagent-install.tar";
$NA_INIT_FILE = "/etc/init.d/nextoneNarsAgent";
if ($MC eq "Linux")
{
	$NA_ETC_START_FILE = "/etc/init.d/rc3.d/S99nextoneNarsAgent";
	$NA_ETC_KILL_FILE = "/etc/init.d/rc0.d/K99nextoneNarsAgent";
} else {
	# for solaris this is a different path
	$NA_ETC_START_FILE = "/etc/rc3.d/S99nextoneNarsAgent";
	$NA_ETC_KILL_FILE = "/etc/rc0.d/K99nextoneNarsAgent";
}
$Unpack = "tar xf ";
$TmpDir = "/tmp/.nainst";
$NAINDEX = ".naindex";
$RootDirResp = $RootDir;
$AgentDirectoryStr = "NarsAgentDirectory";


require 5.6.0;

use Getopt::Std;


sub GetResponse ()
{
	print "Hit <CR> to continue...\n";
	$resp = <>;
}

sub GetSpecialResponse ()
{
	print "Hit <CR> to continue. (OR) <Ctrl-C> to abort..\n";
	$resp = <>;
}


sub PrintHelpMessage ()
{
	print "$Self version $SelfVersion\n";
	print "$Self -v -h \n";
	print "$Self -i  to install \n";
	print "$Self -d  to uninstall \n";
	print "$Self -u  to upgrade\n";
	
	exit 0;
}


##
## Privilege check.
##
sub CheckForSuperuser ()
{
	###########################
	## Must be root
	###########################
    my $logname = `/usr/bin/id -u -n`;
    chomp $logname;
	if ( "$logname" ne "root" )
	{
		print "\nYou must be super-user to run this script.\n";
		print "Exiting....\n ";
		exit 2;
	}
}



##
## Install
##
sub InstallPackage (;$)
{
	my ($cfgdir) = @_;

	# Must be privileged.
	CheckForSuperuser ();

	$StartDir = `pwd`;
	chop $StartDir;

#   Croaks for Linux when no MSW present
#	if (!( -d $ISRootDir )) {
#		die "You need to install iServer Core Package first.\n";
#	}
	## Get name of rootdir

	if (!$ff_install) {
		print "Enter directory to install [$RootDirResp] :";
		# Read..
		chop($resp = <>);
		if ($resp ne "") {
			$RootDirResp = $resp;
		}
	}
	if ($RootDir ne "$RootDirResp") {
		$RootDir = "$RootDirResp/$BaseDir";
		$LocalPkg = "$RootDir/NexTone";
		$RootDirLib = "$RootDir/lib";
	}

my $targetLinksep ="";
my $originalPath=$RootDir;
my $upgrade_flag =0; 
my $targetLink="";
my $defaultLocation="/opt/narsagent";
if ($cfgdir ne "" and $RootDir ne $defaultLocation ) {

$targetLink=`readlink $RootDir`;
chomp($targetLink);
#need to add logic for if targetlink null --Done
if( $targetLink ne ""){
	$upgrade_flag =1;
	$RootDir=$targetLink;
	$LocaDirLib = "$RootDir/lib";
	my $sep="/";
	$targetLinksep = $targetLink  . $sep ;
}
}

#special handling for upgrade from 5.x to 6.x
if(!$upgrade_flag){
	$targetLinksep = $RootDir;
}

	if (!$ff_install) {
		if ( -d $targetLinksep ) {
			chdir $RootDir or die "Unable to cd to $RootDir: $! \n";
			if (-f $NAINDEX) {
				$naindex = `cat $NAINDEX`;
				chop $naindex;
				print "Detected existing version $naindex of RSM Agent Package \n";
				print "Perhaps you need to upgrade...\n";
				sleep 1;
				## Continue installation?
				print "Continue Installation ? [<y>/n] : ";
				chop($resp = <>);
				die "Aborting installation... \n" 
					unless ($resp eq "" or $resp eq 'y' or $resp eq 'Y');
			}

		}

		print "Proceeding to install RSM Agent Package. \n";

		while ( 1 )
		{
			## Get name of mediafile
			print "Enter mediafile [$NAMediaFile] :";

			# Read..
			chop($resp = <>);
			if ($resp ne "") {
				$NAMediaFile = $resp;
			}

			if ( -f "$StartDir/../$NAMediaFile" ) {
				last;
			} else {
				print "No such file: $NAMediaFile\n";
			}
		}
	}

	## Go back to where we started from..and more
	chdir "$StartDir/..";

	## Copy to temporary space.
	if ( ! -d $TmpDir) {
		mkdir ($TmpDir, 0777);
	}

	$status = system ("cp -p $NAMediaFile $TmpDir");
	if ($status) {
		print "cp : $status \n";
	}

	chdir $TmpDir;

	## Extract the archive.
	$status = system ("$Unpack $NAMediaFile");
	if ($status) {
		print "$Unpack : $status \n";
	}

	$NAVersion = `cat $NAINDEX`;
	chop $NAVersion;
	print "\nInstalling RSM Agent Package $NAVersion \n";
	if ($naindex eq $NAVersion)
	{
		print "$NAVersion is already installed \n";
        # in SWM upgarde, always return 0 if installed already
        if ( $SWMF == 0 )
        {
		    GetSpecialResponse();	
        } else {
            return 0;
        }
	}


	##
	## Go through the steps.
	##
	$RootDirAct = "$RootDir-$NAVersion";
	$status = system ("rm -rf $RootDirAct");
	if (! -d "$RootDirAct" ) {
		mkdir "$RootDirAct" 
			or die "Cannot create $RootDirAct directory: $!\n";
	}

	chdir "$RootDirAct/..";
	$status = system ("rm -rf $BaseDir");
	symlink("$BaseDir-$NAVersion", $BaseDir)
		or die "Cannot link $BaseDir to $BaseDir-$NAVersion: $!\n";

	chdir "$RootDirAct";
	symlink("/usr/bin/perl", "perl")
		or die "Cannot link perl to /usr/bin/perl: $!\n";

	## Create the 'NexTone' subdirectory, 'lib' subdirectory.
	if ( ! -d $LocalPkg) {
		mkdir ($LocalPkg, 0755);
	}

	## Copy the stuff over to the narsagent directory 
	my @files;

	$ProdVersion = "$Product-$NAVersion";

	chdir "$TmpDir/$ProdVersion" or die "Unable to cd to $ProdVersion: $!\n";

	
	&replaceFileString( "$TmpDir/$ProdVersion/nextoneNarsAgent", $AgentDirectoryStr, $RootDir);
	## Copy the system files 
	$status = system("mv -f $TmpDir/$ProdVersion/nextoneNarsAgent $NA_INIT_FILE");
	if ($status) {
		print "Error in moving file nextoneNarsAgent to $NA_INIT_FILE\n";
	}
	
	
        if (! -f $NA_ETC_START_FILE)
	{
		$status = system("link $NA_INIT_FILE $NA_ETC_START_FILE");
		if ($status) {
			print "Error in linking $NA_INIT_FILE to $NA_ETC_START_FILE\n";
		}
	}
	if(! -f $NA_ETC_KILL_FILE)
	{
		$status = system("link $NA_INIT_FILE $NA_ETC_KILL_FILE");
		if ($status) {
			print "Error in linking $NA_INIT_FILE to $NA_ETC_KILL_FILE\n";
		}
	}

	## .* matches all the hidden files 
	## first two entries are . and ..  because of the sorting order
	## * matches all the non-hidden files
	@files = glob(".* *");
	shift @files; 				#remove .
	shift @files; 				#remove ..

	$status = system ("cp -Rp @files $RootDir");
	if ($status) {
		print "Error in copying files to $RootDir \n";
	}

	## clean up some -- remove lib files.
	$status = system ("rm -rf $RootDir/lib*");
	if ($status) {
		print "Error in partial cleanup...\n";
	}

	if ( ! -d $RootDirLib ) {
		mkdir ($RootDirLib, 0755);
	}


	@files = glob ("lib*");

	$status = system ("cp -Rp @files $RootDirLib");
	if ($status) {
		print "Error in copying files to $RootDirLib \n";
	}
	else {
		my $prevdir = `pwd`;
		chop $prevdir;
		chdir $RootDirLib;
		my $f;

		foreach $f (@files)
		{	
			
			if ($f =~ /.tar/){

				$status = system ("$Unpack $f ");
			}
		}

		chdir $prevdir;
	}
		

	## Copy other files to $RootDir.
	chdir "..";
	@files = glob (".*index");

	$status = system ("cp -p $NAINDEX $RootDir");
	if ($status) {
		print "Error in copying files over \n";
	}
	
	                                                                                                                                                      
            ##installing rpms for perl-DBD-mysql start                                                                                                
                                                                                                                                                      
       $status = system("rpm -i --test --nodeps  $TmpDir/$ProdVersion/libmysqlclient16-5.1.36-6.7.2.x86_64.rpm  > /dev/null 2>&1 ");                  
       if(!$status){                                                                                                                                  
       print "installing $TmpDir/$ProdVersion/libmysqlclient16-5.1.36-6.7.2.x86_64.rpm \n";                                                           
                                                                                                                                                      
        $status = system("rpm -i --nodeps $TmpDir/$ProdVersion/libmysqlclient16-5.1.36-6.7.2.x86_64.rpm");                                            
         if($status){                                                                                                                                 
                 print "Error installing $TmpDir/$ProdVersion/libmysqlclient16-5.1.36-6.7.2.x86_64.rpm \n";                                           
         }                                                                                                                                            
       else{                                                                                                                                          
         print "installed $TmpDir/$ProdVersion/libmysqlclient16-5.1.36-6.7.2.x86_64.rpm successfully \n";                                             
       }                                                                                                                                              
                                                                                                                                                      
                                                                                                                                                      
       }else{                                                                                                                                         
                                                                                                                                                      
       print "$TmpDir/$ProdVersion/libmysqlclient16-5.1.36-6.7.2.x86_64.rpm is already installed \n";                                                 
       }                                                                                                                                              
                                                                                                                                                      
       $status = system("rpm -i --test --nodeps $TmpDir/$ProdVersion/perl-Data-ShowTable-3.3-707.3.x86_64.rpm  > /dev/null 2>&1");                    
         if(!$status){                                                                                                                                
         print "installing $TmpDir/$ProdVersion/perl-Data-ShowTable-3.3-707.3.x86_64.rpm \n";                                                         
                                                                                                                                                      
          $status = system("rpm -i --nodeps $TmpDir/$ProdVersion/perl-Data-ShowTable-3.3-707.3.x86_64.rpm");                                          
         if($status){                                                                                                                                 
                 print "Error installing $TmpDir/$ProdVersion/perl-Data-ShowTable-3.3-707.3.x86_64.rpm \n";                                           
         }                                                                                                                                            
       else{                                                                                                                                          
         print "installed $TmpDir/$ProdVersion/perl-Data-ShowTable-3.3-707.3.x86_64.rpm successfully \n";                                             
       }                                                                                                                                              
                                                                                                                                                      
         }else{                                                                                                                                       
                                                                                                                                                      
         print "$TmpDir/$ProdVersion/perl-Data-ShowTable-3.3-707.3.x86_64.rpm is already installed \n";                                               
         }                                                                                                                                            
                                                                                                                                                      
       $status = system("rpm -i --test $TmpDir/$ProdVersion/perl-DBD-mysql-4.012-2.1.x86_64.rpm  > /dev/null 2>&1 ");                                  
         if(!$status){                                                                                                                                
               print "installing $TmpDir/$ProdVersion/perl-DBD-mysql-4.012-2.1.x86_64.rpm \n";                                                        
                                                                                                                                                      
               $status = system("rpm -i --nodeps $TmpDir/$ProdVersion/perl-DBD-mysql-4.012-2.1.x86_64.rpm");                                          
               if($status){                                                                                                                           
                               print "Error installing $TmpDir/$ProdVersion/perl-DBD-mysql-4.012-2.1.x86_64.rpm \n";                                  
                       }                                                                                                                              
                       else{                                                                                                                          
                       print "installed $TmpDir/$ProdVersion/perl-DBD-mysql-4.012-2.1.x86_64.rpm successfully\n";                                     
               }                                                                                                                                      
                                                                                                                                                      
         }else{                                                                                                                                       
                                                                                                                                                      
                       print "$TmpDir/$ProdVersion/perl-DBD-mysql-4.012-2.1.x86_64.rpm is already installed \n";                                      
         }                                                                                                                                            
                                                                                                                                                      
                                                                                                                                                      
                                                                                                                                                      
         ##installing rpms for perl-DBD-mysql end                                                                                                     
                                                                                                                                                      
         

	if (!$ff_install) {
		print "Do you want to start narsagent on boot? [<y>/n] \n";
		chomp($resp = <>);
		if ($resp eq "" or $resp eq 'y' or $resp eq 'Y') {
			$status = system("touch $RootDir/.boot");
			if ($status) {
				print "Couldn't create $RootDir/.boot \n";
			}
		}
	}
	else {
		$status = system("touch $RootDir/.boot");
		if ($status) {
			print "Couldn't create $RootDir/.boot \n";
			exit 1;
		}
	}


	&addNarsCronJob(); 
	# Copy the configuration files before /act files are executed
	# Copy the configuration files back if required
	if (defined($cfgdir)) {
		print "Restoring Configuration files from previous version\n";
		print "Could not locate saved configuration file directory $cfgdir\n"
			unless ( -d $cfgdir );
		my @cfgfiles = glob("$cfgdir/*");
		print "Could not copy configuration files back\n" 
			if system("cp -p @cfgfiles $RootDir");
		print "Could not remove $cfgdir. Please remove it manually \n"
			if system("rm -rf $cfgdir");
	}

	##
	## ACTIONs come here.
	##
	my @actfiles;

	chdir "$TmpDir/$ProdVersion" or die "Unable to cd to $ProdVersion: $!\n";
	@actfiles = glob ("*.act");
	$ENV{BASE}=$RootDir;
	if ($ff_install) {
		$ENV{'FF_INSTALL'}=1;
	}
	else {
		$ENV{'FF_INSTALL'}=0;
	}
    if ( $SWMF ) {
        $ENV{'SWM_INSTALL'}=1;
    }
    else {
        $ENV{'SWM_INSTALL'}=0;
    }
	foreach $f (@actfiles) {
		if ( $f =~ m/(\w+)\.act$/ ) {
			$pname = $1;
			print "Installing module $pname ...\n";
			$status = system ("./$f -d $RootDir");
		}
		else {
			print "Unknown package $f \n";
		}
	}

	##
	## Go out and post-process the files appropriately.
	##
	chdir $StartDir;

	##	ToBeDone
	##	$result = `perlcheck.pl`;


	##
	## Clean up.
	##
	chdir "/tmp";
	$status = system ("rm -rf $TmpDir");
	if (-d "/usr/local/narsagent/"){
        	$status = system ("chown -fhR root:root /usr/local/narsagent/*");
		$status = system("ln -s /usr/local/narsagent /opt/narsagent ");
	}
	print "Successfully installed package!! \n";

}


##
## Uninstall's package.
##
sub UninstallPackage (;$)
{

	my ($cfgdir) = @_;
	my (@cfgfiles);

	# Must be privileged.
	CheckForSuperuser ();

	$StartDir = `pwd`;
	chop $StartDir;
	if (!$ff_install) {
		print "Enter current agent directory [$RootDir] :";

		# Read..
		chop($resp = <>);
		if ($resp ne "") {
			$RootDirResp = $resp;
			$RootDir = "$resp/$BaseDir";
			$LocalPkg = "$RootDir/NexTone";
			$RootDirLib = "$RootDir/lib";
		}
	}


my $targetLinksep ="";
my $originalLocation="";
my $targetLink="";
my $upgrade_flag =0;
my $defaultLocation="/opt/narsagent";
##########
	if ($cfgdir ne "" and $RootDir ne $defaultLocation) {
		 $upgrade_flag = 1;
		$originalLocation=$RootDir;
		$targetLink=`readlink $RootDir`;
		#my $slashIndex  = index($targetLink, '/');
		#if ( $slashIndex ne 0){
		#	$targetLink=$RootDirResp . $targetLink;
			
		#}
		chomp($targetLink);
		if( $targetLink ne ""){
			#my $slashIndex  = index($targetLink, '/');
                        #if ( $slashIndex ne 0){
                         #       $targetLink=$RootDirResp . "/" . $targetLink;

                        #}
			my $lastSlashIndex = rindex($targetLink,'/')	;
			#my $targetLinkLen = length($targetLink);
			#my $narsFile= substr($targetLink,
			my $absLink_flag=-1;

			 my $targetLinkLen = length($targetLink);
			
			if( $lastSlashIndex eq  $targetLinkLen - 1 ){
				$lastSlashIndex = rindex($targetLink,'/',$lastSlashIndex -1)    ;
				if( $lastSlashIndex ne -1){
					my $narsFile= substr($targetLink,$lastSlashIndex + 1,$targetLinkLen);
                        		$absLink_flag = index($narsFile,'-');

				}else{
					$lastSlashIndex=$lastSlashIndex + 1;
                        		my $narsFile= substr($targetLink,$lastSlashIndex,$targetLinkLen);
                        		$absLink_flag = index($narsFile,'-');

				}	
			}else{

			$lastSlashIndex=$lastSlashIndex + 1;
                        my $narsFile= substr($targetLink,$lastSlashIndex,$targetLinkLen);
			$absLink_flag = index($narsFile,'-');


			}
			if ($absLink_flag eq   -1 ){
				$RootDir=$targetLink;
			}
			$LocalPkg = "$RootDir/NexTone";
			$RootDirLib = "$RootDir/lib";
			my $slashIndex  = index($targetLink, '/');
                        if ( $slashIndex ne 0){
                                $targetLink=$RootDirResp . "/" . $targetLink;

                        }

			my $sep="/";
			$targetLinksep = $targetLink  . $sep ;
			#my $slashIndex  = index($targetLink, '/');
                	#if ( $slashIndex ne 0){
                        #	$targetLink=$RootDirResp . "/" . $targetLink;

                	#}

		}
	}

#special handling for upgrade from 5.x to 6.x
if(!$upgrade_flag){
 $targetLinksep = $RootDir;
 if( $RootDir eq "/usr/local/narsagent"){
	my $targetLink=`readlink $RootDir`;
	chomp($targetLink);
	if($targetLink eq "/opt/narsagent"){
		$RootDir="/opt/narsagent";
 	}
}
}

	if ( -d $targetLinksep ) {
		chdir $RootDir or die "Unable to cd to $RootDir: $! \n";

		## Read .NAindex
		$NAindex = `cat $NAINDEX`;
		chop $NAindex;

		$NARSCoreVersion = $NAindex;

		print "Detected existing RSM Agent Package $NARSCoreVersion \n";

		#removing cron job before stopping both processes 
		&removeNarsCronJob();		

                print "Stopping RSM Agent...\n";
                system("./narsagent all stop");

		if (defined($cfgdir)) {
			print "Saving Configuration files \n";
			mkdir $cfgdir unless ( -d $cfgdir );
			if (-f './.cfgfiles') {
				@cfgfiles = split("\n", `cat ./.cfgfiles`);
			}
			else {
				print "Can't find a list of configuration files \n";
				print "Saving - nars.cfg, nars.lastseen \n";
				push @cfgfiles, 'nars.cfg', 'nars.lastseen';
			}
                        # save any .xml files (cdr streaming config)
                        push @cfgfiles, glob("*.xml");
			for $file (@cfgfiles) {
				system("cp -p $file $cfgdir/$file 2> /dev/null");
			}
		}

		if (!$ff_install) {
			print "Save the previous installation ? [y/<n>] : ";
			chop($resp = <>);
		}

        # in SWM upgarde, always leave the previous installation untouched
        if ( $SWMF == 1 )
        {
            $resp = "y";
        }

                if ($resp eq "" or $resp eq "n" or $resp eq "N") {

                    print "Proceeding to remove the RSM Agent Package. \n";

                    ## Change to the root directory
                    chdir $RootDir;

                    $status = system ("rm -rf $LocalPkg");
                    if ($status) {
			print "Error removing files in $LocalPkg \n";
                    }

                    $status = system ("rm -rf $RootDirLib");
                    if ($status) {
			print "Error removing files in $RootDirLib \n";
                    }

                    ## Following lines are not needed
                    ## Remove our index file also.
                    ##$status = system ("rm -f $NAINDEX");

                    ## Come back to our starting point.
                    chdir $StartDir;

                    ## Remove the nars-agent root directory
                    $status = system ("rm -rf $RootDir $RootDir-$NAindex");
                    if ($status) {
			print "Error removing files in $RootDirLib \n";
                    }

                    # Remove the system files
		    if (-f $NA_ETC_START_FILE) {
	                $status = system("rm -f $NA_ETC_START_FILE");
         	        if ($status) {
			        print "Error deleting $NA_INIT_FILE to $NA_ETC_START_FILE\n";
		         }
                    }
                    if (-f $NA_ETC_KILL_FILE) {
	                  $status = system("rm -f $NA_ETC_KILL_FILE");
        	 	  if ($status) {
			        print "Error deleting $NA_INIT_FILE to $NA_ETC_KILL_FILE\n";
		          }

                      }
                    if (-f $NA_INIT_FILE) {
			$status = system ("rm -f $NA_INIT_FILE");
			if ($status) {
				print "Error removing $NA_INIT_FILE\n";
			}
                    }
                }
                else
                {
                    ## Come back to our starting point.
                    chdir $StartDir;

                    ## Remove the nars-agent root directory
                    system ("rm -rf $RootDir");
                }
		
		##remove the softlink if exist from the original location
		#chdir $originalLocation;
		#print "original location =$originalLocation";
		#my $pwd=`pwd`;
		#print "pwd=$pwd";
		
		# remove two links, special handling for upgrade from 5.x to 6.x.
		my $defaultLocation="/opt/narsagent";
		if( $cfgdir ne "") {
			$upgrade_flag=1;
		}
		my $usrLink = `readlink /usr/local/narsagent`;
		chomp($usrLink);
		if (!$upgrade_flag and $RootDir eq $defaultLocation and $usrLink eq "/opt/narsagent" ){
			##$status = system ("rm -rf $originalPath-$NAVersion");
            #if ($status) {
				#print "Error removing files in $originalPath-$NAVersion \n";
           # }
			
		$status = system ("rm -rf /usr/local/narsagent");
            if ($status) {
				print "Error removing files in $originalPath \n";
            }
                }

		print "Uninstall successful.\n";

	}
	else {
        # in SWM upgarde, always return 0 if not installed yet
        if ( $SWMF == 0 )
        {
		    die "You need to install RSM Agent Package first.\n";
        } else {
		    print "RSM Agent Package is not installed.\n";
            return 0;
        }
	}

}

sub replaceFileString() {
	my ($file, $str, $val) = @_;
        my $fileTmp = $file.".tmp";
        open IN, "<$file";
        open OUT, ">$fileTmp";
        my $line;
        while($line = <IN>)
        {
                if($line !~m/$str/)
                {
                        print OUT "$line";
                }
                if($line =~m/$str/)
                {
                        $line =~s/$str/$val/;
                        print OUT "$line";
                }
        }
        close IN;
        close OUT;
        my $status = system("cp $fileTmp $file");
        my $status = system("rm -f $fileTmp");

}

#function to add cron job for starting narsagent in case of unexpected termination
sub addNarsCronJob () {
	my $tmpCronFile="oldcrontab";
	my $CronJobSearchString = "./$NarsCheckScript";
	my $CronJobScriptString = " ( cd $RootDir; ./$NarsCheckScript >> /var/log/$NarsCheckScript.log 2>&1 ) ";
	# cron job string to be appended to the cron file
	my $CronJobString = "0-59/5 * * * * $CronJobScriptString ";
	# remove any duplicate jobs running the same script
	my $status=system ( "crontab -l | grep -v \"$CronJobSearchString\" >$tmpCronFile"); 
	# remove comments from temporary cron file created
	system (" sed -i \'\/DO NOT EDIT THIS FILE - edit the master and reinstall\/d\' $tmpCronFile");
  	system (" sed -i '/installed on/d' $tmpCronFile");
  	system ("sed -i '/Cron version/d' $tmpCronFile");
	# add the new job to the cron file 
	$status=system (" echo \"$CronJobString\" >>$tmpCronFile ");
	# reload the crontab
	$status=system (" crontab $tmpCronFile" );
	$status=system ("/etc/init.d/cron reload > /dev/null 2>&1 & ");
	# remove the temporary file
	system ("rm -f $tmpCronFile ");
}

#function to remove cron job for starting narsagent in case of unexpected termination
sub removeNarsCronJob () {
	my $tmpCronFile="oldcrontab";
	my $CronJobSearchString = "./$NarsCheckScript";
	# remove the cronjob entry from the cron file
	my $status=system ( "crontab -l | grep -v \"$CronJobSearchString\" >$tmpCronFile"); 
	# remove comments from temporary file 
	system (" sed -i \'\/DO NOT EDIT THIS FILE - edit the master and reinstall\/d\' $tmpCronFile");
  	system (" sed -i '/installed on/d' $tmpCronFile");
  	system ("sed -i '/Cron version/d' $tmpCronFile");
	# reload the crontab
	$status=system (" crontab $tmpCronFile" );
	$status=system ("/etc/init.d/cron reload > /dev/null 2>&1 & ");
	#remove the temporary file created
	system ("rm -f $tmpCronFile");
	system ("rm -f /var/log/$NarsCheckScript.log");
}

##
## Main
##

if (! @ARGV) {
	PrintHelpMessage ();
}

getopts ("adiuhvst");

# option '-a' for doing SWM upgarde
if ($opt_a) {
    #SWM: Upgrade
	$ff_install = 1;
    $SWMF = 1;
	my $tmpcfgdir = "/tmp/$Product-cfgfiles";

	print "Uninstalling RSM Agent package.\n";
	UninstallPackage ($tmpcfgdir);
    print "Uninstalling NARS package ends.\n";

	print "\nInstalling RSM Agent package.\n";
	InstallPackage ($tmpcfgdir);
	system("daemonize $NA_INIT_FILE start");
	print "Installing NARS package ends.\n";
}

if ($opt_s) {
	#Fast Forward: Installation
	$ff_install = 1;
	open(STDOUT, ">>/var/log/rsmAgentInstall.out");
	open(STDERR, ">>/var/log/rsmAgentInstall.err");
	my $msg = "\n\n========\n".`date`."Installation starts.\n";
	print STDOUT $msg;
	print STDERR $msg;

	InstallPackage ();

	system("daemonize $NA_INIT_FILE start");

	my $msg = `date`."Installation ends.\n========\n\n";
	print STDOUT $msg;
	print STDERR $msg;
}

if ($opt_t) {
	#Fast Forward: Uninstallation
	$ff_install = 1;
	open(STDOUT, ">>/var/log/rsmAgentInstall.out");
	open(STDERR, ">>/var/log/rsmAgentInstall.err");
	my $msg = "\n\n========\n".`date`."Uninstallation starts.\n";
	print STDOUT $msg;
	print STDERR $msg;

	UninstallPackage ();

	my $msg = `date`."Uninstallation ends.\n========\n\n";
	print STDOUT $msg;
	print STDERR $msg;
}

if ($opt_d) {
	print "Uninstalling RSM Agent package. \n";

	GetResponse ();

	UninstallPackage ();
}

if ($opt_i) {
	print "\nInstalling RSM Agent package. \n";
	GetResponse ();

	InstallPackage ();

}

if ($opt_u) {
	print <<eEOF

Upgrading the RSM Agent Package involves uninstalling
the existing package and installing the new RSM Agent package.

If this is what you want to do, press <CR> to continue.
Otherwise, press <Ctrl-C> to abort.

eEOF
;
	GetSpecialResponse ();

	print "Uninstalling RSM Agent package. \n";
	my $tmpcfgdir = "/tmp/$Product-cfgfiles";

	UninstallPackage ($tmpcfgdir);

	print "\nInstalling RSM Agent package. \n";
	GetResponse ();
	InstallPackage ($tmpcfgdir);
}

if ($opt_h) {
	PrintHelpMessage ();
}

if ($opt_v) {
	print "$Self version $SelfVersion\n";
}


exit 0;

