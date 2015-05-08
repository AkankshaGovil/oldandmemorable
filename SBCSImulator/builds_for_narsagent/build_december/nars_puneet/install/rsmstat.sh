#!/bin/sh

# This script provides RSM system status and CDR stat info. It works on only RSM server 4.3 and above
# Bilig Oyun, GENBAND Inc
# Change Logs:
# Dec 27, 2006 - Initial release, rel1.0
# June 19, 2007 - rel2.0, added handling of SuSE OS, added check for temp tables, and added the DB stat
# Feb 25, 2008 - rel2.1 : 
# 1), changes to reflect new company name and branding
# 2), some code cleanup
# 3), added option to show network info
# 4), added "-l" option to show license
# 5), removed "-a" option
# 6, added code to show usage for '/opt/nxtn' partition
# 7, changed the way it detects the OS version (no longer using /etc/issue)
# 8, support for 5.0 and 5.1
# 9, added check for interface stats, bn.properties and logger.properties - Aug 06, 2008
# 10, added check for auto-rerate, max cdrs per table, unrated tables, open file descriptor for JBOSS and optimized db stat code - Aug 28, 2008
# 11, added check for ntp and dns server config - Sept 05, 2008
# Feb 17, 2009 - branding change - rel3.1
# April 21, 2009 - rel4.0 - updated the script for 5.2:
# 1) don't show WARN for memLogHandler.level=ALL
# 2) fixed the WARN for Ethernet interface errors - using ifconfig instead of ip command
# 3) now only show the interface that has IP address configured
# 4) added check for OS patch level (5.2 only)
# 5) commented out the check for cronjob to trim JBOSS logs
# Jan 21, 2010 - rel4.1:
# 1) added support for RSM HA system
# 2) added info about cdr table partition size
# 3) fixed minor issues
# Nov 10, 2010 - rel4.2
# 1) added ha_status to show whether system is HA, or simplex
# 2) added support for 6.0.x
# March 17, 2011 - rel5.0
# 1) added system info section and other minor updates
# 2) tweaked some of the thresholds to be more tolerant
# July 26, 2011 - rel5.1
# added support for 7.x
# Oct 06, 2011 - rel5.2
# 1) added check for default gateway
# 2) updated display info about devices
# 3) some other minor changes
# Jan 04, 2012 - rel5.3
# 1) added support for 8.x
# April 05, 2012 - rel5.4
# 1) added support for -td option to display additional info about CDR tables
# 2) other minor updates
# May 02, 2012 - rel6.0
# 1) support for RSM Hardware Freedom (Redhat) 
#	- for Redhat, use dmidecode and /proc/xxxx to get hardware/system info
#	- added code to handle network interface name that is not eth[0-9]
# 2) now properly show the SBC IP with "-d" option in 8.x. Since 8.0 the IP is stored as dotted decimal

# Config

SCRIPT_VER="Rel6.0, May 02, 2012"
JBOSS_INIT=/etc/init.d/jboss
WEB_PORT=443                                            # Web service port
MYSQL_PORT=3306                                         # MySQL port
NEX_HOME=/opt/nxtn
RSM_HOME=$NEX_HOME/rsm
JBOSS_HOME=$NEX_HOME/jboss
BN_PROP=$RSM_HOME/bn.properties
PART_HI_THRESHOLD=90                                    # Partition usage high threshold
MYSQL_DB_THRESHOLD=4096000                              # MySQL DB usuage threshold, 4000x1024=4000 M
TZ=`date +%Z`
DATE=`date +"%F %T"`
VER=`cat $RSM_HOME/.ivmsindex`                          # RSM version
MAIN_VER=`echo $VER | cut -c 1`
LONG_RUNNING_QUERY=600                                  # considered a long running query if running longer than this (in sec)
TEMP_TABLE_THRESHOLD=10
TOTAL_CDR_THRESHOLD=1000000
UNRATED_TBL_THRESHOLD=6                                 # threshold for cdr tables whose status is not equal to 22
WARN_CNT=0
JBOSS_LSOF_THRESHOLD=600                                # threshold for large number of open FD for JBOSS
LSOF=`which lsof`
HOSTNAME=`hostname`

# Simplex/HA check

if [ -e /usr/lib/ocf/resource.d/genband/jbossnew ] && [ -e /var/lib/heartbeat/crm/cib.xml ]; then
        HA="HA"                                            # HA setup
        if ! crm_mon -1 | grep -q "Current DC"; then
                if ! /etc/init.d/heartbeat status | grep -q OK; then
                        echo "The heartbeat process is not running on the server. Please check. "
                        exit 1
                else
                        echo "The heartbeat process is likely being initialized , please run the script again after 5 min. "
                        exit 1
                fi
        fi

        if ! crm_mon -1 | grep MySQL | grep -i -q $HOSTNAME; then
                echo "Please run this script on the active server. Exiting ..."
                exit 1
        fi
