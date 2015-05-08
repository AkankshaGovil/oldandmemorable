#*******************************************************************

#** Project: Hell Storm
#** Author:  Akanksha	
#** Date:    2006/10/09
#** 
#** Confidential and Proprietary. Copyright 2006
#**
#** Version History
#** Author 	          ChangeMade		          VersionNo.
#** Akanksha Govil	  Initial			  r1-0a-pre3-29832
#
#** Akanksha Govil        Update in the file              r1-0a-pre3-29832 
#                         for error handling.
#
#** Akanksha Govil	  Ticket 31113                    r1-0a-pre4-31113 
#                         Check if Folder exists or not
#                         Added check for the range
#                         specified in the hellrunner.cfg
#                         Code cleanup, Indentation, 
#                         Dccumentationm                         
#
#** Akanksha Govil	  Ticket 31112                    r1-0a-pre4-31112 
#                         Added code for reading
#                         variable from config file.
#			  added nxgenCheck function 
#			  moved which function from
#			  sipcalls.py
#
#** Sharat Mohan	  Ticket 29836                    r1-0a-pre4-29836
#                         Code change to read
#                         new variables from config file
#***********************************************************************/
import sys
import os.path
import pdb
# Ticket 31112
import string
import commands
from hellstormlog import *

scenarioPathData = []
path = []
sc1 = []
sc2 = []
provision = 'false'
scm_config='true'
refreshTimer = 30
pub_realm_ip = None
prv_realm_ip =  None

#Ticket 29836
pub_ep_ip = None
prv_ep_ip = None

pub_iface = None
prv_iface = None

waitTimer = 5
# Ticket 31112 - Nxgen Version variable in Config file
nxgenVersion = 0

class ConfigFile (object):
    """
    Constructor to initialise the 
    path values read from the configuration file
    """
    def __init__(self,path,folderSize,folderExec):
        self.path = path
        self.subFolderSize = folderSize
        self.subFolderExec = folderExec
    
class Paths(object):
    """
    Constructor to initialise the 
    path after they have been expanded according to
    the values specified in the configuration file
    """
    def __init__(self,path,start,end):
        self.path = path
        self.startRange = start
        self.endRange = end
        
