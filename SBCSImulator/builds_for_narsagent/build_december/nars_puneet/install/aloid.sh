#!/bin/sh

#####################################################
#####################################################
#######  The aloid shell script.
#######
#####################################################
#####################################################

## default
PRODUCT="iserver"
ALOID_VERSION=2.0
ALOID_FILEDIR="$BASE/bin/$TARGET"
ALOID_README="$BASE/bin/README-${ALOID_VERSION}"
#ALOID_FILEDIR="/export/home/`whoami`/netoids/src/bin"
#ALOID_README="/export/home/`whoami`/netoids/src/bin/README-${ALOID_VERSION}"
CP=/bin/cp
SED='/usr/bin/sed';
ALOID_INDEX=".aloidindex"
MEDIAFILE="${PRODUCT}install.tar"
SYSVINITFILE="/etc/rc.d/init.d/nextoneIserver"
LICENSE_FILE="iserver.lc"
STARTDIR=`pwd`

## Admin stuff
ALOID_ADMINDEX=".admindex"
ADMMEDIAFILE="${PRODUCT}adm-install.tar"
ALOID_ADMFILEDIR="$BASE/utils"
TMPBASEDIR="/tmp"

## NARS Stuff
NARS_AGENTVERSION=`cat ./narsVersion`
NARS_AGENTINDEX=".naindex"
NARS_AGENTMEDIAFILE="rsmagent-install.tar"
NARS_AGENTFILEDIR="$BASE/nars-agent"
NARS_AGENTPKGFILE="nars-agent-files"

. ./changePath.sh 

PackAloidFiles ()
{
	$ECHON "Enter directory where files are present [$ALOID_FILEDIR]: "
	read resp

	ALOID_FILEDIR=${resp:=$ALOID_FILEDIR}

## Reset default again.
ALOID_README="/export/home/`whoami`/netoids/src/bin/README-${ALOID_VERSION}"

	$ECHON "Enter location of README file [$ALOID_README]: "
	read resp

	ALOID_README=${resp:=$ALOID_README}


	## Ask for temporary directory
	$ECHON "Enter temporary directory to use [$TMPBASEDIR]: "
	read resp

	TMPBASEDIR=${resp:=$TMPBASEDIR}

	## If not present, then make it...
	if [ ! -d "$TMPBASEDIR" ]; then
		$ECHO "$TMPBASEDIR not present. Creating $TMPBASEDIR."
		mkdir $TMPBASEDIR
	fi

	## Create temporary directory
	TMPDIRNAME="$TMPBASEDIR/${PRODUCT}-${ALOID_VERSION}"

	mkdir $TMPDIRNAME

	
	## Copy the file(s)

	for i in `cat aloid_filelist`
	do
		$CP -p $ALOID_FILEDIR/$i $TMPDIRNAME
	done

	
	## Copy the README file also

	## Create the index file
	echo "Generating index file"
	## Save off current directory
	CURRENT_DIR=`pwd`
	## Move to the tmp directory
	cd $TMPBASEDIR
	cat > $ALOID_INDEX << E_EOF
$ALOID_VERSION
E_EOF
	cat > $LICENSE_FILE << E_EOF
iServer 2.0 `date +%m-%d-%Y` 100   100 unbound
Features H323 SIP FCE 
E_EOF
	$ALOID_FILEDIR/lgen $LICENSE_FILE 
	
	## Verify
	echo "Contents of $TMPDIRNAME"
	/bin/ls -a $TMPDIRNAME


	## Go one level up
	cd $TMPBASEDIR

	## Enter media file
	$ECHON "Enter media or filename [$MEDIAFILE]: "

	##
	$ECHON "Making $MEDIAFILE..."
	tar cvf $MEDIAFILE ${PRODUCT}-${ALOID_VERSION} $ALOID_INDEX $LICENSE_FILE
	
	##
	## Cleanup
	/bin/rm -rf $TMPDIRNAME $ALOID_INDEX
	mv $TMPBASEDIR/$MEDIAFILE $BASE/$TARGET.$MEDIAFILE

	$ECHO "..done"

	echo ""
	echo "The packed file is ${BOLD}$MEDIAFILE${OFFBOLD}"
	echo ""
	##
	##
	echo ""
	echo "Packaging successful !!"
	echo ""
}


##
## 
##
PackAdminFiles ()
{
	$ECHON "Enter directory where files are present [$ALOID_ADMFILEDIR]: "
	read resp

	ALOID_ADMFILEDIR=${resp:=$ALOID_ADMFILEDIR}

	## Create temporary directory
	TMPADMDIRNAME="/tmp/${PRODUCT}-${ALOID_ADMVERSION}"

	mkdir $TMPADMDIRNAME

	
	## Copy the file(s)

	CURDIR=`pwd`

	cd $ALOID_ADMFILEDIR

	## Doing this so we can copy absolute filenames..
	##
	for i in `cat $CURDIR/admfiles`
	do
		$CP -p $i $TMPADMDIRNAME
	done

	## back to where we were.
	cd $CURDIR

	## Create the index file
	echo "Generating index file"
	## Save off current directory
	CURRENT_DIR=`pwd`
	## Move to the tmp directory
	cd /tmp
	cat > $ALOID_ADMINDEX << E_EOF
$ALOID_ADMVERSION
E_EOF
	
	## Verify
	echo "Contents of $TMPADMDIRNAME"
	/bin/ls -a $TMPADMDIRNAME


	## Go one level up
	cd /tmp

	## Enter media file
	$ECHON "Enter media or filename [$ADMMEDIAFILE]: "

	##
	$ECHON "Making $ADMMEDIAFILE..."
	tar cvf $ADMMEDIAFILE ${PRODUCT}-${ALOID_ADMVERSION} $ALOID_ADMINDEX 
	
	##
	## Cleanup
	/bin/rm -rf $TMPADMDIRNAME $ALOID_ADMINDEX
	mv /tmp/$ADMMEDIAFILE $BASE/$TARGET.$ADMMEDIAFILE

	$ECHO "..done"

	echo ""
	echo "The packed file is ${BOLD}$ADMMEDIAFILE${OFFBOLD}"
	echo ""
	##
	##
	echo ""
	echo "Admin Packaging successful !!"
	echo ""
}


