#!/bin/bash

##############################
## postUpgradeRSMLite.sh     #	
## Author : Sangeeta Sharma #
##############################

#uncomment for debugging
#set -x

DEFAULT_BACKUPPATH="/opt/nxtn/"
DEFAULT_RESTOREPATH="/opt/nxtn/"
OPT_RESTORE="/opt"
ENVLOCATION="/sbc60upgrade/script/env.cfg"
ISAUTO="n"
OLDIVMS="/opt"


##########################
##########################

##
## Parse command line options
##

set -- `getopt "a:" $*`

for i in $*
do
        case $i in

        -a)
                shift
                ;;
        esac

done


if [ $1 == "SWM_UPG" ]; then
 ISAUTO="y"
else
 ISAUTO="n"
fi


	echo "Restoring RSM Lite..."
	if [ "$ISAUTO" == "n" ]; then
		echo "Please enter backup location for RSM Lite [$DEFAULT_BACKUPPATH]:"
		read BACKUPLINK
	fi
	
	if [ "$BACKUPLINK" == "" ]; then
	   BACKUPLINK="$DEFAULT_BACKUPPATH"
	fi

	CHECKVAR="$(echo `expr substr "$BACKUPLINK" 1 5`)"

	if [ "$CHECKVAR" == "/var/" ]; then

	   OLDLOCATION="$(sed '/^\#/d' "$ENVLOCATION" | grep 'VAR_BACKUP_DIR'  | tail -n 1 | sed 's/^.*=//')"
	   NEWBACKUPLINK=$OLDLOCATION"/old-var"$BACKUPLINK
	   OLDIVMS=$OLDLOCATION"/old-var/opt"

	else

	   OLDLOCATION="$(sed '/^\#/d' "$ENVLOCATION" | grep 'ROOT_BACKUP_DIR'  | tail -n 1 | sed 's/^.*=//')"
	   NEWBACKUPLINK=$OLDLOCATION"/old-root"$BACKUPLINK
	   OLDIVMS=$OLDLOCATION"/old-root/opt"

	fi

	if [ ! -d $NEWBACKUPLINK"rsm" ]; then
		echo "RSM Lite installation doesnot exist."
                exit 2
        fi


	if [ "$ISAUTO" == "n" ]; then
	   echo "Please enter restore location for RSM Lite [$DEFAULT_RESTOREPATH]:"
	   read RESTOREPATH
	fi

	if [ "$RESTOREPATH" == "" ]; then
	   RESTOREPATH="$DEFAULT_RESTOREPATH"
	fi

	cp -r $OLDIVMS"/ivms" $OPT_RESTORE
	
	cp -r $NEWBACKUPLINK"rsm" $RESTOREPATH
	
	if [ $? != 0 ]; then
		echo "Error! while restoring RSM Lite."
                exit 1
        fi

	cp -r $NEWBACKUPLINK"jboss"* $RESTOREPATH >/dev/null 2>&1 

	if [ $? != 0 ]; then
                echo "Error! while restoring RSM Lite."
                exit 1
        fi

	cp -r $NEWBACKUPLINK"jre"* $RESTOREPATH >/dev/null 2>&1
	cp -r $NEWBACKUPLINK"jdk"* $RESTOREPATH >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "Error! while restoring RSM Lite."
		exit 1
	fi 
	echo "RSM Lite restored successfully..."

	exit 0


