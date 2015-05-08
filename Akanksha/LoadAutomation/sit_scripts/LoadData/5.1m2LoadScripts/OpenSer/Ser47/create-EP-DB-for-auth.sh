# !/bin/bash
var=1
range=20000
username=500000
while [ $var -le $range ] ; do
#openserctl add $username $username $username@syschar.com
mysql -e "insert into subscriber (username,password,email_address,phplib_id) values ('$username','$username','$username@syschar.com','$username-guru')" -u root -pverify -D openser
let var=var+1
let username=username+1
done

