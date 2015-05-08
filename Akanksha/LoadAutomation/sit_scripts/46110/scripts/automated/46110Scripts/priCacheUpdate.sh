#Copying the iserver.log file

cat /var/log/iserver.log >>/var/log/iserver_bk.log
>/var/log/iserver.log
nu=`grep  MCACH /var/log/iserver.log | wc -l`

while [ $nu -lt 4 ]
do
    sleep 30
    nu=`grep  MCACH /var/log/iserver.log | wc -l`
    `grep  MCACH /var/log/iserver.log > /tmp/result`
done

#Running runIedgeCache
echo "----------Iedge update time T3 -----------" >> /root/iedgeCacheOutput
/bin/bash /tmp/46110Scripts/iedge_cache.sh >> /root/iedgeCacheOutput

sleep 60

`grep  MCACH /var/log/iserver.log > /tmp/result`
#cat /var/log/iserver_bk.log /var/log/iserver.log > /var/log/iserver.log.1
#mv /var/log/iserver.log.1 /var/log/iserver.log
#rm /var/log/iserver_bk.log     
