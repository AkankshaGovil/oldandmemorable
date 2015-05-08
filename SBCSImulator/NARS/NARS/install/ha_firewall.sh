#! /bin/bash

sed --in-place=.old \
	-e '/^FW_DEV_INT=/s/FW_DEV_INT=.*$/FW_DEV_INT="eth1"/' \
	-e '/^FW_PROTECT_FROM_INTERNAL=/s/FW_PROTECT_FROM_INTERNAL=.*/FW_PROTECT_FROM_INTERNAL="no"/' \
	 /etc/sysconfig/SuSEfirewall2
sed --in-place=.old -e '/^FW_SERVICES_EXT_UDP=/s/FW_SERVICES_EXT_UDP="\(.*\)"$/FW_SERVICES_EXT_UDP="\1 694"/' /etc/sysconfig/SuSEfirewall2
rcSuSEfirewall2 restart
