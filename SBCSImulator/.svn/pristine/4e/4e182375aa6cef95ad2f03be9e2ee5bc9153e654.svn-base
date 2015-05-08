INSTALLLOG="/var/log/iserverinstall.log"
# MODULE TO CUSTOMIZE ECHO COMMAND
ECHO()
{
  echo $*
  echo "[`date`]" $* >>  $INSTALLLOG
}

# PSF BACKUP
# PSF Backup Configuration
#
# $1 - DB Username
# $2 - DB Name
# $3 - Host IP
# $4 - INSTALLLOG
# $5 - BACKUP FILE
#
# $6 - TYPE OF BACKUP
# $7 - TYPE OF BACKUP STATEMENTS
PSFBackupConfig()
{
  ECHO -n "Saving PSF Configuration.."

  if [ -z "$3" ] ; then
    ECHO "....Host IP Missing ..."
    ECHO "$rc_failed"
    exit 1;
  fi

  if ! test -f /usr/local/psf/bin/psfconfig ; then
    ECHO "..../usr/local/psf/bin/psfconfig Not present ..."
    ECHO "$rc_failed"
    exit 1;
  fi

  # Dump ALL PSF Configuration as INSERT Statements
  echo " /usr/local/psf/bin/psfconfig -c $5 -h $3 -D $1 -u $2 -w $6 -x $7 " 1>>$4 2>&1
  
  /usr/local/psf/bin/psfconfig -c $5 -h $3 -D $1 -u $2 -w $6 -x $7 1>>$4 2>&1
  if [ $? -ne 0 ]; then
    ECHO "..../usr/local/psf/bin/psfconfig returned error ..."
    ECHO "$rc_failed"
    exit 1;
  else
    ECHO "$rc_done"
  fi
}



# PSF BACKUP-RESTORE
# PSF Backup Configuration from 4.3 PSF
#
# $1 - DB Username
# $2 - DB Name
# $3 - Host IP
# $4 - INSTALLLOG
# $5 - BACKUP FILE
#
PSFBackupConfigFrom43PSF()
{
  ECHO -n "Restore PSF Configuration from 4.3"

  if [ -z "$3" ] ; then
    ECHO "....Host IP Missing ..."
    ECHO "$rc_failed"
    exit 1;
  fi

  echo -n > $5

  ##  This is not an exhaustive list, but just basic stuff that makes RX work
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "msx_rx" "Auth-Stage"
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "msx_rx" "LocalIPAddr"
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "msx_rx" "Identity"
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "msx_rx" "PortNo"
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "msx_rx" "Realm"
  ## NO NEED TO BACKUP AuthAppId from 4.3 (5.0 has IANA Assigned ID)
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "PeerConfig" "Identity" "msx_rx.PeerConfig.1"
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "PeerConfig" "PortNo" "msx_rx.PeerConfig.1"
  PSFGetAndSave43PSF $1 $2 $3 $4 $5 "PeerConfig" "Realm" "msx_rx.PeerConfig.1"

  ##  This is to get the realm name from the configured LocalIPAddr
  PSFVAL=`psql -q -U$1 -d$2 -h$3 -t -c"SELECT attrvalue from psfcfg where moduleid='msx_rx' and attrname='LocalIPAddr';"|head -1|sed -e 's/^ //g'| sed -e 's/\s$//g'`
  if [ "$PSFVAL" != "" -a "$PSFVAL" != "0.0.0.0" ] ; then
      ALOID_OLD_VERSION=`cat /usr/local/nextone/.aloidindex`
      OLD_CLI="/opt/nxtn/iserver-${ALOID_OLD_VERSION}/bin/cli"
      PSFVAL=`$OLD_CLI realm list | egrep -1 "^ *Rsa *$PSFVAL" | grep Realm | awk -F" " ' { print $2 }'`
      if [ "$PSFVAL" != "" ] ; then
          echo "UPDATE psfcfg SET attrvalue='$PSFVAL' WHERE moduleid='msx_rx' AND attrname='NxRealmName';" >> $5
          echo "UPDATE psfcfg SET attrvalue='0.0.0.0' WHERE moduleid='msx_rx' AND attrname='LocalIPAddr';" >> $5
      fi
  fi

  ECHO "$rc_done"
}

