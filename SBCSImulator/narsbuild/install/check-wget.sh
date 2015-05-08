#!/bin/sh 

LOGDIR=/var/log
LOGFILE=ha-log

if [ $# == 1 ]
then
	sleeptime=`expr $1 + 1`
else
	echo "Exiting No Input provided" >> $LOGDIR/$LOGFILE
	exit
fi

for((;;))
do
# Checking whether the process exist

	pkill -0 -x pm
	y=$?
	
	if [ $y != 0 ]
	then
		echo "pm not running exiting" >> $LOGDIR/$LOGFILE
		exit
	fi

	pkill -0 -x wget
	x=$?

	pid=`pgrep -x wget`
	echo "$pid"

	if [ $x != 0 ]
	then
		#echo "wget not running" >> $LOGDIR/$LOGFILE
		sleep 1
		continue
	else
		#echo "wget running" >> $LOGDIR/$LOGFILE
		sleep $sleeptime
		pkill -0 -x wget
		z=$?
		
		# Get current pid
		currpid=`pgrep -x wget`
		echo "wget old pid $pid  wget new pid $currpid" >> $LOGDIR/$LOGFILE
		
		if [ $z == 0 ] && [ $pid == $currpid ]
		then
			echo "same wget still running killing wget" >> $LOGDIR/$LOGFILE
			`kill -9 \`pgrep -x wget\``
		fi
	fi
done
