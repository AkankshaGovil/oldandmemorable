#!/bin/sh

check_mysql_by_checkproc() {
    checkproc mysqld
    if [ $? -ne 0 ]; then
        MYSQL_RUNNING='0'
    else
        MYSQL_RUNNING='1'
    fi
}

rsync_pam_files() {
	MSG=`rsync -avzr -e "ssh -o StrictHostKeyChecking=no -i /root/.ssh/ssh-key-for-rsync" --files-from=/etc/ha.d/pam_files_to_sync  /etc %PEER_HEARTBEAT_IP%:/etc 2>&1`
    	if [ $? -ne 0 ]; then
			MSG=`rsync -avzr -e "ssh -o StrictHostKeyChecking=no -i /root/.ssh/ssh-key-for-rsync" --files-from=/etc/ha.d/pam_files_to_sync  /etc %PEER_HEARTBEAT_IP_0%:/etc 2>&1`
			if [ $? -ne 0 ]; then
				logger "$0 failed: $MSG"
			fi
    	fi
}

MYSQL_RUNNING='0'
for((;;))
do
	check_mysql_by_checkproc
	if [ $MYSQL_RUNNING -eq '1' ]; then
		rsync_pam_files
	fi
	sleep 5
done
