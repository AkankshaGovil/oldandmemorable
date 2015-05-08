#!/bin/sh 

##
## Install script for NexTone.
##
##
## Sridhar Ramachandran [SR], 11/08/98, first conception.
##


# Include other files..

chmod +x *.sh
chmod +x *.pl
. ./globals.sh
. ./utils.sh
#. ./checkpatch.sh
#. ./alinstall.sh
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/libc
export LD_LIBRARY_PATH
PERL5LIB=/usr/lib/perl5/5.10.0:/usr/lib/perl5/vendor_perl/5.10.0:$PERL5LIB
export PERL5LIB
FILELIST="./filelist"

if [ "$MC" = "SunOS" ]; then
LOGNAME=`/usr/xpg4/bin/id -u -n`
else
LOGNAME=`id -u -n`
fi

MSWUser="ivmsclient"
MSWHostName="127.0.0.1"
MSWPort="5432"
MSWPwd="ivmsclient"
rval=""

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


##
## Set the Parameters for the ivmsLite
##
ivmsLiteInstallSetUp ()
{
  echo "Enter password for RSM to connect to MSx Database:"
  stty -echo
  read resp
  if [ ! -z $resp ];
  then
     MSWPwd=$resp
  fi
  stty echo
  export MSWUSER=$MSWUser
  export PGPASSWORD=$MSWPwd
  psql -U$MSWUSER -dmsw -h$MSWHostName -c "select count(*) from servercfg " -o tmp.txt >test.txt 2>test2.txt
  SEARCH_RESPONSE=`grep -c 'FATAL' test2.txt`
  rm tmp.txt >/dev/null 2>&1
  rm test.txt >/dev/null 2>&1
  rm test2.txt >/dev/null 2>&1

  if [ $SEARCH_RESPONSE != 0 ];
  then
     echo "Please enter the correct username and password for ivmsLite"
     ivmsLiteInstallSetUp
  fi
  rm tmp.txt >/dev/null 2>&1
  rm test.txt >/dev/null 2>&1
  rm test2.txt >/dev/null 2>&1
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
	-i)
		ivms=1
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


		1.	NARS Server Package

		q.   Back to Main Menu

EOF_MENU

	SelectChoice

	read ans

	case $ans in
	1)
		SOFTWARE="NARSServer"
		return
		;;
	q|Q)
		SOFTWARE=""
		return
		;;

	esac
done

}




PickivmsPackage ()
{

while [ 1 ]
do
	ClearScreen
	cat << EOF_MENU


		${BOLD}GENBAND Setup Utility. v$Version${OFFBOLD}


		Choose software package:


		1.	RSM Server Package
		
		2.	RSMLite Package

		q.   Back to Main Menu

EOF_MENU

	SelectChoice

	read ans

	case $ans in
	1)
		SOFTWARE="ivmsServer"
		return
		;;
	2)
		SOFTWARE="iView"
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
ivms=1
if [ $NARS -eq 1 ]
then
	while [ 1 ]
	do
		PrelimMenu
	
		SelectChoice
	
		read ans
	
		case $ans in
		1)	
			License
			PickNARSPackage
			if [ "$SOFTWARE" = "NARSServer" ]; then
				chmod +x NarsServerInst.pl
				ClearScreen
				./NarsServerInst.pl -i	
			elif ["$SOFTWARE" = "NARSAgent" ]; then
				chmod +x NarsAgentInst.pl
				./NarsAgentInst.pl -i
				Pause
			fi
			;;
		2)
			PickNARSPackage
			if [ "$SOFTWARE" = "NARSServer" ]; then
				ClearScreen
#./NarsServerInst.pl -d
				echo " Uninstall not supported yet..."
				Pause
			elif [ "$SOFTWARE" = "NARSAgent" ]; then
				chmod +x NarsAgentInst.pl
				./NarsAgentInst.pl -d
				Pause
			fi
			;;
		3)
			License
			PickNARSPackage
			if [ "$SOFTWARE" = "NARSServer" ]; then
				chmod +x NarsServerInst.pl
				ClearScreen
				./NarsServerInst.pl -u
			elif [ "$SOFTWARE" = "NARSAgent" ]; then
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

elif [ $ivms -eq 1 ]
then

	while [ 1 ]
	do
		PrelimMenu
	
		SelectChoice
	
		read ans
	
		case $ans in
		1)	
			License
			PickivmsPackage
	
			if [ "$SOFTWARE" = "ivmsServer" ]; then
				chmod +x ivmsServerInst.pl
				ClearScreen
				./ivmsServerInst.pl -m
			elif [ "$SOFTWARE" = "iView" ]; then
				chmod +x ivmsServerInst.pl
                                ivmsLiteInstallSetUp
				ClearScreen
				./ivmsServerInst.pl -w
			elif ["$SOFTWARE" = "NARSAgent" ]; then
				chmod +x NarsAgentInst.pl 
				./NarsAgentInst.pl -i
				Pause
			fi
			;;
		2)
			PickivmsPackage
			if [ "$SOFTWARE" = "ivmsServer" ]; then
				ClearScreen
				./ivmsServerInst.pl -d iVMS
			elif [ "$SOFTWARE" = "iView" ]; then
				ClearScreen
                                ivmsLiteInstallSetUp
				./ivmsServerInst.pl -d iVMSLite
			elif [ "$SOFTWARE" = "NARSAgent" ]; then
				chmod +x NarsAgentInst.pl 
				./NarsAgentInst.pl -d
				Pause
			fi
			;;
		3)
			License
			PickivmsPackage

			if [ "$SOFTWARE" = "iView" ]; then
                                echo "Upgrade is not supported for RSM Lite package.";
                                Pause
                                exit 0

                        fi

			if [ "$SOFTWARE" = "ivmsServer" ]; then
				ClearScreen
				chmod +x ivmsServerInst.pl 
				./ivmsServerInst.pl -u iVMS
				Pause
			elif [ "$SOFTWARE" = "iView" ]; then
                                ClearScreen
				chmod +x ivmsServerInst.pl 
                                ivmsLiteInstallSetUp
                                ClearScreen
                                ./ivmsServerInst.pl -u iVMSLite 
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
			PickPackage
	
			if [ "$SOFTWARE" = "iServerCore" ]; then
				MainInstallLoop
			elif [ "$SOFTWARE" = "iServerMain" ]; then
				chmod +x adminstall.pl 
				./adminstall.pl -i
	
				Pause
			fi
			;;
		2)
			PickPackage
			if [ "$SOFTWARE" = "iServerCore" ]; then
				MainUninstallLoop
			elif [ "$SOFTWARE" = "iServerMain" ]; then
				chmod +x adminstall.pl 
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
				chmod +x adminstall.pl 
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

fi


## Successful exit
exit 0

