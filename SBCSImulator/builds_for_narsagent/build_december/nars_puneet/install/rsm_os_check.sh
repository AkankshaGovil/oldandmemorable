#!/bin/bash

##
## GENBAND software update installer.
##
## This is a SLES9 SP4 installer script for upgrading RSMLinux.
## Will check SP4 and RSMLinux master update versions
##
## Files created or modified by installer:
##
##    /etc/RSMLinux-release
## 
######################################################################
# BEGIN
######################################################################

release="5.2.0"
patch="4"
relfile=/etc/RSMLinux-release
if [ ! -e "$relfile" ]; then
    relfile=/dev/null
fi

current_rel="`cat /etc/RSMLinux-release | grep -e "^VERSION = " | cut -d ' ' -f3`"
curren_serv_pack="`cat /etc/SuSE-release | grep -e "^PATCHLEVEL = " | cut -d '=' -f2`"

# Must be root user
uid=$(id -u)
if [ "${uid}" -ne 0 ]; then
    echo "ERROR: Only root users can execute this script."
    exit 1
fi

rpm -q kernel-smp-2.6.5-7.308 &>/dev/null
if [ $? -ne 0 ]; then
    echo "Please execute rsmlinux-sles9_sp4_update on this server before installing any RSM package."
    exit 2
elif 
     [ "$curren_serv_pack" -ne "$patch" ]; then

    echo "Please execute rsmlinux-sles9_sp4_update on this server before installing any RSM package"
    exit 2
else
	if [ "${current_rel%%-*}" != "${release}" ]; then
	    echo "Please execute rsmlinux-suse-master-update-5.2.x-x on this server before installing any RSM package"
	    exit 2;
	fi
fi

exit 0
