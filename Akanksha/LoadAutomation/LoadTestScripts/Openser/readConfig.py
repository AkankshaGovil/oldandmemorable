# Dictionary of dictionary
realmdictlist = {} 
callgendictlist = {}
serdictlist = {} 

def readconfigfile(parameter, returnParam=None):
    """
  This functions fetches the value of the key specified in string 'parameter' from the config file.
    """
  
    value = ''
    file = open("loadConfig","r")

    while 1 :

        line = file.readline()

        if not line:
            break

        if line.startswith('#'):
            continue

        if line == '\n':
            continue

        a = line.strip()

        if a.startswith(parameter):
            value = getvalue(a)
            param =getparam(a)
            #continue

            if (returnParam != None):
                return value,param
            else :
                return value

        continue
    file.close()

def fetchserinfo():
    """
  This function returns the ser information
    """

    value = ''
    file = open("loadConfig","r")
    readfurther = 0
    readcomplete = 0
    sercount = 0
    totsercount = 0
    while 1 :
        line = file.readline()

        if not line:

            if totsercount == 0:

	        print "Please check the config file.Realm information not complete"
            break

        if line.startswith('#'):
            continue

        if line == '\n':
            continue
 
        a = line.strip()
	
	if a.startswith('ser_id'):
            ser_id = getvalue(a)
            readfurther = 1
	    readcomplete = 0
	    sercount = sercount + 1
	    continue

        if readfurther == 1 and sercount > totsercount :

            if a.startswith('ser_ip'):
                ser_ip = getvalue(a)
		readcomplete = 1 
          
            elif a.startswith('ser_mask'):
                ser_mask = getvalue(a)
		readcomplete = 2

            elif a.startswith('ser_domain'):
                ser_domain = getvalue(a)
		readcomplete = 3

            if readcomplete == 3:
	        createSerDict(ser_id,ser_ip,ser_mask,ser_domain)
                readfurther = 0
		totsercount = sercount
		continue
	    else:
                continue
    file.close()
    return serdictlist


def createSerDict(ser_id,ser_ip,ser_mask,ser_domain):

    #sercount = readconfigfile('SER_COUNT')
    #print sercount
  
    serdict = {}
    serdict['IP'] =  ser_ip

    serdict['MASK'] =  ser_mask
    serdict['DOMAIN'] =  ser_domain

    serdictlist[ser_id] = serdict
    #print serdictlist


def fetchrealminfo():
    """
      This function returns the realm information
    """

    value = ''
    file = open("loadConfig","r")
    readfurther = 0
    readcomplete = 0
    realmcount = 0
    totrealmcount = 0
    realmtype = 0
    realm_ip = None
    realm_mask = None
    realm_medpool = None
    while 1 :
        line = file.readline()

        if not line:

            if totrealmcount == 0:

	        print "Please check the config file.Realm information not complete"
            break

        if line.startswith('#'):
            continue

        if line == '\n':
            continue
 
        a = line.strip()
	
	if a.startswith('realm_id'):
            realm_id = getvalue(a)
            readfurther = 1
	    readcomplete = 0
	    realmcount = realmcount + 1
	    print realm_id
	    continue

        if readfurther == 1 and realmcount > totrealmcount :
            if a.startswith('realm_type'):
                realmtype = getvalue(a)
		readcomplete = 1

            elif a.startswith('realm_ip'):
                realm_ip = getvalue(a)
		readcomplete = 2 
          
            elif a.startswith('realm_mask'):
                realm_mask = getvalue(a)
		readcomplete = 3

            elif a.startswith('realm_medpool'):
                realm_medpool = getvalue(a)
		readcomplete = 4

            if readcomplete == 4:
	        createRealmDict(realm_id,realmtype,realm_ip,realm_mask,realm_medpool)
                readfurther = 0
		totrealmcount = realmcount 
	        continue
	    else:
		continue

    file.close()
    return realmdictlist

def createRealmDict(realm_id,realmtype,realm_ip,realm_mask,realm_medpool):
   
    realmdict = {}

    if realmtype == 'sender':
        vnet = 'vnet_sender'
    if realmtype == 'receiver':
        vnet = 'vnet_receiver'
    if realmtype == 'sipproxy':
        vnet = 'vnet_sipproxy'

    
    realmdict['TYPE'] = realmtype
    realmdict['VNET'] = vnet 
    realmdict['IP'] = realm_ip
    realmdict['MASK'] = realm_mask
    realmdict['MEDPOOL'] = realm_medpool

    realmdictlist[realm_id] = realmdict
    #realmdictlist.append(realmdict)
    #print realmdictlist



