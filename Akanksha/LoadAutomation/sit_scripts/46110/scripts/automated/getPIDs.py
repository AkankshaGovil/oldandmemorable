#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def getPIDs(priMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    cmd = "ps -ef | grep gis | grep -v gis_sa | grep -v grep | awk '{print $2}'>/tmp/gis_id"
    ssh.assertCommand(cmd)
    cmd = "ps -ef | grep postmaster | grep -v grep | awk '{print $2}'>/tmp/postgres_id"
    ssh.assertCommand(cmd)
    ssh.disconnect()

def main(argv):

    priMSX=argv[1]
    getPIDs(priMSX)

main(sys.argv) 
