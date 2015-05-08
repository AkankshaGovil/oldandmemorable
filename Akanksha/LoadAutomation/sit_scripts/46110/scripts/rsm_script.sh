cd Import
filepath=$1
device=$2
passwd=$3
echo "-------------------------Importing Regions--------------------------"
#./importroutes.sh  $filepath/Regions.txt importRegions $device $passwd 
./importroutes.sh  $filepath/xaa importRegions $device $passwd 'replace'
if [ $? -ne 0 ]
then
    sleep 600
fi
./importroutes.sh  $filepath/xab importRegions $device $passwd 'add'
if [ $? -ne 0 ]
then
    sleep 600
fi
./importroutes.sh  $filepath/xac importRegions $device $passwd 'add' 
if [ $? -ne 0 ]
then
    sleep 600
fi
./importroutes.sh  $filepath/xad importRegions $device $passwd 'add' 
if [ $? -ne 0 ]
then
    sleep 600
fi
./importroutes.sh  $filepath/xae importRegions $device $passwd 'add' 
if [ $? -ne 0 ]
then
    sleep 600
fi

echo "-------------------------Importing Customer Rate--------------------------"
./importroutes.sh  $filepath/Customer-Rate.txt importCustomerRates $device $passwd 'replace'
if [ $? -ne 0 ]
then
    sleep 600
fi

echo "-------------------------Importing Supplier Rate--------------------------"
./importroutes.sh  $filepath/Supplier-Rate.txt importSupplierRates $device $passwd 'replace'
if [ $? -ne 0 ]
then
    sleep 600
fi

echo "-------------------------Importing Customer Route--------------------------"
./importroutes.sh  $filepath/Customer-Route.txt importCustomerRoutes $device $passwd 'replace'
if [ $? -ne 0 ]
then
    sleep 600
fi

echo "-------------------------Importing Supplier Route--------------------------"
./importroutes.sh  $filepath/Supplier-Route.txt importSupplierRoutes $device $passwd 'replace'
if [ $? -ne 0 ]
then
    sleep 600
fi


echo "LCR Start Time :" `date` >> ./../automated/Result/result

cd ../RouteGenerate

./generateRoute_client.py $2 $3

echo "------------------------------- Route Generate done ----------------------------"
