# !/bin/bash

#clean up the tempfile
trap cleanup 0 1 2 3 6 9 14 15

cleanup()
{
	echo "Caught Signal ... cleaning up."
#rm -rf /tmp/csv-nated*
	echo "Done cleanup ... quitting."
	exit 1
}

# Read the config file and populate the variable
getConfigVal()
{

       ip_start=23.23.90.2
       mask=255.255.0.0
       iface=eth2

	
	var1=`echo $ip_start | cut -d"." -f1 `
	var2=`echo $ip_start | cut -d"." -f2 `

	sec=`echo $ip_start | cut -d"." -f3 `
	first=`echo $ip_start | cut -d"." -f4 `
}

# Function to generate the csv file
GenCSV (){
	rm -f /tmp/csv-nated*
	touch /tmp/csv-nated.txt
        > /tmp/csv-nated.txt
	Counter=0
	echo "You have enterd Total No. Of eps $1"
	TotalEpFun=$1
	SecOct=$sec
	SecOctMax=254

	username=100000
	while [ $SecOct -le $SecOctMax ] ; do
		FirstOct=$first
		FirstOctMax=254
		while [ $FirstOct -le $FirstOctMax ] ; do
			UserMin=0
			UserMax=254
			while [ $UserMin -le $UserMax ] ; do
				 #echo "[authentication username=$username password=$username];$username;$var1.$var1.$SecOct.$FirstOct;40.40.$SecOct.$FirstOct"
				 echo "[authentication username=$username password=$username];$username;$var1.$var1.$SecOct.$FirstOct;40.40.$SecOct.$FirstOct" >> /tmp/csv-nated.txt
			 	let username=username+1
			 	let UserMin=UserMin+1
			 	let TotalEpFun=TotalEpFun-1 
			 	if [ $TotalEpFun -eq 0 ]
			 	then
					echo "CSV file created"
					return
			 	fi
		    	 done
		let FirstOct=FirstOct+1
		done
	let SecOct=SecOct+1
	done 
}

TotalEPs=59940
echo "Total No. of endpoints $TotalEPs"
rate=37
echo "Rate or RPS $rate"
expireorig=181
expire=`expr $expireorig - 1`
echo "Expire value $expire"

getConfigVal
echo "Local Ip on which Script should be run"
SourceIp=SOURCE_IP
echo $SourceIp
echo "Remote Ip where You want to send registers"
RemoteIp=REMOTE_IP
echo $RemoteIp
echo "calling function to generate CSV file"
GenCSV $TotalEPs
echo "returning from Function"


EPsinEachInstance=$((rate*expire))
echo "Number of endpoints registering in each Instance will be $EPsinEachInstance"

if [ $EPsinEachInstance -le $TotalEPs ]
then
	instances=$((TotalEPs/EPsinEachInstance))
else
	instances=1
fi
echo "And Total number of instances will be $instances"

#extra start
one=1
if [ $instances -le $one ]
then
	HalfInstances=1
else
	HalfInstances=$((instances/2))
fi
#extra end
range=$((TotalEPs/254))

echo "Starting instances...."
start=1
BeginLineCount=1
EndLineCount=$EPsinEachInstance
while [ $start -le $instances ] ; do
	touch /tmp/csv-nated$start.txt
	> /tmp/csv-nated$start.txt
	echo "SEQUENTIAL" >> /tmp/csv-nated$start.txt
	cat /tmp/csv-nated.txt | head -n $EndLineCount | tail -n $EPsinEachInstance >> /tmp/csv-nated$start.txt

#extra start
	if [ $start -gt $HalfInstances ]
	then
		sed -e 's/22\.22/22.22/g' /tmp/csv-nated$start.txt > temp.txt
		mv temp.txt  /tmp/csv-nated$start.txt
	fi
#extra end
#	sed -n '"$BeginLineCount","$EndLineCount"p;"$EndLineCount"q' /tmp/csv-nated.txt >> /tmp/csv-nated$start.txt
	BeginLineCount=`expr $EndLineCount + 1`
	EndLineCount=`expr $EndLineCount + $EPsinEachInstance`
        let start=$start+1 
done

echo "running instances"
start=1
delay=$expire
delay=$((delay*1000))

if [ $EPsinEachInstance -le $TotalEPs ]
then
	maxnumber=$EPsinEachInstance
else
	maxnumber=$TotalEPs
fi

while [ $start -le $instances ] ; do
#extra start
	if [ $start -le $HalfInstances ]
	then
		sip=$SourceIp
		rip=$RemoteIp
                echo "sipp -sf new-reg-nated-domain1 -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -users $maxnumber -nostdin -bg -trace_err -default_behaviors -bye,-abortunexp -pause_msg_ign"
	else
		sip=$SourceIp
		rip=$RemoteIp
                #./sipp -sf new-reg-nated-sittest.xml -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -users $maxnumber -nostdin -bg -trace_err -default_behaviors -bye,-abortunexp -pause_msg_ign
                echo "./sipp -sf new-reg-nated-domain2 -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -users $maxnumber -nostdin -bg -trace_err -default_behaviors -bye,-abortunexp -pause_msg_ign"
	fi
#extar end
	#nxgen -sf auth-reg-nated.xml -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -m $maxnumber -bg -trace_err
	#nxgen -sf reg-no-auth-vz.xml -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -m $maxnumber -bg -trace_err
	#nxgen -sf vz-auth-reg-nated.xml -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -m $maxnumber -bg -trace_err
	#./sipp -sf new-reg-nated.xml -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -users $maxnumber -nostdin -bg -trace_err -default_behaviors -bye,-abortunexp -trace_msg -trace_screen
	#echo "./sipp -sf new-reg-nated.xml -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -users $maxnumber -nostdin -bg -trace_err -default_behaviors -bye,-abortunexp"
	#./sipp -sf new-reg-nated.xml -i $sip $rip -inf /tmp/csv-nated$start.txt -d $delay -r $rate -users $maxnumber -nostdin -bg -trace_err -default_behaviors -bye,-abortunexp

        #sleep $expire
	let start=start+1
done

echo "******** TEST IS RUNNING SUCCESSFULLY ************"
echo "------------ Press CTRL-C to stop ----------------"
a=1
b=7
while [ $a -le $b ] ; do
    a=1
    sleep 3600
done
