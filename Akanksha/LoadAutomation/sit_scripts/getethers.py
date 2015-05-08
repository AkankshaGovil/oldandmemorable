#!/usr/bin/env python
#
# Get Ethernet interface names and primary addresses
import os
import posix
import re
import sys

LINUX = 'Linux'
SOLARIS = 'SunOS'

ostype = posix.uname()[0]

def parseSolaris(text):
    import string
    ADDRESS = 'inet'
    INTERFACE = 'e1000g'
    
    t = string.join(text)
    text = t.split()
    state = INTERFACE
    output = ''
    while text != []:
        if state == INTERFACE:
            if text[0].startswith(INTERFACE):
                ifname = text[0]
                ifname = ifname.strip(':')
                output = string.join([output, ifname])
                state = ADDRESS
        if state == ADDRESS:
            if text[0] == ADDRESS:
                del text[0]
                addr = text[0]
                output = string.join([output, addr])
                print output
                state = INTERFACE
                output = ''
        del text[0]

def parseLinux(text):
    interface = re.compile('^[0-9]: eth[0-9]')
    state = 0
    output = ''
    for line in text:
        if state == 0:
            newInt = interface.match(line)
            if newInt:
                phys = newInt.group().split()[1]  # save the name
                state = 1
        else:
            l = line.split()
            if l[0].startswith('link'): continue
            if l[0] == 'inet6':
                state = 0  # done with IPv4 addrs
                continue
            print "%s %s" % (phys, l[1].replace('/24', ''))
            
# determine the OS so we can do the right ifconfig command

if ostype == SOLARIS:
    ipcmd = 'ifconfig -a'
elif ostype == LINUX:
    ipcmd = 'ip addr show'
else:
    print "%s: unknown OS: %s" % (sys.argv[0], ostype)
    sys.exit(1)

# get the interface data

tempfile = '/tmp/if'
os.system("%s > %s" % (ipcmd, tempfile))
f = open(tempfile)
text = f.readlines()
f.close()

# parse it and print each interface

if ostype == SOLARIS:
    parseSolaris(text)
else:
    parseLinux(text)