else
        if [ -e $JBOSS_INIT ]; then
                if grep -q JBOSS_HOME=/usr/local/jboss $JBOSS_INIT; then
                        echo "This server doesn't seem to have 4.3 or above GenView-RSM installed."
                        echo "Please use the \"ivmsstat.sh\" script if you are on iVMS 4.0. Exiting ..."
                        exit 1
                fi
        else
                echo "JBOSS startup script doesn't exist. Looks like the GenView-RSM server is not installed properly. Exiting ..."
                exit 1
        fi      
        HA="simplex"                                            # Simplex and 4.3 and up
fi

# check OS and version 

if [ -e /etc/SuSE-release ]; then
        OS="SUSE"
        OS_VER=`cat /etc/SuSE-release | grep SUSE`
else
        if [ -e /etc/redhat-release ]; then
        OS="REDHAT"
        OS_VER=`cat /etc/redhat-release`
        else
                echo "Neither REDHAT nor SUSE OS detected, exiting ..."
                exit 1
        fi
fi

if [ $OS == "SUSE" ] && [ $MAIN_VER -ne 4 ]; then
        if cat /etc/SuSE-release | grep -q PATCHLEVEL; then
                OS_PATCH_LEVEL=`cat /etc/SuSE-release | grep PATCHLEVEL`
        fi
fi

# Set the right JBOSS dirs to handle RSM 6.0.x and up

if [ $MAIN_VER -ge "6" ]; then					# it is 6.0 and up
	JBOSS_LOG_DIR=$NEX_HOME/jboss/server/rsm/log
	JBOSS_DEP=$JBOSS_HOME/server/rsm/deploy
	MYSQL_DS=$JBOSS_HOME/server/rsm/deploy/mysql-ds.xml
else								# all other (4.3 till 5.2.x, etc)
	JBOSS_LOG_DIR=$NEX_HOME/jboss/server/default/log
	JBOSS_DEP=$JBOSS_HOME/server/default/deploy
	MYSQL_DS=$JBOSS_HOME/server/default/deploy/mysql-ds.xml
fi

# Get MySQL username and password

if [ -e $MYSQL_DS ]; then
        user=`grep -m 1 user-name $MYSQL_DS | cut -f 2 -d ">" | cut -f 1 -d "<"`
        pass=`grep -m 1 password $MYSQL_DS | cut -f 2 -d ">" | cut -f 1 -d "<"`
else
        echo "File $MYSQL_DS doesn't exist. Make sure the RSM is installed properly. Exiting"
        exit 1
fi

mysql="mysql --user=$user --password=$pass"
MYSQL_VER=`$mysql -BNe "select version()"`

# Test MySQL log in

$mysql -e "use bn" > /dev/null
if [ ! $? -eq 0 ]; then
        echo "Couldn't log into the MySQL. Please make sure the MySQL server is running properly. Exiting ..."
        exit 1
fi

# Version number

version()
{
        echo -e "[INFO]  GENBAND GenView-RSM version:\tRSM $HA $VER"
        echo -e "[INFO]  OS version:\t\t\t$OS_VER"
        if [ $OS == "SUSE" ] && [ $MAIN_VER -eq 5 ]; then                       # SLES 9 SP4 for only 5.x release
                if [ "$OS_PATCH_LEVEL" ]; then
                        echo -e "[INFO]  OS patch level:\t\t\t$OS_PATCH_LEVEL"
                else
                        echo -e "[WARN]  SuSE OS patch is not installed"
                        WARN_CNT=`expr $WARN_CNT + 1`
                fi
        fi
        echo -e "[INFO]  MySQL version:\t\t\t$MYSQL_VER"
        echo -e "[INFO]  Version of this script:\t\t$SCRIPT_VER"
        echo
}

# HA Status

ha_status()
{
	if [ $HA == "HA" ]; then
		echo -e "[INFO]  RSM HA System, ACTIVE" 		# ACTIVE is implied. Script does not run on STANDBY
	else
		echo -e "[INFO]  RSM Simplex System"
	fi
}

# JBOSS Status

