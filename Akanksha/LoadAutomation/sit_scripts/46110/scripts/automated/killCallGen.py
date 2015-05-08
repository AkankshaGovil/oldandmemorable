#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def killCallGenUAS(genIP):
    "Connect with remote shell"
    ssh = sessionManager.SSH(genIP)
    #Kill the UAS if any instance is running
    killcmd = "pkill -9 nxgen"
    ssh.assertCommand(killcmd)
    sleep(2)
    ssh.disconnect()


def killCallGenUAC(genIP):
    "Connect with remote shell"
    ssh = sessionManager.SSH(genIP)
    #Kill the UAC if any instance is running
    killcmd = "pkill -9 nexgen"
    ssh.assertCommand(killcmd)
    sleep(2)
    ssh.disconnect()

def main(argv):

    genUASIP=argv[1]
    genUACIP=argv[2]
    killCallGenUAS(genUASIP)
    killCallGenUAC(genUACIP)

main(sys.argv) 
