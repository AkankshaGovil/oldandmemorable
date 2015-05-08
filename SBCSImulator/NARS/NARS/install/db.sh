#!/bin/sh

##
## script to handle the database creation/migration during nars install/upgrade
##

MYSQLOPTIONS="--user=root"
MYSQLUSER=root
MYSQLPASS=""

INSTALLFILEPREFIX=nars-tables
UPGRADEFILEPREFIX=nars-tables-upgrade

ARCH=`uname -s`
if [ "$ARCH" = "Linux" ]
then
  MYSQL="/usr/bin/mysql"
else
  MYSQL="/usr/local/mysql/bin/mysql"
fi

PECHO ()
{
  if [ "$ARCH" = "Linux" ]
  then
    echo -n "$1"
  else
    echo "$1\c"
  fi
}

TECHO ()
{
  if [ "$ARCH" = "Linux" ]
  then
    echo -e "$1"
  else
    echo "$1"
  fi
}

handleInstall ()
{
  ans=$1; 

  INSTALLFILE="$CURDIR/$INSTALLFILEPREFIX-$ans.sql"

  if [ ! -r "$INSTALLFILE" ]
  then
    echo "Unable to find $INSTALLFILE"
    exit 1
  fi

  user=$2;
  pass=$3;

  sed "s/%DBNAME%/nars/g; s/%COMMENT%//g; s/USERNAME/$user/g; s/USERPASSWORD/$pass/g" $INSTALLFILE > install-tables.sql

  $MYSQL $MYSQLOPTIONS < $CURDIR/install-tables.sql
}


handleUpgrade ()
{
  FSLIST=`df -k | grep "^\/" | grep -v "\/proc" | tr -s ' ' ' ' | cut -d" " -f6`
  index=1
  maxindex=1
  for FS in $FSLIST
  do
    TECHO "\t$index. $FS"
    maxindex=$index
    index=`expr $index + 1`
  done

  ans=""
  while [ 1 ]
  do
    PECHO "Please choose the filesystem where the mysql data resides: "
    read ans
    if [ ! -z "$ans" ]
    then
      if [ $ans -ge 1 -a $ans -le $maxindex ]
      then
        break
      else
        echo "Please enter a valid selection"
      fi
    fi
  done

  FSUSAGELIST=`df -k | grep "^\/" | grep -v "\/proc" | tr -s ' ' ' ' | cut -d" " -f5`
  index=1
  for FSUSAGE in $FSUSAGELIST
  do
    if [ $ans -eq $index ]
    then
      USAGE=`echo $FSUSAGE | cut -d% -f1`
    fi
    index=`expr $index + 1`
  done

  if [ $USAGE -ge 50 ]
  then
    echo "The filesystem usage ($USAGE%) seems too high"
    echo "Since a data copy will be made when upgrading the database,"
    echo "we recommend twice as much space available as the current db size"
    PECHO "Go ahead with the upgrade anyway? [n]/y "
    read ans
    if [ -z "$ans" -o "$ans" = "n" -o "$ans" = "N" ]
    then
      exit 0
    fi
  else
    echo "The filesystem usage ($USAGE%) is adequate, proceeding with upgrade"
  fi
  oldver=$1;
  newver=$2;

  UPGRADEFILE="$CURDIR/$UPGRADEFILEPREFIX-$oldver-$newver.sql"
  INSTALLFILE="$CURDIR/$INSTALLFILEPREFIX-$newver.sql"

  if [ ! -r "$UPGRADEFILE" ]
  then
    echo "Upgrading from $oldver to $newver is not supported yet"
    echo "Unable to find $UPGRADEFILE"
    exit 1
  fi
  if [ ! -r "$INSTALLFILE" ]
  then
    echo "Upgrading from $oldver to $newver is not supported yet"
    echo "Unable to find $INSTALLFILE"
    exit 1
  fi

  sed "s/%DBNAME%/narsbak/g; s/%COMMENT%/\#/g" $INSTALLFILE > install-tables.sql
  sed "s/%DBBAKNAME%/narsbak/g; s/%COMMENT%//g" $UPGRADEFILE > upgrade-tables.sql

  PECHO "This may take a long time...";
  PECHO "Please do not abort ..... ";
  $MYSQL $MYSQLOPTIONS < install-tables.sql
  $MYSQL $MYSQLOPTIONS < upgrade-tables.sql
}

# main program

CURDIR=`dirname $0`


op=$1

MYSQL=$2

MYSQLUSER=$3

MYSQLPASS=$4

NARSVERSION=$5

NARSUSER=$6

NARSPASS=$7

if [ ! -z "$MYSQLUSER" ]
then
  MYSQLOPTIONS="--user=$MYSQLUSER"
fi
if [ ! -z "$MYSQLPASS" ]
then
  MYSQLOPTIONS="$MYSQLOPTIONS --password=$MYSQLPASS"
fi

if [ $op = "i" ]
then
  if [ $# -ge 7 ]
  then
  	handleInstall $NARSVERSION $NARSUSER $NARSPASS
  else
	PECHO "usage: db.sh i /usr/bin/mysql root root_password self_version db_username db_password"; 
	exit 0;
   fi;	
        
else
  if [ $# -ge 8 ]
  then
  	curNarsVer=$8
  	handleUpgrade $curNarsVer $NARSVERSION
   else
	PECHO "usage: db.sh u /usr/bin/mysql root root_password self_version db_username db_password cur_nars_version"
	exit 0;
   fi
fi

exit 0
