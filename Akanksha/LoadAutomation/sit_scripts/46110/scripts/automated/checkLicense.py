#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def checkLicense(priMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    cmd = "iserver all status | grep 'Total VPORTS' | awk '{print $3}'" 
    maxCalls = ssh.filter(cmd)
    maxCalls = maxCalls.strip()
    ssh.disconnect()
    if(int(maxCalls) > 2800):
       return 0
    else:
       return 1

def main(argv):

    priMSX=argv[1]
    ret = checkLicense(priMSX)
    print ret
    return ret

main(sys.argv) 
