#!/bin/sh
# This script can be used to backup  and restore/import the GENBAND iVMS/RSM DB. 
# The script supports RSM versions 4.3 and up till 6.x
# It is based on the dbback_rsm.sh and import_tables_by_dir.sh scripts
# The backup option provides 4 ways to backup the DB:
# 1), the entire DB in one MySQL dump file
# 2), all tables other than the CDR tables, one dump file per table
# 3), all tables, one dump file per table
# 4), only the stored procedures, functions and triggers
# The restore option can be used to import the backup taken by the backup options
# Aug 12, 2009 - Bilig Oyun for GENBAND, Inc
# Version 1.0 - initial release
# Version 1.1 - fixed minor issue - Oct 28, 2009
# Version 2.0 -  Jan 20, 2010
# 1) - added support for HA
# 2) - introduced TBL_to_SKIP - any tables listed here will not be backed up if you use the quick backup option
# 3) - added backing up of bn.properties file and mysql-ds.xml file
# Version 2.1 - June 10, 2010
# 4) - added backing up of /etc/my.cnf
# 5) - re-wrote the quick backup to better handle skip tables
#	a) changed quick backup to backup without CDRs
#	b) added another option called custom backup
# Version 2.2 - Nov 10, 2010
# 1) - added support for RSM 6.x
# Version 2.3 - Oct 19, 2011
# 1) - minor bug fixes and perform check for unexpected failures
# 2) - added option to backup CDR export transform files found in $NEX_HOME/rsm/CDRStream/ dir
# Version 2.4 - April 20, 2012
# 1) fixed issue where the script wasn't able to start up the RSM after restore on HA setup
# 2) now mysqldump will use "--force" option - will not abort on SQL error
# 3) other cosmetic improvements

declare -a TBL_NAME
JBOSS_INIT=/etc/init.d/jboss
NEX_HOME=/opt/nxtn
JBOSS_HOME=$NEX_HOME/jboss
RSM_HOME=$NEX_HOME/rsm
VER=`cat $RSM_HOME/.ivmsindex`                          # RSM version
MAIN_VER=`echo $VER | cut -c 1`
WEB_PORT=443
MAX_TRY=30

# Any table whose name matches one of the following pattern will not be backed up 
# for example, if you have "temp" as a pattern below, all tables starting with the word "temp" will be skipped
SKIP_TABLES="activitylogs cdrsummary buysummary sellsummary cdrlogs cdrfiles est_rg PerformanceStatsData temp hrbuy hrsell hrsum hrlogs"

declare -a TBL_to_SKIP=( $SKIP_TABLES )

# confirm function
confirm()
{
read yesno
case $yesno in
"y" | "Y" )
        ;; # continue
"n" | "N" )
        echo "You have chosen \"n\", quiting ..."
        exit 0;;
* )
        echo "Wrong selection, quiting ..."
        exit 1;;
esac
}

# check to make sure MySQL is running first
if ! /etc/init.d/mysql status | grep -q "running"; then
	clear; echo; echo
	echo "MySQL is not running, exiting ..."
	echo "Database backup and restore require that the MySQL is running"
	echo "Please check and try again later."; echo; echo
	exit 1
fi

# Simplex/HA check

clear; echo; echo
if [ -e /usr/lib/ocf/resource.d/genband/jbossnew ] && [ -e /var/lib/heartbeat/crm/cib.xml ]; then
        HA="HA"                                            # HA setup
        if ! crm_mon -1 | grep -q "Current DC"; then
                echo "RSM HA system detected, but can't determine HA status" 
		echo; echo -n "Do you wish to continue? <y|n>: "
                confirm; echo
       	else 
		if ! crm_mon -1 | grep MySQL | grep Started | grep -i -q $HOSTNAME; then
			echo "Standby system detected. Please run this script on the active server. Exiting ..."
               		exit 1
		fi
        fi
