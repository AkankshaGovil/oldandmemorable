#!/bin/bash

#uncomment for debugging
#set -x

Usage()
{
	printf "Usage:\n";
	printf "\tchangeowner.sh [NewOwnerName]\t: Changes ownership to new owner. IVMSCLIENT is used if no owner name is supplied\n";
	printf "\tchangeowner.sh [-h/-H]\t\t: This help message\n";
}

ChangeOwner()
{
	DBNAME=msw
	LHOSTIP="127.0.0.1"
	DBUSERNAME="msw"

	if [ "$1" != "" ]; then
	   if [ "$1" = "-h" ] || [ "$1" = "-H" ]; then
		Usage
		exit 0;
	   else
		NEWOWNER=$1	
	   fi
	else
		NEWOWNER="IVMSCLIENT"
	fi
	
	printf "Setting owner for callingplans, callingroutes, cpbindings tables to: $NEWOWNER \n";

	query="BEGIN;"
	query=${query}"ALTER TABLE callingplans OWNER TO $NEWOWNER;";
	query=${query}"ALTER TABLE callingroutes OWNER TO $NEWOWNER;";
	query=${query}"ALTER TABLE cpbindings OWNER TO $NEWOWNER;";
	query=${query}"COMMIT;";
	psql -U$DBUSERNAME -d$DBNAME -h$LHOSTIP	-qtc "$query" > /dev/null 2>&1
	
	exit 0;
}

ChangeOwner $1
