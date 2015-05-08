#!/bin/sh

# this script updates the max call value of $REG_ID/$PORT to a random number and times the sec it takes to update the cache
# used to check DB and cache consistency for ticket 46110
# make sure the $REG_ID only has one port, which is port 0
# Bilig, April 25, 2008

REG_ID=Srikant
PORT=0
CACHE_FILE=/tmp/iedge_cache
FLOOR=100
RANGE=999
INTERVAL=1
TIMEOUT=600			# max wait time is 10 min

echo; echo `date +%F-%H:%M:%S`
number=0   #initialize
while [ "$number" -le $FLOOR ]
do
        number=$RANDOM
        let "number %= $RANGE"  # Scales $number down within $RANGE.
done

echo "Setting $REG_ID/$PORT max calls to $number"
cli iedge edit $REG_ID $PORT xcalls $number

n=0
cli iedge cache $CACHE_FILE > /dev/null
XCALLS=`grep -A 12 -m 1 $REG_ID $CACHE_FILE | grep "Max Calls" | sed -e 's/   */ /g' | cut -f4 -d" "`
# echo "number is $number and max calls is $XCALLS"
while [ $number -ne $XCALLS ] && [ $n -lt $TIMEOUT ]                           # check to see if the cache is updated. timeout if it takes too long
do
        cli iedge cache $CACHE_FILE > /dev/null
        XCALLS=`grep -A 12 -m 1 $REG_ID $CACHE_FILE | grep "Max Calls" | sed -e 's/   */ /g' | cut -f4 -d" "`
        n=`expr $n + $INTERVAL`
	echo "max calls is $XCALLS and $n sec elapsed..."
        sleep $INTERVAL
done
echo "Took $n sec (it timed out if it is equal to $TIMEOUT)..." 
echo "============================================"; echo
exit 0