else
        if [ -e $JBOSS_INIT ]; then
                if grep -q JBOSS_HOME=/usr/local/jboss $JBOSS_INIT; then
                        echo "This server doesn't seem to have 4.3 or above GenView-RSM installed."
                        exit 1
                fi
        else
                echo "JBOSS startup script doesn't exist. Looks like the GenView-RSM server is not installed properly. Exiting ..."
                exit 1
        fi      
        HA="simplex"                                            # Simplex and 4.3 and up
fi

echo;echo
clear
echo "

                This script is used to backup and restore the GENBAND GenView-RSM database.
                The database backup and restore process usually takes a long time. 
                We recommend that you start the \"screen\" utility before continuing.
                To run the \"screen\" utility, quit this script and type \"screen\" and press ENTER

                Please select one of the following options:

                1.      Let me quit and run \"screen\" before I try again
                2.      I already started \"screen\". Let me continue

";
read opt
case $opt in
1)
        exit 1;;
2)
        ;; # continue
*)      echo "Wrong option, exiting"
        exit 1;;
esac

# Setting up system dir. No need to do it for HA as it was available since 5.0 only
if [ $HA == "simplex" ]; then
        if [ -f $JBOSS_INIT ]; then
                if grep -q JBOSS_HOME=/opt/nxtn/jboss $JBOSS_INIT; then
                        NEX_HOME=/opt/nxtn
                        JBOSS_HOME=$NEX_HOME/jboss
                else
                        NEX_HOME=/usr/local
                        JBOSS_HOME=$NEX_HOME/jboss
                fi
        else
                echo "JBOSS startup script doesn't exist. Looks like the RSM server is not installed properly. Exiting ..."
                exit 1
        fi      

fi

# get the DB password
if [ $MAIN_VER -ge "6" ]; then                                   # it is 6.0 and up
        MYSQL_DS=$JBOSS_HOME/server/rsm/deploy/mysql-ds.xml
        JBOSS_CACHE_DIR=$JBOSS_HOME/server/rsm
else                                                            # all other (4.3 till 5.2.x, etc)
        MYSQL_DS=$JBOSS_HOME/server/default/deploy/mysql-ds.xml
        JBOSS_CACHE_DIR=$JBOSS_HOME/server/default
fi


if [ -f $MYSQL_DS ]; then
        user=`cat $MYSQL_DS | grep user-name| head -1 | cut -f 2 -d ">" | cut -f 1 -d "<"`
        pass=`cat $MYSQL_DS | grep password | head -1 | cut -f 2 -d ">" | cut -f 1 -d "<"`
else
        echo "File $MYSQL_DS doesn't exist. Make sure the RSM is installed properly. Exiting"; echo
        exit 1
fi

mysqldump="mysqldump --user=$user --password=$pass bn --force"		# force option to continue upon error
mysql="mysql --user=$user --password=$pass bn"

# test MySQL log in

$mysql -e "use bn"
if [ ! $? -eq 0 ]; then
        echo "Can't log into the MySQL server. Please make sure that the MySQL is running."
        exit 1
fi

# function to stop JBOSS. Has to properly detect that the server has stopped.
jboss_stop()
{
        echo "Stopping JBOSS, please wait ..."
        /etc/init.d/jboss stop
        a=`pgrep java | wc -l`
        CNT=0
        while [ $a -gt "0"  ]
                do
                echo "JBOSS is still running, number of threads = $a ..."
                a=`pgrep java | wc -l`
                sleep 1
                CNT=`expr $CNT + 1`
                if [ $CNT -eq $MAX_TRY ]
                then
                        echo "Unable to stop the JBOSS gracefully in $MAX_TRY seconds. Proceed to kill the process ..."
                        pkill -9 java
                        break
                fi
        done
        echo "JBOSS stopped ..."; echo
}

