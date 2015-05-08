import sessionManager
import sys
import os

def runIedgeCacheScript(remoteIp, no):
    "Connect with remote shell"
    ssh = sessionManager.SSH(remoteIp)
    #Remotely Start the script
    cmd = "echo ----------Iedge update time T%s ----------- >> /root/iedgeCacheOutput" %(no)
    ssh.assertCommand(cmd)
    cmd = "/bin/bash /tmp/46110Scripts/iedge_cache.sh >> /root/iedgeCacheOutput"
    ssh.assertCommand(cmd)
    ssh.disconnect()



def main(argv):

    print "Runing runIedgeCache.py"

    remoteIp=argv[1]
    no=argv[2]
    runIedgeCacheScript(remoteIp, no)


main(sys.argv)