jboss_status()
{
        jboss_thread=`ps -ef | grep jboss | grep -v grep | wc -l`
        listen=`netstat -an | grep $WEB_PORT| grep LISTEN`
        if [ $jboss_thread -gt "0" ]; then
                if [ "$listen" ]; then
                        jboss_uptime=`ps -eo "%c %t" | grep java | awk '{print $2}'`
                        echo "[INFO]  JBOSS is running and listening to port $WEB_PORT. Up time is $jboss_uptime (day-hh:mm:ss)"
                else
                        echo "[WARN]  JBOSS seems to be running but not listening to port $WEB_PORT"
                        WARN_CNT=`expr $WARN_CNT + 1`
                fi
                JBOSS_LSOF_CNT=`pgrep java | head -1 | xargs $LSOF -p | wc -l`
                if [ $JBOSS_LSOF_CNT -ge $JBOSS_LSOF_THRESHOLD ]; then
                        echo "[WARN]  Large number of open file descriptor found for JBOSS"
                        WARN_CNT=`expr $WARN_CNT + 1`                   
                fi
        else
                echo "[WARN]  JBOSS is not running"
                WARN_CNT=`expr $WARN_CNT + 1`
        fi
}

# MySQL Status

mysql_status()
{
        mysql_thread=`pgrep mysql| wc -l`
        mysql_listen=`netstat -an | grep $MYSQL_PORT| grep LISTEN`
        if [ $mysql_thread -gt "0" ]; then
                if [ "$mysql_listen" ]; then
                        mysql_uptime=`mysqladmin --user=$user --password=$pass version | grep Uptime | awk '{print $2,$3,$4,$5,$6,$7}'`
                        echo "[INFO]  MySQL is running and listening to port $MYSQL_PORT. Up time is $mysql_uptime"
                        else
                                echo "[WARN]  MySQL seems to be running but not listening to port $MYSQL_PORT"       
                                WARN_CNT=`expr $WARN_CNT + 1`
                fi
        else
                echo "[WARN]  MySQL is not running"
                WARN_CNT=`expr $WARN_CNT + 1`
        fi
}

# NTP 

ntp_dns_status()
{
        NTPQ_TMP_FILE=/tmp/ntpq.err
        ntpq -p 2> $NTPQ_TMP_FILE > /dev/null
        if cat $NTPQ_TMP_FILE | grep -q refuse; then
                echo "[WARN]  Either no NTP server configured, or the server is not reachable"
                WARN_CNT=`expr $WARN_CNT + 1`
        fi
        rm -f $NTPQ_TMP_FILE 
        if [ ! -f /etc/resolv.conf ]; then
                echo "[WARN]  /etc/resolv.conf file not found"
                WARN_CNT=`expr $WARN_CNT + 1`
        elif ! grep -q nameserver /etc/resolv.conf; then
                echo "[WARN]  Name server (DNS server) not configured for this server"
                WARN_CNT=`expr $WARN_CNT + 1`
        fi
}

# Check cron

cron_status()
{
		if [ $MAIN_VER -ge "6" ]; then					# it is 6.0 and up
		JBOSS_LOG_DIR=$NEX_HOME/jboss/server/rsm/log
		else								# all other (4.3 till 5.2.x, etc)
		JBOSS_LOG_DIR=$NEX_HOME/jboss/server/default/log
		fi

        logtrim_cron=`crontab -l | grep -v "^#" | grep "$JBOSS_LOG_DIR" | wc -l`
        if [ ! $logtrim_cron -ge 1 ]; then
                echo "[WARN]  Cronjob to trim JBOSS log is probably not installed. Please install the following cron:"
                WARN_CNT=`expr $WARN_CNT + 1`
                echo "5 0 * * * (if [ -d $JBOSS_LOG_DIR ]; then cd $JBOSS_LOG_DIR; find . -name 'server.log.*' -mtime +7 -exec rm -f {} \; ; fi)"
        else
                echo "[INFO]  Cronjob to trim JBOSS log is probably installed"
        fi
}

# Check multiple .ear files in $JBOSS_DEP dir 

ear_file_status()
{
        ear_file_count=`ls -la $JBOSS_DEP/*.ear | wc -l`
        if [ $ear_file_count -gt 1 ]; then 
                echo "[WARN]  More than one .ear files detected in $JBOSS_DEP dir. Please remove all except the bn.ear"
                WARN_CNT=`expr $WARN_CNT + 1`
                else
                        echo "[INFO]  Only one .ear file detected in $JBOSS_DEP dir, which is good"
        fi
        echo
}

# check for bn.properties

bn_prop()
{
        if [ ! -e $BN_PROP ]; then 
                echo "[WARN]  $BN_PROP file doesn't exist"
                WARN_CNT=`expr $WARN_CNT + 1`
        else
                if [ ! -s $BN_PROP ]; then
                        echo "[WARN]  $BN_PROP file is 0 in size"
                        WARN_CNT=`expr $WARN_CNT + 1`
                else
                        echo "[INFO]  $BN_PROP file exists and size is not 0"
                        if grep -q "rerater.auto=true" $BN_PROP; then
                                echo "[WARN]  Automatic rerating is enabled, which could slow down the system"
                                WARN_CNT=`expr $WARN_CNT + 1`
                        fi
                fi
        fi
}

