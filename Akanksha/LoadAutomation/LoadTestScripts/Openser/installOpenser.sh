# This script will install openser on Suse 10.x machine either from a 
# rpm repository or from net.

rpmRepos='/home/abc/rpms' 

cd $rpmRepos
rpm -ivh bison-2.3-21.i586.rpm
rpm -ivh flex-2.5.33-21.i586.rpm
rpm -ivh freeradius-client-libs-1.1.5-13.i586.rpm
rpm -ivh freeradius-client-1.1.5-13.i586.rpm
rpm -ivh linux-kernel-headers-2.6.18.2-3.i586.rpm 
rpm -ivh glibc-devel-2.5-25.i586.rpm
rpm -ivh glibc-2.5-51.i586.rpm
rpm -ivh ncurses-5.5-42.i586.rpm 
rpm -ivh ncurses-devel-5.5-42.i586.rpm
rpm -ivh readline-5.1-55
rpm -ivh libxml2-2.6.26-26 
rpm -ivh mysql-shared-5.0.26-14.i586.rpm
rpm -ivh mysql-client-5.0.26-14.i586.rpm
rpm -ivh zlib-devel-1.2.3-33.i586.rpm
rpm -ivh zlib-1.2.3-33
rpm -ivh mysql-devel-5.0.26-14.i586.rpm
rpm -ivh perl-Data-ShowTable-3.3-602.i586.rpm
rpm -ivh perl-DBD-mysql-3.0008-12.i586.rpm
rpm -ivh mysql-5.0.26-14.i586.rpm
rpm -ivh openssl-0.9.8a-18.10
rpm -ivh openssl-devel-0.9.8d-17.2.i586.rpm
rpm -ivh openser-1.1.1-1.1.i586.rpm 
rpm -ivh openser-mysql-1.1.1-1.1.i586.rpm
cd -

# Check whether mysql database server is running
if [ `/etc/init.d/mysql status | awk -F":" '{print $2}'` != "running" ]
then
  /etc/init.d/mysql start
fi 


# Installing and configuring database.
mysql -u root -e update mysql.user set Password = PASSWORD('password here') where User = 'root'
mysql -u root -e flush privileges

openser_mysql.sh create

#Insert data into openser database
./add-calling-eps-sittest.sh
./add-nated-eps-sittest.sh

