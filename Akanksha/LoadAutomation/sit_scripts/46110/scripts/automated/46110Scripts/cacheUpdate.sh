
getFirstCacheTime()
{
    #> /var/log/iserver.log
    firstcount=`cat /var/log/iserver.log | grep MCACH | grep "Got transaction ID" | wc -l`
    `echo "-------------------Cache Update Start Time----------------" > /tmp/result`
    while true
    do
       count=`cat /var/log/iserver.log | grep MCACH | grep "Got transaction ID" | wc -l`
       if [ $count -gt $firstcount ]
       then
           echo "Cache Update Time found"
           `cat /var/log/iserver.log | grep MCACH | grep "Got transaction ID" | tail -1 >> /tmp/result` 
	   return
       fi	
    done
}


getLastCacheTime()
{
    #res=`cat /var/log/iserver.log | grep MCACH | grep "Done transaction ID" | tail -1`
    firstcount=`cat /var/log/iserver.log | grep MCACH | grep "Done transaction ID" | wc -l`
    while true
    do
        count=`cat /var/log/iserver.log | grep MCACH | grep "Done transaction ID" | wc -l`
	if [ $count -gt $firstcount ] 
	then
            res=`cat /var/log/iserver.log | grep MCACH | grep "Done transaction ID" | tail -1`
	    while true
	    do
	       sleep 5
	       newres=`cat /var/log/iserver.log | grep MCACH | grep "Done transaction ID" | tail -1`
	       if [ $? -eq 0 ]
	       then
		   #Start Here 
		   if [ "$newres" = "$res" ]
		   then
		       `echo "-------------------Cache Update Finish Time----------------" >> /tmp/result`
		       `echo $newres >> /tmp/result`
		       return
		   else
		       res=$newres
		   fi	
	       fi	
	    done
        fi	    
    done

}

getFirstCacheTime
sleep 2
getLastCacheTime