##
##
##
GatherNARSReleasorInfo ()
{

	$ECHON "Enter ${BOLD}NARS Version Number${OFFBOLD} [$NARS_AGENTVERSION] "
	read resp

	NARS_AGENTVERSION=${resp:=$NARS_AGENTVERSION}

}

##
##
##
GatherAdminReleasorInfo ()
{

	$ECHON "Enter ${BOLD}Admin Version Number${OFFBOLD} [$ALOID_ADMVERSION] "
	read resp

	ALOID_ADMVERSION=${resp:=$ALOID_ADMVERSION};
}


##
##
##
GatherReleasorInfo ()
{

	$ECHON "Enter ${BOLD}Version Number${OFFBOLD} [$ALOID_VERSION] "
	read resp

	ALOID_VERSION=${resp:=$ALOID_VERSION};
}

##
##
PackageAloid ()
{
	echo "Packaging Aloid-iServer-Main..."

	GatherReleasorInfo

	PackAloidFiles
}

##
## Package iServer Administration Package
##
PackageAdmin ()
{
	echo "Packaging iServer Admin..."

	GatherAdminReleasorInfo

	PackAdminFiles
	PackageRsync
}

##
## Package NARS Agent
##
PackageNARSAgent ()
{
	echo "Packaging NARS Agent..."
	
	NARS_AGENTPKGFILE=${1:-$NARS_AGENTPKGFILE}

	GatherNARSReleasorInfo

	PackNARSAgent
}

#
#  Package rsync
#
PackageRsync ()
{
	echo "Packaging Rsync Package..."

	RSYNCPKGDIR=rsyncpkg;
	RSYNCTMPF=/tmp/rsync$$.tar;

	CURRDIR=pwd;
	cd $ALOID_ADMFILEDIR;

	RSYNCFILES=`tar -cf $RSYNCTMPF rsyncpkg; tar -tf $RSYNCTMPF | grep -v 'CVS' `
	tar -uvf $BASE/$TARGET.$ADMMEDIAFILE $RSYNCFILES 2>/dev/null;

	/bin/rm -f $RSYNCTMPF
	echo "..done"
}

##
## 
##
PackNARSAgent ()
{
	$ECHON "Enter directory where files are present [$NARS_AGENTFILEDIR]: "
	read resp

	NARS_AGENTFILEDIR=${resp:=$NARS_AGENTFILEDIR}

	## Create temporary directory
	TMPNARSDIRNAME="/tmp/NARS-${NARS_AGENTVERSION}"

	mkdir -p $TMPNARSDIRNAME

	
	## Copy the file(s)

	CURDIR=`pwd`

	cd $NARS_AGENTFILEDIR

	## Doing this so we can copy absolute filenames..
	##
	for i in `cat $CURDIR/$NARS_AGENTPKGFILE | grep -v '\^'`
	do
		# edit all script files to change perl path to /usr/bin/perl if applicable
		case $i in
			*.tar)
				;;
			*)	ChangePath /usr/local/bin/perl /usr/bin/perl $i
				;;
		esac
		#ChangePath /usr/local/bin/perl /usr/bin/perl $i
		$CP -p $i $TMPNARSDIRNAME
	done

	## Files whose absolute path names we want to copy
	## But which are not in current directory
	for i in `cat $CURDIR/$NARS_AGENTPKGFILE | grep '\^'| cut -d'^' -f2`
	do
		basename=`echo $i | $SED -e 's,^.*/,,'`;
		dirname=`echo $i | $SED -e 's,[^/]*$,,'`;
		dirname=${dirname:='./'};

		mkdir -p "$TMPNARSDIRNAME/NexTone";
		$CP -p "$dirname$basename" "$TMPNARSDIRNAME/NexTone";
	done

	## back to where we were.
	cd $CURDIR

	## Create the index file
	echo "Generating index file"
	## Save off current directory
	CURRENT_DIR=`pwd`
	## Move to the tmp directory
	cd /tmp
	cat > $NARS_AGENTINDEX << E_EOF
$NARS_AGENTVERSION
E_EOF
	
	## Verify
	echo "Contents of $TMPNARSDIRNAME"
	/bin/ls -a $TMPNARSDIRNAME


	## Go one level up
	cd /tmp

	## Enter media file
	$ECHON "Enter media or filename [$NARS_AGENTMEDIAFILE]: "
	read resp;

	NARS_AGENTMEDIAFILE=${resp:=$NARS_AGENTMEDIAFILE}

	##
	$ECHON "Making $NARS_AGENTMEDIAFILE..."
	tar cvf $NARS_AGENTMEDIAFILE "NARS-${NARS_AGENTVERSION}" $NARS_AGENTINDEX 
	
	##
	## Cleanup
	/bin/rm -rf $TMPNARSDIRNAME $NARS_AGENTINDEX
	mv /tmp/$NARS_AGENTMEDIAFILE $BASE/$TARGET.$NARS_AGENTMEDIAFILE

	$ECHO "..done"

	echo ""
	echo "The packed file is ${BOLD}$NARS_AGENTMEDIAFILE${OFFBOLD}"
	echo ""
	##
	##
	echo ""
	echo "NARS Agent Packaging successful !!"
	echo ""
}

