#This script will configure openser.cfg
# Usage: /bin/bash configureOpenser.sh <openser_ip> <openser_domain>

usage()
{
  echo "Usage: /bin/bash configureOpenser.sh <openser_ip> <openser_domain> "
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
cp sample/openser-sample.cfg openser.cfg
cp sample/add-calling-eps-sittest-sample.sh add-calling-eps-sittest.sh 
cp sample/add-nated-eps-sittest-sample.sh add-nated-eps-sittest.sh

perl -pi -e "s/\[openser_ip\]/$ipaddress/g" openser.cfg
perl -pi -e "s/\[openser_domain\]/$domain/g" openser.cfg
perl -pi -e "s/\[openser_domain\]/$domain/g" add-calling-eps-sittest.sh 
perl -pi -e "s/\[openser_domain\]/$domain/g" add-nated-eps-sittest.sh 



