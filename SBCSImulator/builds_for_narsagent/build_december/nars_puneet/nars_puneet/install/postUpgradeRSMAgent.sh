#!/bin/bash


## This script searches and restores the narsagent installations after successful SBC upgrade from 5.x release to 6.x or above.
## This script determines the folders to be searched for previous narsagent installations which are to be restored from
## /sbc60upgrade/script/env.cfg file. It assumes that Linux updater takes  backup of entire partition / and /var in  directories  name "old-root"
## "old-var" respectively.
##  This script reads variables "VAR_BACKUP_DIR" and "ROOT_BACKUP_DIR" for the location of "old-var" and "old-root" folders and determines the search directories ( <VAR_BACKUP_DIR>/old-var & <ROOT_BACKUP_DIR>/old-root ) to be searched for narsagent installation.
## searched for narsagent installations 
## The script searches for the directories containing  ".naindex" file. The script differentiates between the actual narsagent installation and narsagent build folder by checking the existance of "*rsmagent.tar" file. Once all the narsagent installations are found from the search directories, firstly  script copies narsagent installation from the backup directory (i.e. <VAR_BACKUP_DIR>/old-var for previous narsagent installations /var ) to the corresponding folders (i.e./var) in new system. After all the narsagents are copied to thier respective folders in new systems, the script creates/establishes appropriate links as it was in previous system.
## 
##

currentPWD=`pwd`;
## Log file
if [ -d "/var/log" ];then
 
	LOG_FILE="/var/log/postUpgradeRSMAgent_"`date +%d_%m_%y_%H_%M_%S`".log"
else
	LOG_FILE="postUpgradeRSMAgent_"`date +%d_%m_%y_%H_%M_%S`".log"
fi

echo "Restore logs are available in $LOG_FILE " | tee -a $LOG_FILE;

## check current os version to decide the location of env.cfg file

currentOSVersion=`gbversion | grep -i "GENBAND GBLinux"| cut -d' ' -f3 | cut -d'-' -f1 |cut -d'.' -f1`;

if [ $? -ne 0 ];then
	echo "Failed to determine OS version. Failed to locate the env.cfg file." | tee -a $LOG_FILE
	echo "Aborting Restore" | tee -a $LOG_FILE
	exit 2;
fi



echo "Current OS version =$currentOSVersion " >>  $LOG_FILE

if [ $currentOSVersion -gt 6 ];then
	ENVLOCATION="/sbcupgrade/script/env.cfg"
else
	ENVLOCATION="/sbc60upgrade/script/env.cfg"

fi

#ENVLOCATION="/sbc60upgrade/script/env.cfg"

echo "Reading env variables from file $ENVLOCATION" >>  tee -a $LOG_FILE

## Getting the folder /var backup 
VAR_OLDLOCATION="$(sed '/^\#/d' "$ENVLOCATION" | grep 'VAR_BACKUP_DIR'  | tail -n 1 | sed 's/^.*=//')"
echo "var old location=$VAR_OLDLOCATION " >> $LOG_FILE;

## Getting the folder / backup
ROOT_OLDLOCATION="$(sed '/^\#/d' "$ENVLOCATION" | grep 'ROOT_BACKUP_DIR'  | tail -n 1 | sed 's/^.*=//')"
echo "root old location=$ROOT_OLDLOCATION" >> $LOG_FILE;

rootSearchDir="/old-root";
varSearchDir="/old-var";

rootBackupDirName[0]="old-root"
rootBackupDirName[1]="old-var"


restorePathParent[0]=""
restorePathParent[1]="/var"

searchDir[0]=$rootSearchDir
if [ "$ROOT_OLDLOCATION" != "/" ];then
	searchDir[0]="$ROOT_OLDLOCATION""${searchDir[0]}"
fi

searchDir[1]=$varSearchDir
if [ "$VAR_OLDLOCATION" != "/" ];then
	searchDir[1]="$VAR_OLDLOCATION""${searchDir[1]}"

fi


