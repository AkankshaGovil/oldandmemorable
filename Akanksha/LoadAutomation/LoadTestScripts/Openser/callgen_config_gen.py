
#!/usr/local/bin/python
import os
import sys
import readConfig

def createCallGenScript(base_dir,genExpandList):
	"""
        Assuming there are 512 endpoints to be used for calls. the number of eps per instance of nxgen is
	dependepent on number of calls gens used.
	the formula is:

	Number of Eps per instance per Ser =      Total EPs
	                                   ---------------------------
					   No. of CALLGEN x 2


	"""
	os.system("mkdir %s/CallGenConfig" %(base_dir))
	totalEps = 512
        call_gen_count = len(genExpandList)
	print call_gen_count
        #self.ser_count = readConfig.readconfigfile('SER_COUNT')
	epPerGenInstance = totalEps /(int(call_gen_count)*2)
	print epPerGenInstance
	
	senderStart = 8000
	senderEndRange = senderStart + (epPerGenInstance * 2) - 1
	receiverStart = senderEndRange + 1
	receiverEnd = receiverStart + epPerGenInstance * 2
       
        

	for i in range(int(call_gen_count)):
	    domain = genExpandList[i]['domain']
	    dirName = "%s/CallGenConfig/CallGen-%s" %(base_dir,i+1)
	    os.system("mkdir %s" %dirName)
	    # Generate the csv file for the registration of sender
            
	    
	    filename = "%s/reg_csv_sender" %(dirName)
            file1 = open(filename,"wr")
	    file1.write("SEQUENTIAL\n")
            
	    filename2 = "%s/reg_csv_recv" %(dirName)
            file2 = open(filename2,"wr")
            file2.write("SEQUENTIAL\n")
	    
	    filename3 = "%s/call_src_csv" %(dirName)
            file3 = open(filename3,"wr")
            file3.write("SEQUENTIAL\n")
             
	    print "Sender start = %s" %senderStart
            recvStart = senderStart + epPerGenInstance * 2 
	    print "Recv start = %s" %recvStart

            for count in range(epPerGenInstance):
                counter1 = senderStart + count
                str = "[authentication username=%s password=%s];%s;\n" %(counter1,counter1,counter1)
	        file1.write(str)
                
		counter2 = recvStart + count
                str = "[authentication username=%s password=%s];%s;\n" %(counter2,counter2,counter2)
	        file2.write(str)

                str2 = "[authentication username=%s password=%s];%s;%s;%s\n"%(counter1,counter1,counter1,counter2,domain)
	        file3.write(str2)

                  
            senderStart = senderStart + epPerGenInstance 





def expandCallGenDict(callgendict,serinfodict,realminfodict):
        dictVal = {}    
        genExpandList = []
	for iter in callgendict.iterkeys():
            subdict =  callgendict[iter]
            dictVal = {}    

	    for iter2 in subdict.iterkeys():
                #print iter2
		val = subdict[iter2]
		#print val
		if iter2 == 'SER' :
                    dictVal['domain'] = fetchVal(val,serinfodict,'DOMAIN')
		elif iter2.startswith('REALM_SEND'):
		    dictVal['realm_send_ip'] = fetchVal(val,realminfodict,'IP')

		elif iter2.startswith('REALM_RECV'):
		    dictVal['realm_send_rec'] = fetchVal(val,realminfodict,'IP')

		elif iter2.startswith('IP'):
		    dictVal['local_ip'] = subdict[iter2]

            genExpandList.append(dictVal)
        return genExpandList

def fetchVal(param,dictionary,subparam):
    if dictionary.has_key(param):
        subdict = dictionary[param]
	if subdict.has_key(subparam):
	    #print subdict[subparam]
	    return subdict[subparam]
    else:
        print "%s not present in the Config file, Please check the file"
	return 0

    
def main():

    base_dir = readConfig.readconfigfile('base_directory')
    callgendict =  readConfig.fetchCallGeninfo()
    serinfodict = readConfig.fetchserinfo()
    #print serinfodict
    realminfodict = readConfig.fetchrealminfo()
    genExpandList = expandCallGenDict(callgendict,serinfodict,realminfodict)
    createCallGenScript(base_dir,genExpandList)

    print genExpandList
    #print realminfodict
    #print callgendict


main()
