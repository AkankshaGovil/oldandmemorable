
vnet_iface_sender="eth2"
vnet_iface_receiver="eth3"
vnet_iface_proxy="eth4"


realm_sender="23.23.00.88"

realm_sender_mask="255.255.0.0"
medpool_sender="1"


realm_receiver="24.24.0.88"
medpool_receiver="2"
realm_receiver_mask="255.255.0.0"

realm_sipproxy="10.145.0.91"
realm_sipproxy_mask="255.255.0.0"

SER_IP_1="10.145.0.91"
SER_MASK_1="255.255.0.0"
SER_DOMAIN_1="as.load52test1.com"

SER_IP_2="10.145.0.91"
SER_MASK_2="255.255.0.0"
SER_DOMAIN_2="as.load52test1.com"

serDict={}
SerList=[]

def writeRealm(realm_type,realm_rsa,realm_mask,realm_vnet,medpool):

    cmd1 = "cli realm add realm_%s" %realm_type
    if (realm_type == "sender")or(realm_type=="receiver"):
        cmd2 = "cli realm edit realm_%s mask %s medpool %s rsa %s vnet vnet_%s" %(realm_type,realm_mask,realm_medpool,realm_rsa,realm_type)
        cmd3 = "cli realm edit realm_%s admin enable addr private emr alwayson imr alwayson sipauth all"%(realm_type)   
    elif(realm_type == "sipproxy"):
        cmd2 = "cli realm edit realm_%s mask %s rsa %s vnet vnet_%s" %(realm_type,realm_mask,realm_medpool,realm_rsa,realm_type)
        cmd3 = "cli realm edit realm_%s admin enable addr private emr alwaysoff imr alwaysoff sipauth all"%(realm_type)   


def writeVnet(vnet_iface,vnet_name):
    cmd1 = "cli vnet add %s" %vnet_name
    cmd2 = "cli vnet edit %s ifname %s gateway 0.0.0.0" %(vnet_name,vnet_iface)


def writeSerIedge(proxy_name,proxy_ip,proxy_realm,proxy_uri):
    
    cmd1 = "cli iedge add %s 0" %proxy_name
    cmd2 = "cli iedge edit %s 0 type sipproxy static %s realm %s uri %s sip enable" %(proxy_name,proxy_ip,proxy_realm,proxy_uri)
    cmd3 = "cli iedge add %s 1" %proxy_name
    cmd4 = "cli iedge edit %s 0 type sipproxy static %s realm %s uri %s sip enable" %(proxy_name,proxy_ip,proxy_realm,proxy_ip)

	

def writeNxConfig():
    pass


