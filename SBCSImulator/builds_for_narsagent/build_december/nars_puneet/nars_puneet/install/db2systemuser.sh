#!/bin/bash


LOG_FILE="adduserdb2system_`date +%d-%m-%Y_%H_%M_%S`.log";
echo "Starting Restore of  DB users to Local System at  `date +%d-%m-%Y_%H_%M_%S`" | tee -a  $LOG_FILE;

JBOSS_HOME="/opt/nxtn/jboss"
MYSQL_DS=$JBOSS_HOME/server/rsm/deploy/mysql-ds.xml;
echo "Retrieving mysql server username/password from $MYSQL_DS file " >> $LOG_FILE;

if [ -f $MYSQL_DS ]; then
        user=`cat $MYSQL_DS | grep user-name| head -1 | cut -f 2 -d ">" | cut -f 1 -d "<"`;
        pass=`cat $MYSQL_DS | grep password | head -1 | cut -f 2 -d ">" | cut -f 1 -d "<"`;
else
        echo "File $MYSQL_DS  doesn't exist. Make sure the RSM is installed properly. Exiting" | tee -a $LOG_FILE; echo;
        exit 1;
fi

echo "Retrieved mysql server username/password from $MYSQL_DS file " >> $LOG_FILE;

echo "select username  from users where username not like 'root';" > tmp.sql;

echo "Reading database users from mysql database using credentials ($user/$pass) " >> $LOG_FILE;
mysql -u$user -p$pass --skip-column-names  bn < tmp.sql > result.txt;

if [ $? -eq 0 ];then
  echo "Total  users from rsm database = `wc -l result.txt` " >> $LOG_FILE;
else
  echo "Failed to read users from rsm database " | tee -a $LOG_FILE;
  exit 2;
fi

if [ ! -f "/etc/passwd" ];then
   echo "Failed to read system users. File /etc/passwd eitehr doesn't exist or not readable " | tee -a $LOG_FILE;
   exit 3;
fi

echo "Reading system users ." >> $LOG_FILE;
systemUsers=` awk -F":" '{ print $1 }' /etc/passwd`;

if [ $? -eq 0 ];then
 echo " Done reading system users ." >> $LOG_FILE;
else
  echo "Failed to read system users " | tee -a $LOG_FILE;
  exit 2;
fi


rm -rf dbusers.txt sysusers.txt
password='Genb@nd1';
encryptedPasswd=$(perl -e 'print crypt($ARGV[0], "password")' $password)

                      if [ $? -eq 0 ];then
                          echo " default password $password is encrypted successfully." >> $LOG_FILE;
                      else
                          echo "Failed to encrypt default password $password. Exiting." | tee -a  $LOG_FILE;
                          exit 4;
                      fi

cat result.txt | while read line;
                 do {
		      isSystemUser=0;
		      userName=`echo $line | cut  -f1`;
		      

		      for systemUser in $systemUsers;
		      do
			
			    if [ "$userName"  ==  "$systemUser" ];then
				echo "User $userName is  a system user" >> $LOG_FILE
				echo "$userName" >> sysusers.txt
				isSystemUser=1;
				break;
			    fi

		      done
	
		    if [ $isSystemUser -eq 0 ];then
			
			echo "User $userName is not a system user" >> $LOG_FILE;

			/usr/sbin/useradd -p $encryptedPasswd $userName;
			if [ $? -eq 0 ];then
			    echo "user $userName added to system successfully" >> $LOG_FILE
				 echo "$userName" >> dbusers.txt

			else
			    echo "Failed to add user $userName to system." | tee -a $LOG_FILE
			fi
			
		    fi
                 }
                 done;
if [  -f "dbusers.txt" ];then
echo "**********************************************************************************************"  | tee -a $LOG_FILE;
	echo "The root user must update the passwords for the following users from the RSM GUI" | tee -a $LOG_FILE;
	echo "" | tee -a $LOG_FILE;
	cat dbusers.txt | tee -a $LOG_FILE;
	echo "" |tee -a $LOG_FILE;
fi
if [  -f "sysusers.txt" ];then
	echo "**********************************************************************************************"  | tee -a $LOG_FILE;

	echo"" | tee -a $LOG_FILE
	echo "The root user needs to update the passwords for the following users from the RSM GUI if the users are not able to log in using their existing passwords" | tee -a $LOG_FILE
	echo "" | tee -a $LOG_FILE
	cat sysusers.txt | tee -a $LOG_FILE;
	echo ""  | tee -a $LOG_FILE
fi


echo "**********************************************************************************************" | tee -a $LOG_FILE
        echo "" |tee -a $LOG_FILE

rm -rf tmp.sql result.txt  dbusers.txt sysusers.txt ;
echo "Done Restoring  DB users to Local System at  `date +%d-%m-%Y_%H_%M_%S`" | tee -a  $LOG_FILE;



