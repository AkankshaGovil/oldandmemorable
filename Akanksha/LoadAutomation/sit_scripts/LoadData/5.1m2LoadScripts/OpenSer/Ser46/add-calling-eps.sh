# !/bin/bash
var=1
range=512
username=8000
while [ $var -le $range ] ; do
#openserctl add $username $username $username@syschar.com
mysql -e "insert into subscriber (username,password,email_address,phplib_id) values ('$username','$username','$username@as.syschar.com','$username-guru')" -u root -pverify -D openser
let var=var+1
let username=username+1
done

# Add two cisco endpoints for verification
mysql -e "insert into subscriber (username,password,email_address,phplib_id) values ('456','456','456@as.syschar.com','456-jmo')" -u root -pverify -D openser
mysql -e "insert into subscriber (username,password,email_address,phplib_id) values ('123','123','123@as.syschar.com','123-jmo')" -u root -pverify -D openser