# check for cdr table partition size

cdr_partition()
{
        CDR_PART_SIZE=`cat $BN_PROP | grep "cdr.partition" | cut -f2 -d"="`
        if [ $MAIN_VER != "4" ] && [ $CDR_PART_SIZE -ge 3600 ]; then
                CDR_PART_SIZE=`expr $CDR_PART_SIZE / 3600`
                echo "[INFO]  CDR table partition size is $CDR_PART_SIZE hour"
        elif [ $MAIN_VER != "4" ] && [ $CDR_PART_SIZE -lt 3600 ]; then
                CDR_PART_SIZE=`expr $CDR_PART_SIZE / 60`
                echo "[INFO]  CDR table partition size is $CDR_PART_SIZE min"
        else
                echo "[INFO]  CDR table partition size is $CDR_PART_SIZE hour"
        fi
}

# check for log levels

log_level()
{
        LOG_CFG=$RSM_HOME/logger.properties
        NON_DEFAULT="INFO\|CONFIG\|FINE\|FINER\|FINEST\|ALL"
        if [ -e $LOG_CFG ]; then
                if cat $LOG_CFG | grep -v '^#'| grep "nextone.bn" | grep -q $NON_DEFAULT || cat $LOG_CFG | grep -v '^#'| grep -v "memLogHandler" | grep ".level=" | grep -q $NON_DEFAULT; then
                        echo "[WARN]  Some log levels are set to higher than the default, which could slow down the system"
                        WARN_CNT=`expr $WARN_CNT + 1`
                else
                        echo "[INFO]  Log levels are all set to the default"
                fi
        else
                echo "[WARN]  $LOG_CFG file doesn't exist"
                WARN_CNT=`expr $WARN_CNT + 1`
        fi
}

# Partition space

part_space()
{
        declare -a PART
        PART=(`df -h  | grep -v "Mounted"| awk '{print $6}' | tr "\n" " "`)
        declare -a PART_USAGE
        PART_USAGE=(`df -h  | grep -v "Mounted" | awk '{print $5}' | cut -f1 -d"%"| tr "\n" " "`)
	PART_SPACE=(`df -h  | grep -v "Mounted" | awk '{print $4}' | tr "\n" " "`)
        PART_TMP_FILE=/tmp/part.usage
        i=0
        while [ $i -lt ${#PART[@]} ]; do
                if [ ${PART_USAGE[$i]} -ge $PART_HI_THRESHOLD ]; then
                        echo  "[WARN] \"${PART[$i]}\" - ${PART_USAGE[$i]}% (${PART_SPACE[$i]} free) - Partition Usage is Too High" >> $PART_TMP_FILE
                        WARN_CNT=`expr $WARN_CNT + 1`
                        i=`expr $i + 1`
                else
                        echo "[INFO] \"${PART[$i]}\" - ${PART_USAGE[$i]}% (${PART_SPACE[$i]} free)" >> $PART_TMP_FILE
                        i=`expr $i + 1`
                fi
        done
        cat $PART_TMP_FILE | column -t                                                  # print it nicely 
        rm -f $PART_TMP_FILE
}

# Database space

db_space()
{
        case $MAIN_VER in
                3)
                mysql_db_space=`$mysql bn -BNe "show table status like 'cdr'" | cut -f 2 -d ":" | cut -f 2 -d " "`
                ;;
                4|5|6|7|8|9)
                mysql_db_space=`$mysql bn -BNe "show table status like 'cdr'" | cut -f 4 -d ":" | cut -f 2 -d " "`
                ;;
                *)
                echo "Unsupported RSM version detected, or the script has run into problem, exiting ..."
                exit 1;;
        esac
        mysql_db_space_in_G=`expr $mysql_db_space / 1024 / 1024`
        if [ $mysql_db_space -lt $MYSQL_DB_THRESHOLD ]; then
                echo "[WARN]  Available MySQL database space is only $mysql_db_space_in_G G, please delete old CDRs. Contact GENBAND Support for details"
                WARN_CNT=`expr $WARN_CNT + 1`
        else
                echo "[INFO]  Free MySQL DB space     -  $mysql_db_space_in_G G"
        fi
        echo
}

# DB Stat