def readConfigFile():
    """
    Function to read the configuration file
    """
        
    global provision 
    global refreshTimer 
    global waitTimer
    global pub_realm_ip
    global prv_realm_ip
   
    #Ticket 29836
    global pub_ep_ip
    global prv_ep_ip
    global pub_iface
    global prv_iface

    # Ticket 31112 - Nxgen Version variable in Config file
    global nxgenVersion
	
    flag =0
    flag2 =0
    count1 = 0 
    count2 = 0 
    count3 = 0 
    counter =0
    subFolderSize = 0
    subFolderExec = 0
    parseCount = 1 
    
    file = open("hellrunner.cfg","r")
    
    while 1 :
        line = file.readline()
        if not line:
            if not flag == 1:
                print "Master folder type not specified"
                sys.exit(1)
            if not flag2 == 1:
                print "Master folder Count not specified"
                print "Value taken to be 1"
            if val == 'Single' :
                parseCount = 1
                    
            break
        
        if line.startswith('#'):
            continue
        if line == "\n":
            continue
        a = line.strip()
        #flag to decide if provisioning has to be done
        if a.startswith('PROVISION'):
            provision = getValue('PROVISION',a)
            continue
    
        if a.startswith('SCM'):
            scm_config = getValue('SCM',a)
            continue

        if a.startswith('refreshTimer'):
            refreshTimer = getValue('refreshTimer',a)
            continue
        # sec wait time
        if a.startswith('MAXWAITTIME') :
            waitTimer = getValue('MAXWAITTIME',a)
            continue

        if a.startswith('pub_realm_ip'):
            pub_realm_ip= getValue('pub_realm_ip',a)
            continue
        if a.startswith('prv_realm_ip'):
            prv_realm_ip= getValue('prv_realm_ip',a)
            continue
        #Ticket 29836
        if a.startswith('pub_ep_ip'):
            pub_ep_ip= getValue('pub_ep_ip',a)
            continue
        if a.startswith('prv_ep_ip'):
            prv_ep_ip= getValue('prv_ep_ip',a)
            continue

        if a.startswith('pub_iface'):
            pub_iface= getValue('pub_iface',a)
	    print pub_iface
            continue
        if a.startswith('prv_iface'):
            prv_iface= getValue('prv_iface',a)
            continue

        # Ticket 31112 - Nxgen Version in Config file
        if a.startswith('nxgenVersion'):
            nxgenVersion = getValue('nxgenVersion',a)
 	    continue
				    
        if a.startswith('MasterFolderType'):
            val = getValue('MasterFolderType',a)
            flag = 1
            if not val in ('Single','Multiple'):
                print "Invalid Master Folder Type Value"
                sys.exit(1)
                
            continue
        
        if a.startswith('MasterFolderCount'):
            parseCount = (int)(getValue('MasterFolderCount',a))
            flag2 = 1 
            continue
         
        if a.startswith('MasterFolderPath'):
            path1 = getValue('MasterFolderPath',a)
            path.append(path1)
            count1 =  count1 + 1
            continue
      
        if a.startswith('SubFolderSize') :
            subFolderSize = getValue('SubFolderSize',a)
            sc1.append(subFolderSize)
            count2 =  count2 + 1
            continue
   
        if a.startswith('SubFolderForExecution'):
            subFolderExec = getValue('SubFolderForExecution',a)
            sc2.append(subFolderExec)
            count3 =  count3 + 1
            continue
                
    # Check if all the 3 options are specified for each Master folder type
    if not (count1 == count2 == count3 ) :
        print "Invalid paths or number of paths specified"
        sys.exit(1)
        
    try:
        # Initialise the ConfigFile data with the values read
        for i in range(parseCount):
            if path[i] is not None and sc1[i] is not None and sc2[i] is not None:
                scenarioPathData.append(ConfigFile(path[i],sc1[i],sc2[i]))
                counter = counter + 1
    except IndexError:
        print "Error occured while reading the configuration file"
        
    # Close the file
    file.close()
    # Return the total number of master folder paths and details read
    return counter

def getValue(parameter,line):
    """
    This function returns the value of each parameter
    after spliting from '='
    """
        
    str = line.split('=')
    return str[1].strip()
	
def getFinalPaths(dataCounter):
    """
    
    """
    listOfPaths = []
    for i in range(dataCounter):
        pathForExecution = []
        # If the path is not a directory
        # Skip and go to the next value
        if not os.path.isdir(scenarioPathData[i].path):
            print "Error::  %s - Path doesn't exist " %scenarioPathData[i].path
            continue
    
        # If a range is given for executing scenarios under subfolder
        if not scenarioPathData[i].subFolderExec == 'All' :
            
            if scenarioPathData[i].subFolderExec.find('-') is -1 :
                print "Error:: Incorrect format of subFolderExec field - %s" %scenarioPathData[i].subFolderExec
                continue
            # Split the range eg. 100-200 for '-'
            a = scenarioPathData[i].subFolderExec.split('-')
            startRange = int(a[0])
            endRange = int(a[1])
            # Ticket 31113 - Folder check fix
            if endRange < startRange :
                print "Error :: Incorrect Range specified in cfg file for \
path \"%s\"" %scenarioPathData[i].path
                continue
  
            size = int(scenarioPathData[i].subFolderSize)
            # find the starting folder in the range and
            # the last folder according to the range and the folder
            # size specified
            startFolder = findRange(int(a[0].strip()),size)
            endFolder = findRange(int((a[1]).strip()),size)

            # If both starting folder and the ending folder are same
            # add to the list the expanded scenario path and the start and the
            # end range
            if startFolder == endFolder :
                path1 = scenarioPathData[i].path + '/' + startFolder
                if os.path.isdir(path1):
                    pathForExecution.append(Paths(path1,startRange,endRange))
                
            # If both starting folder and the ending folder are different
            # for each folder under Master folder path, starting from the
            # starting folder till the end folder, add the path ,start and 
            # end for the folder to the list
            else:   
                
                tempStart = startFolder.split('-')
                tempEnd = endFolder.split('-')
            
                counter1 = int(tempStart[0])/size
                counter2 = int(tempEnd[1])/size
                count = 1
                step = counter2 - counter1
                
                while(counter1 != counter2):
                        
                    folderStart = (size * counter1) + 1
                    folderEnd = size * (counter1 + 1)
                    folder = str(folderStart) + '-' + str(folderEnd)
               	    #Increment the counter1 by 1
                    path1 = scenarioPathData[i].path + '/' + folder 
                    # if we are appending the starting folder path
                    # set start as the starting range 
                    if count == 1 :
                        start = startRange
                        end = folderEnd 
                	
                    # if we are appending the end folder path
                    # set end as the ending range 
                    elif count == step :
                       start = folderStart 
                       end = endRange
                    
                    # For all other intermediatory folder paths
                    # set end and start first scenario and the last
                    # scenario number
                    else:
                        start = folderStart 
                        end = folderEnd 
                        
                    if os.path.isdir(path1):
                        pathForExecution.append(Paths(path1,start,end))
                    else:
                        print "Error::%s - Path not Found" %path1
                    counter1 = counter1 + 1
                    count = count+1 
                    
 	# if all the scenarios in the path have to be executed.
        # List the master folder path and append each individual folder
        # in the directory along with the starting scenario number
        # and the last scenario number to the list
        elif scenarioPathData[i].subFolderExec == 'All' :
            startRange = 0
            endRange = 0
            dirlist = os.listdir(scenarioPathData[i].path)
            for name in dirlist:
                if name.find('-') is -1 :
                    continue
                a = name.split('-')
                startRange = int(a[0])
                endRange = int(a[1])
        	
                path1 = scenarioPathData[i].path + '/' + name
                if os.path.isdir(path1):
                    pathForExecution.append(Paths(path1,startRange,endRange))
        	
        listOfPaths.append(pathForExecution)
    
    return listOfPaths
         	    

