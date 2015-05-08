#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def setDebugLevel(priMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    cmd = "/usr/local/nextone/bin/nxconfig.pl -e debug-modcache -v 1" 
    ssh.assertCommand(cmd)
    cmd = "/usr/local/nextone/bin/nxconfig.pl -e maxcallduration -v 1800" 
    ssh.assertCommand(cmd)
    ssh.disconnect()

def main(argv):

    priMSX=argv[1]
    setDebugLevel(priMSX)

main(sys.argv) 
