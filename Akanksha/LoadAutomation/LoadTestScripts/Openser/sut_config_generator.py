#!/usr/local/bin/python

import readConfig
import sys
import os


def writeRealm(count,realm_type,realm_rsa,realm_mask,realm_vnet,realm_medpool,filename):

    cmd1 = "cli realm add realm_%s_%s" %(realm_type,count)
    if (realm_type == "sender")or(realm_type=="receiver"):
        cmd2 = "cli realm edit realm_%s_%s mask %s medpool %s rsa %s vnet vnet_%s" %(realm_type,count,realm_mask,realm_medpool,realm_rsa,realm_type)
        cmd3 = "cli realm edit realm_%s_%s admin enable addr private emr alwayson imr alwayson sipauth all"%(realm_type,count)   
    elif(realm_type == "sipproxy"):
        cmd2 = "cli realm edit realm_%s mask %s rsa %s vnet vnet_%s" %(realm_type,realm_mask,realm_rsa,realm_type)
        cmd3 = "cli realm edit realm_%s admin enable addr private emr alwaysoff imr alwaysoff sipauth all"%(realm_type)   

    file = open(filename, "a")
    file.write(cmd1+"\n")
    file.write(cmd2+"\n")
    file.write(cmd3+"\n")
    file.close()

def writeVnet(vnet_iface,vnet_name,filename):
    cmd1 = "cli vnet add %s" %vnet_name
    cmd2 = "cli vnet edit %s ifname %s gateway 0.0.0.0" %(vnet_name,vnet_iface)

    file = open(filename, "a")
    file.write(cmd1+"\n")
    file.write(cmd2+"\n")
    file.close()


def writeSerIedge(proxy_name,proxy_ip,proxy_realm,proxy_uri,filename):
    
    cmd1 = "cli iedge add %s 0" %proxy_name
    cmd2 = "cli iedge edit %s 0 type sipproxy static %s realm %s uri %s sip enable" %(proxy_name,proxy_ip,proxy_realm,proxy_uri)
    cmd3 = "cli iedge add %s 1" %proxy_name
    cmd4 = "cli iedge edit %s 1 type sipproxy static %s realm %s uri %s sip enable" %(proxy_name,proxy_ip,proxy_realm,proxy_ip)

	
    file = open(filename, "a")
    file.write(cmd1+"\n")
    file.write(cmd2+"\n")
    file.write(cmd3+"\n")
    file.write(cmd4+"\n")
    file.close()


def writeNxConfig():
    pass

def main(argv):
    
    base_dir = readConfig.readconfigfile('base_directory')
    #os.system("mkdir %s" %base_dir)

    filename = "%s/sut_config" %base_dir
    os.system("> %s" %filename)
    vnetinfodict = readConfig.fetchvnetinfo()
    for i in vnetinfodict:
        writeVnet(i['IP'],i['NAME'],filename)

    realminfodict = readConfig.fetchrealminfo()
    count = 0
    for i in realminfodict:
        count=count+1
        writeRealm(count,i['TYPE'],i['IP'],i['MASK'],i['VNET'],i['MEDPOOL'],filename)

    serinfodict = readConfig.fetchserinfo()
    for i in serinfodict:
        writeSerIedge(i['NAME'],i['IP'],'realm_sipproxy',i['DOMAIN'],filename)
        

main(sys.argv)

