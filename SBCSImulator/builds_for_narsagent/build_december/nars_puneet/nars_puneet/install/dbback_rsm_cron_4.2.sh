#!/bin/sh
# This script can be used to back up the GENBAND RSM system DB and system files/dir automatically via a cronjob. 
# And it has option to transfer the backup file to a remote server via either FTP, or SCP
# Important Notes about the script:
# Before using the script, appropriate values for the "User Configuration" section has to be set up. 
# Also, extra config is required if the back up files to be automatically transferred to a remote server.
# See the "FTP Task" and "SCP Task" secitons of the script for additional info on how to set up FTP and SCP file transfer
# The cronjob has to be in the root cron
# This script only backs up non-CDR tables!!!
# This script also does NOT back up any tables whose names match the pattern listed in the $SKIP_TABLE
# This script auto-detects HA or Simplex system. On HA system, it backs up both the DB and system files on active
# + It only backs up the system files on the standby
# This script requires a file called "files_to_backup" to be present in the same dir as this script
# The "files_to_backup" should contain all files/dir to be backed up, one per line
# This script tests whether file/dir exist before attempts to backup, so any files/dir for both simplex
# + and HA can be included in one single file
# The cronjob that calls this script should look like the one below -
# 5 0 * * * (cd /home/nextone/scripts; ./dbback_rsm_cron_4.0.sh >> /tmp/dbback_rsm.log  2>&1)
# The script supports all versions of RSM to date (4.3 and up)
# Bilig Oyun for GENBAND
# Version 2.0, June 15, 2010
# Version 2.0 is based on rsm_backup_restore_2.1.sh
# Version 2.1, June 14, 2011 - support for RSM 6.0 and up
# Version 3.0, June 23, 2011 - Now supports both HA and simplex 
# Version 3.1, July 13, 2011 - Added FTP option
# Version 4.0, Aug 05, 2011 - 
# 1) added SCP option
# 2) added option to backup other system files
# Version 4.1, Aug 11, 2011 - 
# 1) now the script will backup the system files and dir on standby server
# 2) included the $HOSTNAME in the backup file name for easy identification
# Version 4.2, Aug 22, 2011 - bug fixes

# User Configurations

REMOTE_BACKUP_OPT=SCP					# "NONE", "FTP", or "SCP" and "SCP" is preferred as FTP is dodgy
BACKUP_DIR=/home/genband/dbback				# dir where the backup files are stored
SCP_USER=bilig						# username used to SCP the backup file over to $REMOTE_SERVER
REMOTE_SERVER=65.122.90.154				# remote FTP or SCP server where the backup to be transferred
REMOTE_DIR=tmp/daily_backup/				# remote dir where the archive files to be stored

# Other Config
declare -a TBL_NAME
JBOSS_INIT=/etc/init.d/jboss
NEX_HOME=/opt/nxtn
JBOSS_HOME=$NEX_HOME/jboss
DATE=`date +%F-%H-%M-%S`
RSM_HOME=$NEX_HOME/rsm
VER=`cat $RSM_HOME/.ivmsindex`                          # RSM version
MAIN_VER=`echo $VER | cut -c 1`
HOSTNAME=`hostname`
FTP=/usr/bin/ftp
SCP=/usr/bin/scp
BACKUP_FILE_LIST=./files_to_backup
TRANSFER_ERROR=/tmp/dbback_file_transfer.err		# temp error file for FTP task
TMP_BACKUP_DIR=/var/tmp/temp_backup_$DATE
FILE_BACKUP=${HOSTNAME}_System_Files_${DATE}.tar.gz
DB_BACKUP=${HOSTNAME}_DB_Files_${DATE}.tar.gz
RSM_BACKUP=${HOSTNAME}_BACKUP_${DATE}.tar


# Any table whose name matches one of the following pattern will not be backed up 
# for example, if you have "temp" as a pattern below, all tables starting with the word "temp" will be skipped

