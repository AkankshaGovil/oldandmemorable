#!/bin/bash

runIedgeCache()
{
    echo "Started iedge cache on Primary MSX in background">>/tmp/46110Log
    #python runIedgeCache.py $1 &
    python runIedgeCache.py $1 $2
    echo " Done---->">>/tmp/46110Log
    return
}

getCacheUpdate()
{
    echo "Get Cache updates from MSX $1 in background">>/tmp/46110Log
    #python runCacheUpdate.py $1 &
    python runCacheUpdate.py $1 
    return
}


iedgeUpdateTimeCapture()
{
    #> /var/log/bn.log.0
    `echo "-------------------iedge Update Time----------------" >>$resultPathOnRSM/result`
    firstcount=`grep -ia "Sent one batch to RSM/MSW" /var/log/bn.log.0 | wc -l`
    while true
    do
       count=`grep -ia "Sent one batch to RSM/MSW" /var/log/bn.log.0 | wc -l`
       if [ $count -gt $firstcount ]
       then
           echo "Sent one batch to RSM/MSW found">>/tmp/46110Log
           `grep -ia "Sent one batch to RSM/MSW" /var/log/bn.log.0 | tail -1  >>$resultPathOnRSM/result`
	   runIedgeCache $priMSX 1
	   return
       fi
       sleep 2	
    done
}

rsmRouteGenerationTimeCapture()
{
    #> /var/log/bn.log.0
    `echo "-------------------Route Generation Time----------------" >>$resultPathOnRSM/result`
    firstcount=`grep -ia "total time taken in milliseconds" /var/log/bn.log.0 | wc -l`
    while true
    do
       count=`grep -ia "total time taken in milliseconds" /var/log/bn.log.0| wc -l`
       if [ $count -gt $firstcount ]
       then
           echo "Route Generation Time found">>/tmp/46110Log
           `grep -ia "total time taken in milliseconds" /var/log/bn.log.0 | tail -1 >>$resultPathOnRSM/result`
	   runIedgeCache $priMSX 2
	   return
       fi	
       sleep 30
    done
}





pri=$1
region=$2

# Emptying the result file

`>$resultPathOnRSM/result`

#--------First Step---------
#call python script for remotely running getlocaldb.sh
echo "Running get local db on MSX">>/tmp/46110Log
python getLocaldbOnMSX.py $secMSX $pri $region

echo " Starting capture for iedge update time on RSM ......">>/tmp/46110Log
echo " It will take some time. Please do not abort the script!">>/tmp/46110Log
iedgeUpdateTimeCapture


echo "Get Cache update time on $priMSX">>/tmp/46110Log
#getCacheUpdate $priMSX 
python runPriCacheUpdate.py $priMSX

echo " Starting capture for RSM Route generation time">>/tmp/46110Log
rsmRouteGenerationTimeCapture

sleep 7000
echo "Get Cache update time on $secMSX">>/tmp/46110Log
python runSecCacheUpdate.py $secMSX
echo "---------------Stage Complete-----------">>/tmp/46110Log
exit 0
