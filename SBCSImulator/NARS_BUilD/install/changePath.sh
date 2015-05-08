#!/bin/sh

# This script takes the path that is hardcoded in the files, and a path to check if it 
# is applicable and edits the given files to use that path
# E.g., if the hardcoded path is /usr/local/bin/perl and the the path to check is /usr/bin/perl, this script
# checks at execution time which path exists and change that path string in the given list of files
#
# usage: changePath <path in the code> <path to change to> [file names]
#

. ./globals.sh

ChangePath ()
{
	HARDVERSION=$1
	shift
	NEWVERSION=$1
	shift

	if [ -x $HARDVERSION ]
	then
		$ECHO "Will leave path at: $HARDVERSION"
	elif [ -x $NEWVERSION ]
	then
		$ECHO "Using new path: $NEWVERSION"
		replace $HARDVERSION $NEWVERSION -- $*
	else
		$ECHO "Unable to find $HARDVERSION or $NEWVERSION"
		return 1
	fi

	return 0
}