SKIP_TABLES="activitylogs cdrsummary buysummary sellsummary cdrlogs cdrfiles est_rg PerformanceStatsData temp  hrbuy hrsell hrsum hrlogs"

declare -a TBL_to_SKIP=( $SKIP_TABLES )

# Simplex/HA check

ha_check() {
        if [ -e /usr/lib/ocf/resource.d/genband/jbossnew ] && [ -e /var/lib/heartbeat/crm/cib.xml ]; then
		# HA setup
		echo "RSM HA system detected ..."
                if ! /usr/sbin/crm_mon -1 | grep -q "Current DC"; then
                        echo "Can't determine HA status, exiting."
                        exit 1
                else
                        if ! /usr/sbin/crm_mon -1 | grep MySQL | grep Started | grep -i -q $HOSTNAME; then
                                echo "STANDBY server detected, will only back up the system files/dir ..."
				CLUSTER_STATUS=HA_STANDBY
			else
				echo "ACTIVE server detected, will back up both the system files/dir and database ..."
				CLUSTER_STATUS=HA_ACTIVE
			fi
                fi
        else
                echo "Simplex system detected ..."
		CLUSTER_STATUS=SIMPLEX
        fi
}

# MySQL check

mysql_check() {
        if [ $MAIN_VER -ge "6" ]; then                                   # it is 6.0 and up
                MYSQL_DS=$JBOSS_HOME/server/rsm/deploy/mysql-ds.xml
        else                                                            # all other (4.3 till 5.2.x, etc)
                MYSQL_DS=$JBOSS_HOME/server/default/deploy/mysql-ds.xml
        fi
        if [ -f $MYSQL_DS ]; then
                user=`cat $MYSQL_DS | grep user-name| head -1 | cut -f 2 -d ">" | cut -f 1 -d "<"`
                pass=`cat $MYSQL_DS | grep password | head -1 | cut -f 2 -d ">" | cut -f 1 -d "<"`
        else
                echo "File $MYSQL_DS doesn't exist. Make sure the that the RSM is installed properly. Exiting."; echo
                exit 1
        fi

        mysqldump="mysqldump --user=$user --password=$pass bn"
        mysql="mysql --user=$user --password=$pass bn"
}


# FTP Task
# Using FTP auto-login to transfer the backup file
# log in info etc should be defined in ~/.netrc file
# example of ~/.netrc file (chmod 600 is required on this file):
# machine ftp_IP/hostname login ftp_user password ftp_pass

ftp_task() {
        cd  $BACKUP_DIR
        echo; echo "Start uploading the backup file onto FTP server $REMOTE_SERVER in $REMOTE_DIR..."

$FTP -iv $REMOTE_SERVER <<EOF  | tee $TRANSFER_ERROR
bin
cd $REMOTE_DIR
put $RSM_BACKUP
quit
EOF
        if [ -s $TRANSFER_ERROR ]; then
                echo; echo "FTP transfer received an error. This could be due to one of the following reasons: "
		echo "1). The FTP upload failed, or "
		echo "2). The file transfer was successful, but the server returned an \"unknown command\" error "
		echo "    because of combatibility issue with the client. In this case, there is nothing to worry about. " 
		echo "Please see the file transfer log above for more details."; echo
        else
                echo; echo "FTP upload is successful."
        fi
        rm -f $TRANSFER_ERROR
}

# SCP Task
# SSH public/private key authentication must be set up prior to using this script
# And the authentication should not prompt for passphrase (empty passphrase when the keys are generated)
# The general steps to setup the SSH public/private key authentication are:
# 1) run "ssh-keygen" on the RSM to generate the key. Do not enter any passphrase
# 2) run "ssh-copy-id -i id_rsa.pub root@remote_host" to transfer the public key to the $REMOTE_SERVER
# 3) test the SSH

