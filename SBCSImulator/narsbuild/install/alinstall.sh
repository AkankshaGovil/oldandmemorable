#!/bin/sh

################################
#### File:	alinstall.sh
####
################################

# Need this to install JRE patched for SunOS
#. ./checkpatch.sh

PRODUCT="iserver"
MEDIAFILE="${PRODUCT}install.tar"
INDEXFILE=".aloidindex"
INSTALLTMPDIR="/tmp/nextone-install"
LICENSEFILE="iserver.lc"

ARAVOXFILE="aravox.xml"
IPFILTERFILE="ipfilter.cfg"
DOWNLOADSERVERDIR="jserver-data"
BACKUPDBDIR="iserver_db"

if [ "$MC" = "SunOS" ]; then
    JREFILE="jre13.sh"
    JREINSTALLDIR="/usr/j2re1_3_1_01"
    JREDEFAULTDIR="j2re1_3_1_01"
else
#    LIBC=`/sbin/ldconfig -D 2>&1 | grep libc.so.6 | grep -v warning | tr -d ' ' | cut -d">" -f2 | cut -d\- -f2 | cut -d\. -f-3`
    # LIBC will be of format 2.1.x, extract the last digit
#    _THIRDDIGIT=`echo $LIBC | cut -d"." -f3`
#    if [ $_THIRDDIGIT -ge 2 ]; then
#	JREFILE="jre122.sh"
	JREFILE="jre122.tar.bz2"
	JREINSTALLDIR="/usr/local/jre1.2.2"
	JREDEFAULTDIR="jre1.2.2"
#    else
#	JREFILE="jre1.2.tar.gz"
#	JREINSTALLDIR="/usr/local/jre1.2"
#	JREDEFAULTDIR="jre1.2"
#    fi
fi

CheckForSuperuser ()
{
	###########################
	## Must be root
	###########################
	if [ "$LOGNAME" != "root" ]; then
		echo ""
		echo "You must be super-user to run this script."
		echo "Exiting.... "
		exit 2
	fi

}

