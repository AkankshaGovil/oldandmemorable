#!/bin/sh 

##
## Install script for NexTone.
##
##
## Sridhar Ramachandran [SR], 11/08/98, first conception.
##

NARS=0;

# Include other files..

. ./globals.sh
. ./utils.sh
#. ./checkpatch.sh
#. ./alinstall.sh


FILELIST="./filelist"

if [ "$MC" = "SunOS" ]; then
LOGNAME=`/usr/xpg4/bin/id -u -n`
else
LOGNAME=`id -u -n`
fi

## 
## Prelim. to main menu
##
PrelimMenu ()
{
	ClearScreen
	ScreenNum=0.0
	cat << EOF_MENU
							$ScreenNum



		${BOLD}GENBAND Setup Utility. v$Version${OFFBOLD}



		1.	Install a version of software.

		2.	Uninstall a version of software.

		3.	Upgrade a version of software.


		q.   Exit this utility.

EOF_MENU
}


##########################
##########################
## main (argc, argv)
##########################
##########################

##
## Parse command line options
##

set -- `getopt "FVvhnme:r:o:" $*`
if [ $? != 0 ]; then
	echo $Usage
	exit 2
fi

for i in $*
do
	case $i in
	-h)
		$ECHO $HELP
		exit 0
		;;
	-V)
		VERBOSE=ON
		shift
		;;
	-v)
		echo "$0: ${BOLD}$ProgDescription -- version $Version of $ProgDate${OFFBOLD}"
		exit 0
		;;
	-m)
		MENU=0
		shift
		;;
	-n)
		NARS=1
		;;
	-F)
		FORCE=ON
		shift
		;;
	-e)
		LOGNAME=$2
		shift 2
		;;
	-r)
		ROOT=$2
		shift 2
		;;
	-o)
		OPTIONS_FILE=$2

		## Source the options in.
		. $OPTIONS_FILE

		shift 2
	esac
done

shift


## Identify target and image

if [ ! -z "$1" ]; then
	CURR_TARGET=$1
	shift
	if [ ! -z "$1" ]; then
		CURR_IMAGE=$1
		shift
	fi
fi


##
## Display license
##

License()
{
    ClearScreen
        more ./LICENSE
        accept=0
        while [ $accept != 1 ];
        do
        $ECHO  " "
        $ECHON "Do you agree to the above license terms? [y/n]: "
        read resp rest
        case $resp in
                y* |Y*)
                        accept=1;;
                n* | N*)
                        $ECHO "You cannot install this software unless you agree
 to the licensing terms."
                        $ECHO  "Exiting..."
                        exit 1;;
        esac
done
}


PickPackage ()
{

while [ 1 ]
do
	ClearScreen
	cat << EOF_MENU


		${BOLD}GENBAND Setup Utility. v$Version${OFFBOLD}


		Choose software package:


		1.	iServer Core Package

		2.	iServer Administration Package

		q.   Back to Main Menu

EOF_MENU

	SelectChoice

	read ans

	case $ans in
	1)
		SOFTWARE="iServerCore"
		return
		;;
	2)
		SOFTWARE="iServerAdmin"
		return
		;;
	q|Q)
		SOFTWARE=""
		return
		;;

	esac
done

}


PickNARSPackage ()
{

while [ 1 ]
do
	ClearScreen
	cat << EOF_MENU


		${BOLD}GENBAND Setup Utility. v$Version${OFFBOLD}


		Choose software package:


		1.	NARS Agent Package

		q.   Back to Main Menu

EOF_MENU

	SelectChoice

	read ans

	case $ans in
	1)
		SOFTWARE="NARSAgent"
		return
		;;
	q|Q)
		SOFTWARE=""
		return
		;;

	esac
done

}

##
## Are we menu-ed or not?
##



##
## Main Loop
##
if [ $NARS -eq 0 ]
then
	while [ 1 ]
	do
		PrelimMenu
	
		SelectChoice
	
		read ans
	
		case $ans in
		1)	
			License
			PickPackage
	
			if [ "$SOFTWARE" = "iServerCore" ]; then
				MainInstallLoop
			elif [ "$SOFTWARE" = "iServerMain" ]; then
				./adminstall.pl -i
	
				Pause
			fi
			;;
		2)
			PickPackage
			if [ "$SOFTWARE" = "iServerCore" ]; then
				MainUninstallLoop
			elif [ "$SOFTWARE" = "iServerMain" ]; then
				./adminstall.pl -d
	
				Pause
			fi
			;;
		3)
			License
			PickPackage
			if [ "$SOFTWARE" = "iServerCore" ]; then
				MainUpgradeLoop
			elif [ "$SOFTWARE" = "iServerMain" ]; then
				./adminstall.pl -u
	
				Pause
			fi
			;;
		q|Q)
			ClearScreen
			exit 0
			;;
		esac
	
	done
else
	while [ 1 ]
	do
		PrelimMenu
	
		SelectChoice
	
		read ans
	
		case $ans in
		1)	
			License
			PickNARSPackage
	
			if [ "$SOFTWARE" = "NARSAgent" ]; then
				./NarsAgentInst.pl -i
	
				Pause
			fi
			;;
		2)
			PickNARSPackage
			if [ "$SOFTWARE" = "NARSAgent" ]; then
				./NarsAgentInst.pl -d
	
				Pause
			fi
			;;
		3)
			License
			PickNARSPackage
			if [ "$SOFTWARE" = "NARSAgent" ]; then
#				./NarsAgentInst.pl -u
				echo "Update Not supported yet..."
	
				Pause
			fi
			;;
		q|Q)
			ClearScreen
			exit 0
			;;
		esac
	
	done
fi


## Successful exit
exit 0

