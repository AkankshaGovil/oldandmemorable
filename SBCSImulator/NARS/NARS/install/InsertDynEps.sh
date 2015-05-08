#!/bin/bash

. ./CommonFunctions.sh

DbGetPeerIserver()
{
  DB_PEERISERVER=`psql -Umsw -q -t -c"select attrvalue from servercfg where attrname = 'peer-iserver' AND MachineId = '$1';" | head -1`
  RET=$?
  echo $DB_PEERISERVER | sed -e 's/^\s*//g' | sed -e 's/\s*$//g'
  return $RET
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

export SWMF=0
./CommonFunctions.sh -peeripaddr $PEERISERVER $SWMF
if [ $? -eq 0 ]; then
    echo -e "\nERROR: connectivity b/w SCM pair is down, exit 1\n"
	exit 1
fi

echo "begin transaction;" >> /var/tmp/insertdyneps.pgsql
pg_dump -Umsw --column-inserts --data-only -t endpoints | grep dynamic- >> /var/tmp/insertdyneps.pgsql
if [ $? -ne 0 ]; then
    echo -e "\nERROR: pg_dump returned failure, exit 1\n"
	exit 1
fi
echo "SELECT transaction INTO tempdynep FROM pg_locks WHERE pid = pg_backend_pid() AND transaction IS NOT NULL LIMIT 1; end transaction; update event SET txid = (select transaction from tempdynep LIMIT 1), event_type=1; drop table tempdynep;" >> /var/tmp/insertdyneps.pgsql

scp /var/tmp/insertdyneps.pgsql root@$PEERISERVER:/var/tmp
if [ $? -ne 0 ]; then
    echo -e "\nERROR: scp returned failure, exit 1\n"
	exit 1
fi

InsertDynEps()
{
cat <<__CMDTEXT

psql -Umsw < /var/tmp/insertdyneps.pgsql		

__CMDTEXT
}

RemoteExecution $PEERISERVER InsertDynEps
if [ $? -ne 0 ]; then
    echo -e "\nERROR: remote command execution failed, exit 1\n"
	exit 1
fi

exit 0