MainInstallLoop ()
{

	CheckForSuperuser

	STARTDIR=`pwd`

	if [ -d "/usr/local/nextone" ]; then
		ClearScreen
		$ECHO " "
		$ECHO " "
		$ECHO "GENBAND iServer Installer has detected a previous installation of iServer."
		$ECHO "Please use the Upgrade option if you wish to upgrade to a new release."
                cd $STARTDIR
                Pause
                return 0 

	fi

	$ECHON "Enter media or file [$MEDIAFILE]: "
	read resp

	if [ -z "$resp" ]; then
		resp=$MEDIAFILE
	fi

	MEDIAFILE=$resp

	## Go up to the parent directory
	cd ..

	if [ ! -f "$MEDIAFILE" ]; then
		echo "Cannot find $MEDIAFILE: No such file or directory"
		echo "Exiting..."
		exit 1
	fi

	## Blurb about space requirements etc.
	##

	SIZEOFMEDIA=`/bin/ls -l $MEDIAFILE | awk ' { print $5 } ' `
	SPACE=`expr 3 \* $SIZEOFMEDIA / 1024`

	## Check if we meet the space requirements
        AVAIL=`df -k  /usr  |sed '1d' |awk '{print $4}'`
        if [ $AVAIL -lt $SPACE ] ; then
		$ECHO "You will need atleast $SPACE Kbytes for this install."
		$ECHO "Only $AVAIL Kbytes available"
		AreYouSure "Are you sure you want to proceed" "y"
		if [ $? = 0 ]; then
			echo "Exiting..."
			exit 1
		fi
	else 
		$ECHO "$SPACE Kbytes Needed,  $AVAIL Kbytes available ... Proceeding"
	fi

	## Create tmp directory
	## Actually ask for tmp directory.
	$ECHON "Enter temporary directory to use for the install: [$INSTALLTMPDIR]: "
	read resp

	if [ -z "$resp" ]; then
		resp=$INSTALLTMPDIR
	fi

	INSTALLTMPDIR=$resp

	if [ ! -d "$INSTALLTMPDIR" ]; then
		$ECHO "$INSTALLTMPDIR does not exist. Creating $INSTALLTMPDIR..."
		mkdir $INSTALLTMPDIR
	fi

	cp $MEDIAFILE $INSTALLTMPDIR

	cd $INSTALLTMPDIR

	##
	## TAR out the MEDIAFILE
	##
	tar xvf $MEDIAFILE

	ALOID_VERSION=`cat ${INDEXFILE}`
	echo "${PRODUCT}_VERSION is $ALOID_VERSION"

	AreYouSure "Are you sure you are installing ${PRODUCT} version $ALOID_VERSION " "y"
	if [ $? = 0 ]; then
		echo "Exiting..."
		exit 1
	fi

	##
	## Now copy the files to its respective places.
	##

	TMPDIRNAME="${INSTALLTMPDIR}/${PRODUCT}-${ALOID_VERSION}"
	cd $TMPDIRNAME

	##
	## Must be root to do this
	##

        ##
        ## Create /usr/local if it doesn't exist
        ##
        if [ ! -d /usr/local ];
                then mkdir /usr/local
        fi


	INSTALLDIR="/usr/local/nextone-${ALOID_VERSION}"
	mkdir $INSTALLDIR

	##
	## Copy the index file
	##
	cp -p $INSTALLTMPDIR/${INDEXFILE} $INSTALLDIR

	##########################
	## Create the directories
	##########################
	mkdir $INSTALLDIR/bin
	mkdir $INSTALLDIR/databases
	mkdir $INSTALLDIR/locks

	##
	## Remove the old stuff.
	##
	rm -rf /databases
	rm -rf /locks

	## Link the databases directory.
	echo ""
	$ECHO "Linking /databases...."
	ln -s $INSTALLDIR/databases /databases

	## Link the locks directory.
	$ECHO "Linking /locks...."
	ln -s $INSTALLDIR/locks    /locks

	if [ "$MC" != "SunOS" ]; then
		/bin/cp $STARTDIR/nextoneIserver /etc/rc.d/init.d
		/sbin/chkconfig --add nextoneIserver
	else
		/bin/cp $STARTDIR/nextoneIserver /etc/rc3.d/S99nextoneIserver
	fi

	AreYouSure "Do you want to start iserver on boot" "y"
	if [ $? = 0 ]; then
		rm -f /databases/boot
	else
		touch /databases/boot
	fi
	##############################
	### Copy the executables
	##############################
	echo ""
	echo "Installing in $INSTALLDIR"
	echo ""

	## This is a very dumb install
	for i in `ls *`
	do
		$ECHON "Copying $i....."
		cp -p $i $INSTALLDIR/bin
		$ECHO "..done"
	done

	##
	## Fix the permissions
	##
	chown -R root $INSTALLDIR 
	chgrp -R root $INSTALLDIR

	##
	## Link the executable directory.
	##
	rm -f /usr/local/nextone

	ln -s $INSTALLDIR /usr/local/nextone

	###########################
	## Initialize the databases
	###########################
	$INSTALLDIR/bin/cli db init

	###########################
	## server.cfg file
	###########################
	$INSTALLDIR/bin/sconfig -n -o /usr/local/nextone/bin/server.cfg

        ############################
        ## Copy License file
        ############################
        cd $STARTDIR
        InstallLicFile

	############################
	## Install cron stuff.
	############################
##	cd $STARTDIR
##	./croninst

	#
	# Install 
	while [ 1 ]
	do
	    cd $STARTDIR
	    JreInstallLoop
	    if [ $? -eq 0 ]; then
		break
	    fi
	done

	echo ""
	echo "Installation Complete !!"
	echo ""

	cd $STARTDIR
	rm -rf $INSTALLTMPDIR
	
	Pause
}



