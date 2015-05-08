#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def runCallGenUAS(genIP, gwIP):
    "Connect with remote shell"
    ssh = sessionManager.SSH(genIP)
    cdcmd = "cd /opt/nxgen/bin"
    ssh.assertCommand(cdcmd)
    #Run nxgen in server mode
    cmd = "nxgen -i %s -i %s -sf uas.xml -bg" %(gwIP, genIP)
    ssh.assertCommand(cmd)
    ssh.disconnect()


def runCallGenUAC(genIP, gwIP, rate):
    "Connect with remote shell"
    ssh = sessionManager.SSH(genIP)
    cdcmd = "cd /root/"
    ssh.assertCommand(cdcmd)
    #Run nxgen in client mode
    cmd = "./nexgen %s -i %s -s 222 -r %s -d 40000 -bg -trace_stat -stf /tmp/callstat.log" %(gwIP, genIP, rate)
    ssh.assertCommand(cmd)
    ssh.disconnect()

def main(argv):

    genUASIP=argv[1]
    genUACIP=argv[2]
    gatewayIP=argv[3]
    percentage=int(argv[4])
    rate = 0
    if (percentage == 100):
        rate = 30
    elif (percentage == 20):
        rate = 70
    else:
        print "No valid percentage %s" %percentage
        return 
    runCallGenUAS(genUASIP, gatewayIP)
    runCallGenUAC(genUACIP, gatewayIP, rate)

main(sys.argv) 
