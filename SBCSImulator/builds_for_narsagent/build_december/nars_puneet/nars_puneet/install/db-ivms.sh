#!/bin/sh

##
## script to handle the database creation/migration during ivms install/upgrade
##

MYSQLOPTIONS="--user=root"
MYSQLUSER=root
MYSQLPASS=""

INSTALLFILEPREFIX=ivms-tables
UPGRADEFILEPREFIX=ivms-tables-upgrade

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

  #INSTALLFILE="$CURDIR/$INSTALLFILEPREFIX-$ans.sql"
  INSTALLFILE="$CURDIR/bn.sql"
  PERMISSIONSFILE="$CURDIR/ivms.sql"
  if [ ! -r "$INSTALLFILE" ]
  then
    echo "Unable to find $INSTALLFILE"
    exit 1
  fi

  user=$2;
  pass=$3;

  sed "s/%DBNAME%/bn/g; s/%COMMENT%//g; s/USERNAME/$user/g; s/USERPASSWORD/$pass/g" $INSTALLFILE > install-tables.sql
  sed "s/%DBNAME%/bn/g; s/%COMMENT%//g; s/USERNAME/$user/g; s/USERPASSWORD/$pass/g" $PERMISSIONSFILE >> install-tables.sql

  $MYSQL $MYSQLOPTIONS < $CURDIR/install-tables.sql
  #add exit
  VAR_INSTALL=$?
  if [ $VAR_INSTALL -ne 0 ]
  then
        exit $VAR_INSTALL
  fi

  # add bnsp.sql
  BNSPFILE="$CURDIR/bnsp.sql"
  if [ -r "$BNSPFILE" ]
  then
    sed "s/%DBNAME%/bn/g;" $BNSPFILE > install-sp.sql
    $MYSQL $MYSQLOPTIONS --force < install-sp.sql 2>bnsp.err
    VAR_BNSP=$?
    if [ $VAR_BNSP -ne 0 ]
    then
        echo "Failed to execute $BNSPFILE"
        exit $VAR_BNSP
    fi
  fi

# add bnimportsp.sql
  BNIMPORTSPFILE="$CURDIR/bnimportsp.sql"
  if [ -r "$BNIMPORTSPFILE" ]
  then
    sed "s/%DBNAME%/bn/g;" $BNIMPORTSPFILE > install-sp.sql
    $MYSQL $MYSQLOPTIONS --force < install-sp.sql 2>bnsp.err
    VAR_BNIMPORTSP=$?
    if [ $VAR_BNIMPORTSP -ne 0 ]
    then
        echo "Failed to execute $BNIMPORTSPFILE"
        exit $VAR_BNIMPORTSP
    fi
  fi
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

# bug 17937, there doesn't seem to be a safe usage limit at this moment, so commenting this out
  #if [ $USAGE -ge 50 ]
  #then
  #  echo "The filesystem usage ($USAGE%) seems too high"
  #  echo "Since a data copy will be made when upgrading the database,"
  #  echo "we recommend twice as much space available as the current db size"
  #  PECHO "Go ahead with the upgrade anyway? [n]/y "
  #  read ans
  #  if [ -z "$ans" -o "$ans" = "n" -o "$ans" = "N" ]
  #  then
  #    exit 0
  #  fi
  #else
  #  echo "The filesystem usage ($USAGE%) is adequate, proceeding with upgrade"
  #fi

  echo "The filesystem usage is $USAGE%, proceeding with upgrade"

  oldver=$1;
  newver=$2;

  UPGRADEFILE="$CURDIR/$UPGRADEFILEPREFIX-$oldver-$newver.sql"
  #INSTALLFILE="$CURDIR/$INSTALLFILEPREFIX-$newver.sql"
  INSTALLFILE="$CURDIR/bn.sql"
  PERMISSIONSFILE="$CURDIR/ivms.sql"

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
  #add exit
  VAR_INS=$?
  if [ $VAR_INS -ne 0 ]
  then
        exit $VAR_INS
  fi

  # add bnsp.sql
  BNSPFILE="$CURDIR/bnsp.sql"
  if [ -r "$BNSPFILE" ]
  then
    sed "s/%DBNAME%/bn/g;" $BNSPFILE > install-sp.sql
    $MYSQL $MYSQLOPTIONS --force < install-sp.sql 2>bnsp.err
    VAR_BNSP=$?
    if [ $VAR_BNSP -ne 0 ]
    then
        echo "Failed to execute $BNSPFILE"
        exit $VAR_BNSP
    fi
  fi

  # add bnimportsp.sql
  BNIMPORTSPFILE="$CURDIR/bnimportsp.sql"
  if [ -r "$BNIMPORTSPFILE" ]
  then
    sed "s/%DBNAME%/bn/g;" $BNIMPORTSPFILE > install-sp.sql
    $MYSQL $MYSQLOPTIONS --force < install-sp.sql 2>bnsp.err
    VAR_BNIMPORTSP=$?
    if [ $VAR_BNIMPORTSP -ne 0 ]
    then
        echo "Failed to execute $BNIMPORTSPFILE"
        exit $VAR_BNIMPORTSP
    fi
  fi

  $MYSQL $MYSQLOPTIONS < upgrade-tables.sql
  VAR_UPG=$?
  if [ $VAR_UPG -ne 0 ]
  then
        exit $VAR_UPG
  fi

}

# main program

CURDIR=`dirname $0`


op=$1

MYSQL=$2

MYSQLUSER=$3

MYSQLPASS=$4

IVMSVERSION=$5

IVMSUSER=$6

IVMSPASS=$7

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
  	handleInstall $IVMSVERSION $IVMSUSER $IVMSPASS
  else
	PECHO "usage: db.sh i /usr/bin/mysql root root_password self_version db_username db_password"; 
	exit 0;
   fi;	
        
else
  if [ $# -ge 8 ]
  then
  	curIvmsVer=$8
  	handleUpgrade $curIvmsVer $IVMSVERSION
   else
	PECHO "usage: db.sh u /usr/bin/mysql root root_password self_version db_username db_password cur_ivmss_version"
	exit 0;
   fi
fi

exit 0