searchFailCount=0
for i in $(seq 0 1);
do
        if [ ! -d ${searchDir[$i]}  ];then
                echo "Backup Directory ${searchDir[$i]} doesn't exists" | tee -a $LOG_FILE
                searchFailCount=`expr $searchFailCount + 1`
        fi
done

if [ $searchFailCount -eq ${#searchDir[@]} ];then
	echo "" >> $LOG_FILE
	echo "No Backup directory exists, Aborting the restore process" | tee -a $LOG_FILE
	echo "" >> $LOG_FILE
	exit 1;
fi



echo""
echo "*******************************************************************************************" >> $LOG_FILE
echo "Previous RSMAgent Installations are stored at locations:" >>   $LOG_FILE;
for i in $(seq 0 1);
do 
	echo "$i)" "${searchDir[$i]}" >> $LOG_FILE
done


for counter in $(seq  0 1);
do 


	echo "" >> $LOG_FILE
	echo "****************************************************************************" >>  $LOG_FILE
	echo "" >> $LOG_FILE


	echo "Searching RSMAgent Installations in "${searchDir[$counter]}""    >>    $LOG_FILE;
	echo"" >> $LOG_FILE

	narsagentBackup=`find -L "${searchDir[$counter]}" -type f -name .naindex 2>/dev/null | sed 's/''\/.naindex*$//'`
	if [ "${narsagentBackup[@]}" != "" ];then
		echo " RSMAgent installations found in ${searchDir[$counter]}" | tee -a $LOG_FILE
		echo "" >> $LOG_FILE
		echo "${narsagentBackup[@]}" >>  $LOG_FILE
		echo"" >> $LOG_FILE
	else
		echo "" >> $LOG_FILE
 		echo "No RSMAgent installations found in ${searchDir[$counter]}" | tee -a $LOG_FILE
		echo"" >> $LOG_FILE
		continue;
	fi

	echo "*****************************************************************************"   >>  $LOG_FILE

	unset linkNarsagentFileArray

	 

	index=0
	for backupFile in $narsagentBackup;
	do
		
		backupFileParent="$(echo $backupFile | sed 's/narsagent.*//'| sed -e "s/\/*$//")"
		 startval=`expr length "$backupFileParent""/" + 1`

                endval=`expr length "$backupFile"`

                narsFile="$(echo `expr substr "$backupFile" "$startval" "$endval"`)"
		

		#echo "narsFile = $narsFile" | tee -a $LOG_FILE;
		linkPath=`readlink $backupFileParent`;

		match=`expr match $narsFile "narsagent-"`;
		#echo "match =$match";
		if [  $match -gt 0  -a   "$linkPath" != ""  ]; then
			#echo "Skipping restore of $backupFile " | tee -a $LOG_FILE;
			continue;
 		fi
 		
		echo "************************************************************************************" >>$LOG_FILE
		##checking for rsmagent.tar file to ensure that folder is narsagent installation
		isInstaller=`ls $backupFile | grep rsmagent-install.tar | wc -l`
		if [ $isInstaller -eq 1 ];then
			echo "$backupFile contains rsmagent-install.tar file and is not a valid RSMAgent installation" >> $LOG_FILE;
			echo "skipping $backupFile" >> $LOG_FILE;
			
			continue;
		fi
		echo " start restoring $backupFile" >>  $LOG_FILE
	
		## Get parent folder of previous narsagent installation  
		backupFileParent="$(echo $backupFile | sed 's/narsagent.*//'| sed -e "s/\/*$//")"
		
		echo "Parent of $backupFile = $backupFileParent " >> $LOG_FILE
		
		## Get the location if the parent directory is a link to other folder
		linkPath=`readlink "$backupFileParent"`
		
		if [ "$linkPath" != "" ];then
			echo "Parent folder $backupFileParent Points to $linkPath" >> $LOG_FILE
		else
			echo "Parent folder $backupFileParent is not a softlink" >> $LOG_FILE
		fi

		restorePath="$(echo $backupFileParent | sed "s/^.*${rootBackupDirName[$counter]}//")"
		
		echo " Actual Restore Path Parent after upgrade $restorePath"  >> $LOG_FILE
		echo "Checking if backup narsagent parent is softlink " >> $LOG_FILE
		##check if parent directory of  previous narsagent installation is a softlink 
		if [ "$linkPath" != "" ];then
		## YES::Parent directory of previous narsagent installation is a softlink to $linkPath	
			echo "YES::Parent directory of narsagent backup $backupFileParent points to $linkPath" >> $LOG_FILE
			
			#previousDir=`pwd`;
			echo "Change directory to Parent directory of narsagent backup $backupFileParent" >> $LOG_FILE
			cd "$backupFileParent"; 
			##if 
			if [  -d $linkPath ];then
				echo "Changing to directory  pointed by narsagent backup parent directory " >> $LOG_FILE
				cd "$linkPath";
			else
				
				echo "Folder  $backupFile pointing to $linkPath doesnt exists" >> $LOG_FILE
				echo "Failed to restore $backupFile. Please see the logs for information" | tee -a $LOG_FILE
				echo "Skipping restore of $backupFile " | tee -a $LOG_FILE
				continue;
				
			fi
		
			
			absLinkPath=`pwd`
			
			echo "Absolute Path after changing directory to softlink path $absLinkPath " >> $LOG_FILE
	
			absLinkPath="$(echo $absLinkPath | sed "s/^.*${rootBackupDirName[$counter]}//")"

			echo "Parent directory of softlink Path after upgrade =$absLinkPath " >> $LOG_FILE

			##check if restorePath and abslinkpath combination exits
			found=0 ## 0 means not present
			for i in $(seq 0 `expr ${#linkNarsagentFileArray[@]} - 1`);do
				if [ "$restorePath"";""$absLinkPath;" == ${linkNarsagentFileArray[$i]} ] ;then
					found=1 ##1 means present
					echo "Restore;Softlink Path combination ${linkNarsagentFileArray[$i]} already exists in the list for index $i" >> $LOG_FILE
					break;
				fi
			done
		
			if [ $found -eq 0 ];then
				echo "Restore;Softlink Path combination ${linkNarsagentFileArray[$i]} doesn't exists in the list " >> $LOG_FILE		
				linkNarsagentFileArray[$index]="$restorePath"";""$absLinkPath;" 
				echo "Restore;Softlink Path combination ${linkNarsagentFileArray[$i]} added  in the list " >> $LOG_FILE
			
				index=`expr $index + 1`
			fi	
			echo "$backupFile will be restored after Narsagent successfully restores in $linkPath" >> $LOG_FILE
			continue;
		
		else
		 	 ## NO::Parent directory of previous narsagent installation is not  a softlink 
                        echo "NO::Parent directory of narsagent backup $backupFileParent is not a softlink" >> $LOG_FILE

			restorePath="${restorePathParent[$counter]}""$restorePath"
			echo "Actual restore Path parent after upgrade $restorePath for narsagent backup $backupFile" >> $LOG_FILE


		##check if restorePath="" it means / 
		if [ "$restorePath" != "" ]; then
   			if [ ! -d $restorePath ];then
				echo "Actual restore Path parent after upgrade $restorePath doesn't exists. Creating directory structure $restorePath" >> $LOG_FILE
				mkdir -p "$restorePath";
				if [ $? -eq 0 ];then
					echo "Directory structure $restorePath created successfully" >> $LOG_FILE
				else
					echo "Failed to created Directory structure $restorePath " >> $LOG_FILE
					echo "$backupFile can not be restore to $restorePath" | tee -a $LOG_FILE
					continue;
				fi
			else
				
				echo "Actual restore Path parent after upgrade  ${restorePathParent[$counter]}$restorePath already exists" >> $LOG_FILE
				

			fi
		fi

	##Determining narsagent folder name	
		startval=`expr length "$backupFileParent""/" + 1`

		endval=`expr length "$backupFile"`
	
		narsFile="$(echo `expr substr "$backupFile" "$startval" "$endval"`)"

		if [ "$restorePath" == "" ];then
			cd /;

		else

			cd $restorePath;
		fi

		##checking if narsagent folder already exists in actual restore path

		if [ -d "$narsFile" ];then
			echo "$narsFile already exists in actual restore Path parent directory $restorePath" >> $LOG_FILE
					
			echo "Deleting existing "$restorePath"/"$narsFile" " >> $LOG_FILE
	
			rm -rf $narsFile
			if [ $? -ne 0 ];then
				echo "Unable to delete existing narsagent folder $narsFile" >> $LOG_FILE
			else
				echo "Existing narsagent folder $narsFile deleted successfully"	>> $LOG_FILE
			fi
		fi

		if [ "$restorePath" == "" ];then
			restorePath="/"
		fi
		
		echo "Restoring RSMAgent $backupFile to $restorePath" | tee -a $LOG_FILE

		cp -r -p $backupFile $restorePath

		if [ $? -eq 0 ];then
			echo "RSMAgent in $backupFile restored successfully in $restorePath" | tee -a $LOG_FILE
		else
	
			echo "RSMAgent in $backupFile failed to restore  in $restorePath" | tee -a $LOG_FILE

		fi
	fi

done

echo "#####################################################################################################" >> $LOG_FILE
echo "Restore;LinkPath value combination List" >> $LOG_FILE
echo "  ${linkNarsagentFileArray[@]}" >> $LOG_FILE
echo""

## Performing restore for Restore;LinkPath combination.
	for i in $( seq 0 `expr $index - 1` )
	do
		echo "#####################################################################################################" >> $LOG_FILE

		echo "Restore;LinkPath combination at index $i  is ${linkNarsagentFileArray[$i]}" >> $LOG_FILE

		restorePath="$(echo ${linkNarsagentFileArray[$i]} |cut -d';' -f1 )"
		linkPath="$(echo ${linkNarsagentFileArray[$i]} |cut -d';' -f2 )"

		echo "Restore part of (Restore;LinkPath) ${linkNarsagentFileArray[$i]} = $restorePath" >> $LOG_FILE

		echo "LinkPath part of (Restore;LinkPath) ${linkNarsagentFileArray[$i]} =$linkPath" >> $LOG_FILE
	
		##checking if Link Path in backup folder (i.e. searchDir[0] or searchDir[1]) exists
		if [ ! -d "${searchDir[$counter]}""$linkPath" ];then
			
			echo "${searchDir[$counter]}$linkPath doesn't exists and narsagent in ${restorePathParent[$counter]}$restorePath failed to restore" | tee -a $LOG_FILE
		else
			echo "LinkPath $linkPath exists in backup folder ${searchDir[$counter]}.Searching for narsagent installations in "${searchDir[$counter]}""$linkPath".... " >> $LOG_FILE

			narsagentLinkInstall=`find -L "${searchDir[$counter]}""$linkPath" -type f -name .naindex 2>/dev/null | sed 's/''\/.naindex*$//'`
			echo "Narsagent installations found in "${searchDir[$counter]}""$linkPath" " >> $LOG_FILE
			echo "${narsagentLinkInstall[@]}" >> $LOG_FILE
			
			for narsagentLink in $narsagentLinkInstall;
			do
				##checking for rsmagent.tar file to ensure that folder is narsagent installation
                		isInstaller=`ls $narsagentLink | grep rsmagent-install.tar | wc -l`
                		if [ $isInstaller -eq 1 ];then
                        		echo "$narsagentLink contains rsmagent-install.tar file and is not a valid narsagent installation" >> $LOG_FILE;
                        		echo "skipping $backupFile" >> $LOG_FILE;

                        		continue;
                		fi

				echo "narsagentLink = $narsagentLink" >> $LOG_FILE

				echo "serachdir = ${searchDir[$counter]}" >> $LOG_FILE
				##Determinig narsagent folder name
				startval=`expr length "${searchDir[$counter]}""$linkPath""/" + 1`
				endval=`expr length "$narsagentLink"`
				narsFile="$(echo `expr substr "$narsagentLink" "$startval" "$endval"`)"

				echo "narsFile = $narsFile" >> $LOG_FILE

				echo "restorePath new =$restorePath">> $LOG_FILE


				if [ "${restorePathParent[$counter]}"$restorePath != "" ];then
					if [ ! -d "${restorePathParent[$counter]}""$restorePath" ];then
						echo "Actual Restore Path Parent folder "${restorePathParent[$counter]}""$restorePath" doesn't exists. Creating the same directory structure " >> $LOG_FILE
						
						mkdir -p "${restorePathParent[$counter]}""$restorePath"

						if [ $? -ne 0 ];then
							echo "Failed to create restore folder for "${restorePathParent[$counter]}""$restorePath" " >>  $LOG_FILE
							echo "Failed to restore RSMAgent in "${restorePathParent[$counter]}""$restorePath" "|  tee -a	$LOG_FILE
							continue
						else
							echo "restore path folder "${restorePathParent[$counter]}""$restorePath" created successfully" >> $LOG_FILE
						fi
						echo "creating "${restorePathParent[$counter]}""$restorePath" " >> $LOG_FILE

					fi
				fi
				
				
				## Changing directory to Actual Restore Path Parent folder 
				if [ "${restorePathParent[$counter]}""$restorePath" == "" ];then
					cd /;
				else
					cd "${restorePathParent[$counter]}""$restorePath";
					if [ $? -ne 0 ];then
						echo "Failed to navigate to "${restorePathParent[$counter]}""$restorePath" " >> $LOG_FILE
						echo "failed to restore RSMAgent in "${restorePathParent[$counter]}""$restorePath" " | tee -a $LOG_FILE
					
						continue;
					
					fi
				fi
				
##checking for the existance of softlik to narsagent
                match=`expr match $narsFile "narsagent-"`;
                #echo "match =$match";
                if [  $match -gt 0  ]; then
                       # echo "Skipping restore of $narsFile" | tee -a $LOG_FILE;
                        continue;
                fi


				if [  -L "$narsFile" ];then




					echo "Softlink  $narsFile already exists in  "${restorePathParent[$counter]}""$restorePath"  " >> $LOG_FILE
					echo "Deleting softlink $narsFile" >> $LOG_FILE 

					rm -rf "$narsFile"



					if [ $? -ne 0 ];then
						echo "Failed to delete existing softlink $narsFile in "${restorePathParent[$counter]}""$restorePath"" >> $LOG_FILE
					else
						echo "Successfully deleted existing softlink $narsFile in "${restorePathParent[$counter]}""$restorePath"" >> $LOG_FILE
					fi
				fi
				echo "Restoring RSMAgent in  "${searchDir[$counter]}""$restorePath""/""$narsFile" to  ${restorePathParent[$counter]}""$restorePath""/""$narsFile" "" | tee -a $LOG_FILE
				ln -s "${restorePathParent[$counter]}""$linkPath""/""$narsFile" "$narsFile"
				if [ $? -ne 0 ];then
					echo "Failed to create softlink $narsFile to  "${restorePathParent[$counter]}""$linkPath""/""$narsFile" " >> $LOG_FILE
					echo "Failed to restore RSMAgent in "${restorePathParent[$counter]}""$restorePath" " | tee -a $LOG_FILE
				else
					echo "RSMAgent in "${searchDir[$counter]}""$restorePath""/""$narsFile" restored successfully  in ${restorePathParent[$counter]}""$restorePath""/""$narsFile" | tee -a $LOG_FILE
				fi

		
			done
		fi 


	done




done
echo"" >> $LOG_FILE
echo "Restore operaton completed successfully!!" >> $LOG_FILE
echo "" >> $LOG_FILE
cd $currentPWD;
