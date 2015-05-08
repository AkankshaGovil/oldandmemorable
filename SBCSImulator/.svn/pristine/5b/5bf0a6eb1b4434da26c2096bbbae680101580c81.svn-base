#!/bin/bash

iserverdir="/opt/nextone"
iserverbindir="${iserverdir}/bin"

if [ -f $iserverdir/.aloidindex ]; then
    iserverVersion=`cat $iserverdir/.aloidindex`
    if [ -z "$iserverVersion" ]; then
        echo "No entry found in .aloidindex!!"
        exit 1
    fi
else
    echo "/opt/nextone/.aloidindex missing!!. Couldn't fetch the iserver version"
    exit 1
fi

pghbaconf="/var/lib/pgsql/data$iserverVersion/pg_hba.conf"
peeriserver=`cat $iserverbindir/dbinfo |grep HostIP |tail -1 |awk -F= '{print $2}'`
peerNodeId=`cat $iserverbindir/dbinfo |grep NodeID |tail -1 |awk -F= '{print $2}'`

# Take backup of dbinfo, /etc/ais/openais.conf & pg_hba.conf 
cp $iserverbindir/dbinfo $iserverbindir/dbinfo_bkup
cp /etc/ais/openais.conf /etc/ais/openais.conf_bkup
cp $pghbaconf ${pghbaconf}_bkup

# 1. Edit /etc/ais/openais.conf
sed -i 's/bindnetaddr:.*/bindnetaddr: 127.0.0.0/' /etc/ais/openais.conf; pkill aisexec; init q

# 2. Edit pg_hba.conf
sed -i "/$peeriserver/d" $pghbaconf
rcpostgresql reload
     
# 3. Edit dbinfo
peerIP=127.0.0.225
sed -i '6,9d' $iserverbindir/dbinfo
echo "NodeID=$peerNodeId">> $iserverbindir/dbinfo
echo "HostIP=$peerIP">> $iserverbindir/dbinfo
echo "DBName=msw">> $iserverbindir/dbinfo
echo "UserName=msw">> $iserverbindir/dbinfo