db_stat()
{
declare -a TBL=(vnet realms endpoints callingplans callingroutes cpbindings)

# Devices
        sleep 2;
        msw_no=`$mysql bn -BNe "select count(*) from msws where clusterid > 0"`
        echo "=== Devices --- $msw_no Devices/SBC configured ==="; echo
	if [ $MAIN_VER -lt 8 ]; then
	        $mysql bn -e "select clusterid as 'Cluster ID', mswid as 'SBC ID', mswname as 'SBC Hostname', inet_ntoa(mswip) as 'SBC MGMT IP', flag as Flag,  IF(dataCollectionEnabled = '0', 'Disabled', 'Enabled') as 'SNMP Polling', currentVersion as 'Current SBC Version' from msws where clusterid > 0 order by clusterid"; echo
	fi
	if [ $MAIN_VER -ge 8 ]; then		# from 8.0 we store the IP as dotted decimal format
	        $mysql bn -e "select clusterid as 'Cluster ID', mswid as 'SBC ID', mswname as 'SBC Hostname', mswip as 'SBC MGMT IP', flag as Flag,  IF(dataCollectionEnabled = '0', 'Disabled', 'Enabled') as 'SNMP Polling', currentVersion as 'Current SBC Version' from msws where clusterid > 0 order by clusterid"; echo
	fi
# Partitions
        sleep 2;
        group_no=`$mysql bn -BNe "select count(*) from groups where partitionid >= 1"`
        echo "=== Partitions --- $group_no Partitions configured ==="; echo
        $mysql bn -e "select groupname as 'Partition Name', partitionid as 'ID' from groups where partitionid >= 1 order by groupname"
        echo;

# Users
        sleep 2;
        user_no=`$mysql bn -BNe "select count(*) from users where partitionid >= 1"`
        echo "=== Users --- $user_no Users configured ==="; echo
        $mysql bn -e "select users.username as 'User Name', groups.groupname as 'Partition' from users join groups on users.partitionid = groups.partitionid where users.partitionid >= 1 group by users.username order by users.username"
        echo;

# Regions
        sleep 2;
        region_no=`$mysql bn -BNe "select count(*) from regions"`
        echo "=== Regions --- $region_no Dialcodes configured in the regions table ===";echo;
        $mysql bn -e "select groups.groupname as 'Partition name', count(*) as 'Dialcode Count' from regions join groups on groups.partitionid = regions.partitionid group by regions.partitionid order by groups.groupname"
        echo;

# Alarms
        sleep 2;
        alarm_no=`$mysql bn -BNe "select count(*) from alarms"`
        echo "=== Alarms --- $alarm_no alarms configured in the alarms table ===";echo;
        $mysql bn -e "select groups.groupname as 'Partition name', count(*) as 'Alarm Count' from alarms join groups on groups.partitionid = alarms.partitionid group by alarms.partitionid order by groups.groupname"
        echo;

# Other tables
        for TABLE in ${TBL[@]}; do
                sleep 2
                NO=`$mysql bn -BNe "select count(*) from $TABLE"`
                echo "=== $TABLE --- $NO $TABLE configured ==="; echo
                echo "$TABLE by partition - "
                $mysql bn -t -e "select groups.groupname as 'Partition name', count(*) as '$TABLE Count' from $TABLE join groups on groups.partitionid = $TABLE.partitionid group by $TABLE.partitionid order by groups.groupname"; echo
                echo "$TABLE by Cluster ID - "
                $mysql bn -e "select clusterid as 'Cluster ID', count(*) as '$TABLE Count' from $TABLE group by clusterid order by clusterid"
                echo;
        done

}

# CDR Stat

cdr_stat()
{
        total_cdrs=`$mysql bn -BNe "select sum(totalcdrs) from cdrlogs"`
        if [ $total_cdrs = "NULL" ]; then
                echo "[WARN]  Didn't find any CDRs on the server. This is probaly a new installation." 
                WARN_CNT=`expr $WARN_CNT + 1`
                echo "Please contact GENBAND support if it is not the case"; echo
        else
                MAX_CDR=`$mysql bn -BNe "select max(totalcdrs) from cdrlogs"`
                if [ $MAX_CDR -gt $TOTAL_CDR_THRESHOLD ]; then
                        echo "[WARN]  CDR tables with more than $TOTAL_CDR_THRESHOLD CDRs detected, which could affect the system performance"
                        WARN_CNT=`expr $WARN_CNT + 1`
                fi
                UNRATED_TBL_CNT=`$mysql bn -BNe "select count(*) from cdrlogs where status != 22"`
                if [ $UNRATED_TBL_CNT -ge $UNRATED_TBL_THRESHOLD ]; then
                        echo "[WARN]  $UNRATED_TBL_CNT unrated or unsummarized CDR tables found"
                        WARN_CNT=`expr $WARN_CNT + 1`
                fi
                echo "[INFO]  Total number of CDRs in RSM DB is $total_cdrs"
                first_cdr_date=`$mysql bn -BNe "select min(from_unixtime(startdateint)) from cdrlogs" | cut -f 1 -d " "`
                echo "[INFO]  The earliest CDRs in RSM DB is from $first_cdr_date"
                last_table=`$mysql bn -BNe "select max(cdrtablename) from cdrlogs"`
                last_table_start=`$mysql bn -BNe "select from_unixtime(startdateint) from cdrlogs where cdrtablename='$last_table'"`
                last_table_end=`$mysql bn -BNe "select from_unixtime(enddateint) from cdrlogs where cdrtablename='$last_table'"`
                echo "[INFO]  The last table in the DB is $last_table ($last_table_start - $last_table_end $TZ)"
                echo "[INFO]  The date & time of the last CDR in the table is: " 
                $mysql bn  -e "select msws.mswname as 'MSx Name', max(from_unixtime(datetimeint)) as 'Last CDR Date & time ($TZ)' from msws join $last_table on msws.mswid = $last_table.mswid   group by msws.mswid"
                echo  "[INFO]  It is $DATE $TZ right now"
                echo
        fi
}

