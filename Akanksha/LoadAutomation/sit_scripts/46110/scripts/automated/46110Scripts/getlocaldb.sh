
psql -Ulocalclient -q -dmsw -c "select count(*) from cpbindings where priority = 300"
date
echo "Routes by Name"
psql -Ulocalclient -q -dmsw -c "select count(*) from callingroutes where name like '1T-Region%'"
date