##
## AreYouSure
##
## New calling convention: AreYouSure $1 $2
## where $1 is the prompt
## and   $2 is the default answer (one of y or n)
##
AreYouSure ()
{
        if [ $# -eq 3 ]
        then
                if [ $3 -eq 1 ]         #AUF is ON
                then
                        return 0
                fi
        fi

        # Initialize yesorno
        yesorno=$2

        echo ""
        ECHO "                $1 ?[${BOLD}$yesorno${OFFBOLD}]:"

        read resp
        if [ ! -z "$resp" ]; then
                yesorno=`echo $resp | cut -c 1 -`
        fi

        if [ "$yesorno" = "y" ] || [ "$yesorno" = "Y" ]; then
                return 1
        else
                return 0
        fi
}

##
## trimLeadingSpaces
##
## where $1 is the string to be trimmed
##
trimLeadingSpaces()
{
        if [ $# -ne 1 ]; then
                echo "Usage: trimLeadingSpaces <string>"
        fi

        echo $1| sed -e 's/^\s//g'
}

# PreUpgradeLoop takes care of all the back-up to be taken for
# Pre 6.0 to 6.0 Upgrade and shall be executed as a part of GB Linux
# backup procedure.
# Usage of this script shall be PreUpgradeLoop or "sh PreUpgrade.sh" from command line.

PreUpgradeLoop ()
{
	# PRE_UPGRADE VALIDITY TEST
	SWMF=0
	INDEXFILE=".aloidindex"
	if [ ! -f "/usr/local/nextone/.aloidindex" ]; then
		ECHO "No installed version. Cannot take backup for pre-requisite to 6.0 Upgrade. Exiting !!"
		exit 2
	fi


	# VARIABLE INITIALIZATION
	DATABASES="databases/databases"
	WarningFlag=0

	PSFINDEXFILE=".psfindex"

	DBNODEID=-1
	PEERDBNODEID=-1
	DBNAME=msw
	LHOSTIP="127.0.0.1"
	DBUSERNAME="msw"
	ALOID_OLD_VERSION=`cat /usr/local/nextone/.aloidindex`
	if test -f "/usr/local/nextone/${PSFINDEXFILE}" ; then
		PSF_OLD_VERSION=`cat /usr/local/nextone/${PSFINDEXFILE}`
	else
		PSF_OLD_VERSION=""
	fi
	CURRENTBINDIR="/opt/nxtn/iserver-${ALOID_OLD_VERSION}"
	UPGRADETMPDIR="/var/tmp/nextone-upgrade"
	MACHINEID=`hostname`
	MACHINEID=`trimLeadingSpaces "$MACHINEID"`
	STARTDIR=`pwd`
	EXPORT_FILE="$UPGRADETMPDIR/SBCProvisionData.xml" 
	INSTALLLOG="/var/log/iserverinstall.log"
	MASTERIP="127.0.0.1"
	BACKUPDBDIR="iserver_db"
	MDEVICESFILE="mdevices.xml"

	# BACKUP STARTS HERE

	if [ ! -f $CURRENTBINDIR/bin/nxconfig.pl ]; then
		ECHO "nxconfig.pl not present - so pre-upgrade to 6.0 not possible ..."
	fi	

	# Remove install tmp dir	
	rm -rf $UPGRADETMPDIR
	mkdir $UPGRADETMPDIR

	cd $UPGRADETMPDIR


	ECHO -e "\n\t\t\033[1;38mDATA BACKUP FROM ISERVER VERSION-$ALOID_OLD_VERSION AS PRE-REQUISITE TO 6.0 UPGRADE\033[0m\n"

    	# Postgress is required. Would be running with default or previous configuration.

	rcpostgresql status
	if [ $? -ne 0 ]; then
		rcpostgresql start
	fi

	# Save the existing provisioning data from the master / slave / standalone database.

	ECHO -n "Saving old database ..." 
	$CURRENTBINDIR/bin/cli db export $EXPORT_FILE 1>>$INSTALLLOG 2>&1
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

	# Pgdump of the extra tables - As of now the tables being treated for pgdump are
	# 1. li_interceptedcalls
	# 2. clihistory
	# 3. msw_outage

	pg_dump -U postgres --column-inserts --data-only -t clihistory msw > nonProvisionTables.sql
	pg_dump -U postgres --column-inserts --data-only -t msw_outage msw >> nonProvisionTables.sql
	pg_dump -U postgres --column-inserts --data-only -t li_interceptedcalls msw >> nonProvisionTables.sql

	# Save the old ivmsclient password.  Use the old password with the new DB (fp 53192)
	ECHO -n "Saving ivms client password .."
	echo "IVMSCLIENTDBPASS=`psql -Umsw -t -q -c "select rolpassword from pg_authid where rolname='ivmsclient'" | sed 's/^ //'`" > ivmsClientDbPass.txt

	# Save license.

	ECHO
	ECHO -n "Saving old licence ..." 
	ECHO
	ECHO -n "Old License saved at:  "
	cd $UPGRADETMPDIR
	$CURRENTBINDIR/bin/nxconfig.pl -L >>$INSTALLLOG 2>&1
	ECHO "$rc_done" 

	#generate the file currentConfiguration.sql and save it in $UPGRADETMPDIR directory

	ECHO "Saving Current Configuration file .. "
	$CURRENTBINDIR/bin/nxconfig.pl -C -D $DBNAME -u $DBUSERNAME -h $MASTERIP # this generates currentConfiguration.sql thru DbGetCurrConfig() in ServerCfg.pm
	if [ $? != 0 ]; then
		ECHO "Error in saving Current Configuration file .. "
		exit 1
	fi

	# Generate the file fullConfiguration.txt and save it in $UPGRADETMPDIR directory
	ECHO "Saving Full Configuration file .. "
	$CURRENTBINDIR/bin//nxconfig.pl -S > fullConfiguration.txt
	if [ $? != 0 ]; then
		ECHO "Error in saving Full Configuration file .. "
		exit 1
	fi


	# PSF BACKUP Start
	ECHO "Saving PSF Configuration & Data .. "
	if [ "${PSF_OLD_VERSION}" != "" ] ; then
		# Copy OLD Install Backup
		PSFINSBACKUPFILE="/usr/local/psf/conf/.psf_bkp_install.dat"
		if test -f $PSFINSBACKUPFILE ; then
			cp -pf $PSFINSBACKUPFILE $UPGRADETMPDIR
		else
			ECHO "Error in saving PSF Data .. " 	
			exit 1
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
			cp -pf $PSFBACKUPFILE $UPGRADETMPDIR
		else
			ECHO "Error in saving PSF Configuration .. " 	
			exit 1
		fi
	fi
	# PSF BACKUP End

	#Upgrade from a Version ***prior*** to the Version where mdevices.xml became Machine Dependent

	ECHO "Saving mdevices file .. "

	# Get the mdevices.xml from the DB
	cd $UPGRADETMPDIR/${MDEVICESBACKUP}
	$CURRENTBINDIR/bin/nxconfig.pl -M -D $DBNAME -u $DBUSERNAME -h $MASTERIP >> $INSTALLLOG 2>&1

	MDEVICESBACKUP="${MDEVICESFILE}-${ALOID_OLD_VERSION}"
	if [ $? -eq 0 ] ; then
		ECHO "Saved mdevices file successfully"
	else
		ECHO "Error in saving mdevices file .. " 	
		exit 1
	fi
	
	ECHO "Saving backupdbdir file .. "
	BKDBBACKUP="${BACKUPDBDIR}-${ALOID_OLD_VERSION}"
	if [ -d "$CURRENTBINDIR/bin/${BACKUPDBDIR}" ]; then
		cp -pr $CURRENTBINDIR/bin/${BACKUPDBDIR} $UPGRADETMPDIR/${BKDBBACKUP}
	else
		ECHO "Backup DB Dir not present ..  " 	
	fi
	
	return 0
}

PreUpgradeLoop
