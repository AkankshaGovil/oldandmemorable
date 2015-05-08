#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def killVPort(priMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    ###Killing the existing instace of the script to be added
    pid = 'None'
    cmd=" ps x | grep captureVportStat | grep -v grep | awk '{print $1}'"
    pid = ssh.filter(cmd)
    if (pid != 'None'):
        cmd = "kill -9 %s" %pid
        ssh.assertCommand(cmd)
    ssh.disconnect()


def main(argv):

    priMSX=argv[1]
    killVPort(priMSX)

main(sys.argv) 
