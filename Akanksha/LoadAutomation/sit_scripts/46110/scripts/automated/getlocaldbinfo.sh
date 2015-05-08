#!/bin/bash

trap exithandler TERM INT

function exithandler()
{
        echo "Exit handler called"
        rm /tmp/$0.pid;
}

function main()
{
  echo "------------------------"
  date
				#       echo "Routes"
				#       psql -Ulocalclient -q -dmsw -c "select count(*) from callingroutes"
				#       date
				#       echo "Plans"
				#       psql -Ulocalclient -q -dmsw -c "select count(*) from callingplans"
				#       date
				#       echo "Bindings"
				#       psql -Ulocalclient -q -dmsw -c "select count(*) from cpbindings"
				#       date
				#       echo "Endpoints"
				#       psql -Ulocalclient -q -dmsw -c "select count(*) from endpoints"
				#       date
  echo "Bindings by Priority"
  psql -Ulocalclient -q -dmsw -c "select count(*) from cpbindings where priority = 300.135.0.178.135.0.178"
  date
  echo "Routes by Name"
  psql -Ulocalclient -q -dmsw -c "select count(*) from callingroutes where name like '1T-Region%'"
  date
}

if [ -e /tmp/$0.pid ];then
 
    echo "/tmp/$0.pid exists. Please kill the previous instance of the script"
    exit 0; 
else    
    touch /tmp/$0.pid;
fi

while [ 1 -eq 1 ]; do 
    main;
    sleep 40;
done

rm /tmp/$0.pid;

