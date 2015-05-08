#!/bin/bash 

################################
#### File:  Upgrade.sh
################################

# Need this to Upgrade MSX with or without RSM 
UpgradeLoop ()
{
		if [ "$1" = "AU" ]; then
				#Auto-upgrade flag on
				AUF=1
		else
				#Auto-upgrade flag off
				AUF=0	
		fi

		if [ "$1" == "SWM_UPG" ]; then
				AUF=1
				SWMF=1
		else
				SWMF=0	
		fi

		if [ $SWMF -ne 1 ]; then
				CheckPermission "sysadmin"
		fi 

		export INSTALLTYPE="UPGRADE";

		DATABASES="databases/databases"
		WarningFlag=0

		DBNODEID=-1
		PEERDBNODEID=-1
		DBNAME=msw
		LHOSTIP="127.0.0.1"
		DBUSERNAME="msw"

		#get the machineid
		MACHINEID=`hostname`
		MACHINEID=`trimLeadingSpaces "$MACHINEID"`

		> "$INSTALLLOG"


		if [ ! -f "/usr/local/nextone/.aloidindex" ]; then
				$ECHO "No installed version. Cannot upgrade. Exiting !!"
				if [ $SWMF -ne 1 ]; then
						exit 2
				else
						return 2
				fi
		fi

		STARTDIR=`pwd`

		# Remove install tmp dir	
		rm -rf $INSTALLTMPDIR

		cd ..

		if [ ! -f "$MEDIAFILE" ]; then
				if [ $SWMF -ne 1 ]; then
						$ECHON "Enter media or file [$MEDIAFILE]: "
						read resp

						if [ -z "$resp" ]; then
								resp=$MEDIAFILE
						fi

						MEDIAFILE=$resp
				fi

				if [ ! -f "$MEDIAFILE" ]; then
						ECHO "Cannot find $MEDIAFILE: No such file or directory"
						ECHO "Exiting..."
						if [ $SWMF -ne 1 ]; then
								exit 1
						else
								return 1
						fi
				fi
		fi

		#Figure out the older version of software.
		ALOID_OLD_VERSION=`cat /usr/local/nextone/.aloidindex`
		#compare the installed version
		vc1=`versionCompare $ALOID_OLD_VERSION`


		#Blurt about space requirements etc.

		SIZEOFMEDIA=`/bin/ls -l $MEDIAFILE | awk ' { print $5 } ' `
		SPACE=`expr 3 \* $SIZEOFMEDIA / 1024`

		#Extra space in /var/tmp for untarring the media file.The sapce needed is taken as thrice the size of Tar file.
		# The same sapce requirement is taken in the /usr part.
		SPACETMPVAR=$SPACE

		#Figure out the older version of software.
		ALOID_OLD_VERSION=`cat /usr/local/nextone/.aloidindex`
		if [ $vc1 -gt 0 ]; then
				OLDDATADIR="/var/databases-${ALOID_OLD_VERSION}"
		else
				OLDDATADIR="/var/lib/pgsql/data${ALOID_OLD_VERSION}"
		fi

		if [ ! -d "$OLDDATADIR" ]; then
				ECHO "Cannot find $OLDDATADIR: No such directory"
				ECHO "Exiting..."
				if [ $SWMF -ne 1 ]; then
						exit 1
				else
						ECHO "Ending Upgradation Process..."
						return 1
				fi
		fi

		#Space for the datafile in Kbs.	
		DBSPACEVAR=`$DUCMD -kbs  $OLDDATADIR    |awk '{print $1}'`
		DBSPACEVAR=`expr $DBSPACEVAR / 1024`

		# 30% Extra space ,in case of any new object added in db. 
		DBEXTRAVAR=`expr 30 \* $DBSPACEVAR / 100`

		#Summing the above three: (/var/lib/pgsql/datafile + /var/tmp/nxtn/ + 30% of /var/lib/pgsql/datafile
		SPACEVAR=`expr $SPACETMPVAR + $DBSPACEVAR + $DBEXTRAVAR`

		#Check if we meet the space requirements
		#use the -P option to avoid errors in case filesystem name is long
		Disk_space_check "$SPACE " "/usr" 
		Disk_space_check "$SPACEVAR " "/var" 


		# Recreate install tmp dir
		mkdir $INSTALLTMPDIR
		if [ $? != 0 ]; then
				ECHO "Cannot create directory $INSTALLTMPDIR."
				ECHO "Exiting.."
				if [ $SWMF -ne 1 ]; then
						exit 1
				else
						return 1
				fi
		fi

		cp $MEDIAFILE $INSTALLTMPDIR
		cd $INSTALLTMPDIR

		tar xf $MEDIAFILE 1>/dev/null 2>>$INSTALLLOG

		#Figure out the newer version of software.
		ALOID_VERSION=`cat ${INDEXFILE}`
		PSF_VERSION=`cat ${PSFINDEXFILE}`

		if test -f "/usr/local/nextone/${PSFINDEXFILE}" ; then
				PSF_OLD_VERSION=`cat /usr/local/nextone/${PSFINDEXFILE}`
		else
				PSF_OLD_VERSION=""
		fi

		#compare the version to be installed
		vc2=`versionCompare $ALOID_VERSION`

		if [ $SWMF -ne 1 ]; then
				ECHO -e "\n\t\t\033[1;38mUPGRADING FROM ISERVER VERSION-$ALOID_OLD_VERSION TO ISERVER VERSION-$ALOID_VERSION\033[0m\n"
		else
				ECHO "UPGRADING FROM ISERVER VERSION-$ALOID_OLD_VERSION TO ISERVER VERSION-$ALOID_VERSION\n"
		fi

		if [ "$ALOID_VERSION" = "$ALOID_OLD_VERSION" ]; then
				ECHO -e "Cannot upgrade to the same version $ALOID_VERSION"
				$ECHO "Exiting..."
				if [ $SWMF -ne 1 ]; then
						exit 1
				else
						ECHO "Ending Upgradation Process..."
						return 3
				fi
		fi

		if [ $SWMF -ne 1 ]; then
				AreYouSure "Are you sure you want to upgrade to iServer version $ALOID_VERSION " "y"
				if [ $? = 0 ]; then
						ECHO "Exiting..."
						exit 1
				fi
		fi
		# [1] 33407 #

		Machine="NONE"

		if [ $vc1 -le 0 ]; then
				# From 4.2

				CLUSTER=`GetDbClusterName`
				if [ -n "$CLUSTER" ]; then

						Machine=`GetMachine`
						REMOTEIP=`GetRemoteDbHost`

				fi

				OLD_CLI_PATH="/opt/nxtn/iserver-${ALOID_OLD_VERSION}"

				######################################################
				## Special handling in case 4.2 is installed in 
				## path similar to 4.0 i.e /usr/local/nextone-<rel no>
				######################################################

				if [ ! -d "$OLD_CLI_PATH" ]; then
						OLD_CLI_PATH="/usr/local/nextone-${ALOID_OLD_VERSION}"
				fi
		else
				OLD_CLI_PATH="/usr/local/nextone-${ALOID_OLD_VERSION}"
		fi

		# [2] 33407 #

		if [ $SWMF -ne 1 ]; then
				. $STARTDIR/CreateSecureSessionWithoutPasswd.sh
		fi
		if [ "$Machine" = "FirstMachine" ]; then

				AssertSCMStandbyOnFirstMachine

				if [ $SWMF -ne 1 ]; then
						CreateSecureSessionWithoutPasswd $REMOTEIP
						AbortOnError "${warn}Could not create Secure Session without Passwd!!!${rc_restore}"
				fi
				DisableSetDbRoleCmdText | sh

				RemoteExecution $REMOTEIP DisableSetDbRoleCmdText
				if [ $? -ne 0 ]; then
						if [ $WarningFlag -eq 0 ]; then
								ECHO "Warning ! Couldn't configure remote system properly. Still Continuing.."
								WarningFlag=1 
						else  
								echo "Warning ! Couldn't configure remote system properly. Still Continuing" >>$INSTALLLOG  
						fi
				fi  

				RemoteExecution $REMOTEIP RemoveDBRedundancyFromInit
				if [ $? -ne 0 ]; then
						if [ $WarningFlag -eq 0 ]; then
								ECHO "Warning ! Couldn't configure remote system properly. Still Continuing.."
								WarningFlag=1 
						else  
								echo "Warning ! Couldn't configure remote system properly. Still Continuing" >>$INSTALLLOG  
						fi
				fi

				if [ $vc1 -le 0 ]; then
						trap 'SigHandlerUpgrade' 1 2 15
				fi

		elif [ "$Machine" = "SecondMachine" ]; then
				if [ $SWMF -ne 1 ]; then
						CreateSecureSessionWithoutPasswd $REMOTEIP
						AbortOnError "${warn}Could not create Secure Session without Passwd!!!${rc_restore}"
				fi 
				SCMCheckCmdText | sh

				if [ $? = 0 ]; then
						RemoteExecution $REMOTEIP SCMCheckCmdText
						ret=$?
						if [ $SWMF -ne 1 ]; then
								AbortOnError "${warn}Iserver not started on the Standby!!!${rc_restore}"
						else 
								if [ $ret -ne 0 ]; then
										logwithid error "${FUNCNAME}: Iserver not started on the Standby!!!"
										return 2
								fi
						fi
						WaitForSCMReplicationFromSecondMachine
				fi

		else
				DisableSetDbRoleCmdText | sh
		fi

		# Postgress is required. Would be running with default or previous configuration.

		rcpostgresql status
		if [ $? -ne 0 ]; then
				rcpostgresql start
		fi

		###
		#1. Save the existing provisioning data from the master / standalone database.

		EXPORT_PREFIX="upg"
		EXPORT_FILE="$INSTALLTMPDIR/${EXPORT_PREFIX}.exp"

		# save database only for firstMachine or standalone (NONE)
		if [ "$Machine" != "SecondMachine" ]; then
				ECHO -n "Saving old database ..." 
				$OLD_CLI_PATH/bin/cli db export $EXPORT_FILE 1>>$INSTALLLOG 2>&1
				if [ $? = 0 ]; then
						ECHO "$rc_done" 
				else
						ECHO "$rc_failed" 
						ECHO -e "\033[1;38mUnable to save the previous provisioning data\033[0m\n"
						if [ $SWMF -ne 1 ]; then
								AreYouSure "Do you want to proceed" "n"
								if [ $? -eq 0 ]; then
										ECHO "Refer $INSTALLLOG for a detailed log." 
										exit 2
								fi
						fi
				fi
		fi

		# Is the current version configured to start on boot?

		START_ON_BOOT=false
		if [ -f /databases/boot ]; then
				START_ON_BOOT=true
		fi

		# Save the old ivmsclient password.  Use the old password with the new DB (fp 53192)
		IVMSCLIENTDBPASS=`psql -Umsw -t -q -c "select rolpassword from pg_authid where rolname='ivmsclient'" | sed 's/^ //'`


		#1. Saved provision data in $EXPORT_FILE. In case of failure it may not exist.
		###

		###
		#2. Save license.


		if [ -f $OLD_CLI_PATH/bin/nxconfig.pl ]; then
				ECHO -n "Saving old licence ..." 
				cd $OLD_CLI_PATH/bin
				./nxconfig.pl -L >>$INSTALLLOG 2>&1
				cd -
				ECHO "$rc_done" 
		fi

		#2. Saved license.
		###

		###
		# 3. Stopping daemons.

		ECHO -n "Stopping daemons ..." 
		/usr/local/nextone/bin/iserver all stop > /dev/null

		# Ensure that all the processes are stopped before upgradation

		sed -i '/\/usr\/local\/nextone\/bin\/aisexec/d' /etc/inittab 
		telinit q

		kill -9 `pgrep -x pm` 1>/dev/null 2>&1
		kill -9 `pgrep -x aisexec` 1>/dev/null 2>&1
		kill -9 `pgrep -x execd` 1>/dev/null 2>&1 
		kill -9 `pgrep -x dbsync` 1>/dev/null 2>&1 
		kill -9 `pgrep -x gis` 1>/dev/null 2>&1
		kill -9 `pgrep -x gis_sa` 1>/dev/null 2>&1
		kill -9 `pgrep -x pm_sa` 1>/dev/null 2>&1
		kill -9 `pgrep -x naf` 1>/dev/null 2>&1

		ECHO "$rc_done" 

		# 3. Stopping daemons. Partially completed. 
		# BUG - This is a 4.2 specific process list.

		sed -e "/^ispd/d" /etc/inetd.conf >$TMPDIR/inetd.conf
		if [ $? = 0 ]; then   
				cp $TMPDIR/inetd.conf /etc/inetd.conf
				/etc/init.d/inetd restart
				ECHO -n "Stopping ispd ..." 
				sleep 2
				pkill -TERM -x ispd

				# Wait for ispd to stop
				# If ispd does not stop within 5 min, kill it 
				WaitForISPDToStop
				if [ $? = 1 ]; then
						ECHO -n "Killing ispd ..."
						kill -9 `pgrep -x ispd` 1>/dev/null 2>&1
						sleep 2
				fi 

				#Remove shared memory associated with ispd
				#The macro ISERVER_STATE_SHM_KEY values to 2
				ipcrm -M 0x00000002 2>/dev/null
				ECHO "$rc_done" 
		fi

		# 3. Stopped ispd, removed ISERVER_STATE_SHM_KEY, if it was supposed to be running (runs in SCM 4.0 & SCM 4.2).
		###

		###
		# 4. Backing up mdevices, current configuration in case of 4.2 as older version and mdevices, server.cfg in case of 4.0.

		MDEVICESBACKUP="${MDEVICESFILE}-${ALOID_OLD_VERSION}"

		#if installed version is 4.2 or later

		if [ $vc1 -le 0 ]; then
				#generate the file currentConfiguration.sql and save it in $INSTALLTMPDIR directory
				cd $OLD_CLI_PATH/bin/

				# 33407 #
				FindMasterIP

				# for FP-55092
				# Special handling for 4.2m4vz15 patch 
				# In this patch a new config 'dnscacheinterval' was introduced 
				# and by mistake instead of attrvalue the attrdeflt was set to 86400
				query="select attrdeflt, attrvalue from servercfg where attrname='dnscacheinterval';"
				psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP -qtc "$query" | awk -F"|" '{print $1 $2}' | while read DEFAULT VALUE
		  do
						if [ "$DEFAULT" == "86400" ]; then
								if [ -z "$VALUE" ]; then
										query="update servercfg set attrvalue='86400' where attrname='dnscacheinterval';"
										psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP -qtc "$query" > /dev/null 2>&1
								fi
						fi
				done
				./nxconfig.pl -C -D $DBNAME -u $DBUSERNAME -h $MASTERIP
				mv currentConfiguration.sql $INSTALLTMPDIR

				#
				# 48436 - make interface-monitor-list machine independent starting 5.1 #
				#
				OLD_IFLIST="AttrName.*=.*'interface-monitor-list' .*AND .*MachineID.*=.*'"$MACHINEID"'"
				NEW_IFLIST="AttrName = 'interface-monitor-list' AND MachineID = ''"
				sed -i $INSTALLTMPDIR/currentConfiguration.sql -e "s/$OLD_IFLIST/$NEW_IFLIST/i"

				#get the mdevices.xml from the DB
				./nxconfig.pl -M -D $DBNAME -u $DBUSERNAME -h $MASTERIP >> $INSTALLLOG 2>&1

				#RSMLite Start
				# Backup the RSMLite Tables in the MSW Schema
				ECHO "Backing up RSMLite Tables ..."
				RSMLite_DataBackup
				#RSMLite End

				# PSF BACKUP-RESTORE Start
				#
				# UPGRADE --> Backup the Changed Configuration on the EXISTING DB
				#
				if [ "${PSF_OLD_VERSION}" != "" ] ; then
						# Copy OLD Install Backup
						PSFINSBACKUPFILE="/usr/local/psf/conf/.psf_bkp_install.dat"
						if test -f $PSFINSBACKUPFILE ; then
								cp -pf $PSFINSBACKUPFILE $INSTALLTMPDIR
						fi

						# PSF Backup Current configuration
						PSFBACKUPFILE="/usr/local/psf/conf/.psf_bkp_current.dat"
						`echo $PSF_OLD_VERSION | grep -q '^4.3'`
						if [ $? -eq 0 ] ; then
								PSFBackupConfigFrom43PSF $DBUSERNAME $DBNAME $MASTERIP $INSTALLLOG $PSFBACKUPFILE "changed" "update"
						else
								PSFBackupConfig $DBUSERNAME $DBNAME $MASTERIP $INSTALLLOG $PSFBACKUPFILE "changed" "update"
						fi

						if test -f $PSFBACKUPFILE ; then
								cp -pf $PSFBACKUPFILE $INSTALLTMPDIR
						fi
				fi
				# PSF BACKUP-RESTORE End

				#Upgrade from a Version ***prior*** to the Version where mdevices.xml became Machine Dependent

				if [ -f "$OLD_CLI_PATH/bin/new-mdevices.xml" ]; then
						mv -f $OLD_CLI_PATH/bin/new-mdevices.xml $INSTALLTMPDIR/${MDEVICESBACKUP}
				fi

				#Upgrade from a Version ***after*** the Version where mdevices.xml became Machine Dependent

				if [ -f "$OLD_CLI_PATH/bin/$MACHINEID-mdevices.xml" ]; then
						mv -f $OLD_CLI_PATH/bin/$MACHINEID-mdevices.xml $INSTALLTMPDIR/${MDEVICESBACKUP}
				fi
				cd -
		else
				#if installed version is 4.0
				SCFGBACKUP="server.cfg-${ALOID_OLD_VERSION}"
				if [ -f $OLD_CLI_PATH/bin/server.cfg ]; then
						cp -p $OLD_CLI_PATH/bin/server.cfg	$INSTALLTMPDIR/${SCFGBACKUP}
				fi

				MDEVICESBACKUP="${MDEVICESFILE}-${ALOID_OLD_VERSION}"

				if [ -f "$OLD_CLI_PATH/bin/${MDEVICESFILE}" ]; then
						cp -p $OLD_CLI_PATH/bin/${MDEVICESFILE} $INSTALLTMPDIR/${MDEVICESBACKUP}
				fi
		fi

		BKDBBACKUP="${BACKUPDBDIR}-${ALOID_OLD_VERSION}"
		if [ -d "$OLD_CLI_PATH/bin/${BACKUPDBDIR}" ]; then
				cp -pr $OLD_CLI_PATH/bin/${BACKUPDBDIR} $INSTALLTMPDIR/${BKDBBACKUP}
		fi

		#backup the routeManager script, if exists
		ROUTEMGRBACKUP="${ROUTEMGRFILE}-${ALOID_OLD_VERSION}"
		if [ -f "$OLD_CLI_PATH/bin/${ROUTEMGRFILE}" ]; then
				cp -p $OLD_CLI_PATH/bin/${ROUTEMGRFILE} $INSTALLTMPDIR/${ROUTEMGRBACKUP}
		fi

		#backup the old codemap files
		CODEMAPBACKUP="${CODEMAPDIR}-${ALOID_OLD_VERSION}"
		OLDCODEMAPDIR="$INSTALLTMPDIR/${CODEMAPBACKUP}"
		if [ ! -d "${OLDCODEMAPDIR}" ]; then
				mkdir ${OLDCODEMAPDIR}
		fi
		if [  -d "${OLD_CLI_PATH/bin/codemap}" ]; then
				cp -p $OLD_CLI_PATH/bin/codemap/${CODEMAPTXTFILES} ${OLDCODEMAPDIR} 2>/dev/null
				cp -p $OLD_CLI_PATH/bin/codemap/${CODEMAPDATFILES} ${OLDCODEMAPDIR} 2>/dev/null
		else
				cp -p $OLD_CLI_PATH/bin/${CODEMAPTXTFILES} ${OLDCODEMAPDIR} 2>/dev/null
				cp -p $OLD_CLI_PATH/bin/${CODEMAPDATFILES} ${OLDCODEMAPDIR} 2>/dev/null
		fi  
		###
		# 5. Old version is 4.2. Managing redundancy setup.

		if [ $vc1 -le 0 ]; then
				# From 4.2
				CLUSTERNAME=`GetDbClusterName`

				if [ -n "$CLUSTERNAME" ]; then
						cd /usr/local/nextone/bin
						. /usr/local/nextone/bin/mswreplication.sh
						cd -


						PEERISERVER=`DbGetPeerIserver $MACHINEID|sed -e 's/^\s//g' | sed -e 's/\s$//g'`
						CONTROLIF=`DbGetControlInterface $MACHINEID||sed -e 's/^\s//g'|sed -e 's/\s$//g'`
						if [ -n "$CONTROLIF" ]; then
								CONTROLIPADDR=`GetControlIpAddr $CONTROLIF|sed -e 's/^\s//g'|sed -e 's/\s$//g'`
						fi

						LINENUM=`grep -n $CONTROLIPADDR /usr/local/nextone/bin/dbinfo |awk -F":" '{print $1}'`
						if [ -z "$LINENUM" ]; then 
								RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
								RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
								tput bold on
								ECHO "$CONTROLIPADDR is not configured in dbinfo, did you configure iServer for redundancy?"
								ECHO "If yes, dbinfo may be corrupted . . . Please uninstall & install!"
								tput bold off
								if [ $SWMF -ne 1]; then
										exit -1
								else
										return 1
								fi
						fi
						NODELINE=`expr $LINENUM - 1`


						DBNODEID=`GetLocalNodeID`
						PEERDBNODEID=`GetRemoteNodeID`

						# [3] 33407 #
						if [ "$Machine" = "FirstMachine" ]; then  
								DetectMaster $DBNODEID $CONTROLIPADDR
								if [ $? -eq 1 ]; then 
										#local DB is master, failover to the slave.

										ECHO -n "Local DB is MASTER, switching it to slave ..."

										WaitForMinuteBoundary

										echo "[`date`] rep_switchover" >> $INSTALLLOG

										rep_switchover 1>>$INSTALLLOG 2>&1

										HandleDbSwitchingError $? local

										ECHO ${rc_done} 
								fi

								ECHO -n "Removing cluster ..."

								rep_nodeclean $DBNODEID $PEERDBNODEID 1>>$INSTALLLOG 2>&1
								ECHO ${rc_done}

								###########################################
								# Waiting for slon to close on the remote #
								###########################################

								sleep 60

								RemoteExecution $REMOTEIP StartSetDbRoleCmdText
								if [ $? -ne 0 ]; then
										if [ $WarningFlag -eq 0 ]; then
												ECHO "Warning ! Couldn't configure remote system properly. Still Continuing.."
												WarningFlag=1 
										else  
												echo "Warning ! Couldn't configure remote system properly. Still Continuing" >>$INSTALLLOG  
										fi
								fi


						fi

						# ?: Why would they both be not set?

						if [ -n "$PEERISERVER" -a -n "$CONTROLIPADDR" ]; then
								RemRedundantPgConf $PEERISERVER $CONTROLIPADDR
						elif [ -n "$CONTROLIPADDR" ]; then
								RemRedundantPgConf $CONTROLIPADDR
						fi

						chown postgres:postgres $INSTALLDIR/$DATABASES/pg_hba.conf

						########################################################
						# Remove entries from peeriserver from msw_status.
						# This has to be done after replication is stopped.
						########################################################

						if [ -n "$PEERISERVER" ]; then
								psql -U$DBUSERNAME -d$DBNAME -h$PEERISERVER -c"delete from servercfg where machineid = '$MACHINEID'" 1>>$INSTALLLOG 2>&1
								psql -U$DBUSERNAME -d$DBNAME -h$PEERISERVER -c"delete from msw_status  where machineid = '$MACHINEID'" 1>>$INSTALLLOG 2>&1

								# PSF BACKUP-RESTORE Start
								if [ "${PSF_OLD_VERSION}" != "" ] ; then
										psql -U$DBUSERNAME -d$DBNAME -h$PEERISERVER -c"delete from psfcfg where machineid = '$MACHINEID'" 1>>$INSTALLLOG 2>&1
								fi
								# PSF BACKUP-RESTORE End
						fi

				fi
		fi

		# 5. Old 4.2. Managed redundancy setup. 
		# Made the other node as master.
		# Removed the node from the redundancy setup.
		# Removed the peering information from msw_status, severcfg from peer.. 
		###


		if [ $vc1 -le 0 ]; then

				#installed version 4.2

				#Backup the dbinfo file
				cp -pf $OLD_CLI_PATH/bin/dbinfo $INSTALLTMPDIR/

				DBNODEID=`$OLD_CLI_PATH/bin/iniParser.awk PARAMETER=NodeID $OLD_CLI_PATH/bin/dbinfo| head -1`
				PEERDBNODEID=`$OLD_CLI_PATH/bin/iniParser.awk PARAMETER=NodeID $OLD_CLI_PATH/bin/dbinfo| tail -1`

				#Stop Database
				StopPostgres

				#replace the (/etc/sysconfig/postgresql) data${ALOID_OLD_VERSION} dir name with the data name

				ECHO -n "Replacing data${ALOID_OLD_VERSION} in [/etc/sysconfig/postgresql] with the data ..." 
				ReplaceIserverOldVerWithDataDir

				ECHO "$rc_done" 
				StartPostgres
		fi

		ECHO -n "Uninstalling OpenAIS ..." 
		uninstallAIS
		ECHO "$rc_done" 

		if [ $SWMF -ne 1 ]; then
				################
				# Copying new release 
				################

				TMPDIRNAME="${INSTALLTMPDIR}/${PRODUCT}-${ALOID_VERSION}"
				cd $TMPDIRNAME

				INSTALLDIR="/opt/nxtn/iserver-${ALOID_VERSION}"
				rm -rf $INSTALLDIR >> /dev/null

				mkdir -p $INSTALLDIR
				if [ $? != 0 ]; then
						if [ $vc1 -le 0 ]; then
								RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
								RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
						fi
						ECHO "Cannot create directory $INSTALLDIR" 
						ECHO "Aborting upgrade. Exiting ..." 
						exit 1
				fi
		fi

		#Also remove the old link and create the new link
		if [ $vc1 -le 0 ]; then 
				rm /opt/nextone 2>/dev/null
				if [ $? -eq 1 ]; then
						rm /usr/local/nextone
				fi
		else
				rm /usr/local/nextone
		fi
		if [ $? != 0 ]; then
				if [ $vc1 -le 0 ]; then
						RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
						RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
				fi
				ECHO "Directory /usr/local/nextone is not empty" 
				ECHO "Aborting upgrade. Exiting ..." 
				if [ $SWMF -ne 1 ]; then
						exit 1
				else
						return 1
				fi
		fi

		# PSF unlink
		if [ "${PSF_OLD_VERSION}" != "" ] ; then
				PSFUnlink 
		fi

		$SOFTLINK $INSTALLDIR /opt/nextone

		if [ $SWMF -ne 1 ]; then
				#Copy the index file
				cp -p $INSTALLTMPDIR/${INDEXFILE} $INSTALLDIR
				cp -p $INSTALLTMPDIR/${DATEFILE} $INSTALLDIR

				#PSF Save Index File
				if test -f "$INSTALLTMPDIR/${PSFINDEXFILE}" ; then
						cp -p $INSTALLTMPDIR/${PSFINDEXFILE} $INSTALLDIR
				fi

				#Create the directories
				mkdir $INSTALLDIR/bin
				mkdir $INSTALLDIR/databases
				mkdir $INSTALLDIR/bin/codemap
				mkdir $INSTALLDIR/locks

				#Create the dbschema directory
				mkdir $INSTALLDIR/dbschema

				if [ ! -d /usr/share/snmp ]; then
						mkdir -p /usr/share/snmp
				fi

				if [ ! -d /usr/share/snmp/mibs ]; then
						mkdir -p /usr/share/snmp/mibs
				fi

				if [ ! -d $INSTALLDIR/lib ]; then
						mkdir -p $INSTALLDIR/lib
				fi

				#Create default CDR directory if it doesn't exist

				if [ ! -d $CDRDEFAULTDIR ]; then 
						mkdir $CDRDEFAULTDIR
				fi
		fi

		rm -f /databases
		rm -f /locks

		$SOFTLINK $INSTALLDIR/databases /databases
		$SOFTLINK $INSTALLDIR/locks /locks

		if [ $SWMF -ne 1 ]; then
				#Copy the executables
				ECHO ""
				ECHO "Installing in $INSTALLDIR ..." 
				ECHO ""

				#This is a very dumb install
				ECHO -n "Copying files ..."
				for i in `ls *`
				do
						if [ `echo $i  | grep -c  "codemap_" ` -eq 1 ]; then
								cp -p $i $INSTALLDIR/bin/codemap
						else
								cp -p $i $INSTALLDIR/bin
						fi	  
				done
				ECHO "$rc_done"
		fi

		#Fix the permissions
		chown -R root:root $INSTALLDIR
		if [ `grep -c "^nxadmin" /etc/group` -gt 0 ]; then
				chgrp nxadmin $INSTALLDIR/bin
				chmod 775 $INSTALLDIR/bin
				chgrp nxadmin $INSTALLDIR/databases
				chmod 775 $INSTALLDIR/databases
		fi

		#Move switch version script sv to /usr/bin
		mv $INSTALLDIR/bin/sv /usr/bin

		ECHO -n "Installing OpenAIS ..." 
		installAIS
		ECHO "$rc_done" 

		if [ $SWMF -ne 1 ]; then
				#Move *.so from bin to lib directory
				mv $INSTALLDIR/bin/libSaEvt.so $INSTALLDIR/lib
				mv $INSTALLDIR/bin/libEvent.so $INSTALLDIR/lib
		fi

		# Install New Version of PSF. Link to the new version
		ECHO "Installing PSF"
		if [ $SWMF -ne 1 ]; then
				PSFInstall ${PSF_VERSION} $TMPDIRNAME/psf.rpm
		fi
		PSFLink ${PSF_VERSION}

		#Edit the ld.so.conf file
		CheckInsert /opt/nextone/lib /etc/ld.so.conf
		ldconfig

		#update the system parameters
		UpdateSystemParam

		installRadiusDictionaries

		#Adding purging utility to crontab
		cronline='0 * * * * /usr/local/nextone/bin/purge.sh'
		AddCronJob purge.sh "database housekeeping" "$cronline" 

		########################################
		# Start Creation of Default POSTGRES DB
		########################################

		DATADIR="/var/lib/pgsql/data${ALOID_VERSION}"
		OLDDATADIR="/var/lib/pgsql/data${ALOID_OLD_VERSION}"

		StopPostgres 2>/dev/null

		# This directory may exist, specially in a test setup from old.
		ECHO -n "Making dir /var/lib/pgsql/data${ALOID_VERSION} ..." 
		rm -fr $DATADIR
		mkdir -p $DATADIR
		chown -R postgres:postgres $DATADIR
		ECHO "$rc_done" 

		ECHO -n "Replacing /etc/sysconfig/postgresql/data with the data${ALOID_VERSION} ..." 
		ReplaceDataDirWithIserverVer
		ECHO "$rc_done" 

		#
		# Starting postgres, will create the necessary files, like pg_hba.conf etc
		StartPostgres

		#Link the /var/lib/pgsql/data{ALOID_VERSION} directory to $INSTALLDIR/databases

		$SOFTLINK $DATADIR $INSTALLDIR/$DATABASES

		ECHO -n "Adding stand-alone configuration in pg_hba.conf ..." 
		AddStandAlonePgConf
		if [ $? -ne 0 ]; then
				if [ $vc1 -le 0 ]; then
						RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
						RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
				fi
				ECHO "$rc_failed" 
				if [ $SWMF -ne 1 ]; then
						exit -1
				else
						return 1
				fi
		fi
		chown postgres:postgres $INSTALLDIR/$DATABASES/pg_hba.conf
		ECHO "$rc_done"

		ECHO -n "Adding local-host entry into postgresql.conf file"
		pglistenaddr="'127.0.0.1'"
		mv $INSTALLDIR/bin/postgresql.conf $INSTALLDIR/$DATABASES/
		sed -i "/listen_addresses =*/c listen_addresses = $pglistenaddr" $INSTALLDIR/$DATABASES/postgresql.conf
		chown postgres:postgres $INSTALLDIR/$DATABASES/postgresql.conf
		ECHO "$rc_done"

		#Need to start the Database
		RestartPostgres

		########################################
		# At this point the Default POSTGRES is UP and RUNNING
		########################################

		if [ $vc2 -le 0 ]; then
				cd $INSTALLDIR/bin
				. $INSTALLDIR/bin/mswreplication.sh
				cd -

				CreateDbUsers
				if [ $? -ne 0 ]; then
						if [ $vc1 -le 0 ]; then
								RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
								RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
						fi
						ECHO "Upgrade failed: Error in CreateDbUsers()" 
						if [ $SWMF -ne 1 ]; then
								exit -1
						else
								return 1
						fi
				fi

				CreateDefaultDb
				if [ $? -ne 0 ]; then
						if [ $vc1 -le 0 ]; then
								RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
								RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
						fi
						ECHO "Upgrade failed: Error in CreateDefaultDb()" 
						if [ $SWMF -ne 1 ]; then
								exit -1
						else
								return 1
						fi
				fi

				# change the default ivmsclient database password.
				# On upgrades, we use the md5 password from old db.  (fp 53192) 
				AlterIvmsclientDBPasswd $IVMSCLIENTDBPASS

				#version installed was 4.2 or later

				if [ $vc1 -le 0 ]; then
						cp -pf $INSTALLTMPDIR/dbinfo $INSTALLDIR/bin
				else
						WriteStandAloneDbInfo
						if [ $? -ne 0 ]; then
								ECHO "Upgrade failed: Error in WriteStandAloneDbInfo()" 
								if [ $SWMF -ne 1 ]; then
										exit -1
								else
										return 1
								fi
						fi
				fi

				DBNAME="msw"
				DBUSERNAME="msw"
				LHOSTIP="127.0.0.1"
		fi #if [ $vc2 -le 0 ] - This is a needless loop.

		cd $INSTALLTMPDIR

		RestartPostgres
		if [ $? -ne 0 ]; then
				if [ $vc1 -le 0 ]; then
						RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
						RemoteExecution $REMOTEIP AddDBRedundancyIntoInit 
				fi
				ECHO "Upgrade failed: Error in RestartPostgres()" 
				if [ $SWMF -ne 1 ]; then
						exit -1
				else
						return 1
				fi
		fi

		cd $INSTALLDIR/bin/

		ECHO -n "Creating Database Schema and Tables" 
		psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/createtable.pgsql 1>>$INSTALLLOG 2>&1
		if [ $? -ne 0 ]; then
				ECHO "$rc_failed" 
				if [ $SWMF -ne 1 ]; then
						exit 1;
				else
						return 1
				fi
		else
				ECHO "$rc_done" 
		fi

		ECHO -n "Creating Journal and Event Tables" 
		psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/journal_event_create.pgsql 1>>$INSTALLLOG 2>&1
		if [ $? -ne 0 ]; then
				if [ $vc1 -le 0 ]; then
						RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
						RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
				fi
				ECHO "$rc_failed" 
				if [ $SWMF -ne 1 ]; then
						exit 1;
				else
						return 1
				fi
		else
				ECHO "$rc_done" 
		fi

		if [ $vc2 -gt 0 ]; then

				# ? : This is not possible, the script is for 4.2 or later.

				ECHO "Upgrading server.cfg " 
				if [ $AUF -ne 1 ]; then
						#generate new server.cfg with inputs from $INSTALLTMPDIR/$SCFGBACKUP
						$INSTALLDIR/bin/sconfig -d $INSTALLTMPDIR -f $SCFGBACKUP -o $INSTALLDIR/bin/server.cfg
				else
						#Get the previous configuration
						cp -p $INSTALLTMPDIR/${SCFGBACKUP} $INSTALLDIR/bin/server.cfg
				fi

		else

				#Get the previous configuration
				if [ $vc1 -le 0 ]; then
						#Since the installed version was 4.2 or later we already have the file currentConfiguration.sql

						mv $INSTALLTMPDIR/currentConfiguration.sql $INSTALLDIR/bin

						# PSF BACKUP-RESTORE Start
						#
						# COPY Files to INSTALLTMPDIR
						#
						PSFTEMPINSBACKUPFILE="$INSTALLTMPDIR/.psf_bkp_install.dat"
						PSFCPTEMPINSBACKUPFILE="/usr/local/psf/conf/.psf_bkp_install.old.dat"
						if test -f $PSFTEMPINSBACKUPFILE ; then
								cp -pf $PSFTEMPINSBACKUPFILE $PSFCPTEMPINSBACKUPFILE
						fi
						PSFTEMPBACKUPFILE="$INSTALLTMPDIR/.psf_bkp_current.dat"
						PSFCPTEMPBACKUPFILE="/usr/local/psf/conf/.psf_bkp_current.old.dat"
						if test -f $PSFTEMPBACKUPFILE ; then
								cp -pf $PSFTEMPBACKUPFILE $PSFCPTEMPBACKUPFILE
						fi
						# PSF BACKUP-RESTORE End

				else

						#We need to generate currentConfiguration.sql
						#from the saved server.cfg

						$INSTALLDIR/bin/sconfig -d $INSTALLTMPDIR -f $SCFGBACKUP -u $INSTALLDIR/bin/currentConfiguration.sql
						# Change the fwname from HKNIFE to MS.  This should be fixed in sconfig
						# but no time to look at that right now.  Taking a chance with a general
						# replacement of "HKNIFE", so create a backup file with extension ".bck"
						# in case we need to troubleshoot.
						sed --in-place=.bck 's/HKNIFE/MS/' $INSTALLDIR/bin/currentConfiguration.sql
				fi

				$INSTALLDIR/bin/prep-insert-queries.sh
				createlang plpgsql -U$DBUSERNAME -d$DBNAME 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/insert-default-server-configuration.pgsql 1>>$INSTALLLOG 2>&1 
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/error.strings.default.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/all_trigger_func.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/getcurrenttransactionid_pg81.pgsql 1>>$INSTALLLOG 2>&1

				#Create PSF Table Set and Insert Default Configuration
				PSFCreateTable $DBUSERNAME $DBNAME $LHOSTIP $INSTALLLOG
				PSFCreateFunction $DBUSERNAME $DBNAME $LHOSTIP $INSTALLLOG
				PSFInsertDefaultConfig $DBUSERNAME $DBNAME $LHOSTIP $INSTALLLOG
				# PSF BACKUP-RESTORE Start
				#
				# UPGRADE-INSTALL --> Backup the Entire Configuration on NEW DB
				#
				PSFBACKUPFILE="/usr/local/psf/conf/.psf_bkp_install.dat"
				PSFBackupConfig $DBUSERNAME $DBNAME $LHOSTIP $INSTALLLOG $PSFBACKUPFILE "all" "insert"
				# PSF BACKUP-RESTORE End
				#Run Above PSF functions prior to sock_event_trigger_func

				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/sock_event_trigger_func.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/dbclean.pgsql 1>>$INSTALLLOG 2>&1

				grep -w "could not load library \"$INSTALLDIR/lib/libEvent.so\"" $INSTALLLOG 
				if [ $? -eq 0 ]; then
						if [ $vc1 -le 0 ]; then
								RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
								RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
						fi
						ECHO "Error in loading libEvent.so";
						ECHO "Exiting..."
						if [ $SWMF -ne 1 ]; then
								exit 1
						else
								return 1
						fi
				fi

				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/endpoint_trig.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/before_trig.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/before_realm_entry.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/before_vnet_entry.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/before_cert_domain_entry.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/views.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/ins.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/dbsave.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/dbswitch.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/bulkmodify.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/rumaster_redundancy.pgsql 1>>$INSTALLLOG 2>&1
				psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/bin/grant.pgsql 1>>$INSTALLLOG 2>&1

				ECHO -n "Moving mib files to /usr/share/snmp/mibs . . ."
				mv $INSTALLDIR/bin/*MIB.txt /usr/share/snmp/mibs

				ECHO -n "Moving pgsql files to dbschema . . ." 

				mv $INSTALLDIR/bin/*.pgsql $INSTALLDIR/dbschema
				mv $INSTALLDIR/bin/server.key $INSTALLDIR/$DATABASES
				mv $INSTALLDIR/bin/server.crt $INSTALLDIR/$DATABASES

				chown postgres:postgres $INSTALLDIR/$DATABASES/server.key
				chmod 600 $INSTALLDIR/$DATABASES/server.key

				chown postgres:postgres $INSTALLDIR/$DATABASES/server.crt
				ECHO "${rc_done}" 
				ECHO ""

				#Loading the file./currentConfiguration.sql

				./nxconfig.pl -c -D $DBNAME -u $DBUSERNAME -h $LHOSTIP

				#Hard Code the internalifs to all
				DbSetInternalifsToAll

				# RSMLite Start
				# Only Restore the RSMLite Tables in the MSW Schema
				if test -f $INSTALLTMPDIR/rsmlitedata.sql ; then
						ECHO "Restoring RSMLite Tables ..."
						psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLTMPDIR/rsmlitedata.sql  1>> $INSTALLLOG 2>&1
				else
						ECHO "ERROR: File: $INSTALLTMPDIR/rsmlitedata.sql NOT Found" 1>> $INSTALLLOG 2>&1
				fi
				# RSMLite End

				# PSF BACKUP-RESTORE Start
				# Restore the PSF Configuration
				#
				# UPGRADE-INSTALL --> Restore the Changed Configuration on the LOCAL DB
				#
				PSFOLDCURRENTFILE="/usr/local/psf/conf/.psf_bkp_current.old.dat"
				PSFRestoreConfig $DBUSERNAME $DBNAME $LHOSTIP $INSTALLLOG $PSFOLDCURRENTFILE
				# PSF BACKUP-RESTORE End

				##########################################################################
				# At this point the schema is created irrespective of upgrade from 4.0 or 4.2 with the database in standalone mode
				##########################################################################

				# For 4.2 upgrade, we upgrade as slave
				# For 4.0 we upgrade as master if master is not available, else as slave

				echo "stand_alone" > $TMPDIR/redundancy_type

				if [ $vc1 -le 0 ]; then
						#Previous installed version is 4.2 or later

						if [ -n "$CLUSTERNAME" ]; then
								#Previous installation was redundancy
								echo "slave" > $TMPDIR/redundancy_type

								dbresp="y"
								peer_server="master"

								DbGetRedundancyType $PEERDBNODEID $PEERISERVER
								if [ $? -ne 1 ]; then
										#peer is not master or unable to contact peer DB
										if [ $SWMF -ne 1 ]; then
												ECHO -n "Database on peer is not configured as master or unable to" 
												ECHO -n " contact peer DB, local DB will be configured as master" 
												ECHO -n " continue? [$dbresp]: " 
												read dbresp1
												if [ $dbresp1 ]; then
														dbresp=$dbresp1
												fi  
										fi
										if [ "$dbresp" = "y" ]; then
												# TODO: To check if the there is any need for the questions, since we have all the answers in currentConfiguration.sql. 
												export INSTALLTYPE="FRESH"
												echo "master" > $TMPDIR/redundancy_type
										else
												RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
												RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
												if [ $SWMF -ne 1 ]; then
														exit 1
												else
														return 1
												fi
										fi
								fi
						fi  
				else 
						#Previous installed version is 4.0

						export INSTALLTYPE="UPGRADE"
						DBNODEID=2
						PEERDBNODEID=1
						echo "slave" > $TMPDIR/redundancy_type


						PEERISERVER=`DbGetPeerIserver $MACHINEID|sed -e 's/^\s//g' | sed -e 's/\s$//g'`

						if [ -n "$DEBUG" ]; then
								ECHO "PEERISERVER in case of upgrade from 4.0 $PEERISERVER" 
						fi 

						if [ -n "$PEERISERVER" ]; then

								dbresp="y"
								peer_server="master"

								DbGetRedundancyType $PEERDBNODEID $PEERISERVER

								if [ $? -ne 1 ]; then

										#peer is not master or unable to contact peer DB

										if [ $SWMF -ne 1 ]; then
												vermajor=`echo $ALOID_VERSION|awk -F"[^0-9]" '{print $1}'`
												verminor=`echo $ALOID_VERSION|awk -F"[^0-9]" '{print $2}'`
												ECHO -n "The peer MSX does not appear to be upgrade to ${vermajor}.${verminor} yet."
												ECHO -n " This machine will be the database master."
												ECHO -n " Continue? [$dbresp]: "
												read dbresp1
												if [ $dbresp1 ]; then
														dbresp=$dbresp1
												fi  
										fi
										if [ "$dbresp" = "y" ]; then
												# TODO: To check if the there is any need for the questions, since we have all the answers in currentConfiguration.sql. 
												export INSTALLTYPE="FRESH"
												DBNODEID=1
												PEERDBNODEID=2
												echo "master" > $TMPDIR/redundancy_type
												Machine="FirstMachine"

										else
												if [ $SWMF -ne 1 ]; then
														exit 1
												else
														return 1
												fi
										fi
								fi
						else
								DBNODEID=1
								PEERDBNODEID=-1
								echo "stand_alone" > $TMPDIR/redundancy_type
						fi
				fi

				if [ $AUF -ne 1 ]; then
						./nxconfig.pl -E -D $DBNAME -u $DBUSERNAME -h $LHOSTIP
				fi
				cd -

				#TODO: Generate $TMPDIR/redundancy.

		fi
		# Moving this code here because we need the value of this variable
		# irrespective of redundant or stand-alone setup. Earlier it was copied in
		# case of standand-alone setup only which caused function
		# Populate_Service_Ports() from not getting executed. 
		red_type=`cat $TMPDIR/redundancy_type 2>/dev/null`


		#Check if it is a redundant configuration

		if [ $vc2 -le 0 ];then
				#if previous iServer version was < 4.2 and this is an Auto-Upgrade task

				#Get the redundant information

				###
				# Redundancy pre-requisites.

				PEERISERVER=`DbGetPeerIserver $MACHINEID|sed -e 's/^\s*//g'| sed -e 's/\s$*//g'`
				MGMTIP=`DbGetMgmtIp $MACHINEID| sed -e 's/^\s*//g'| sed -e 's/\s$*//g'`
				CONTROLIF=`DbGetControlInterface $MACHINEID|sed -e 's/^\s*//g'| sed -e 's/\s$*//g'`
				if [ -n "$CONTROLIF" ]; then
						CONTROLIPADDR=`GetControlIpAddr $CONTROLIF| sed -e 's/^\s*//g'| sed -e 's/\s$*//g'`
				fi

				#Update and Start NxFirewall
				if [ -f "/sbin/Nxfirewall" ] ; then

						echo -n "Update Nxfirewall Configuration"
						/sbin/Nxfirewall updateconf 1>/dev/null 2>&1
						echo "${rc_done}"

						echo -n "Restart Nxfirewall"
						/sbin/Nxfirewall start 1>/dev/null 2>&1
						echo "${rc_done}"
				fi

				#change listen_addresses in postgresql.conf

				if [ -n "$MGMTIP" ]; then
						if [ -n "$CONTROLIPADDR" ]; then
								pglistenaddr="'127.0.0.1,$MGMTIP,$CONTROLIPADDR'"
						else
								pglistenaddr="'127.0.0.1,$MGMTIP'"
						fi
				else
						if [ -n "$CONTROLIPADDR" ]; then
								pglistenaddr="'127.0.0.1,$CONTROLIPADDR'"
						else
								pglistenaddr="'127.0.0.1'"
						fi
				fi

				EditPostgreSqlConf $pglistenaddr
				chown postgres:postgres $INSTALLDIR/$DATABASES/postgresql.conf

				RestartPostgres

				if [ $? -ne 0 ]; then
						ECHO "Upgrade failed: Error in RestartPostgres()"
						ECHO "Check the problems and restart postmaster"
				fi

				###
				# Managing redundancy here.

				#if peeriserver specified, its redundant configuration

				if [ -n "$PEERISERVER" -a -n "$CONTROLIPADDR" ]; then

						AddRedundantPgConf $PEERISERVER $CONTROLIPADDR

						if [ $? -eq 0 ]; then
								chown postgres:postgres $INSTALLDIR/$DATABASES/pg_hba.conf

								# TODO: This is an incorrect file.
								WriteRedundantDbInfo  $DBNODEID $CONTROLIPADDR $PEERDBNODEID $PEERISERVER

								if [ $? -ne 0 ]; then
										if [ $vc1 -le 0 ]; then
												RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
												RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
										fi
										ECHO "Install failed: Error in WriteRedundantDbInfo() $CONTROLIPADDR $PEERISERVER"
										if [ $SWMF -ne 1 ]; then
												exit -1
										else
												return 1
										fi
								fi

								ReloadPostgres

						else
								# TODO : Dont know how this helps
								if [ $vc1 -le 0 ]; then
										RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
										RemoteExecution $REMOTEIP AddDBRedundancyIntoInit
								fi
								ECHO "Install failed: Error in AddRedundantPgConf() $PEERISERVER"
								if [ $SWMF -ne 1 ]; then
										exit -1
								else
										return 1
								fi
						fi

						#Create the redundant RUMsater(<int>) function
						psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP < $INSTALLDIR/dbschema/rumaster_redundancy.pgsql 1>>$INSTALLLOG 2>&1

						# This file is created by nxconfig.pl -E.

						if [ "$red_type" = "slave" ]; then 
								#peeriserver database is master

								cd $INSTALLDIR/bin
								. ./mswreplication.sh

								cp ./currentConfiguration.sql ./updateServerConfig.sql

								# [5] 33407 #

								StartSetDbRoleCmdText | sh

								# [6] 33407 #

								if [ "$Machine" = "FirstMachine" ]; then

										X=1   

										#
										# FP#43394
										# Drop the psfcfg constraint on first machine if upgrading from 4.3
										#
										`echo $PSF_OLD_VERSION | grep -q '^4.3'`
										if [ $? -eq 0 ] ; then
												echo "Upgrading 4.3 - So dropping the psfcfg constraint on $LHOSTIP" 1>> $INSTALLLOG 2>&1
												psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP -c "alter table psfcfg drop constraint psfcfg_machineid_key;" 1>>$INSTALLLOG 2>&1
										fi

										while [ $X = 1 ]; do 

												ECHO -n "Please don't abort. Waiting for Subscription on $LHOSTIP to be active (Can take about 1 hour for large database) ..."
												WaitForActiveSubscription $LHOSTIP

												X=$?

												if [ $X = 1 ]; then
														if [ $SWMF -ne 1 ]; then
																AreYouSure "Subscription is not yet Active. Do you want to abort" "n"

																if [ $? = 1 ] ; then
																		RemoteExecution $REMOTEIP EnableSetDbRoleCmdText
																		if [ $? -ne 0 ]; then
																				if [ $WarningFlag -eq 0 ]; then
																						ECHO "Warning ! Couldn't configure remote system properly. Still Continuing.."
																						WarningFlag=1 
																				else  
																						echo "Couldn't configure remote system properly. Still Continuing" >>$INSTALLLOG  
																				fi
																		fi
																		RemoteExecution $REMOTEIP AddDBRedundancyIntoInit  
																		if [ $? -ne 0 ]; then
																				if [ $WarningFlag -eq 0 ]; then
																						ECHO "Warning ! Couldn't configure remote system properly. Still Continuing.."
																						WarningFlag=1 
																				else  
																						echo "Couldn't configure remote system properly. Still Continuing" >>$INSTALLLOG  
																				fi
																		fi
																		ECHO "${warn}Upgrade incomplete. Pls uninstall the release.${rc_restore}" 
																		exit 1
																fi 
														else
																ECHO "${warn}Upgrade incomplete. Pls uninstall the release.${rc_restore}" 
																return 1
														fi
												fi 

										done

										ECHO ${rc_done}

										ECHO -n "Making this Master ..."

										WaitForMinuteBoundary

										echo "[`date`] rep_switchover" >> $INSTALLLOG

										rep_switchover 1>>$INSTALLLOG 2>&1

										HandleDbSwitchingError $?

										ECHO ${rc_done}

										ECHO -n "Dropping the other node ..."
										rep_nodeclean $PEERDBNODEID $DBNODEID 1>>$INSTALLLOG 2>&1
										ECHO ${rc_done}

										sleep 60

										StartSetDbRoleCmdText | sh

										ECHO -n "Reinitializing the cluster ..."
										rep_init 1>>$INSTALLLOG 2>&1
										ECHO ${rc_done}


										# Updating internal RSA's if they are set to zero...
										psql -Umsw -c"SELECT check_and_correct_internalrsa_func();" 1>/dev/null 2>&1

										FindMasterIP

										# Remove Old Configuration EXCEPT Other Node's Machine Dependent
										psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP -c "delete from servercfg where machineid = '$MACHINEID' or machineid  = '' ;" 1>>$INSTALLLOG 2>&1
										# Restore DEFAULT Configuration from NEW DB
										psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP < $INSTALLDIR/dbschema/insert-default-server-configuration.pgsql 1>>$INSTALLLOG 2>&1
										psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP < $INSTALLDIR/dbschema/rumaster_redundancy.pgsql 1>>$INSTALLLOG 2>&1
										psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP < $INSTALLDIR/dbschema/error.strings.default.pgsql 1>>$INSTALLLOG 2>&1

										# Restore CHANGED Configuration from OLD DB
										./nxconfig.pl -c -D $DBNAME -u $DBUSERNAME -h $MASTERIP

										# RSMLite Start
										# Update MSW Tables with Changes required for RSM/RSMLite
										ECHO "RSMLite Updating Tables ..."
										if test -f $INSTALLTMPDIR/updatemsxdata.sql ; then
												psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP   < $INSTALLTMPDIR/updatemsxdata.sql  1>> $INSTALLLOG 2>&1
										else
												ECHO "ERROR: (SCM) File: $INSTALLTMPDIR/updatemsxdata.sql NOT Found" 1>> $INSTALLLOG 2>&1
										fi
										# RSMLite End

										# PSF BACKUP-RESTORE Start
										# Restore the PSF Configuration
										#
										# UPGRADE-INSTALL --> Restore the Changed Configuration on the MASTER DB
										#
										# Remove Old Configuration EXCEPT Other Node's Machine Dependent
										psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP -c "delete from psfcfg where machineid = '$MACHINEID' or machineid  = '' ;" 1>>$INSTALLLOG 2>&1

										#
										# FP#43394
										# Add back the psfcfg constraint on first machine if upgrading from 4.3
										#
										`echo $PSF_OLD_VERSION | grep -q '^4.3'`
										if [ $? -eq 0 ] ; then
												psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP -c "delete from psfcfg;" 1>>$INSTALLLOG 2>&1
												echo "Upgrading 4.3 - adding back the psfcfg constraint on $MASTERIP" 1>> $INSTALLLOG 2>&1
												psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP -c "alter table psfcfg add constraint psfcfg_machineid_key UNIQUE(machineid, moduleid, attrname);" 1>>$INSTALLLOG 2>&1
										fi

										# Restore DEFAULT Configuration from NEW DB
										PSFBACKUPFILE="/usr/local/psf/conf/.psf_bkp_install.dat"
										PSFRestoreConfig $DBUSERNAME $DBNAME $MASTERIP $INSTALLLOG $PSFBACKUPFILE

										# Restore CHANGED Configuration from OLD DB
										PSFOLDCURRENTFILE="/usr/local/psf/conf/.psf_bkp_current.old.dat"
										PSFRestoreConfig $DBUSERNAME $DBNAME $MASTERIP $INSTALLLOG $PSFOLDCURRENTFILE
										# PSF BACKUP-RESTORE End

								elif [ "$Machine" = "SecondMachine" ] || [ "$Machine" = "NONE" ] ; then

										./nxconfig.pl -r

										# PSF BACKUP-RESTORE Start
										#
										# Restore the PSF Machine Dependent Configuration
										#
										PSFMCDBACKUPFILE="/usr/local/psf/conf/.psf_bkp_machinedep.dat"
										PSFBackupConfig $DBUSERNAME $DBNAME $LHOSTIP $INSTALLLOG $PSFMCDBACKUPFILE "machinedep" "insert"
										FindMasterIP
										PSFRestoreConfig $DBUSERNAME $DBNAME $MASTERIP $INSTALLLOG $PSFMCDBACKUPFILE
										# PSF BACKUP-RESTORE End

								fi


								FindMasterIP

								#./nxconfig.pl -m -D $DBNAME -u $DBUSERNAME -h $MASTERIP

								./msw_status_update.sh

								psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP -c "UPDATE msw_status SET attrvalue = $DBNODEID WHERE attrname = 'nodeid' and machineid = '$MACHINEID';" 1>>$INSTALLLOG 2>&1 

								AllowRedundancyForMSWClient $CONTROLIPADDR

								cd -
						else
								#peeriserver database is not availabe, hence this is master.

								cd $INSTALLDIR/bin

								ECHO -n "Configuring local DB as MASTER ..."
								rep_init 1>>$INSTALLLOG 2>&1
								if [ $? -eq 0 ]; then
										ECHO ${rc_done}
								else
										ECHO ${rc_failed}
								fi

								#./nxconfig.pl -m -D $DBNAME -u $DBUSERNAME -h $CONTROLIPADDR

								./msw_status_update.sh

								psql -U$DBUSERNAME -d$DBNAME -h$CONTROLIPADDR -c "UPDATE msw_status SET attrvalue = $DBNODEID WHERE attrname = 'nodeid' and machineid = '$MACHINEID';" 1>>$INSTALLLOG 2>&1 

								AllowRedundancyForMSWClient $CONTROLIPADDR
								cd -
						fi
				else
						cd $INSTALLDIR/bin
						./msw_status_update.sh 
						cd -
				fi
		fi

		#
		# Handled redundancy.
		###

		FindMasterIP

		if [ $vc1 -gt 0 -a $AUF -eq 1 ]; then
				#get the fwname attrvalue from DB
				FWNAME=`psql -Umsw -q -h$MASTERIP -t -c"Select attrvalue from servercfg where attrname='fwname';"|head -1|sed -e 's/^ //g'| sed -e 's/\s$//g'`
				if [ "$FWNAME" = "NSF" -o "$FWNAME" = "HK" ]; then
						psql -Umsw -q -h$MASTERIP -c"Update servercfg set attrvalue='MS' where attrname='fwname';"
				fi
		fi

		#The DB has all required configuration now

		###
		# Restoring the data from the old.

		#copy the database backup files, if exists
		if [ -d "$BKDBBACKUP" ]; then
				cp -pr $BKDBBACKUP $INSTALLDIR/bin/${BACKUPDBDIR}
		fi

		#Insert the default mdevices.xml in DB otherwise we 
		#will miss the default value of mdevices
		cd $INSTALLDIR/bin/
		./nxconfig.pl -m -D $DBNAME -u $DBUSERNAME -h $MASTERIP
		cd -

		# convert pools.xml file to mdevices.xml
		if [ "$vc2" -le '0' -a "$vc1" -eq '2' -a -f $OLD_CLI_PATH/bin/pools.xml ]; then 
				echo "converting pool.xml to mdevices.xml" >> $INSTALLLOG
				mv $INSTALLDIR/bin/mdevices.xml $INSTALLDIR/bin/mdevices_sample.xml
				cd $INSTALLDIR/bin
				./convert_pool_xml.pl -i $OLD_CLI_PATH/bin/pools.xml \
				-o $INSTALLDIR/bin/mdevices.xml
				cp $OLD_CLI_PATH/bin/pools.xml $INSTALLDIR/bin/old_pools.xml
				cd -
		fi

		if [ $vc2 -gt 0 ]; then
				#version being installed < 4.2
				#copy the mdevices.xml, if exists
				if [ -f "$MDEVICESBACKUP" ]; then
						cp -p $MDEVICESBACKUP $INSTALLDIR/bin/$MDEVICESFILE
				fi
		else
				#version being installed >= 4.2
				#copy the mdevices.xml from $TMPINSTALLDIR to $INSTALLDIR/bin/ (To retain prv version mdevices.xml)
				if [ -f "$MDEVICESBACKUP" ]; then
						cp -p $MDEVICESBACKUP $INSTALLDIR/bin/$MDEVICESFILE
				fi
				#insert the mdevices.xml
				cd $INSTALLDIR/bin/

				./nxconfig.pl -m -D $DBNAME -u $DBUSERNAME -h $MASTERIP

				cd -
		fi

		#copy the routeManager script, if exists
		if [ -f "$ROUTEMGRBACKUP" ]; then
				sed -i.bak -e '/^[[:space:]]*DeleteNoarpEntries/d' -e '/sub DeleteNoarpEntries/,/^}/d'  -e '/# DeleteNoarpEntries/d' $ROUTEMGRBACKUP
				cp -p $ROUTEMGRBACKUP $INSTALLDIR/bin/$ROUTEMGRFILE
		fi

		#copy the codemap backup files
		if [ -d "$CODEMAPBACKUP" ]; then
				cp -p $CODEMAPBACKUP/${CODEMAPTXTFILES} $INSTALLDIR/bin/codemap 2>/dev/null
				cp -p $CODEMAPBACKUP/${CODEMAPDATFILES} $INSTALLDIR/bin/codemap 2>/dev/null
		fi


		#Copy license file 
		# This is a mess with a lot of duplicated code. The InstallLicFile routine
		# should be written to handle  all license file possibilities. 
		if [ $AUF -ne 1 ];then
				#if not Auto-upgrade ask if license is to be reused
				if [ -f $OLD_CLI_PATH/bin/$LICENSEFILE ]; then
						$ECHON "Do you want to reuse existing License File ?[${BOLD}y${OFFBOLD}]:"
						read resp
						if [ "$resp" = "n" ]; then
								cd $STARTDIR; InstallLicFile $vc2; cd -
						else
								cp $OLD_CLI_PATH/bin/$LICENSEFILE /usr/local/nextone/bin
								cd /usr/local/nextone/bin
								./nxconfig.pl -l -D $DBNAME -u $DBUSERNAME -h $MASTERIP
								cd -
						fi
				else
						cd $STARTDIR; InstallLicFile $vc2; cd -
				fi
		else # autoupgrade

				# If the old version is less than 4.2, cannot reuse license
				if [ $vc1 -gt 0 ]; then
						#If DB is already installed on peer, skip loading temp Licence file 
						GetRemoteNodeIDFromPeer $CONTROLIPADDR $PEERISERVER $DBUSERNAME
						PEERDBNODEID=$?
						if [ $PEERDBNODEID -eq 1 ]; then
								$ECHON "Cannot reuse license file from $ALOID_OLD_VERSION."\
								"Temporary license already installed on peer."
						else
								$ECHON "Cannot reuse license file from $ALOID_OLD_VERSION."\
								"Installing temporary license."
								cd $STARTDIR; InstallLicFile $vc2; cd -
						fi
				else
						if [ $SWMF -ne 1 ]; then
								$ECHON "Do you want to reuse existing License File ?[${BOLD}y${OFFBOLD}]:"
								read resp
								if [ "$resp" = "n" ]; then
										cd $STARTDIR; InstallLicFile $vc2; cd -
								else
										cp $OLD_CLI_PATH/bin/$LICENSEFILE /usr/local/nextone/bin
										cd /usr/local/nextone/bin
										./nxconfig.pl -l -D $DBNAME -u $DBUSERNAME -h $MASTERIP
										cd -
								fi
						else
								# If the upgrade process has not installed the license
								# copy it from the previous build
								if [ ! -f $INSTALLDIR/bin/$LICENSEFILE ]; then
										cp $OLD_CLI_PATH/bin/$LICENSEFILE /usr/local/nextone/bin
								fi
								cd $INSTALLDIR/bin
								./nxconfig.pl -l -D $DBNAME -u $DBUSERNAME -h $MASTERIP
								loginfo "Inserting license file into the database with the following command -"
								loginfo "cwd = $INSTALLDIR/bin cmd = ./nxconfig.pl -l -D $DBNAME -u $DBUSERNAME -h $MASTERIP"
								loginfo "License file -"
								logFile info ./iserverlc.xml
								ret=$?
								cd -
								if [ $ret -ne 0 ]; then
										logwithid error "$FUNCNAME: insert license file failed!"
										return 1
								fi
						fi     
				fi
		fi
		# Update the config param max-transport-mtu-size to 2500 if necessary
		#
		UpdateMaxTransportMtuSize $ALOID_OLD_VERSION

		#
		UpdateIPLayerRateLimiting $ALOID_OLD_VERSION

		# remove ip layer outgoing ratelimiting for unknown endpoints
		#
		Remove_IP_LAYER_RL_O_UNK_EP $ALOID_OLD_VERSION

		###
		# System updates.

		#Add cronjob to periodically check for postgres and slon(in case redundant)
		cronline='* * * * * /usr/local/nextone/bin/setdbrole.sh'
		AddCronJob setdbrole.sh "database redundancy" "$cronline"

		#Remove previous boot services
		/sbin/chkconfig -d nextoneIserver 2>/dev/null
		/sbin/chkconfig -d nextoneDBRedundancy 2>/dev/null
		rm -f /etc/init.d/nextoneDBRedundancy
		rm -f /etc/init/d/nextoneIserver

		#Add New boot services
		$SOFTLINK $INSTALLDIR/bin/setdbrole.sh /etc/init.d/nextoneDBRedundancy 
		/sbin/chkconfig -a nextoneDBRedundancy
		/bin/cp -pf $STARTDIR/nextoneIserver /etc/init.d/
		/sbin/chkconfig --add nextoneIserver

		if [  -d /etc/ais ]; then
				if [ -f "/etc/ais/openais.conf" ]; then
						echo "Editing AIS configuration"
						EditAISConfFile
				fi

				Log_function info "GENBAND MSX checking for incomplete arp entry"
				mcast_ip="226.94.1.1"
				host=`/bin/hostname`
				cntl_if=`/usr/local/nextone/bin/nxconfig.pl -S | grep control-interface | grep $host | awk '{print $4}'`
				incompl_ip=`/sbin/arp -n | grep incomplete | grep $mcast_ip | awk '{print $1}'`
				if [ -n "$incompl_ip" ];
				then
						Log_function error "GENBAND MSX incomplete arp entry found for multiast address \"$mcast_ip\" on control interface $ctrl_if"
						Log_function error "GENBAND MSX replacing arp entry "
						/sbin/ip neigh replace $mcast_ip dev $cntl_if lladdr 01:00:5e:5e:01:01 nud noarp
				fi

				echo "Starting AIS"
				/bin/grep /usr/local/nextone/bin/aisexec /etc/inittab > /dev/null
				if [ $? -ne 0 ]; then
						cp -f /etc/inittab /etc/inittab.orig
						echo "99:35:respawn:/usr/local/nextone/bin/aisexec" >> /etc/inittab
						telinit q
				fi
		fi

		echo "Starting AIS"

		#copy named configuration
		if test -f "$STARTDIR/$NAMEDFILE" ; then
				cp -pf $STARTDIR/$NAMEDFILE /usr/local/nextone/bin/named.conf
		fi
		if [[ $(grep -c "#nextone#" /etc/named.conf) == 0 ]]
		then
				echo "###############nextone#########################" >> /etc/named.conf
		fi 	

		###
		# Clean up.

		#Cleanup-Remove temporary files etc.
		rm -f $INSTALLDIR/bin/sconfig
		rm -f $INSTALLDIR/bin/server.cfg

		#PSF : psf.rpm got copied to /usr/local/nextone/bin, clean it
		rm -f $INSTALLDIR/bin/psf.rpm

		if [ $SWMF -ne 1 ]; then
				cd $INSTALLTMPDIR
				#Remove main iserver directory.
				rm -rf ${PRODUCT}-${ALOID_VERSION}
				#Remove any archive files
				rm -f *.tar
				rm -f $INDEXFILE
				rm -f $DATEFILE
		fi

		# Retain the start-on-boot state of the previous installation

		if $START_ON_BOOT; then
				touch /databases/boot
		else
				rm -f /databases/boot
		fi

		###
		# Restoring provision data.

		old_version=`expr substr $ALOID_OLD_VERSION 1 3`
		new_version=`expr substr $ALOID_VERSION 1 3`

		if [ "$red_type" != "slave" ]; then

				# Case : standalone or master

				ECHO "Importing the existing data to the newer version ..."
				ECHO -n "This may take some time depending on the amt of data!"
				$INSTALLDIR/bin/cli db add -I $EXPORT_FILE 1>>$INSTALLLOG 2>&1

				if [ $? -eq 0 ];then
						ECHO "${rc_done}"

				else
						ECHO "$rc_failed"
						ECHO -e "\033[1;38mUnable to restore the previous provisioning data. Data is saved in $INSTALLDIR/bin/oldpovision.xml \033[0m\n"

						mv $EXPORT_FILE $INSTALLDIR/bin/oldpovision.xml
				fi

				# Initialize service sets
				old_version=`expr substr $ALOID_OLD_VERSION 1 3`

				new_version=`expr substr $ALOID_VERSION 1 3`

		else
				#store the existing provisioning data so that in any misap we can
				#have the data to manually import
				mv $EXPORT_FILE $INSTALLDIR/bin/oldpovision.xml
		fi  

		# Service Sets introduced in 4.3 - for upgrades from releases earlier than
		# 4.3 initialize service sets. This needs to be done only on the first m/c
		# in a cluster / during the upgrade of a standalone box 
		if [ "$Machine" = "FirstMachine" ] || [ "$red_type" = "stand_alone" ]; then
				# Initialize service sets
				if [ "$old_version" = "4.0" ] || [ "$old_version" = "4.2" ]; then
						echo "adding service sets" >> $INSTALLLOG
						InitServiceSet
						Populate_Service_Ports
				fi

				if [ "$old_version" = "4.3" ] || [ "$old_version" = "4.3" ]; then
						echo "adding service sets" >> $INSTALLLOG
						InitServiceSet
						Populate_Service_Ports
				fi

				# 5.0->maple: Correct HdrPolicy table
				# 4.x or 5.0 ->maple: Insert default policies

				ApplyHdrPolCorrection
				flag=$?
				if [ $flag -eq 1 ] ; then
						echo "adding default hdr rules and hdr policies" >> $INSTALLLOG
						if [ "$old_version" = "5.0" -o "$old_version" = "5.1" ] ; then
								psql -Umsw -c"SELECT modify_hdrpolicy_hdrrule_tables_func();" 1>/dev/null 2>&1	
						fi
				fi

				# These functions now need to be called unconditionally as we have stopped exporting the
				# hdrrules in the xml file - this is being done because its the default provisioning data.  
				# 1 => Upgrade from 5.2 or above; 2 => Upgrade from 4.0,4.2,4.3,5.0,5.1
				# In case of '2', we need to create a system profile
				if [ $flag -eq 1 ] ; then
						ApplyHdrPolicyToEpRealm 2
				else
						ApplyHdrPolicyToEpRealm 1
				fi
				DeleteHdrPolGlobalConfig

				# RSMLite Start
				# Update MSW Tables with Changes required for RSM/RSMLite
				ECHO "RSMLite Updating Tables ..."
				if test -f $INSTALLTMPDIR/updatemsxdata.sql ; then
						psql -U$DBUSERNAME -d$DBNAME -h$MASTERIP   < $INSTALLTMPDIR/updatemsxdata.sql  1>> $INSTALLLOG 2>&1
				else
						ECHO "ERROR: (STANDALONE OR FIRSTMACHINE) File: $INSTALLTMPDIR/updatemsxdata.sql NOT Found" 1>> $INSTALLLOG 2>&1
				fi
				# RSMLite End

		fi


		ECHO -e "\n\t\t\033[1;38mIserver Core Package Upgrade Complete !!\033[0m\n"
		cd $STARTDIR

		# TODO: ?
		chown postgres:ais $INSTALLDIR/$DATABASES/pg_hba.conf.*

		#Now allow setdbrole.sh to execute

		# [7] 33407 #
		if [ "$Machine" = "NONE" ]; then
				rm -f $TMPDIR/roleinprogress
		fi

		rm -f $TMPDIR/redundancy_type
		return 0

}

