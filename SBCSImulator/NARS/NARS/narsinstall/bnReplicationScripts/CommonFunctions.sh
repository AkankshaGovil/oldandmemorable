#!/bin/sh

ISERVERINSTALLBINDIR="/usr/local/nextone/bin"
MASTERIP="127.0.0.1"

trimLeadingSpaces()
{
	if [ $# -ne 1 ]; then
		echo "Usage: trimLeadingSpaces <string>"
	fi

	echo $1| sed -e 's/^\s//g'
}

trimTrailingSpaces()
{
	if [ $# -ne 1 ]; then
		echo "Usage: trimTrailingSpaces <string>"
	fi

	echo $1| sed -e 's/\s$//g'
}

GetLocalNodeID()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=NodeID $ISERVERINSTALLBINDIR/dbinfo| head -1
}

GetLocalHostIP()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=HostIP $ISERVERINSTALLBINDIR/dbinfo| head -1
}

GetRemoteNodeID()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=NodeID $ISERVERINSTALLBINDIR/dbinfo| tail -1
}

GetRemoteHostIP()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=HostIP $ISERVERINSTALLBINDIR/dbinfo| tail -1
}

GetClusterName()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=ClusterName $ISERVERINSTALLBINDIR/dbinfo
}

GetDbClusterName()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=ClusterName $ISERVERINSTALLBINDIR/dbinfo
}

GetRemoteDbUser()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=UserName $ISERVERINSTALLBINDIR/dbinfo| tail -1
}

GetRemoteDbNode()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=NodeID $ISERVERINSTALLBINDIR/dbinfo| tail -1
}

GetRemoteDbName()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=DBName $ISERVERINSTALLBINDIR/dbinfo| tail -1
}

GetRemoteDbHost()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=HostIP $ISERVERINSTALLBINDIR/dbinfo| tail -1
}

GetLocalDbUser()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=UserName $ISERVERINSTALLBINDIR/dbinfo| head -1
}

GetLocalDbNode()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=NodeID $ISERVERINSTALLBINDIR/dbinfo| head -1
}

GetLocalDbName()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=DBName $ISERVERINSTALLBINDIR/dbinfo| head -1
}

GetLocalDbHost ()
{
	$ISERVERINSTALLBINDIR/iniParser.awk PARAMETER=HostIP $ISERVERINSTALLBINDIR/dbinfo| head -1
}

TryDbConnect()
{
	LOCALDBNAME=`GetLocalDbName`
	
	if [ $# -ne 1 ]
	then
		psql -t -q -Uslon -d$LOCALDBNAME -c"select 1;" >& /dev/null
	else
		psql -t -q -h$1 -Uslon -d$LOCALDBNAME -c"select 1;" >& /dev/null
	fi
	return $?
}

#$1 is the input to the RUMaster() function
#Return: 
#	if Master 1
#	if Slave 0
DbGetRedundancyType()
{
	LOCALDBNAME=`GetLocalDbName`
	if [ $# -ne 2 ]
	then
		echo "Usage: DbGetRedundancyType <Node Id> <peeriserver-ip>"
		return -1
	fi

	TryDbConnect $2
	if [ $? -eq 0 ]; then
		redundancystatus=`psql -Uslon -h$2 -d$LOCALDBNAME -t -c"select RUMaster($1);" 2>/dev/null|head -1` 1>/dev/null 2>&1
		if [ "$redundancystatus" = "" ]; then
			 return 2;
        fi
		if [ $redundancystatus -eq 1   ]; then
			return $redundancystatus
		fi
		if [ $redundancystatus -eq 0   ]; then
			return $redundancystatus
		fi
		#return $redundancystatus
		return 2
	else
		return 2 
	fi
}

DetectInconsistentState()
{
	LOCALHOSTIP=$1
	LOCALNODE=$2
	REMOTENODE=$3
	DBNAME=msw
	status=2

	DbGetRedundancyType $LOCALNODE $LOCALHOSTIP
	REDTYPE=$?
	if [ $REDTYPE -eq 2 ]; then
		return 1;
	elif [ $REDTYPE -eq 1 ]; then
		return 0
	else
		status=`psql -t -q -Uslon -d$DBNAME -c"select count(con_seqno) from _mswcluster.sl_confirm c join (select max(ev_seqno) as seqno from _mswcluster.sl_event where ev_origin=$REMOTENODE and ev_type = 'ENABLE_SUBSCRIPTION') as e on e.seqno = c.con_seqno where con_origin = $LOCALNODE;"|head -1`
		
		if [ $status = 1 ]; then
			return 0;
		elif [ $status = 0 ]; then
			return 1;
		else
			echo 'Problem in finding inconsistency';
			return 0
		fi
	fi
}

DetectMaster()
{
	LOCALDBNAME=`GetLocalDbName`
	if [ $# -ne 2 ]
	then
		echo "Usage: DetectMaster <Node Id> <peeriserver-ip>"
		return -1
	fi

	TryDbConnect $2
	if [ $? -eq 0 ]
	then
		redundancystatus=`psql -Uslon -h$2 -d$LOCALDBNAME -t -c"select RUMaster($1);"|head -1 |sed -e 's/^\s//g'`
		return $redundancystatus
	else
		return -1
	fi
}

FindMasterIP()
{
     LOCALNODE=`GetLocalNodeID`
     LOCALHOSTIP=`GetLocalHostIP`
     REMOTENODE=`GetRemoteNodeID`
     REMOTEHOSTIP=`GetRemoteHostIP`

     DetectMaster $LOCALNODE $LOCALHOSTIP
     LOCALISMASTER=$?
    if [ $LOCALISMASTER -eq 1 ]; then #Master is available
	   MASTERIP= $LOCALHOSTIP
	   return 0;
    fi

    DetectMaster $REMOTENODE $REMOTEHOSTIP
    REMOTEISMASTER=$?
    if [ $REMOTEISMASTER -eq 1 ]; then #Master is available
       MASTERIP=$REMOTEHOSTIP
	   return 0;
    fi
	MASTERIP="127.0.0.1"
	return 0;
}

