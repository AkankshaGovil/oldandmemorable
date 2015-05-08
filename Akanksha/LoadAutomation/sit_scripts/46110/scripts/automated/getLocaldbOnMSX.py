import sessionManager
import sys
import os

def runGetLocalDBScript(ip):
    "Connect with remote shell"
    ssh = sessionManager.SSH(ip)
    #--------Setp 2---
    #copy the script on secondary MSX
    confFile = '46110Scripts/getlocaldbinfo.sh'
    cmd = "scp %s root@%s:/tmp/46110Scripts/" %(confFile,ip)
    print cmd
    os.system(cmd)
    #--------Step 3------
    ###Killing the existing instace of the script to be added
    pid = 'None'
    cmd=" ps x | grep getlocal | awk '{print $1}'"
    pid = ssh.filter(cmd)
    if (pid != 'None'):
	print pid
        cmd = "kill -9 %s" %pid
        ssh.assertCommand(cmd)
    print "Executing command"
    cmd = " nohup /bin/bash /tmp/46110Scripts/getlocaldbinfo.sh >> /home/brenda/lcr-cron-getlocal-day1 &"
    newpid = ssh.filter(cmd)
    print newpid
    #ssh.disconnect()


#-----------Step 1-----
# Write the script to a file
def changeGetLocalDBScript(priority, region):

    "Writing to getlocaldb.sh script"
    confFile = '46110Scripts/getlocaldbinfo.sh'
    cmd = "perl -pi -e 's/= *[0-9]*/= %s/g' %s" %(priority,confFile)
    os.system(cmd)
    cmd = "perl -pi -e 's/ *1T-[aA-zZ]*%%/1T-%s%%/g' %s" %(region,confFile)
    os.system(cmd)


def main(argv):

    print " Executing getLocaldbonMSX.py" 
    remoteIp=argv[1]
    priority=argv[2]
    region=argv[3]
    changeGetLocalDBScript(priority, region)
    runGetLocalDBScript(remoteIp)


main(sys.argv)
