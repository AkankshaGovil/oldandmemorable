#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def tarCDR(priMSX, currdate, stage):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    cdcmd = "cd /var/cdrs"
    ssh.assertCommand(cdcmd)
    cmd = "tar -cvf %s-stage-%s-cdr.tar D%s.CDT" %(currdate, stage, currdate)
    ssh.assertCommand(cmd)
    cmd = "rm D%s.CDT" %(currdate)
    ssh.assertCommand(cmd)
    ssh.disconnect()


def main(argv):

    priMSX=argv[1]
    currdate=argv[2]
    stage=argv[3]
    
    tarCDR(priMSX, currdate, stage)

main(sys.argv) 
