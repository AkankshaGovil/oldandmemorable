#!/bin/sh 
# Slony script to add "bn" schema to "msw" set of tables for replication
# @author: Abhishek Agrawal
# @date: Feb-28-2006

#include "bnSync" script
. ./CommonFunctions.sh
. ./bnSync.sh 

export DBINFOPATH="/usr/local/nextone/bin/dbinfo"
export NXBIN="/usr/local/nextone/bin"


USERNAME=$1
HOSTIP1=$2
HOSTIP2=$3




if [ $# -ne 3 ];
then
	echo "usage: fireBnSync.sh <username> <hostip1> <hostip2>"
	exit 0;
fi





GetDbClusterName()

{

        $NXBIN/iniParser.awk PARAMETER=ClusterName $DBINFOPATH

}

 

TryConnect()

{
        psql -Umsw -t -c"select 1 as dummy;" 1>/dev/null 2>&1
        return $?
}

 

TryConnect

if [ $? != 0 ]; then

            echo "Error: Could not connect to DB msw!"
            exit -1
fi

 

if [ -f $DBINFOPATH ]; then

            CLUSTERNAME=`GetDbClusterName`
            MACHINEID=`hostname`
            if [ -n "$CLUSTERNAME" ]; then
                        PEERISERVER=`GetRemoteHostIP $MACHINEID`
                        if [ -n "$PEERISERVER" ]; then

                                    #Do ur stuff here . . . . 
				    psql -U$USERNAME -dmsw -h$HOSTIP1 -c"select 1 from bn.msws" >/dev/null 2>&1
				    if [ $? != 0 ]; then
					    echo "Error: bn schema not found on $HOSTIP while connecting with user $USERNAME!"
					    exit -1
				    fi

				    psql -U$USERNAME -dmsw -h$HOSTIP2 -c"select 1 from bn.msws" >/dev/null 2>&1
				    if [ $? != 0 ]; then
					    echo "Error: bn schema not found on $HOSTIP while connecting with user $USERNAME!"
					    exit -1
				    fi
					
                                    bn_rep_init

                        else

                                    echo "Error: msw installation appears to be corrupted: no peer-iserver configured for CLUSTERNAME = $CLUSTERNAME"
                                    exit -1
                        fi

            else

                        echo "Warning: Non-Clustered msw configured on this machine!"
                        exit 1

            fi

else

            echo "Error: msw installation appears to be corrupted: dbinfo file does not exist"
            exit -1

fi
