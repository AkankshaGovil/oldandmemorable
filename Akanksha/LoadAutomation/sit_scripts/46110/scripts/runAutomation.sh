export priMSX="10.135.0.177"
export secMSX="10.135.0.178"
export resultPathOnRSM="/root/46110/scripts/automated/Result"
export PathOnMSX="/tmp/46110Scripts/"

callGenServer="10.135.0.118"
callGenClient="10.135.0.117"
gatewayIp="10.135.0.204"

deviceName="msx177"
RsmUserPasswd="nextone123"

currdate=`date +%Y%m%d`
#########################################

echo "Running Stage 1"

FilePath="/root/46110/data/100-1"
priority=300
region="Region"
percentage=100

pid=`ps -ef | grep RSM-Mon.sh | grep -v grep | awk '{print $2}'`
kill -9 $pid 2>/dev/null
cd automated
./runCallGen.py $callGenServer $callGenClient $gatewayIp $percentage
sleep 300 
./captureVportStat.py $priMSX
./RSM-Mon.sh $priority $region > tmp & 
cd ../
./rsm_script.sh $FilePath $deviceName $RsmUserPasswd
sleep 300
./gather_result.sh 1 $currdate
sleep 600
cd automated
./killCallGen.py $callGenServer $callGenClient
./fileCleanup.py $priMSX $secMSX
./tarCDR.py $priMSX $currdate 1
cd ../

echo "End of Stage 1"
###########################################
sleep 18000
###########################################

echo "Running Stage 2"

FilePath="/root/46110/data/20-1"
priority=400
region="Praful"
percentage=20

pid=`ps -ef | grep RSM-Mon.sh | grep -v grep | awk '{print $2}'`
kill -9 $pid 2>/dev/null
cd automated
./runCallGen.py $callGenServer $callGenClient $gatewayIp $percentage
sleep 300 
./captureVportStat.py $priMSX
./RSM-Mon.sh $priority $region > tmp & 
cd ../
./rsm_script.sh $FilePath $deviceName $RsmUserPasswd
sleep 300
./gather_result.sh 2 $currdate
sleep 600
cd automated
./killCallGen.py $callGenServer $callGenClient
./fileCleanup.py $priMSX $secMSX
./tarCDR.py $priMSX $currdate 1
cd ../

echo "End of Stage 2"
###########################################
sleep 7200
###########################################

echo "Running Stage 3"

FilePath="/root/46110/data/100-1"
priority=300
region="Region"
percentage=20

pid=`ps -ef | grep RSM-Mon.sh | grep -v grep | awk '{print $2}'`
kill -9 $pid 2>/dev/null
cd automated
./runCallGen.py $callGenServer $callGenClient $gatewayIp $percentage
sleep 300 
./captureVportStat.py $priMSX
./RSM-Mon.sh $priority $region > tmp & 
cd ../
./rsm_script.sh $FilePath $deviceName $RsmUserPasswd
sleep 300
./gather_result.sh 3 $currdate
sleep 600
cd automated
./killCallGen.py $callGenServer $callGenClient
./fileCleanup.py $priMSX $secMSX
./tarCDR.py $priMSX $currdate 1
cd ../

echo "End of Stage 3"
###########################################
sleep 7200
###########################################

echo "Running Stage 4"

FilePath="/root/46110/data/20-1"
priority=400
region="Praful"
percentage=20

pid=`ps -ef | grep RSM-Mon.sh | grep -v grep | awk '{print $2}'`
kill -9 $pid 2>/dev/null
cd automated
./runCallGen.py $callGenServer $callGenClient $gatewayIp $percentage
sleep 300 
./captureVportStat.py $priMSX
./RSM-Mon.sh $priority $region > tmp & 
cd ../
./rsm_script.sh $FilePath $deviceName $RsmUserPasswd
sleep 300
./gather_result.sh 4 $currdate
sleep 600
cd automated
./killCallGen.py $callGenServer $callGenClient
./fileCleanup.py $priMSX $secMSX
./tarCDR.py $priMSX $currdate 1
cd ../

echo "End of Stage 4"

###########################################
sleep 7200
###########################################

echo "Running Stage 5"

FilePath="/root/46110/data/100-1"
priority=300
region="Region"
percentage=20

pid=`ps -ef | grep RSM-Mon.sh | grep -v grep | awk '{print $2}'`
kill -9 $pid 2>/dev/null
cd automated
./runCallGen.py $callGenServer $callGenClient $gatewayIp $percentage
sleep 300 
./captureVportStat.py $priMSX
./RSM-Mon.sh $priority $region > tmp & 
cd ../
./rsm_script.sh $FilePath $deviceName $RsmUserPasswd
sleep 300
./gather_result.sh 5 $currdate
sleep 600
cd automated
./killCallGen.py $callGenServer $callGenClient
./fileCleanup.py $priMSX $secMSX
./tarCDR.py $priMSX $currdate 1
cd ../

echo "End of Stage 5"

###########################################
sleep 7200
###########################################

echo "Running Stage 6"

FilePath="/root/46110/data/100-3"
priority=400
region="Nextone"
percentage=100

pid=`ps -ef | grep RSM-Mon.sh | grep -v grep | awk '{print $2}'`
kill -9 $pid 2>/dev/null
cd automated
./runCallGen.py $callGenServer $callGenClient $gatewayIp $percentage
sleep 300 
./captureVportStat.py $priMSX
./RSM-Mon.sh $priority $region > tmp & 
cd ../
./rsm_script.sh $FilePath $deviceName $RsmUserPasswd
sleep 300
./gather_result.sh 6 $currdate
sleep 600
cd automated
./killCallGen.py $callGenServer $callGenClient
./killVportStat.py $priMSX
./tarCDR.py $priMSX $currdate 1

echo "End of Stage 6"

###########################################
sleep 1800
###########################################

pid=`ps -ef | grep RSM-Mon.sh | grep -v grep | awk '{print $2}'`
kill -9 $pid 2>/dev/null
./fileCleanup.py $priMSX $secMSX