def findRange(number,size):
    """
    """
    # If number is less than size
    # then the folder is the starting folder
    if number <=size :
        folder = '1-'+ str(size)
    
    # If number is exactly divisible by size
    elif (number % size) == 0:
        folder = str((number - size) + 1)+'-' + str(number)
    
    # If number is greater than size
    elif (number > size) :
        counter = number/size
        folder = str((size * counter)+1)+'-'+str(size * (counter+1))
    
    return folder

def printPath(expandedPaths):
    hellstormlog.debug("Order of execution :") 
    for i in range(len(expandedPaths)):
        a = expandedPaths[i]
        count = len(a)
        for j in range(count):
            hellstormlog.debug("    Path %s : %s    " %(j,a[j].path)) 
   

    
def configValues():
    counter = readConfigFile()
    # Ticket 31112 - Nxgen Version variable in Config file
    #nxgenCheck()
    expandedPaths = getFinalPaths(counter)
    return expandedPaths 
    
# Ticket 31112 - Nxgen Version variable in Config file
# Moved the function from sipcalls.py to parser.py    
def which (filename):
    """ 
    To get the execution path of the command to run
    """
    
    if os.path.dirname(filename) != '':
       if os.access (filename, os.X_OK):
	    return filename
    if not os.environ.has_key('PATH') or os.environ['PATH'] == '':
        p = os.defpath
    else:
        p = os.environ['PATH']
    pathlist = string.split (p, os.pathsep)
    for path in pathlist:
        f = os.path.join(path, filename)
        if os.access(f, os.X_OK):
            return f
    return None

# Ticket 31112 - Nxgen Version variable in Config file
def nxgenCheck():
    """ 
    To get the execution path of the command to run
    """
    global nxgenVersion
    path =  which('nxgen')
    if path is None:
        print "Error: Nxgen not installed on the system"
	sys.exit(1)
    command = commands.getoutput("rpm -qa | grep nxgen")
    if command < nxgenVersion:
	print "\nError: The nxgen version installed is less than required"
	print "Please upgrade to %s or higher version\n" %command
	sys.exit(1)
	
   
def main():    	
    expandedPaths = configValues()
    printPath(expandedPaths)
    count = len(expandedPaths)
    for i in range(count):
        a = expandedPaths[i]
        count = len(a)
        for j in range(count):
            print a[j].path
   
if __name__ == '__main__':
    startLogger("DEBUG")
    main()