# file backup task - back up important system files here
file_backup()
{
	echo; echo "Backing up the bn.properties file ..."
	cp $NEX_HOME/rsm/bn.properties $BACKUP_DIR
	echo "Backing up the mysql-ds.xml file ..."
	cp $MYSQL_DS $BACKUP_DIR
	echo "Backing up the /etc/my.cnf file ..."
	cp /etc/my.cnf $BACKUP_DIR
	echo "Backing up the $NEX_HOME/rsm/CDRStream/transform dir ..."
	cd $BACKUP_DIR
	tar czfpP CDR_export_transform_files.tar.gz $NEX_HOME/rsm/CDRStream/transform
	echo
}
# backup task
backup()
{
echo; echo -n "Enter the backup dir path. Please make sure that the disk partition has plenty of space: "
read BACKUP_DIR
if [ ! -d $BACKUP_DIR ]; then
        echo -n "Backup dir doesn't exist. Create it? <y|n>: "
        confirm
        mkdir -p $BACKUP_DIR
        echo "Backup dir created..."
fi

TBL_NAME=(`$mysql -BNe "show tables" | tr '\n' ' '`)

echo "

                Please select from one of the following backup options.
                Optin #2 is recommended if you want to backup everything but CDRs


        1.      Full Backup - 
                Backup the entire database as one big file 
                Multiple hours and multiple GBs of disk space are required for DB with 5 mil or more CDRs

        2.      Backup Without CDRs - 
                Backup the non-CDR tables, one table per file. CDRs are not saved
                Doesn't require a lot of time and disk space
	
	3.	Custom Backup -
		In addition to skipping the CDR tables, tables whose names matching the pattern listed 
		in variable SKIP_TABLES are not backed up

        4.      Full Backup, Separate Tables - 
                Backup all the tables, one table per file (mysqldump the tables, gzipped).
                Multiple hours and multiple GB of disk space required for DB with 5 mil or more CDRs

        q.      Quit without doing anything

"
echo -n "Enter your selection <1|2|3|4|q>: "
read BKUP_OPT
echo

n=0
while [ $n -lt ${#TBL_NAME[@]} ]; do
#        MATCH_CNT=`expr match ${TBL_NAME[$n]} cdr1`
        case $BKUP_OPT in
        1)
                clear; echo; echo "Backing up the entire database could take a long time and the RSM server can become slow."
                echo "Also, you should not make any changes to the RSM databse during the backup process."; echo
                echo -n "Do you wish to continue? <y|n>: "
                confirm
                echo; echo "Backing up the entire database, please wait ..."
                $mysqldump | gzip > $BACKUP_DIR/bn_dump.sql.gz
                if [ $? -eq 1 ]; then
                        echo; echo "Database backup failed,  please check any previous error messages for details."
                        exit 1
                fi
                echo; echo "The entire DB is saved as $BACKUP_DIR/bn_dump.sql.gz"
		file_backup
		echo; echo "Database backup is completed."; echo
		exit 0				# exit here, otherwise will backup again in a loop
                ;;

        2)
                if [ $n -eq 0 ]; then                   # only show this once at the beginning
                        clear; echo; echo "You have selected the \"Backup Without CDRs\" option."
                        echo "This script will not backup any CDR tables. "
                        echo; echo -n "Do you wish to continue? <y|n>: "
                        confirm; echo
                fi
                MATCH=0
                # Setting MATCH flag for cdr tables to skip
                MATCH_CNT=`expr match ${TBL_NAME[$n]} cdr1`
                if [ $MATCH_CNT -gt 0 ]; then
                        MATCH=1
                fi

                # Skip, or backup based on $MATCH flag value
                if [ $MATCH -eq 1 ]; then
                        echo "Skipping table ${TBL_NAME[$n]} ..."
                else
                        echo "Backing up table ${TBL_NAME[$n]} as $BACKUP_DIR/${TBL_NAME[$n]}.sql.gz ..."
                        $mysqldump ${TBL_NAME[$n]} | gzip > $BACKUP_DIR/${TBL_NAME[$n]}.sql.gz
               		if [ $? -eq 1 ]; then
                        	echo; echo "backup of table ${TBL_NAME[$n]} failed,  please check any previous error messages for details."
	                fi
                fi
                ;;
        3)
		if [ $n -eq 0 ]; then			# only show this once at the beginning
			clear; echo; echo "You have selected the \"Custom Backup\" option."
			echo "This script will not backup any CDR tables. "
			echo "Also, any tables whose names matching the following words will not be backed up:"; echo
			echo $SKIP_TABLES | tr " " "\n"; echo
			echo "You can update the list by editing the \$SKIP_TABLES variable in this script"; echo
			echo -n "Do you wish to continue? <y|n>: "
			confirm; echo
		fi
		MATCH=0
		# checking the table name against TBL_to_SKIP pattern and set the flag
		m=0
		while [ $m -lt ${#TBL_to_SKIP[@]} ]; do
			MATCH_CNT_SKIP=`expr match ${TBL_NAME[$n]} ${TBL_to_SKIP[$m]}`
			if [ $MATCH_CNT_SKIP -gt 0 ]; then
				MATCH=1			# matching pattern found
				m=`expr $m + 1`
				break			# matching pattern found and skipped. no need to check remaining	
			fi
			MATCH=0				# no match found
			m=`expr $m + 1`
		done

                # Setting MATCH flag for cdr tables to skip
                MATCH_CNT=`expr match ${TBL_NAME[$n]} cdr1`
                if [ $MATCH_CNT -gt 0 ]; then
                        MATCH=1
                fi

		# Skip, or backup based on $MATCH flag value 
		if [ $MATCH -eq 1 ]; then
			echo "Skipping table ${TBL_NAME[$n]} ..."
		else
                	echo "Backing up table ${TBL_NAME[$n]} as $BACKUP_DIR/${TBL_NAME[$n]}.sql.gz ..."
			$mysqldump ${TBL_NAME[$n]} | gzip > $BACKUP_DIR/${TBL_NAME[$n]}.sql.gz
                        if [ $? -eq 1 ]; then
                                echo; echo "backup of table ${TBL_NAME[$n]} failed,  please check any previous error messages for details."
                        fi
		fi
                ;;
        4)
                echo "Backing up table ${TBL_NAME[$n]} ..."
                $mysqldump ${TBL_NAME[$n]} | gzip > $BACKUP_DIR/${TBL_NAME[$n]}.sql.gz
		if [ $? -eq 1 ]; then
			echo; echo "backup of table ${TBL_NAME[$n]} failed,  please check any previous error messages for details."
		fi
                ;;

        5)	# Hidden option. For internal use only	
                echo "Backing up the stored procedure/functions and triggers only ..."
                $mysqldump --routines --no-create-info --no-data --no-create-db --skip-opt | gzip > $BACKUP_DIR/bnsp_triggers.sql.gz
		if [ $? -eq 1 ]; then
			echo; echo "backup of table ${TBL_NAME[$n]} failed,  please check any previous error messages for details."
		exit 1
		fi
                echo; echo "All stored procedures/functions and triggers are saved as $BACKUP_DIR/bnsp_triggers.sql.gz." ; echo
                exit 0
                ;;
        q)
                echo "You have selected to quit."; echo
                exit 0
                ;;
        *)
                echo "Wrong choice, quiting."; echo
                exit 1
                ;;
        esac
        n=`expr $n + 1`
