#!/bin/bash

while read line
do
   if [ ! -z "$line" ]
   then
       param=`echo $line|awk -F"=" '{print $1}'`
       val=`echo $line|awk -F"=" '{print $2}'`

       if [ $param == "ip_start" ]
       then
           ip_start=$val
       elif [ $param == "mask" ]
       then
           mask=$val
       elif [ $param == "iface" ]
       then
           iface=$val
       else
           echo "$param is not a valid parameter"
       fi
   fi
done < genConfig

#sec=90
#first=2

var1=`echo $ip_start | cut -d"." -f1 `
var2=`echo $ip_start | cut -d"." -f2 `

sec=`echo $ip_start | cut -d"." -f3 `
first=`echo $ip_start | cut -d"." -f4 `
last=254
var=0
let temp=sec+1

while [ $sec -lt $temp ] ; do
    #echo $sec
    #first=2
    last=254
    while [ $first -le $last ] ; do
        echo "ifconfig $iface:$var $var1.$var2.$sec.$first netmask $mask up "
        #ifconfig eth2:$var 23.23.$sec.$first netmask 255.255.0.0 up 

	      let var=var+1
	      let first=first+1
    done
    let sec=sec+1
done