# CDR table status

cdr_table_status()
{
        echo "[INFO]  CDR Table Summary Info: "
        total_tables=`$mysql bn -BNe "select count(*) from cdrlogs"`
        echo "The following CDR tables are present in the DB ($total_tables tables in total): "; echo
        $mysql bn -e "select cdrtablename as 'CDR Table', from_unixtime(startdateint) as 'Start Date & Time' , from_unixtime(enddateint) as 'End Date & Time', totalcdrs as 'Total CDRs', status as 'Status Value' from cdrlogs order by startdateint"
        echo "$total_tables tables in total"
        echo
}

# CDR table status with details -
# list the last insertion, last modified and created date/time for troubleshooting rating and summarizer issues
# inoke with -td option

cdr_table_status_detail()
{
        echo "[INFO]  CDR Table Summary Info: "
        total_tables=`$mysql bn -BNe "select count(*) from cdrlogs"`
        echo "The following CDR tables are present in the DB ($total_tables tables in total): "; echo
        $mysql bn -e "select cdrtablename as 'CDR Table', from_unixtime(startdateint) as 'Start Date & Time' , from_unixtime(enddateint) as 'End Date & Time', totalcdrs as 'Total CDRs', status as 'Status Value' , from_unixtime(LastInsertionInt) as 'Last Insert', from_unixtime(LastModifiedInt) as 'Last Modified', from_unixtime(CreatedInt) as 'Created' from cdrlogs order by startdateint"
        echo "$total_tables tables in total"
        echo
}

# Help text

help()
{
        echo "
        GENBAND GenView-RSM System Status and Statistics Script
        $SCRIPT_VER 

        The following options are currently supported for this script:

                no argument: Show everyting except CDR Table Summary Info and DB stat info
                -t: table only, display CDR Table Summary Info only
                -td: table only with details, display CDR Table Summary Info with  more details
                -v: version, display version info only
                -d: DB, display DB statistics only
                -p: process, display long running processes/queries only
                -l: license, displays the current RSM license
                -h: help, display the usage help

        The following also can be configured by editing the "Config" section of the script:

                - Web service port, default is 443
                - MySQL port, default is 3306
                - Partition usage high threshold (%), default is 90%
                - MySQL DB space usage threshold (KB), default is 4096000, or 4000M.
                If the available DB space is less than this, a warning message is displayed
                - Long running queries, default is 600 sec. Any queries running longer than this is considered long
        "; echo
}

# Process status

process_status()
{
        long_query=`$mysql -BNe "show processlist"| awk '{if (($7 != "NULL") && ($6 >= '"$LONG_RUNNING_QUERY"')) print $1}' | wc -l`
        if [ $long_query -eq 0 ]; then
                echo "[INFO]  No long running queries found"
        else
                echo "[WARN]  Found the following queries that have been running for more than $LONG_RUNNING_QUERY sec: "; echo
                WARN_CNT=`expr $WARN_CNT + 1`
                echo "Id        User    Host            DB      Command Time    State   Query" 
                echo "-----------------------------------------------------------------------"
                $mysql -BN -e "show processlist" | awk '{if (($7 != "NULL") && ($6 >= '"$LONG_RUNNING_QUERY"')) print}'
                echo "-----------------------------------------------------------------------"; echo
                echo "Long running queries can slow down system performance, and/or CDR streaming." 
                echo "Please contact GENBAND support for how to terminate the queries without affecting your system."
                echo
        fi
}

# temp table check

