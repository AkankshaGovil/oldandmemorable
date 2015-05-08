#!/bin/sh

##
## Package script for packing and shipping GENBAND executable.
##
##
## Sridhar Ramachandran, 11/08/98.
##

## Include help file
##. ./help.sh

## Globals
. ./globals.sh

## Utilities
. ./utils.sh

## Include aloid file
. ./aloid.sh

## Options processing
USAGE="$0 [-n]";
NARS=0;
PAR=0;

while getopts np c
do
	case $c in
		n) NARS=1;;
		p) NARS=1; PAR=1;;
		\?)  echo $USAGE; exit 0;
	esac
done
shift `expr $OPTIND - 1`

##
## Self identification.
MY_VERSION_NAME="GENBAND Packing Program, "
MY_VERSION_ID="v0.1"
MY_COPYRIGHT="Copyright 2012 GENBAND."

NETOID_FILELIST="./netoid_filelist"
ALOID_FILELIST="./aloid_filelist"
NARS_FILELIST="nars-agent-files"
NARS_PAR_FILELIST="nars-agent-files.par"

PROG_VERSION_NAME=
PROG_VERSION_ID=

GENERIC_PACK_HELP="See the file help.sh for packaging help."

## Clear the screen.
#ClearScreen

##
## Provide self identification
##
echo ""
echo "$MY_VERSION_NAME $MY_VERSION_ID"
echo "$MY_COPYRIGHT"
echo ""

##
## Offer generic help and instructions.
##
echo "$GENERIC_PACK_HELP"
echo ""

##
## Before entering mainloop, check for user input.
##
echo "Hit <CR> to continue"
read resp
echo " "


##
## Main loop
##
if [ $NARS -eq 1 ]
then
	while [ 1 ]
	do
	$ECHON "Are you packing NARS Agent? [y/n] "
	read resp

		case "$resp" in
		[yY]*)
			echo "You have picked Nars Agent Package. "
			echo ""
			if [ $PAR -eq 1 ]
			then
				PackageNARSAgent $NARS_PAR_FILELIST
			else
				PackageNARSAgent $NARS_FILELIST
			fi
			break
		;;
		[nN]*)
			echo "Ciao "
			echo ""
			exit;
		;;
		*)
			echo "Answer [y/n] !!"
		;;
		esac
	
	done
else
	while [ 1 ]
	do
	$ECHON "What are you packing? [A]loid-iServer-Core/[N]-iServer-Admin "
	read resp
	
		case "$resp" in
		[aA]*)
			echo "You have picked iServer Core Package. "
			echo ""
			PackageAloid
			break
		;;
		[nN]*)
			echo "You have picked iServer Administration Package. "
			echo ""
			PackageAdmin
			break
		;;
		*)
			echo "Answer correctly !!"
		;;
		esac
	
	done
fi

echo "Exiting... " 
exit 0
