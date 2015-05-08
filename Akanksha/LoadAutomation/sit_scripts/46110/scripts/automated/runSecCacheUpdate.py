#!/usr/local/bin/python
import sessionManager
import sys
import os

#To do
# make the ip address passed through the commandline to be able to run on promary and secondary msx

def runSecCacheUpdate(remoteIp):
    "Connect with remote shell"
    ssh = sessionManager.SSH(remoteIp)
    
    #Remotely Start the script
    cmd = "/bin/bash /tmp/46110Scripts/secCacheUpdate.sh" 
    ssh.assertCommand(cmd)
    ssh.disconnect()


def main(argv):

    print " Running runSecCacheupdate.py" 
    remoteIp=argv[1]
    runSecCacheUpdate(remoteIp)


main(sys.argv)
