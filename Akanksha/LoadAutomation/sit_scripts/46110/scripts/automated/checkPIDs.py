#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def checkPIDs(priMSX):
    "Connect with remote shell"
    ssh = sessionManager.SSH(priMSX)
    cmd = "ps -ef | grep gis | grep -v gis_sa | grep -v grep | awk '{print $2}'"
    curr_pid = ssh.filter(cmd)
    cmd = "cat /tmp/gis_id"
    init_pid = ssh.filter(cmd)
    if (curr_pid != init_pid):
       return 4
    cmd = "ps -ef | grep postmaster | grep -v grep | awk '{print $2}'"
    curr_pid = ssh.filter(cmd)
    cmd = "cat /tmp/postgres_id"
    init_pid = ssh.filter(cmd)
    if (curr_pid != init_pid):
       return 5
    ssh.disconnect()
    return 0

def main(argv):

    priMSX=argv[1]
    ret = checkPIDs(priMSX)
    print ret
    return ret

main(sys.argv) 
