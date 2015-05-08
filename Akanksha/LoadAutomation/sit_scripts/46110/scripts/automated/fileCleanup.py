#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def cleanUpinPrimaryMSX(priMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    #cleanUp result files
    cmd = ">/root/iedgeCacheOutput"
    ssh.assertCommand(cmd)
    cmd = ">/tmp/result"
    ssh.assertCommand(cmd)
    cmd = ">/tmp/vportStat"
    ssh.assertCommand(cmd)
    cmd = ">/opt/mem_stats"
    ssh.assertCommand(cmd)
    ssh.disconnect()

def cleanUpinSecondaryMSX(secMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(secMSX)
    #cleanUp result files
    cmd = ">/home/brenda/lcr-cron-getlocal-day1"
    ssh.assertCommand(cmd)
    cmd = ">/tmp/result"
    ssh.assertCommand(cmd)
    ssh.disconnect()


def main(argv):

    priMSX=argv[1]
    secMSX=argv[2]
    cleanUpinPrimaryMSX(priMSX)
    cleanUpinSecondaryMSX(secMSX)

main(sys.argv) 
