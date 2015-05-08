#!/usr/local/bin/python
import os
import sys
import readConfig

def getConfigValue():
    serinfodict = readConfig.fetchserinfo()
    return serinfodict

def createScript(input, base_dir):

    count=0
    for i in input: 
        count=count+1
        cmd="/bin/bash configureOpenser.sh %s %s" %(i['IP'], i['DOMAIN'])
        os.system(cmd)
        cmd="mkdir -p %sSER-%s" %(base_dir, count)
        os.system(cmd)
        cmd="cp openser.cfg %sSER-%s" %(base_dir, count) 
        os.system(cmd)
        cmd="cp add-nated-eps-sittest.sh %sSER-%s" %(base_dir, count) 
        os.system(cmd)
        cmd="cp add-calling-eps-sittest.sh %sSER-%s" %(base_dir, count) 
        os.system(cmd)
        cmd="cp new-reg-nated.xml %sSER-%s" %(base_dir, count) 
        os.system(cmd)
        cmd="rm add-calling-eps-sittest.sh add-nated-eps-sittest.sh openser.cfg new-reg-nated.xml"
        os.system(cmd)
    

def main(argv):

    base_dir='./LoadTestSetup/'
    data=getConfigValue()
    createScript(data, base_dir)

main(sys.argv)

