stage=$1
currdate=$2
resultPath="/root/46110/scripts/automated/Result/$currdate/stage-$stage"
echo $resultPath
mkdir -p $resultPath


echo "Copying result from Primary MSX" 
`scp root@$priMSX:/root/iedgeCacheOutput $resultPath`
`scp root@$priMSX:/tmp/result $resultPath/Mcach_pri`
`scp root@$priMSX:/tmp/vportStat $resultPath`


echo "Copying result from Secondary MSX" 
`scp root@$secMSX:/home/brenda/lcr-cron-getlocal-day1 $resultPath`
`scp root@$secMSX:/tmp/result $resultPath/Mcach_sec`

cp /root/46110/scripts/automated/Result/result $resultPath
