#!/bin/sh

#
# Usage: publish.sh [-u id] [-b begintime] [-e endtime] [-P product] [-m majorversion] [-v version] [-s status] [-t type] [-n numtests] [-p numpassed] [-S systemhw] [-M mediahw] [-N nextestversion] [-c name:email] [-d displaystring:relativepath] [-d ...]
#
# For inserts, the following fields are mandatory:
#	-b begintime
#	-P product
#	-m majorversion
#	-v version
#	-s status
#	-t type
#	-n numtests
#	-p numpassed
#	-S systemhw
#	-M mediahw
#	-N nextestversion
#	-c name:email
# The script will return a positive integer value that is the unique identifier of the record inserted into the database.
#
# For updates, the following fields are mandatory:
#	-u id
#	-e endtime
#	-s status
#	-n numtests
#	-p numpassed
#
# The script returns negative values upon error
#

#
# validate the string passed for a valid database timestamp string
#
ValidateDate () {
  local DATETIME="$*"
  #echo datetime=$DATETIME

  # validate the date string
  Date=`echo $DATETIME | cut -d" " -f1`

  # validate the year
  Year=`echo $Date | cut -d"-" -f1`
  if [ $Year -lt 2007 ]
  then
    echo "$0: Invalid year in $DATETIME"
    exit -1
  fi
  # validate the month
  Month=`echo $Date | cut -d"-" -f2`
  if [ $Month -lt 1 -o $Month -gt 12 ]
  then
    echo "$0: Invalid month in $DATETIME"
    exit -1
  fi
  # validate the day (just the general range, not month specific
  Day=`echo $Date | cut -d"-" -f3`
  if [ $Day -lt 1 -o $Day -gt 31 ]
  then
    echo "$0: Invalid day in $DATETIME"
    exit -1;
  fi

  # validate the time string
  Time=`echo $DATETIME | cut -d" " -f2`
  #echo time=$Time

  # validate the hour
  Hour=`echo $Time | cut -d":" -f1`
  #echo $Hour
  if [ $Hour -lt 0 -o $Hour -gt 24 ]
  then
    echo "$0: Invalid hours in $DATETIME"
    exit -1
  fi

  # validate the minute
  Min=`echo $Time | cut -d":" -f2`
  #echo $Min
  if [ $Min -lt 0 -o $Min -gt 60 ]
  then
    echo "$0: Invalid minutes in $DATETIME"
    exit -1
  fi

  # validate the second
  Sec=`echo $Time | cut -d":" -f3`
  #echo $Sec
  if [ $Sec -lt 0 -o $Sec -gt 60 ]
  then
    echo "$0: Invalid seconds in $DATETIME"
    exit -1
  fi

  # all good now, just return
}


#
# prints the usage message
#
Usage () {

USAGE="Usage: publish.sh [-u id] [-b begintime] [-e endtime] [-P product] [-m majorversion] [-v version] [-s status] [-t type] [-n numtests] [-p numpassed] [-S systemhw] [-M mediahw] [-N nextestversion] [-c name:email] [-d displaystring:relativepath] [-d ...] 
For inserts, the following fields are mandatory:
	-b begintime
	-P product
	-m majorversion
	-v version
	-s status
	-t type
	-n numtests
	-p numpassed
	-S systemhw
	-M mediahw
	-N nextestversion
	-c name:email
The script will return a positive integer value that is the unique identifier of the record inserted into the database.

For updates, the following fields are mandatory:
	-u id
	-e endtime
	-s status
	-n numtests
	-p numpassed

The script returns negative values upon error."

echo "$USAGE"
}

#
# process  the input arguments to this script
#
ProcessOptions () {
  while getopts u:b::e:P:m:v:s:t:n:p:S:M:N:c:d: i "$@"
  do
    case "$i" in
    u)
	ID=$OPTARG
	;;
    b)
	BEGINDATE=$OPTARG
        echo opt=$OPTARG
	ValidateDate $BEGINDATE
	;;
    e)
	ENDDATE=$OPTARG
	ValidateDate $ENDDATE
	;;
    P)
	PRODUCT=$OPTARG
	;;
    m)
	MAJORVERSION=$OPTARG
	;;
    v)
	VERSION=$OPTARG
	;;
    s)
	STATUS=$OPTARG
	;;
    t)
	TYPE=$OPTARG
	;;
    n)
	TESTS=$OPTARG
	;;
    p)
	PASS=$OPTARG
	;;
    S)
	SYSTEM=$OPTARG
	;;
    M)
	MEDIA=$OPTARG
	;;
    N)
	NEXTESTVERSION=$OPTARG
	;;
    c)
	CONTACT=$OPTARG
	;;
    d)
	DETAILS=$OPTARG
	;;
    [?])
	Usage
	exit -2
	;;
    esac
  done
  shift `expr $OPTIND - 1`
}

#
# executes the mysql command
#
ExecuteMySql () {

  #return mysql -v -h 127.0.0.1 -u root -proot -P 8889 -D testdb -e "$1"
  /opt/lampstack-5.5/mysql/bin/mysql --socket=/opt/lampstack-5.5/mysql/tmp/mysql.sock -uroot -pverify -D testdb -e "$1"
  echo
}

#
# Validate the mandatory options for insert
#
ValidateInsert () {
  echo ""
}

#
# insert the given data, exit with a code that equals the inserted record id
#
DoInsert () {

  # validate arguments
  ValidateInsert

  DETAILS="index"`date +%s`

  COLS="(""Id ,Created , TestStart , TestEnd , Product , MajorVersion , SUTVersion , TestStatus , TestType , NumTests , NumPass , SystemHW , MediaHW , DetailsKey, LastModified , NextestVersion , Contact , Comments"")"

  VALS="(NULL,\"\",\"$BEGINDATE\" ,\"$ENDDATE\",\"$PRODUCT\",\"$MAJORVERSION\",\"$VERSION\",\"$STATUS\",\"$TYPE\",\"$TESTS\",\"$PASS\",\"$SYSTEM\",\"$MEDIA\",\"$DETAILS\",\"\",\"$NEXTESTVERSION\",\"$CONTACT\",NULL)"

  ExecuteMySql "INSERT INTO tests $COLS VALUES $VALS;"

  ExecuteMySql "select max(LAST_INSERT_ID(Id)) from tests;" > /home/test/tmp1.txt
  ID=`cat tmp1.txt | grep [0-9]`

  ExecuteMySql "INSERT INTO details VALUES (NULL, \"$ID\",\"$DETAILS\" , 'Results', \"$RESULT_RELATIVE_PATH\");"

  #returning the last insert Id
  exit $ID
}

#
# Validate the mandatory options for update
#
ValidateUpdate () {
  echo ""
}

#
# update the database record with the given data, exit with a code that equals the updated record id
#
DoUpdate () {

  # validate arguments
  ValidateUpdate
  
  #echo "calling DoUpdate function"
  #echo "update tests set NumTests = $TESTS, NumPass = $PASS, TestEnd=\"$ENDDATE\", TestStatus=\"$STATUS\" where id=$ID;"
  ExecuteMySql "update tests set NumTests = $TESTS, NumPass = $PASS, TestEnd=\"$ENDDATE\", TestStatus=\"$STATUS\" where id=$ID;"
  
  exit 0 
}

# input argument processing
ProcessOptions "$@"

# Do the insert or the update
if [ -z "$ID" ]
then
  DoInsert
else
  DoUpdate
fi

# should never be getting here...
exit -3

