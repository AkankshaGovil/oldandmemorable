#!/bin/bash

. ./alinstall.sh

DeleteDynEps()
{
cat <<__CMDTEXT

psql -Umsw < /var/tmp/deletedyneps.pgsql 2>&1 >> /var/log/iserver.log

__CMDTEXT
}

if [ -n "$SWMF" ]; then
        echo "SWM Case" 1> /dev/null 2>&1
else
        export SWMF=0
fi

RestoreDynEps()
{
cat <<__CMDTEXT

psql -Umsw < /var/tmp/restoredyneps.pgsql 2>&1 >> /var/log/iserver.log

__CMDTEXT
}

MACHINEID=`hostname`
if [ -z "$MACHINEID" ]; then
    echo -e "\nERROR: \$MACHINEID is null, exit 1\n"
	exit 1
fi

PEERISERVER=`DbGetPeerIserver $MACHINEID | sed -e 's/^\s//g'| sed -e 's/\s$//g'`
if [ -z "$PEERISERVER" ]; then
    echo -e "\nERROR: \$PEERISERVER is null, exit 1\n"
	exit 1
fi

./CommonFunctions.sh -peeripaddr $PEERISERVER $SWMF
if [ $? -eq 0 ]; then
    echo -e "\nERROR: connectivity b/w SCM pair is down, exit 1\n"
	exit 1
fi

echo "begin transaction;" > /var/tmp/deletedyneps.pgsql
echo "DELETE FROM endpoints where serialnumber like 'dynamic-%';" >> /var/tmp/deletedyneps.pgsql
echo "SELECT transaction INTO deletedynep FROM pg_locks WHERE pid = pg_backend_pid() AND transaction IS NOT NULL LIMIT 1; end transaction; update event SET txid = (select transaction from deletedynep LIMIT 1), event_type=1; drop table deletedynep;" >> /var/tmp/deletedyneps.pgsql

echo "begin transaction;" > /var/tmp/restoredyneps.pgsql
pg_dump -Umsw --column-inserts --data-only -t endpoints | grep "dynamic-" >> /var/tmp/restoredyneps.pgsql
echo "SELECT transaction INTO restoredynep FROM pg_locks WHERE pid = pg_backend_pid() AND transaction IS NOT NULL LIMIT 1; end transaction; update event SET txid = (select transaction from restoredynep LIMIT 1), event_type=1; drop table restoredynep;" >> /var/tmp/restoredyneps.pgsql

#ensure IDs (column 1 of the table) are auto-generated
sed -i 's/(id, /(/' /var/tmp/restoredyneps.pgsql
sed -i 's/VALUES ([0-9]*, /VALUES (/' /var/tmp/restoredyneps.pgsql

#copy pgsqls to the peer MSX for execution
if [ $SWMF -eq 1 ]; then
        scp -i /var/lib/nextone/install/ssh/sshkey -o stricthostkeychecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=5 /var/tmp/deletedyneps.pgsql /var/tmp/restoredyneps.pgsql root@$PEERISERVER:/var/tmp
else
        scp /var/tmp/deletedyneps.pgsql /var/tmp/restoredyneps.pgsql root@$PEERISERVER:/var/tmp
fi

if [ $? -ne 0 ]; then
    echo -e "\nERROR: scp returned failure, exit 1\n"
	exit 1
fi

RemoteExecution $PEERISERVER DeleteDynEps
if [ $? -ne 0 ]; then
    echo -e "\nERROR: remote command execution failed, exit 1\n"
	exit 1
fi

#sleep for 5 secs
sleep 5

RemoteExecution $PEERISERVER RestoreDynEps
if [ $? -ne 0 ]; then
    echo -e "\nERROR: remote command execution failed, exit 1\n"
	exit 1
fi

#sleep again for 5 secs
sleep 5

echo -e "\nRestoration of dynamic endpoints was successful, please initiate switchover!\n"

exit 0
