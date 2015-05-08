#!/usr/local/bin/python
import sessionManager
import sys
import os


def runPriCacheUpdate(remoteIp):
    "Connect with remote shell"
    ssh = sessionManager.SSH(remoteIp)
    
    #Remotely Start the script
    cmd = "/bin/bash /tmp/46110Scripts/priCacheUpdate.sh >>/dev/null&"
    ssh.assertCommand(cmd)
    ssh.disconnect()


def main(argv):

    print " Running runPriCacheupdate.py" 
    remoteIp=argv[1]
    runPriCacheUpdate(remoteIp)


main(sys.argv)
