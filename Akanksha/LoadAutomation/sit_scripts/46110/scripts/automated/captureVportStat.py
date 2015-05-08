#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def captureVPort(priMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    cmd = ">/tmp/vportStat"
    ssh.assertCommand(cmd)
    cmd = "/bin/bash /tmp/46110Scripts/captureVportStat.sh &"
    ssh.assertCommand(cmd)
    ssh.disconnect()


def main(argv):

    priMSX=argv[1]
    captureVPort(priMSX)

main(sys.argv) 
