#!/bin/sh
#
# patch.sh  - used while installing iView on solaris
#
#
DIR=${1:-.}
. $DIR/checkpatch.sh

CheckAndInstallPatches 1.3
status=$?
if [ $status -eq 2 ]; then
    echo "One or more of the patches installed require rebooting"
    echo
    echo "Installation is not yet complete, please re-run the installation"
    echo "script after the reboot to continue with the installation"
    exit 0
elif [ $status -ne 0 ]; then
    AreYouSure "Did not complete installing patches, continue?" "n"
    if [ $? -eq 0 ]; then
	exit 1
    fi
fi

# check if any packages are needed
./checkpackage.sh

# proceed to the GUI install
./install.bin
exit 0