done
file_backup			# file backup for option 2, 3 and 4
echo "Database backup is completed."; echo
}

# restore task
restore()
{
# handling HA system
if [ $HA == "HA" ]; then
        echo "
                This looks like an HA system. Please proceed only after you have done the following 2 steps:

                1). Stop the heartbeat on BOTH servers - Stop on standby first and then active
                2). Start the MySQL only on this server. DO NOT start the heartbeat

        ";

                echo -n "                Do you wish to continue? <y|n>: "
        confirm; echo
        if /etc/init.d/heartbeat status | grep -q "OK"; then
                echo "
                The heartbeat process is still running. 
                Please perform the following 2 steps and try again:

                1). Stop the heartbeat on both servers - Stop on standby first and then active
                2). Start the MySQL only on this server. DO NOT start the heartbeat

                ";
                exit 1
        elif ! /etc/init.d/mysql status | grep -q "running"; then
                echo "MySQL is not running on this server. Please start it and try again"; echo
                exit 1
        fi
else 
        echo; echo "In order to restore the database from backup, we need to stop the JBOSS."
        echo -n "Do you wish to stop the JBOSS now? <y|n>: "
        confirm; echo
        jboss_stop
fi
clear; echo
echo; echo -n "Which of the following backup options did you use to backup the DB ? "
echo; echo "

        1.      Full backup - selected option #1 during the backup
                Entire DB in one big .sql.gz file 

        2.      Backup Without CDRs - selected option #2 during the backup
                Only the non-CDR tables, one table per file in .sql.gz format 

	3.	Custom Backup - selected option #3 during the backup	
		Backup without the CDRs and without the tables listed in \$SKIP_TABLES

        4.      Full backup - selected option #4 the during backup
                Backup all the tables, one table per file 

        q.      Quit without doing anything

