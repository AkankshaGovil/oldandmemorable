import sessionManager
import sys
import os

def runIedgeCacheScript(remoteIp):
    "Connect with remote shell"
    #--------Setp 2---
    #copy the script on pri MSX
    scpcmd = "scp iedge_cache.sh root@%s:/tmp/" %remoteIp
    print scpcmd
    local.assertCommand(scpcmd)
    #--------Step 3------
    ###Killing the existing instace of the script to be added
    #--------Step 4------
    #Remotely Start the script
    cmd = "echo ----------Iedge update time T1 ----------- >> /root/iedgeCacheOutput"
    ssh.assertCommand(cmd)
    cmd = "/tmp/iedge_cache.sh >> /root/iedgeCacheOutput"
    ssh.assertCommand(cmd)
    print cmd
    #s.disconnect()

def copyScripts(localSsh,remote,remoteIp):
    scpcmd = "scp facia_firstdb root@%s:/tmp/" %remoteIp
    print scpcmd
    localSsh.assertCommand(scpcmd)
    scpcmd = "scp Endpoints.pl root@%s:/tmp/" %remoteIp
    print scpcmd
    localSsh.assertCommand(scpcmd)
    scpcmd = "scp cliSetupCommand root@%s:/tmp/" %remoteIp
    print scpcmd
    localSsh.assertCommand(scpcmd) 
    cmd = "chmod +x /tmp/cliSetupCommand"
    remote.assertCommand(cmd)



def main(argv):

    #for arg in sys.argv:

    print argv
    remoteIp=argv
    #priority=argv[2]
    #region=argv[3]
    #runIedgeCacheScript(remoteIp)
    ssh = sessionManager.SSH(remoteIp)
    local = sessionManager.LocalShell()
    copyScripts(local,ssh,remoteIp)
    #runIedgeCacheScript('172.16.44.106')


#main(sys.argv)
main('172.16.43.110')

