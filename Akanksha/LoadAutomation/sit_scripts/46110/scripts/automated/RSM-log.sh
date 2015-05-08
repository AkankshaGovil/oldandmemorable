#!/bin/bash

lcrStartTimeCapture()
{
    #> /var/log/bn.log.0
    `> result`
    `echo "-------------------LCR Start Time----------------" >> result`
    while true
    do
       `cat /var/log/bn.log.0 | grep -i "Action is iserver"  >> result`
       if [ $? -eq 0 ]
       then
           echo "Action is iserver found"
	   return
       fi	
    done
}

calliedge_cache()
{
    return
}

iedgeUpdateTimeCapture()
{
    #> /var/log/bn.log.0
    `echo "-------------------iedge Update Time----------------" >> result`
    while true
    do
       `cat /var/log/bn.log.0 | grep -i "Sent one batch to RSM/MSW"  >> result`
       if [ $? -eq 0 ]
       then
           echo "Sent one batch to RSM/MSW found"
	   return
       fi	
    done
}

rsmRouteGenerationTimeCapture()
{
    #> /var/log/bn.log.0
    `echo "-------------------Route Generation Time----------------" >> result`
    while true
    do
       `cat /var/log/bn.log.0 | grep -i "total time taken in milliseconds" | awk -F"milliseconds: " '{print $2}'  >> result`
       if [ $? -eq 0 ]
       then
           echo "Route Generation Time found"
	   return
       fi	
    done
}
getFirstCacheTime()
{
    #> /var/log/iserver.log
    `echo "-------------------Cache Update Start Time----------------" >> result`
    while true
    do
       `cat /var/log/iserver.log | grep MCACH | grep "Got transaction ID"`
       if [ $? -eq 0 ]
       then
           echo "Cache Update Time found"
	   return
       fi	
    done
}
getLastCacheTime()
{
    res=`cat /var/log/iserver.log | grep MCACH | grep "Done transaction ID" | tail -1`
    #if [ $? -eq 0 ]
    #then
	    while true
	    do
	       sleep 5
	       newres=`cat /var/log/iserver.log | grep MCACH | grep "Done transaction ID" | tail -1`
	       if [ $? -eq 0 ]
	       then
		   #Start Here 
		   if [ $newres -eq $res ]
		   then
		       `echo "-------------------Cache Update Finish Time----------------" >> result`
		       `echo $newres >> result`
		       return
		   else
		       res=$newres
		   fi	
	       fi	
	    done
    #else
    #   return 1  	    
    #fi	    

}
cacheUpdateTimeCapture()
{
    getFirstCacheTime
    sleep 5
    getLastCacheTime
}
runGetLocalDBScript()
{
    `getlocaldb.sh >> /home/Brenda/lcr-cron-getlocal-day1 &`
    return
}


changeGetLocalDBScript()
{
    # Decide getlocaldb's path	
    `echo "" > getlocaldb.sh`	
    `echo "psql -Ulocalclient -q -dmsw -c \"select count(*) from cpbindings where priority = $1\"" >> getlocaldb.sh`
    `echo "date" >> getlocaldb.sh`
    `echo "echo \"Routes by Name\"" >> getlocaldb.sh`
    `echo "psql -Ulocalclient -q -dmsw -c \"select count(*) from callingroutes where name like '1T-$2%'\"" >> getlocaldb.sh`
    `echo "date" >> getlocaldb.sh`
    runGetLocalDBScript
}

#lcrStartTimeCapture 
pri=300
region="Region"


#--------First Step---------
changeGetLocalDBScript $pri $region