";
echo -n "Enter your selection <1|2|3|4|q>: "
read option

case $option in
1)
        echo; echo -n "Enter the full dir path where the backup file is saved: "
        read dest_dir
        if [ ! -d $dest_dir ]; then
                echo "Directory $dest_dir doesn't exist, exiting ..."
                exit 1
        fi

        # import from default file name
	IMPORT_FLAG=0				# initialize the flag
        if [ -f $dest_dir/bn_dump.sql.gz ]; then
                echo; echo -n "Import from file \"$dest_dir/bn_dump.sql.gz\" ? <y|n>: "
                read yesno
                case $yesno in
                "y" | "Y" )
                        echo; echo "Importing the DB. This could take a long time, please wait ..."
                        gunzip < $dest_dir/bn_dump.sql.gz | $mysql
                        if [ ! $? -eq 0 ]; then
                                echo; echo "Unable to import the DB. Please check the error message for details"
                        exit 1
                        fi       
                        echo; echo "Done importing $dest_dir/bn_dump.sql.gz"
			IMPORT_FLAG=1		# remember that import is done already
                        ;;
                "n" | "N" )
			IMPORT_FLAG=0		# decided not to import from default file. Import not done
                        ;; 
                * )
                        echo "Wrong choice, quiting."; echo
                        exit 0
                        ;;
                esac
	fi		
	if [ $IMPORT_FLAG -eq 0 ]; then		# import wasn't done yet. Need to prompt the DB file name
                echo; echo -n "Enter the name of the backup file which contains the DB in $dest_dir: "
                read file
                if [ ! -f $dest_dir/$file ]; then
                        echo "$dest_dir/$file doesn't exist. Please try again with correct file name."; echo
                        exit 1
                fi
                echo; echo "Importing $dest_file/$file into the RSM DB. This will overwrite all of your current data in the DB."
                echo; echo -n "Do you want to continue? <y|n>: "
                confirm; echo
                echo "Importing the DB. This could take a long time, please wait ..."
                gunzip < $dest_dir/$file | $mysql
                if [ ! $? -eq 0 ]; then
                        echo; echo "Unable to import the DB. Please check the error message for details"
                        exit 1
                fi
                echo; echo "Successfully imported $dest_dir/$file."
        fi
        ;;
2|3|4)
        echo; echo "Enter the full dir path where the backup files are saved" 
        echo -n "Please make sure that there aren't any other files in the dir: "
        read dest_dir
        if [ ! -d $dest_dir ]; then
                echo "Directory $dest_dir doesn't exist, exiting ..."
		exit 1
        fi
        cd $dest_dir
        echo; echo "Importing all files from $dest_dir into the RSM DB "
	echo "This will overwrite the data in your current DB."
        echo; echo -n "Do you want to continue? <y|n>: "
        confirm; echo
        for file in *.sql.gz
        do
                echo "Importing file \"$file\" ..."
                gunzip < $file | $mysql
        done
        echo; echo "Tables restored successfully."; echo
        ;;
