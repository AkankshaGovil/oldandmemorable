#Copying the iserver.log file

scp root@10.135.0.177:/tmp/result /tmp/priResult

fname="/tmp/priResult"
>/tmp/result

exec<$fname
while read line
do
   type=`echo $line | awk '{print $10}'`
   transacId=`echo $line | awk '{print $13}'`
   grep $transacId /var/log/iserver.log | grep $type >> /tmp/result
done