def fetchCallGeninfo():
    """
      This function returns the realm information
    """

    value = ''
    file = open("loadConfig","r")
    flag_type = 4 
    flag_type_1 = 5
    flag_type_2 = 6 
    flag_type_3 = 7
    restart = 0 
    readfurther=0
    readcomplete = 0
    callgencount =0
    totalcallgencount = 0
    while 1 :
        line = file.readline()

        if not line:
            if totalcallgencount == 0:

	        print "Please check the config file.Call Gen information not complete"
            break

        if line.startswith('#'):
            continue

        if line == '\n':
            continue
 
        a = line.strip()
        
	if a.startswith('call_gen_id'):
            call_gen_id = getvalue(a)
            readfurther = 1
	    callgencount = callgencount + 1
	    continue

        if readfurther == 1 and callgencount > totalcallgencount:
            if a.startswith('CALL_GEN_IP'):
                callgen = getvalue(a)
                flag_type=1
		readcomplete = 1
                #continue

            elif a.startswith('ser'):
                ser_id = getvalue(a)
                flag_type_1=1
		readcomplete = 2 
                #continue
      
            elif a.startswith('realm_send'):
                realm_send_id = getvalue(a)
                flag_type_2=1
	        print "Flag type"
	        print flag_type_2
		readcomplete = 3 
                #continue

            elif a.startswith('realm_recv'):
                realm_recv_id = getvalue(a)
	        print "Flag type"
                flag_type_3=1
	        print flag_type_3
		readcomplete = 4 

	    if readcomplete == 4:
               print " All gen id %s infor read" %call_gen_id
	       totalcallgencount =  callgencount  
	       readfurther = 0
	       createCallGenDict(call_gen_id,callgen,ser_id,realm_send_id,realm_recv_id)
	       continue
            else :
	       continue
        #print flag_type
	#print flag_type_1
	#print flag_type_3
        #elif flag_type == flag_type_1== flag_type_2 == flag_type_3:
	#    print "call gen"
        #    print callgen
	#    print ser_id
        #    #print realm_ip
            #print realm_mask
	    #createRealmDict(realmtype,realm_ip,realm_mask,realm_medpool)
        #    restart = 0
	#    flag_type = 4
	#    flag_type_1 = 5
	#    continue

    file.close()
    return callgendictlist 


def createCallGenDict(call_gen_id,callgen,ser_id,realm_send_id,realm_recv_id):
   
    callgendict = {}

    
    callgendict['IP'] = callgen 
    callgendict['SER'] = ser_id 
    callgendict['REALM_SEND'] = realm_send_id 
    callgendict['REALM_RECV'] = realm_recv_id

    callgendictlist[call_gen_id] = callgendict

    #realmdictlist.append(realmdict)
    #print callgendictlist

def fetchvnetinfo():
    """
    This function returns the vnet information
    """

    vnetdictlist = []
    type = ''

    for i in range(3):
    
        vnetdict = {}

        if i == 0:
            type = 'sender'
            name = 'vnet_sender' 
        if i == 1:
            type = 'receiver'
            name = 'vnet_receiver' 
        if i == 2:
            type = 'proxy'
            name = 'vnet_sipproxy' 

        vnetdict['TYPE'] = type
        vnetdict['NAME'] = name
        vnetdict['IP'] = readconfigfile('vnet_iface_' + type)

        vnetdictlist.append(vnetdict)

    return vnetdictlist


def getvalue(line):
    """
    This function returns the value of each parameter
    after spliting from '='
    """

    str = line.split('=')
    
    #removing spaces and inverted commas from the string
    return (str[1].strip()).replace('\"','')

def getparam(line):
    str = line.split('=')
    
    #removing spaces and inverted commas from the string
    return (str[0].strip()).replace('\"','')

def main():
  reg_gen_ip = readconfigfile('REG_GEN')
  print reg_gen_ip
  serinfodict = fetchserinfo()
  print serinfodict
  realminfodict = fetchrealminfo()
  print realminfodict
  #vnetinfodict = fetchvnetinfo()
  #print vnetinfodict

  fetchCallGeninfo()


if __name__ == '__main__':
  main()