MainUninstallLoop ()
{

	###########################
	## Must be root
	###########################
	CheckForSuperuser

	STARTDIR=`pwd`

	## Create tmp directory

	if [ ! -d "$INSTALLTMPDIR" ]; then
		mkdir $INSTALLTMPDIR
	fi

	cd $INSTALLTMPDIR

	ALOID_VERSION=`cat /usr/local/nextone/${INDEXFILE}`
	echo "ISERVER_VERSION is $ALOID_VERSION"

	AreYouSure "Are you sure you are uninstalling ISERVER version $ALOID_VERSION " "y"
	if [ $? = 0 ]; then
		$ECHO "Aborting Uninstall ..."
		cd $STARTDIR
		Pause
		return 0
	fi

	##
	## Must be root to do this
	##

	INSTALLDIR="/usr/local/nextone-${ALOID_VERSION}"
	cd $INSTALLDIR


	#########################
	## Stop the daemons before 
	## removing them
	#########################
	$ECHO "Stopping daemons..."

	/usr/local/nextone/bin/iserver all stop </dev/null > /dev/null

	##
	## Remind user of database backup
	##

	DBBACKUP="/tmp/database-${ALOID_VERSION}"
	AreYouSure "Do you want to backup your database" "y"

	if [ $? = 1 ]; then

		$ECHON "Enter full pathname of backup database : [$DBBACKUP]: "
		read resp

		if [ -z "$resp" ]; then
			resp=$DBBACKUP
		fi

		DBBACKUP=$resp

		$ECHO "Saving old database as $DBBACKUP"

		## Creates an export file in the local dir.
		##
		/usr/local/nextone/bin/cli db export $DBBACKUP
	fi

	##
	## Remind user of server.cfg backup
	##

	SCFGBACKUP="/tmp"
	AreYouSure "Do you want to backup your server configuration files" "y"

	if [ $? = 1 ]; then

		$ECHON "Enter full pathname of the directory to copy the backup files : [$SCFGBACKUP]: "
		read resp

		if [ -z "$resp" ]; then
			resp=$SCFGBACKUP
		fi

		SCFGBACKUP=$resp

		$ECHO "Saving old server configuration files in $SCFGBACKUP"

		## copy config files
		##
		cp -pf /usr/local/nextone/bin/server.cfg $SCFGBACKUP
		cp -pf -r /usr/local/nextone/bin/${DOWNLOADSERVERDIR} $SCFGBACKUP 2>/dev/null
		cp -pf /usr/local/nextone/bin/${ARAVOXFILE} $SCFGBACKUP 2>/dev/null
		cp -pf /usr/local/nextone/bin/${IPFILTERFILE} $SCFGBACKUP 2>/dev/null
		cp -pf /usr/local/nextone/bin/*.val $SCFGBACKUP 2>/dev/null
		cp -pf -r /usr/local/nextone/bin/${BACKUPDBDIR} $SCFGBACKUP 2>/dev/null
	fi

	##
	## Remind user of iserver.lc backup
	##

	LICBACKUP="/tmp/$LICENSEFILE-${ALOID_VERSION}"
	AreYouSure "Do you want to backup your iServer license file" "y"

	if [ $? = 1 ]; then

		$ECHON "Enter full pathname for License file : [$LICBACKUP]: "
		read resp

		if [ -z "$resp" ]; then
			resp=$LICBACKUP
		fi

		LICBACKUP=$resp

		$ECHO "Saving old config file as $LICBACKUP"

		## copy config file
		##
		cp -p /usr/local/nextone/bin/$LICENSEFILE $LICBACKUP
	fi

	##########################
	## Delete the directories
	##########################
	rm -rf $INSTALLDIR/bin

	pkill -TERM ispd

	rm -rf $INSTALLDIR/databases
	rm -rf $INSTALLDIR/locks

	## Remove the main dir also
	cd ..
	rm nextone
	rm -rf $INSTALLDIR

	##
	## Remove the old stuff.
	## This is destructive.
	##
	rm -rf /databases
	rm -rf /locks

	##
	## Remove startup stuff
	##
	if [ "$MC" != "SunOS" ]; then
		/sbin/chkconfig --del nextoneIserver
		rm -f /etc/rc.d/init.d/nextoneIserver
	else
		rm -f /etc/rc3.d/S99nextoneIserver
	fi

	############################
	#### Cleanup 
	#### Remove temporary files etc.
	############################
	cd $INSTALLTMPDIR
	# Remove main iserver directory.
	rm -rf ${PRODUCT}-${ALOID_VERSION}

	# Remove any archive files
	rm -f *.tar
	rm -f $INDEXFILE


	echo ""
	echo "Uninstall successful !!"
	echo ""

	cd $STARTDIR

	## Remove other directories
	rm -rf $INSTALLTMPDIR

	Pause
}



MainUpgradeLoop ()
{
	CheckForSuperuser

	STARTDIR=`pwd`

	$ECHON "Enter media or file [$MEDIAFILE]: "
	read resp

	if [ -z "$resp" ]; then
		resp=$MEDIAFILE
	fi

	MEDIAFILE=$resp

	## Go up to the parent directory
	cd ..

	if [ ! -f "$MEDIAFILE" ]; then
		echo "Cannot find $MEDIAFILE: No such file or directory"
		echo "Exiting..."
		exit 1
	fi

	##
	## Create tmp directory
	## Actually ask for tmp directory.
	##
	$ECHON "Enter temporary directory to use for the install: [$INSTALLTMPDIR]: "
	read resp

	if [ -z "$resp" ]; then
		resp=$INSTALLTMPDIR
	fi

	INSTALLTMPDIR=$resp


	if [ ! -d "$INSTALLTMPDIR" ]; then
		mkdir $INSTALLTMPDIR

		if [ $? != 0 ]; then
			echo "Cannot create directory $INSTALLTMPDIR"
			echo "Exiting.."
			exit 1 
		fi
	fi

	cp $MEDIAFILE $INSTALLTMPDIR

	cd $INSTALLTMPDIR

	##
	## Figure out the older version of software.
	##
	$ECHO "Your existing databases may be incompatible with the "
	$ECHO "upgraded software.  They may need to be converted over"
	$ECHO "to the new format so as to avoid losing any data."

	AreYouSure "Do you want the Installer to upgrade existing databases " "y"

	if [ $? = 1 ]; then

#		ALOID_OLD_VERSION=`ls -l /usr/local/nextone |awk '{print $11}' | cut -c20-`
		ALOID_OLD_VERSION=`cat /usr/local/nextone/.aloidindex`
		$ECHO "Upgrading from version $ALOID_OLD_VERSION"
		OLD_CLI_PATH="/usr/local/nextone-${ALOID_OLD_VERSION}"

		## Perform some validation
		##
		if [ ! -d "$OLD_CLI_PATH" ]; then
			$ECHO "$OLD_CLI_PATH: No such directory"
			$ECHO "Cannot upgrade from non-existent version."
			$ECHO "Perhaps this needs to be a full install..."
			$ECHO "Exiting!!"
			exit 2
		fi


		#########################
		## Stop the daemons before
		## removing them
		#########################
		$ECHO "Stopping daemons..."
		/usr/local/nextone/bin/iserver all stop </dev/null  > /dev/null

		## Do the batch processing
		EXPORT_PREFIX="upg"
		EXPORT_FILE="${EXPORT_PREFIX}.exp"

		$ECHO "Saving old database as $EXPORT_FILE"

		## Creates an export file in the local dir.
		##
		$OLD_CLI_PATH/bin/cli db export $EXPORT_FILE

		## Backup server.cfg
		SCFGBACKUP="server.cfg-${ALOID_OLD_VERSION}"
		cp -p $OLD_CLI_PATH/bin/server.cfg  $INSTALLTMPDIR/${SCFGBACKUP}

		## backup the download server files, if exists
		DSBACKUP="${DOWNLOADSERVERDIR}-${ALOID_OLD_VERSION}"
		if [ -d "$OLD_CLI_PATH/bin/${DOWNLOADSERVERDIR}" ]; then
		    cp -pr $OLD_CLI_PATH/bin/${DOWNLOADSERVERDIR} $INSTALLTMPDIR/${DSBACKUP}
		fi

		## backup the old database files, if exists
		BKDBBACKUP="${BACKUPDBDIR}-${ALOID_OLD_VERSION}"
		if [ -d "$OLD_CLI_PATH/bin/${BACKUPDBDIR}" ]; then
		    cp -pr $OLD_CLI_PATH/bin/${BACKUPDBDIR} $INSTALLTMPDIR/${BKDBBACKUP}
		fi

		## backup the aravox.xml, if exists
		ARAVOXBACKUP="${ARAVOXFILE}-${ALOID_OLD_VERSION}"
		if [ -f "$OLD_CLI_PATH/bin/${ARAVOXFILE}" ]; then
		    cp -p $OLD_CLI_PATH/bin/${ARAVOXFILE} $INSTALLTMPDIR/${ARAVOXBACKUP}
		fi

		## backup the ipfilter.cfg, if exists
		IPFILTERBACKUP="${IPFILTERFILE}-${ALOID_OLD_VERSION}"
		if [ -f "$OLD_CLI_PATH/bin/${IPFILTERFILE}" ]; then
		    cp -p $OLD_CLI_PATH/bin/${IPFILTERFILE} $INSTALLTMPDIR/${IPFILTERBACKUP}
		fi

		##
		## Backup the h323cfg-*.val files -- they better exist!
		##
		# Dont back up any more
		#H323VALFILE="h323-config.val-${ALOID_OLD_VERSION}"
		#cp -p $OLD_CLI_PATH/bin/*.val $INSTALLTMPDIR

	else
		$ECHO " " 
		$ECHO "ABORTING Upgrade " 
		$ECHO "If you do not want to upgrade databases then " 
		$ECHO "try doing Uninstall followed by Install" 
		$ECHO " " 
                cd $STARTDIR
                Pause
                return 0
	fi

	##
	## TAR out the MEDIAFILE
	##
	tar xvf $MEDIAFILE

	ALOID_VERSION=`cat ${INDEXFILE}`
	echo "ISERVER_VERSION is $ALOID_VERSION"

	if [ "$ALOID_VERSION" = "$ALOID_OLD_VERSION" ]; then
		$ECHO "Cannot upgrade to the same version - $ALOID_VERSION"
		$ECHO "Trying to Upgrade from $ALOID_OLD_VERSION $ALOID_VERSION"
		$ECHO "Exiting..."
		exit 1
	fi



	AreYouSure "Are you sure you are upgrading to ISERVER version $ALOID_VERSION " "y"
	if [ $? = 0 ]; then
		echo "Exiting..."
		exit 1
	fi

	##
	## Now copy the files to its respective places.
	##

	TMPDIRNAME="${INSTALLTMPDIR}/${PRODUCT}-${ALOID_VERSION}"
	cd $TMPDIRNAME

	##
	## Must be root to do this
	##

	INSTALLDIR="/usr/local/nextone-${ALOID_VERSION}"
	rm -rf $INSTALLDIR >> /dev/null

	mkdir $INSTALLDIR
	if [ $? != 0 ]; then
		echo "Cannot create directory $INSTALLDIR"
		echo "Aborting upgrade...exiting."
		exit 1
	fi

	## Also remove the old link and create the new link
	rm /usr/local/nextone

	if [ $? != 0 ]; then
		echo "Directory /usr/local/nextone is not empty"
		echo "Aborting upgrade...exiting."
		exit 1
	fi

	ln -s $INSTALLDIR  /usr/local/nextone

	##
	## Copy the index file
	##
	cp -p $INSTALLTMPDIR/${INDEXFILE} $INSTALLDIR


	##########################
	## Create the directories
	##########################
	mkdir  $INSTALLDIR/bin
	mkdir  $INSTALLDIR/databases
	mkdir  $INSTALLDIR/locks

	##
	## Copy the old stuff over.
	## 
	##
	## THIS IS WRONG!! This is not the way to upgrade databases.
## 		cp -p /databases/*.gdbm $INSTALLDIR/databases
##		cp -p /locks/* $INSTALLDIR/locks

	rm -f /databases
	rm -f /locks

	ln -s $INSTALLDIR/databases /databases
	ln -s $INSTALLDIR/locks	/locks


	##############################
	### Copy the executables
	##############################
	echo ""
	echo "Installing in $INSTALLDIR"
	echo ""

	## This is a very dumb install
	for i in `ls *`
	do
		$ECHON "Copying $i....."

		if [ ".$i" = ".ispd" ];	then
			pkill -TERM ispd
		fi

		cp -p $i $INSTALLDIR/bin

		$ECHO "..done"
	done

	##
	## Fix the permissions
	##
	chown -R root $INSTALLDIR 
	chgrp -R root $INSTALLDIR

	#################################
	## Do the DB copy operations..
	#################################
	cd $INSTALLTMPDIR

	$INSTALLDIR/bin/cli db create $EXPORT_FILE

	$INSTALLDIR/bin/cli db copy $EXPORT_FILE

	echo "Upgrading server.cfg "
	$INSTALLDIR/bin/sconfig -d $INSTALLTMPDIR -f $SCFGBACKUP -o $INSTALLDIR/bin/server.cfg 

	## copy the download server data, if exists
	if [ -d "$DSBACKUP" ]; then
	    cp -pr $DSBACKUP $INSTALLDIR/bin/${DOWNLOADSERVERDIR}
	fi

	## copy the database backup files, if exists
	if [ -d "$BKDBBACKUP" ]; then
	    cp -pr $BKDBBACKUP $INSTALLDIR/bin/${BACKUPDBDIR}
	fi

	## copy the aravox.xml, if exists
	if [ -f "$ARAVOXBACKUP" ]; then
	    cp -p $ARAVOXBACKUP $INSTALLDIR/bin/$ARAVOXFILE
	fi

	## copy the ipfilter.cfg, if exists
	if [ -f "$IPFILTERBACKUP" ]; then
	    cp -p $IPFILTERBACKUP $INSTALLDIR/bin/$IPFILTERFILE
	fi

	## Copy the h323cfg*-val files.
	# dont have to do it anymore
	#cp -p $INSTALLTMPDIR/*.val $INSTALLDIR/bin

	$ECHO "Upgrade of database successful..."

        ############################
        ## Copy license file 
        ############################
        $ECHO ""
        $ECHON "Do you want to reuse existing License File ?[${BOLD}y${OFFBOLD}]:"
	read resp
	if [ "$resp" = "n" ]; then
		cd $STARTDIR
		InstallLicFile
	else
		cp $OLD_CLI_PATH/bin/iserver.lc /usr/local/nextone/bin
	fi

	############################
	#### Cleanup 
	#### Remove temporary files etc.
	############################

        cd $INSTALLTMPDIR
        # Remove main iserver directory.
        rm -rf ${PRODUCT}-${ALOID_VERSION}

        # Remove any archive files
        rm -f *.tar
        rm -f $INDEXFILE

	##
	## Ask to remove old install directory
	##
	AreYouSure "Do you want to remove the previous install directory ($OLD_CLI_PATH)" "n"
	if [ $? -eq 1 ]; then
		rm -rf  $OLD_CLI_PATH
	fi

	AreYouSure "Do you want to start iserver on boot" "y"
	if [ $? = 0 ]; then
		rm -f /databases/boot
	else
		touch /databases/boot
	fi


	while [ 1 ]
	do
	    cd $STARTDIR
	    JreInstallLoop
	    if [ $? -eq 0 ]; then
		break
	    fi
	done

        echo ""
        echo "Upgrade Complete!!"

        cd $STARTDIR
	## Remove other directories
	rm -rf $INSTALLTMPDIR
        Pause
        return 0

}

JreInstallLoop ()
{
	CheckForSuperuser

	if [ "$MC" = "SunOS" ]; then
		CheckAndInstallPatches 1.3
		status=$?
		if [ $status -eq 2 ]; then
			$ECHO "One or more of the patches installed require rebooting the machine"
			$ECHO ""
			$ECHO "Installation is not yet complete, please re-run this installation"
			$ECHO "script after the reboot to continue with the installation"
			exit 0
		elif [ $status -ne 0 ]; then
			AreYouSure "Did not complete installing patches, continue?" "n"
			if [ $? -eq 0 ]; then
				return 1
			fi
		fi
	fi

	STARTDIR=`pwd`

	## check if /usr/local/nextone/bin is there
	if [ ! -d "/usr/local/nextone/bin" ]; then
		$ECHO ""
		$ECHO "Cannot find /usr/local/nextone/bin"
		$ECHO "Please install the iServer software before installing JRE"
		Pause
		return 1
	fi

	## ask if JRE already installed
	AreYouSure "Install JRE from scratch" "n"
	if [ $? -eq 0 ]; then
	    AreYouSure "Create softlinks to an existing JRE installation" "y"
	    if [ $? -eq 1 ]; then
		ORIGJREINSTALLDIR=$JREINSTALLDIR
		while [ 1 ]
		do
		    GetJreInstallDir

		    if [ ! -d "$JREINSTALLDIR" ]; then
			$ECHO "Directory \"$JREINSTALLDIR\" does not exist"
		    elif [ ! -x "$JREINSTALLDIR/bin/java" ]; then
			$ECHO "Executable file \"$JREINSTALLDIR/bin/java\" does not exist"
		    else
			break
		    fi
		done

		## set JREINSTALLDIR
		JreInstallFinish
		return 0
	    else
		return 0
	    fi
	fi

	cd ..

	if [ "$JREFILE" = "jre13.sh" -o "$JREFILE" = "jre122.sh" ]; then
	    $ECHON "Enter shell archive file [$JREFILE]: "
	else
	    $ECHON "Enter compressed file [$JREFILE]: "
	fi
	read resp

	if [ -z "$resp" ]; then
		resp=`pwd`/$JREFILE
	fi

	FULLJREFILE=$resp
	if [ ! -f "$FULLJREFILE" ]; then
		echo "Cannot find $FULLJREFILE: No such file or directory"
		Pause
		return 1
	fi

	##
	## Accept install dir
	##
	while [ 1 ]
	do
	    $ECHON "Enter destination directory [$JREINSTALLDIR]: "
	    read resp

	    if [ -z "$resp" ]; then
		    resp=$JREINSTALLDIR
	    fi

	    JREINSTALLDIR=$resp

	    if [ -d "$JREINSTALLDIR" ]; then
		    AreYouSure "Destination directory already exists, overwrite?" "y"
		    if [ $? = 1 ]; then
			    rm -rf $JREINSTALLDIR
			    break
		    fi
	    else
		break
	    fi
	done

	## Create tmp directory
	if [ ! -d "$INSTALLTMPDIR" ]; then
		mkdir $INSTALLTMPDIR
	fi

	##
	## TAR out the JREFILE
	##
	$ECHO ""
	$ECHO "Installing in $JREINSTALLDIR"
	$ECHO ""
	cd $INSTALLTMPDIR
	if [ "$JREFILE" = "jre13.sh" -o "$JREFILE" = "jre122.sh" ]; then
	    rm -rf $JREDEFAULTDIR
	    $FULLJREFILE
	    if [ $? -ne 0 ]; then
		Pause
		return 1
	    fi
	elif [ "$JREFILE" = "jre122.tar.bz2" ]; then
	    rm -rf $JREDEFAULTDIR
	    tar xvfI $FULLJREFILE
	    if [ $? -ne 0 ]; then
		$ECHO "Error untaring file..."
		Pause
		return 1
	    fi
	else
	    rm -rf jre1.2
	    tar xfz $FULLJREFILE
	    if [ $? -ne 0 ]; then
		$ECHO "Error untaring file..."
		Pause
		return 1
	    fi
	fi
	# sometimes cannot move between file systems, so do a copy here
	cp -pR $JREDEFAULTDIR $JREINSTALLDIR

	##
	## Fix the permissions
	##
	chown -R root $JREINSTALLDIR
	chgrp -R root $JREINSTALLDIR

	## finish up installation
	rm -rf $INSTALLTMPDIR/$JREDEFAULTDIR
	JreInstallFinish
	return 0
}

GetJreInstallDir ()
{
	$ECHO ""
	$ECHON "Enter existing JRE directory [$ORIGJREINSTALLDIR]: "
	read resp

	if [ -z "$resp" ]; then
	    resp=$ORIGJREINSTALLDIR
	fi

	JREINSTALLDIR=$resp
}

JreInstallFinish ()
{
	##
	## Link the executable directory.
	##
	rm -f /usr/local/nextone/bin/java
	ln -s $JREINSTALLDIR/bin/java /usr/local/nextone/bin/java

	echo ""
	echo "JRE Installation successful !!"
	echo ""

	cd $STARTDIR

	Pause
}

InstallLicFile()
{
        STARTDIR=`pwd`

        ORIGLICFILE=$INSTALLTMPDIR/iserver.lc

			
		$ECHO ""
		while [ 1 ]
		do
			$ECHON "Enter license file path [$ORIGLICFILE]: "
			read resp
			if [ -z "$resp"  ]; then
				resp=$ORIGLICFILE
				break
			fi
			if [  -f "$resp" ]; then
				break
			fi
			$ECHON "$resp does not exist."
		done

        LICFILE=$resp
        cp -f $LICFILE /usr/local/nextone/bin/iserver.lc

        cd $STARTDIR
}



