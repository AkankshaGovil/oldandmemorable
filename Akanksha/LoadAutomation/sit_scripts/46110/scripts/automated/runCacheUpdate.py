#!/usr/local/bin/python
import sessionManager
import sys
import os

#To do
# make the ip address passed through the commandline to be able to run on promary and secondary msx

def runCacheUpdate(remoteIp):
    "Connect with remote shell"
    ssh = sessionManager.SSH(remoteIp)
    
    #Remotely Start the script
    cmd = "/bin/bash /tmp/46110Scripts/cacheUpdate.sh >>/dev/null&"
    #cmd = "/bin/bash /tmp/46110Scripts/cacheUpdate.sh" 
    ssh.assertCommand(cmd)
    ssh.disconnect()


def main(argv):

    print " Running runCacheupdate.py" 
    remoteIp=argv[1]
    runCacheUpdate(remoteIp, resultPath)


main(sys.argv)