temp_table_status()
{
        TEMP_TABLE_COUNT=`$mysql bn -BNe "show tables like 'temp%'" | wc -l`
        if [ $TEMP_TABLE_COUNT -ge $TEMP_TABLE_THRESHOLD ]; then
                echo "[WARN]  Large number of temp tables found in the DB, which may slow down the system"
                WARN_CNT=`expr $WARN_CNT + 1`
        else
                echo "[INFO]  Didn't find large number of temp tables in DB, which is good"
        fi
}

# Network info

network()
{
        INTERFACE=`ip -f inet addr | grep "state UP" | head -1 | tr -d [:space:] | cut -f2 -d ":"`
        IP_ADDR=`ip addr show $INTERFACE | grep -w inet | cut -f1 -d"/" | cut -f6 -d" " | head -1`
        MAC_ADDR=`ip addr show $INTERFACE | grep ether | cut -f6 -d" "`
        echo -e "[INFO]  Hostname:\t\t\t$HOSTNAME"
        echo -e "[INFO]  $INTERFACE IP: \t\t\t$IP_ADDR"
        if [ $HA == "HA" ]; then
                VIP=`cat /var/lib/heartbeat/crm/cib.xml | grep 'name="ip"' | cut -f6 -d'"'`
                echo -e "[INFO]  HA shared/virtual IP address:\t$VIP"
        fi
        echo -e "[INFO]  $INTERFACE MAC:\t\t\t$MAC_ADDR"

	# check default gateway config for SuSE
	if [ $OS == "SUSE" ]; then
		if [ ! -f  /etc/sysconfig/network/routes ]; then
			echo "[WARN]  Default gateway config file \"/etc/sysconfig/network/routes\" not found"
			echo "        Please use \"yast\" to reconfigure the default gateway"
			WARN_CNT=`expr $WARN_CNT + 1`
		elif ! grep -q default /etc/sysconfig/network/routes; then
			echo "[WARN]  No default gateway configured. Please use \"yast\" to configure a default gateway"
			WARN_CNT=`expr $WARN_CNT + 1`
		fi
	fi

        SPEED=`ethtool $INTERFACE | grep Speed | awk {'print $2'}`
        DUPLEX=`ethtool $INTERFACE | grep Duplex | awk {'print $2'}`
        if [ $DUPLEX != "Full" ]; then
                echo "[WARN]  $INTERFACE speed is at $SPEED $DUPLEX duplex. Full duplex is recommended"
                WARN_CNT=`expr $WARN_CNT + 1`
        else
                echo -e "[INFO]  $INTERFACE Speed:\t\t\t$SPEED $DUPLEX duplex"
        fi

        COLLISION=`ip -s link show $INTERFACE | grep -A 1 collsns | grep -v collsns | awk  {'print $6'}`
        if [ $COLLISION -gt 0 ]; then
                echo -e "[WARN]  Collisions on interface $INTERFACE"
                WARN_CNT=`expr $WARN_CNT + 1`
        else
                echo -e "[INFO]  No Collisions on interface $INTERFACE"
        fi

        ERR_RX=`ifconfig $INTERFACE | grep -w -m 1 RX | awk {'print $3'} | cut -f2 -d":"`
        ERR_TX=`ifconfig $INTERFACE | grep -w -m 1 TX | awk {'print $3'} | cut -f2 -d":"`
        if [ $ERR_TX -gt 0 ] || [ $ERR_RX -gt 0 ]; then
                echo "[WARN]  Errors on interface $INTERFACE"
                WARN_CNT=`expr $WARN_CNT + 1`
        else
                echo "[INFO]  No errors on interface $INTERFACE"
        fi

        DROP_RX=`ip -s link show $INTERFACE | grep -w -A 1 RX | tail -1 | awk {'print $4'}`
        DROP_TX=`ip -s link show $INTERFACE | grep -w -A 1 TX | tail -1 | awk {'print $4'}`
        if [ $DROP_TX -gt 0 ] || [ $DROP_RX -gt 0 ]; then
                echo "[WARN]  Dropped packets on interface $INTERFACE"
                WARN_CNT=`expr $WARN_CNT + 1`
        else
                echo "[INFO]  No dropped packets on interface $INTERFACE"
        fi
        echo
}

# License

license()
{
        echo "Below is your current RSM license: "; echo
        echo -e `$mysql bn -BNe "select File from license"`
        echo
}

# hardware info

