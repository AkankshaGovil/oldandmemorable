#!/usr/local/bin/python
import os
import sys
import readConfig
import sut_config_generator

class GenerateLoadScripts(object):

    def __init__(self,base_dir):
        self.base_dir=base_dir    
        self.getConfigValue()
	self.sampleLocation="./sample"

    def getConfigValue(self):

        self.reg_gen_ip = readConfig.readconfigfile('REG_GEN')
	self.reg_ip_start = readConfig.readconfigfile('virtual_ip_start')
	self.reg_ip_iface = readConfig.readconfigfile('virtual_ip_iface')
	self.reg_ip_mask = readConfig.readconfigfile('virtual_ip_mask')
	self.reg_remote_ip = readConfig.readconfigfile('remote_realm_ip')


        self.serinfodict = readConfig.fetchserinfo()
        self.realminfodict = readConfig.fetchrealminfo()	
	print self.realminfodict
        self.vnetinfodict = readConfig.fetchvnetinfo()
    
    def createSerScript(self):
        """ Create the scripts for SER and copy them to the respective folders
	"""
        input = self.serinfodict 
        count=0
        for i in input: 
            count=count+1
            cmd="/bin/bash configureOpenser.sh %s %s" %(i['IP'], i['DOMAIN'])
            os.system(cmd)
            cmd="mkdir -p %s/SER-%s" %(self.base_dir, count)
            os.system(cmd)
            cmd="cp openser.cfg %s/SER-%s" %(self.base_dir, count) 
            os.system(cmd)
            cmd="cp add-nated-eps-sittest.sh %s/SER-%s" %(self.base_dir, count) 
            os.system(cmd)
            cmd="cp add-calling-eps-sittest.sh %s/SER-%s" %(self.base_dir, count) 
            os.system(cmd)
            cmd="rm add-calling-eps-sittest.sh add-nated-eps-sittest.sh openser.cfg new-reg-nated-%s.xml" %i['DOMAIN']
            os.system(cmd)
    

    def createRegScript(self, base_dir):

        finalLoc=self.base_dir+'/'+'Registration/'

	self.copySampleFiles('if-nd-sample.sh',finalLoc,'if-nd.sh')
        
	fileTobeChanged = finalLoc + 'if-nd.sh'

        cmd = ('perl -pi -e "s/VIRTUAL_IP_START/%s/g" %s' %(self.reg_ip_start,fileTobeChanged)) 
	os.system(cmd)
	print cmd
        cmd = ('perl -pi -e "s/VIRTUAL_IP_MASK/%s/g" %s' %(self.reg_ip_mask,fileTobeChanged)) 
	print cmd
	os.system(cmd)
        cmd = ('perl -pi -e "s/VIRTUAL_IFACE/%s/g" %s' %(self.reg_ip_iface,fileTobeChanged)) 
	print cmd
	os.system(cmd)

	self.copySampleFiles('new-reg-load-2Ser-sample.sh',finalLoc,'new-reg-load-2Ser.sh')

	fileTobeChanged = finalLoc + 'new-reg-load-2Ser.sh'

        cmd = ('perl -pi -e "s/VIRTUAL_IP_START/%s/g" %s' %(self.reg_ip_start,fileTobeChanged)) 
	os.system(cmd)
	print cmd
        cmd = ('perl -pi -e "s/VIRTUAL_IP_MASK/%s/g" %s' %(self.reg_ip_mask,fileTobeChanged)) 
	print cmd
	os.system(cmd)
        cmd = ('perl -pi -e "s/VIRTUAL_IFACE/%s/g" %s' %(self.reg_ip_iface,fileTobeChanged)) 
	print cmd
	os.system(cmd)
        cmd = ('perl -pi -e "s/SOURCE_IP/%s/g" %s' %(self.reg_gen_ip,fileTobeChanged)) 
	print cmd
        cmd = ('perl -pi -e "s/REMOTE_IP/%s/g" %s' %(self.reg_remote_ip,fileTobeChanged)) 
	print cmd
        
        input = self.serinfodict 
        count=0
        for i in input: 
            count=count+1
	    finalFile='new-reg-nated-%s.xml' %i['DOMAIN']
	    print finalFile
	    self.copySampleFiles('new-reg-nated-sample.xml',finalLoc,finalFile)

            cmd = 'perl -pi -e "s/\[openser_domain\]/%s/g" %s%s ' %(i['DOMAIN'],finalLoc,finalFile)
	    print cmd
            os.system(cmd)

        
        #pass
#        perl -pi -e "s/SOURCE_IP/23.23.0.88/g" new-reg-load.sh  
#        perl -pi -e "s/REMOTE_IP/24.24.0.88/g" new-reg-load.sh  
#        perl -pi -e "s/XML_FILE_SER_1/new-reg-nated-domain1/g" new-reg-load.sh  
#        perl -pi -e "s/XML_FILE_SER_2/new-reg-nated-domain2/g" new-reg-load.sh  


    def createSutScript(self,base_dir):
        filename = "%s/sut_config" %base_dir
        os.system("> %s" %filename)
        for i in self.vnetinfodict:
            sut_config_generator.writeVnet(i['IP'],i['NAME'],filename)

        for i in self.realminfodict:
            sut_config_generator.writeRealm(i['TYPE'],i['IP'],i['MASK'],i['VNET'],i['MEDPOOL'],filename)
    
        for i in self.serinfodict:
            sut_config_generator.writeSerIedge(i['NAME'],i['IP'],'realm_sipproxy',i['DOMAIN'],filename)









    def copySampleFiles(self, sampleFileName, finalLocation, finalFile):
        """Function to copy the sample files to the final directory structure"""

	cmd = "cp %s/%s %s/%s" %(self.sampleLocation,sampleFileName,finalLocation,finalFile)
	print cmd
	os.system(cmd)
           

def main(argv):

    base_dir = readConfig.readconfigfile('base_directory')
    #os.system("mkdir %s" %base_dir)



    os.system("mkdir %s/Registration" %base_dir)
    r=GenerateLoadScripts(base_dir)
    r.createCallGenScript(base_dir)
    #r.createSerScript()
    #r.createRegScript(base_dir)
    #r.createSutScript(base_dir)

main(sys.argv)