5)
        echo -n "Enter the full dir path where the backup file is saved: "
        read dest_dir
        if [ ! -d $dest_dir ]; then
                echo "Directory $dest_dir doesn't exist, exiting ..."
                exit 1
        fi
        # import from default file name
        if [ -f $dest_dir/bnsp_triggers.sql.gz ]; then
                echo -n "Import stored procedures/functions and triggers from file \"$dest_dir/bnsp_triggers.sql.gz\" ? <y|n>: "
                read yesno
                case $yesno in
                "y" | "Y" )
                        echo "Importing the stored procedures/functions and triggers, please wait ..."
                        gunzip < $dest_dir/bnsp_triggers.sql.gz | $mysql
                        if [ ! $? -eq 0 ]; then
                                echo "Unable to import the DB. Please check the error message for details"
                        exit 1
                        fi
                        echo "Done importing $dest_dir/bnsp_triggers.sql.gz."
                        exit 0
                        ;;
                "n" | "N" )
                        ;; # continue and prompt for the file name
                * )
                        echo "Wrong choice, quiting."
                        exit 0
                        ;;
                esac
        fi
        # default file doesn't exist
        echo -n "Enter the name of the file which contains the stored procedures/functions and triggers: "
        read file
        if [ ! -f $dest_dir/$file ]; then
                echo "$dest_dir/$file doesn't exist. Please try again with correct dir path and file name."; echo
                exit 1
        fi
        echo "Importing $dest_dir/$file into the RSM DB. This will overwrite your current stored procedure/functions and triggers."
        echo; echo -n "Do you want to continue? <y|n>: "
        confirm; echo
        echo "Importing stored procedures/functions and triggers, please wait ..."
        gunzip < $dest_dir/$file | $mysql
        if [ ! $? -eq 0 ]; then
                echo "Unable to import the DB. Please check the error message for details"
                exit 1
        fi
        echo "Successfully imported $dest_dir/$file."
        ;;
q)
        echo "You have selected to quit."
        exit 0
        ;;
*)
        echo "Wrong selection, please try again."; echo
        exit 1
        ;;
esac

if [ $HA == "HA" ]; then
        echo; echo "Do you want this script to start the heartbeat on this server?"
	echo "This requires stopping the MySQL first and the starting the heartbeat."
        echo; echo -n "Do you want to proceed ? <y|n>: "
        confirm; echo
	/etc/init.d/mysql stop
	echo
        if /etc/init.d/mysql status | grep -q "running"; then
                echo "MySQL is still running. Please manually stop the MySQL and then start the heartbeat"; echo
                exit 1
        fi
	rm -rf $JBOSS_CACHE_DIR/work/
	rm -rf $JBOSS_CACHE_DIR/tmp/
	rm -rf $JBOSS_CACHE_DIR/data/
	/etc/init.d/heartbeat start
	listen=`netstat -an | grep $WEB_PORT | grep LISTEN`
	while [ -z "$listen" ]; do
		echo "Heartbeat is starting up, please wait ..."
		sleep 15
		listen=`netstat -an | grep $WEB_PORT | grep LISTEN`
	done
	echo; echo "Heartbeat is started. Please remember to start the heartbeat on the other server."; echo
else
        echo; echo -n "Do you want to start the JBOSS now? <y|n>: "
        confirm; echo
	echo "Proceeding to start up the JBOSS, please wait ..."; echo
	rm -rf $JBOSS_CACHE_DIR/work/
	rm -rf $JBOSS_CACHE_DIR/tmp/
	rm -rf $JBOSS_CACHE_DIR/data/
	/etc/init.d/jboss start
	listen=`netstat -an | grep $WEB_PORT | grep LISTEN`
	while [ -z "$listen" ]
		do
		echo "JBOSS is starting up, please wait ..."
		sleep 5
		listen=`netstat -an | grep $WEB_PORT | grep LISTEN`
	done
	echo; echo "The JBOSS is started and it is ready to accept connection from the web..."; echo
fi
}

# Main
clear
echo "


                Please select one of the following options:

                1.      I want to backup the RSM database 
                2.      I want to restore the database from backup files I already have
                q.      Quit without doing anything

";
read opt
case $opt in
1)
        backup
        exit 0
        ;;
2)
        restore
        exit 0
        ;; 
q)
        echo; echo "You have decided to quit."; echo
        exit 0
        ;;
*)
        echo "Wrong choice, quiting."
        exit 1
        ;;
esac
############## END of SCRIPT #################