hw_info()
{
	if [ $OS == "SUSE" ]; then	
		HW_TYPE=`hwinfo --bios | grep "Product id" | cut -f2 -d'"'`

		case $HW_TYPE in
		"SWV25")
			echo "[WARN]  \"Westville\" server, End of Life and out of support"
			WARN_CNT=`expr $WARN_CNT + 1`
			;;
		"SE7520JR22")
			echo "[INFO]  \"Jarrell\" server"
			;;
		"S5000PAL")
			echo "[INFO]  \"Annapolis\" server"
			;;
		*)
			echo "[WARN] Unknown server type detected. Make sure it is a GENBAND server!!!"
			WARN_CNT=`expr $WARN_CNT + 1`
			;;
		esac
		

		MEM_SIZE=`hwinfo --memory | grep "Memory Size"`
		echo "[INFO]  Installed$MEM_SIZE"
	fi

	if [ $OS == "REDHAT" ]; then
		VENDOR=`dmidecode -t system | grep Manu | cut -d" " -f2-`
		MODEL=`dmidecode -t system | grep Product | cut -d" " -f3-`
		echo "[INFO]  RSM Hardware Freedom - $VENDOR $MODEL"
		MEM_SIZE=`grep MemTotal /proc/meminfo  | tr -s [:space:] " " | cut -f2 -d" "`
		MEM_SIZE_GB=`expr $MEM_SIZE / 1024 / 1024`
		echo "[INFO]  Installed Memory Size: $MEM_SIZE_GB GB"
		CPU_CNT=`dmidecode -t processor | grep "Core Count" | cut -f3 -d" "`
		CPU_MODEL=`dmidecode -t processor | grep Version | cut -f2- -d" " | tr -s [:space:]`
		echo "[INFO]  No. of CPU Cores and Model: $CPU_CNT x $CPU_MODEL"
	fi
	echo
	
}


# Banner

banner()
{
        clear
        echo "
                                ### GENBAND GenView-RSM System Status and Statistics ###
                                                $DATE
                                -------------------------------------------------

                                Please clear all warnings identified by [WARN], unless otherwise
                                instructed by GENBAND support.
                                Please check with GENBAND support if you are not sure
                                about how to clear a warning

                                -------------------------------------------------

        ";
        help                    # display usage help and default options
        echo "Please press ENTER key to continue ..."
        echo; echo
        read any
        if [ $any ]; then
                echo "Please wait while we check your system ..."
                sleep 2
        fi
        clear; echo
}

# Main

if [ $1 ]; then
        case $1 in
        -h)
                clear
                help
                exit 0;;
        -t)                             # display CDR Table Summary only
                clear; echo; echo -e "\t\t=== CDR TABLE SUMMARY ==="; echo
                echo "This may take a while to display ..."; echo
                cdr_table_status
                exit 0;;
        -td)                             # display CDR Table Summary with details
                clear; echo; echo -e "\t\t=== CDR TABLE SUMMARY  with Details ==="; echo
                echo "This may take a while to display ..."; echo
                cdr_table_status_detail
                exit 0;;
        -v)                             # display version only
                clear; echo; echo -e "\t\t=== Version Info ==="; echo
                version
                echo; echo
                exit 0;;
        -d)                             # display DB stat only
               clear; echo; echo -e "\t\t=== DB STATISTICS ==="; echo
               echo "This may take a while to display ..."; echo
               db_stat
               echo; echo
               exit 0;;
        -p)
                clear; echo; echo -e "\t\t=== QUERY STATUS ==="; echo
                process_status 
                echo; echo
                exit 0;;
        -l)
                clear; echo; echo -e "\t\t=== LICENSE INFO =="; echo
                license
                echo; echo
                exit 0;;
        *)
                echo
                echo "Invalid option. \"-h\" for help. Exiting..."
                echo; echo
                exit 0;;
        esac
fi                                      # option not specified, default

#                banner
clear; echo; 
uptime; echo
echo -e "\t\t=== VERSION INFO ==="
version
echo -e "\t\t=== SYSTEM INFO ==="
ha_status
hw_info
echo -e "\t\t=== NETWORK INFO ==="
network
echo -e "\t\t=== SYSTEM STATUS ==="
jboss_status
mysql_status
ntp_dns_status
# cron_status                           # retired. We now have log management in 4.3m6, 5.1m2 and 5.2 - Bilig, 04212009
temp_table_status
bn_prop
cdr_partition
log_level
ear_file_status
echo -e "\t\t=== DISK USAGE and DB SPACE STATUS ==="
part_space
db_space
echo -e "\t\t=== CDR STATISTICS ==="
cdr_stat
echo -e "\t\t=== DB QUERY STATUS ==="
process_status
if [ $WARN_CNT -gt 0 ]; then
        echo; echo "==========================================================="
        echo "$WARN_CNT WARNINGS FOUND. PLEASE CHECK THE OUTPUT ABOVE FOR DETAILS"; echo
else
        echo; echo "======================"
        echo "NO WARNINGS FOUND."; echo
fi
# ================================= END of SCRIPT - Thank you for using the script!!! ====================================
