#!/usr/local/bin/python

import sessionManager
import sys
import os
from time import *

def isCallSuccessful():
    """ 
    Check from Nxgen counters whether all the Calls were successful.
    Read the csv log file of Nxgen and compare the value of the Successful
    Call Cumulative counter with the proposed number of calls.   
    """
    try:
        f = open("/tmp/callstat.log", 'r')
        linelist = f.readlines()
        f.close()

        # The first line in the file would have names of the counter seperated by ;
        counternameslist = linelist[0].split(';')

        # The last line in the file would have the values of the counters at the 
        # end of the run seperated by a ;
        valuelist = linelist[len(linelist)-1].split(';')

        # Create a dictionary containing the counter name and its value
        countername_value = {}
        for i in range(0,len(counternameslist)):
            countername_value[counternameslist[i]] = valuelist[i]

        if ((int(countername_value["FailedCall(C)"])==0) and (int(countername_value["SuccessfulCall(C)"])>0)):
            return 0
        else:
            return 1
    except:
        return 2 

def copyCallStat(remoteIP):
    "Connect with remote shell"
    ssh = sessionManager.SSH(remoteIP)
    cmd = "scp /tmp/callstat.log root@10.140.254.200:/tmp"
    ssh.assertCommand(cmd)
    ssh.disconnect()

def main(argv):

    remoteIP=argv[1]
    copyCallStat(remoteIP)
    res = isCallSuccessful()
    print res
    return res

main(sys.argv) 
