#This script will configure openser.cfg
# Usage: /bin/bash configureOpenser.sh <openser_ip> <openser_domain>

usage()
{
  echo "Usage: /bin/bash configureReg.sh <openser_ip> <openser_domain> "
  exit 1
}

if [ $# -ne 2 ]
then
    usage
fi
 
ipaddress=$1
domain=$2

# Configure openser.cfg file.
#mv /etc/openser/openser.cfg /etc/openser/openser-orig.cfg
#cp openser-sample.cfg openser.cfg
#cp add-calling-eps-sittest-sample.sh add-calling-eps-sittest.sh 
#cp add-nated-eps-sittest-sample.sh add-nated-eps-sittest.sh
cp new-reg-nated-sample.xml new-reg-nated-$domain.xml
cp new-reg-load2-sample.sh new-reg-load.sh

#perl -pi -e "s/\[openser_ip\]/$ipaddress/g" openser.cfg
#perl -pi -e "s/\[openser_domain\]/$domain/g" openser.cfg
#perl -pi -e "s/\[openser_domain\]/$domain/g" add-calling-eps-sittest.sh 
#perl -pi -e "s/\[openser_domain\]/$domain/g" add-nated-eps-sittest.sh 
perl -pi -e "s/SOURCE_IP/23.23.0.88/g" new-reg-load.sh  
perl -pi -e "s/REMOTE_IP/24.24.0.88/g" new-reg-load.sh  
perl -pi -e "s/XML_FILE_SER_1/new-reg-nated-domain1/g" new-reg-load.sh  
perl -pi -e "s/XML_FILE_SER_2/new-reg-nated-domain2/g" new-reg-load.sh  