scp_task() {
        echo; echo "Start copying the backup file onto remote server $REMOTE_SERVER in $REMOTE_DIR ..."; echo
	$SCP $BACKUP_DIR/$RSM_BACKUP $SCP_USER@$REMOTE_SERVER:$REMOTE_DIR
	if [ ! $? -eq 0 ]; then
		echo; echo "SCP file transfer failed, please check logs for details."
	else
		echo; echo "SCP file transfer is successful."
	fi
}	

# file backup task

file_backup() {
        if [ ! -e $BACKUP_FILE_LIST ]; then
                echo "$BACKUP_FILE_LIST file not found, not able to backup system files ..."
                return 1
        fi
        echo; echo "Starting to backup system files ..."; echo
        echo "Backing up the $MYSQL_DS file ..."
        cp $MYSQL_DS $TMP_BACKUP_DIR                    # do it separately as $MYSQL_DS dir differ by version


        declare -a ARR_BACKUP_FILES=( `cat $BACKUP_FILE_LIST | grep "." | grep -v "^#" | tr "\n" " "` )
        n=0
        while [ $n -lt ${#ARR_BACKUP_FILES[@]} ]; do
                if [ -f  ${ARR_BACKUP_FILES[$n]} ]; then
                        echo "Backing up normal file ${ARR_BACKUP_FILES[$n]} ..."
                        cp ${ARR_BACKUP_FILES[$n]} $TMP_BACKUP_DIR
                        if [ ! $? -eq 0 ]; then
                                echo "Backing up of file ${ARR_BACKUP_FILES[$n]} failed ..."
                                return 1
                        fi
                fi
                if [ -d  ${ARR_BACKUP_FILES[$n]} ]; then
                        echo "Backing up directory ${ARR_BACKUP_FILES[$n]} ..."
                        cp -r ${ARR_BACKUP_FILES[$n]} $TMP_BACKUP_DIR
                        if [ ! $? -eq 0 ]; then
                                echo "Backing up of dir ${ARR_BACKUP_FILES[$n]} failed ..."
                                return 1
                        fi
                fi
                n=`expr $n + 1`
        done
        echo; echo "Done backing up system files."
	echo; echo "Creating archive file for system files/dir ..."; echo
	cd $TMP_BACKUP_DIR
	tar cvzf $FILE_BACKUP *
	if [ ! $? -eq 0 ]; then
                echo; echo "System file archive creation failed, please see log for details."
                return 1
        fi
        echo; echo "System file archive created, file is $TMP_BACKUP_DIR/$FILE_BACKUP"; echo

}

# DB Backup task

db_backup() {
        echo "Starting to backup the RSM DB tables ..."; echo
        TBL_NAME=(`$mysql -BNe "show tables" | tr '\n' ' '`)

        n=0
        while [ $n -lt ${#TBL_NAME[@]} ]; do
                MATCH=0
                # checking the table name against TBL_to_SKIP pattern and set the flag
                m=0
                while [ $m -lt ${#TBL_to_SKIP[@]} ]; do
                        MATCH_CNT_SKIP=`expr match ${TBL_NAME[$n]} ${TBL_to_SKIP[$m]}`
                        if [ $MATCH_CNT_SKIP -gt 0 ]; then
                                MATCH=1                 # matching pattern found
                                m=`expr $m + 1`
                                break                   # matching pattern found and skipped. no need to check remaining
                        fi
                        MATCH=0                         # no match found
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
                        echo "Backing up table ${TBL_NAME[$n]} ..."
                        $mysqldump ${TBL_NAME[$n]} > $TMP_BACKUP_DIR/${TBL_NAME[$n]}.sql
                        if [ ! $? -eq 0 ]; then
                                echo "Backing up of table  ${TBL_NAME[$n]} failed ..."
                                return 1
                        fi
                fi
                n=`expr $n + 1`
        done
        echo; echo "Done backing up the RSM DB tables."
	echo; echo "Creating archive file for RSM DB backup files ..."; echo 
	cd $TMP_BACKUP_DIR
	tar cvzf $DB_BACKUP *.sql
        if [ ! $? -eq 0 ]; then
                echo; echo "RSM DB archive file creation failed, please see log for details."
                return 1
        fi
        echo; echo "RSM DB file archive created, file is $TMP_BACKUP_DIR/$DB_BACKUP"; echo
	
}


# Archive task

create_archive() {
        echo "Creating backup archive ..."; echo
        cd  $TMP_BACKUP_DIR
	case $CLUSTER_STATUS in
		SIMPLEX|HA_ACTIVE)
        		tar -cf $BACKUP_DIR/$RSM_BACKUP $FILE_BACKUP $DB_BACKUP
			if [ $? -eq 1 ]; then
                		echo "Backup archive creation failed ..."
				return 1
			fi
			;;
		HA_STANDBY)		# only 1 file to archive
        		tar -cf $BACKUP_DIR/$RSM_BACKUP $FILE_BACKUP
			if [ $? -eq 1 ]; then
                		echo "Backup archive creation failed ..."
				return 1
			fi
			;;
		*)                              # should not come here
			echo; echo "Invalid cluster status detected. Script could have hit a bug. Exiting."
			return 1
			;;
	esac
        echo "Backup archive created, backup file is $BACKUP_DIR/$RSM_BACKUP"; echo
        echo "Deleting the temporary backup dir $TMP_BACKUP_DIR ..."
        rm -rf $TMP_BACKUP_DIR
}

# Main

echo; echo "-------------------------------------------------------"
echo; echo "Backup start time: `date`"; echo
ha_check
mysql_check

if [ ! -d $BACKUP_DIR ]; then
        echo "Backup dir $BACKUP_DIR doesn't exist exiting."; echo
	exit 1
fi

if [ ! -d $TMP_BACKUP_DIR ]; then
        echo "Creating temporary backup dir $TMP_BACKUP_DIR ..."
        mkdir $TMP_BACKUP_DIR
else
        rm -rf $TMP_BACKUP_DIR/*        # clean the temp dir before proceed
fi

file_backup
if [ $? -eq 1 ]; then
        echo "DB backup failed, please check logs for details."
	exit 1
fi

# backup the DB only when it is SIMPLEX, or HA ACTIVE

case $CLUSTER_STATUS in
	SIMPLEX)
		echo; echo "RSM Simplex server, proceed to back up the database ..."
		$mysql -e "use bn"
		if [ ! $? -eq 0 ]; then
			echo "Can't log into the MySQL server. Please make sure that the MySQL is running."
			exit 1
		fi
		db_backup
		if [ $? -eq 1 ]; then
			echo; echo "Database backup failed,  please check logs for details."
			exit 1
		fi
		;;
	HA_ACTIVE)
		echo; echo "RSM HA Active server, proceed to back up the database ..."
		$mysql -e "use bn"
		if [ ! $? -eq 0 ]; then
			echo "Can't log into the MySQL server. Please make sure that the MySQL is running."
			exit 1
		fi
		db_backup
		if [ $? -eq 1 ]; then
			echo; echo "Database backup failed,  please check logs for details."
			exit 1
		fi
		;;
	HA_STANDBY)
		echo; echo "HA Standby server, will not back up the database on this server."
		;;
	*)				# should not come here
		echo; echo "Invalid cluster status detected. Script could have hit a bug. Exiting."
		exit 1
		;;
esac

create_archive
if [ $? -eq 1 ]; then
        echo "Create backup archive file failed,  please check logs for details."
        exit 1
fi

case $REMOTE_BACKUP_OPT in
	FTP)
		ftp_task
		;;
	SCP)
		scp_task
		;;
	NONE)
		echo; echo "Remote backup option is set to NONE. Will not transfer backup file to remote server."
		;;
	*)
		echo; echo "Invalid value for REMOTE_BACKUP_OPT, will not transfer backup file to remote server."
esac

echo; echo "Backup end time: `date`"
echo; echo "-------------------------------------------------------"; echo

############################### END of SCRIPT ##########################################
