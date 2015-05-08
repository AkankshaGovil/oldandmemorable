# !/bin/bash
var=1
range=75000
username=100000
while [ $var -le $range ] ; do
#openserctl add $username $username $username@syschar.com
    mysql -e "insert into subscriber (username,password,email_address,phplib_id) values ('$username','$username','$username@[openser_domain]','$username-52load')" -u root -D openser
     #mysql -e "insert into subscriber (username,password,email_address,phplib_id) values ('$username','$username','$username@as.load52test1.com','$username-52load')" -u root -pverify -D openser
    let var=var+1
    let username=username+1
    echo " Adding ep $var"
done

