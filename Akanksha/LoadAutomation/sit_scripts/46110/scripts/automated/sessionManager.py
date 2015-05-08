"""
File Name       :   sessionManager.py
File Owner      :   Nabanita Dutta 
Description     :   This files defines the classes and methods for creating, 
                    maintaining and tearing session for remote amd local shell.
 
History         : 

Modified By                Version         Date                  Description
------------------        ----------      -----               ------------------

"""

"""
Import          :
"""
					    
import os
import pexpect
import re
import signal
import string
import types 
import sys
#import tempfile
#import threading
import time
import globalVar

"""
CONSTANTS	:

"""
# Add the error list to the expected 
expList = [pexpect.EOF, pexpect.TIMEOUT]

CTRL_C = '\x03'


"""
Classes		:
"""

class SessionManagerException(Exception):
    "Generic exception for all sessions.  Accepts a string."
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return self.value
        
class SessionManagerCommandError(Exception):
    "Error sending or executing a command."
    def __repr__(self):
        return "The session prompt was not seen in the output."
    
class SessionManager(object):
    """Abstract base class for session operations.  Although the public
    methods are implemented, the session specific private methods must
    be defined by descendents of SessionManager.
    """
    
    def __init__(self, command, args, prompt, parent=None, timeout=30,context=None ):
        """
        Construct a new session by 'connecting' to a command via
        pexpect and then doing whatever negotiations are necessary to
        establish positive contact.

        Arguments: 
        command  -- command or path to command that the session will run

        args     -- command line options and arguments

        prompt   -- the prompt that precedes each user input

        parent   -- the session object that contains the spawned
                    expect process that this new session will attach to

        timeout  -- default timeout for expect() calls [30 seconds]

        """
        if parent:
            self.spawnProc = parent.spawnProc
            self.isChild = True
        else:
            self.isChild = False
	    
        self.context = context
        self.command = command

        self.args = args
        self.prompt = prompt
        self.sshTimeout = int ( globalVar.sshTimeout)
        if (timeout != 0) :
            self.sshTimeout = timeout
        
        try:
            self._connect()            
            # sleeping 2 second to give control to other processes
            # This is done to resolve EOF problem
            time.sleep(2)

            # Checking if the spawned process lives. It is observed that the
            # spawned process for gen dies because of TIME_WAIT problem 
            # If the process had died, sleep for 60 secs so that the socket
            # is closed or binding is released (BSD implementation) 
            # Try spawning the process again, this time it should get thru.

            if not self.spawnProc.isalive():
                time.sleep(60)
                self._connect()
            
        except pexpect.EOF:
            if self.spawnProc.isalive():
                raise SessionManagerException("error starting %s" % command)
            else:
                self._postConnect()
        except Exception, e:
            msg = "session error: %s" % e
            self.disconnect()
            raise e
	    
	    
    def issueCommand(self,command, timeout=3, message=None):
        """
        Send a command to the process spawned by pexpect and and do
        not wait for anything.

        This command should not be used unless really necessary
        """
        p = self.spawnProc
        p.sendline(command)
        #self._checkCommandStatus()       
    


    # Renamed assertCommand from Command
    def assertCommand(self,command, expected=None, timeout=30, message=None):

        assertTimeout = int (globalVar.assertTimeout)
        if (timeout != 0) :
            assertTimeout = timeout

        ssh = self.spawnProc
        eatPrompt = True
        if not expected:
            eatPrompt = False
            expected = self.prompt
        
        if not message:
            message = 'command "%s" timed out waiting for %s' % \
                       (command, expected)
        
        expList.append(expected)    
        ssh.sendline(command)

        res = ssh.expect(expList, assertTimeout)
        
        if eatPrompt: 
            ssh.expect(self.prompt, assertTimeout)
            if (res != expList.index(expected)):
                self._postCheck(res, message)
        #try :    
        #    if eatPrompt: 
        #        ssh.expect(self.prompt, timeout)
        #except pexpect.TIMEOUT:
        #    raise SessionManagerException(message)

        return ssh.before

    def assertOutput(self, expected=None, timeout=5, message=None):
       """
       This functionsWait for the expected output from the spawned pexpect process.
       
       This method sends nothing to the process but expects output;
       useful in cases where some event other than direct command input
       is causing the process to react.

       If expect times out or end of file is received an AssertionError will be raised
       """
       assertTimeout = int (globalVar.assertTimeout)
       if (timeout != 0) :
           assertTimeout = timeout
       p = self.spawnProc
      
       #If any expected output is specified, append it to the List    
       if not expected:
           expected = self.prompt    
       expList.append(expected) 
       
       if not message :
           message = "Expected output %s not received" %expected
       
       # Wait for the output 
       result = p.expect(expList, assertTimeout)
       # If expected is true and the output is not expected, Call the _postCheck function
       if (result != expList.index(expected)):
          self._postCheck(result, message)
       expList.remove(expected)

       
    def filter(self, subcommand, pattern=None, delim=None):
        """
        Send a command and return filtered output.
        """
        #print "filter command:%s" %subcommand
        # Clear the buffer so that the output of the previous command(s) is
        # eaten up
        clear = False
        count = 0
        # Changed the code to support delimeter other than '#'
        if (not delim):
            prompt = self.prompt
        else:
            prompt = delim
        while(clear == False):
            res = self.spawnProc.expect([prompt,pexpect.TIMEOUT],.5)
            if (res == 1):
                clear = True
        output = self._sendAndTrim(subcommand,delim)
        #self._checkCommandStatus()
        return output
	        
    def disconnect(self):
        """
        Disconnect from the session.  If we are a subsession, close
        the spawned pexpect process.  This method assumes the
        subsession has sent whatever commands necessary to end itself,
        so we expect an EOF here before the close.

        Expect the process to be closing or already closed, which
        generates an EOF.  Look # for a 2-second timeout also.

        If no spawnProc is defined, return quietly so that callers don't
        have problems when calling disconnect() more than once.
        """
        if not self.spawnProc:
            return
        
        ssh = self.spawnProc
        try:
            ssh.expect([pexpect.EOF], self.sshTimeout)
        except OSError,e:
            ssh.kill(signal.SIGKILL)
            self.cleanUp()
        except pexpect.TIMEOUT:
            ssh.kill(signal.SIGKILL)
            self.cleanUp()
        except Exception, exc: 
            ssh.kill(signal.SIGKILL)
            self.cleanUp()
        self.cleanUp()
        
    def cleanUp(self):
        """Clean up all the resource created during the session creation"""
        self.isConnected=False
        self.spawnProc=None

           
    ############################################################
    # Internal methods below - may be overridden by descendents
    ############################################################

    def _postCheck (self, result, message=None, promptCheck=False):
        """ 
        This function does the error handling for the functions:
        assertOutput, assertCommand, filter.
	
        If error is end of file or timeout then AssertionError is raised
        with the message.
	   
        Arguments:
        result : The result of the p.expect command
        message : Message to be printed if the command failed
        """
        if not message:
            message = "Execution of command failed"
        if promptCheck :
            if (result == expList.index(self.prompt)):
                # got a prompt, want to save the prompt chunk so we can use
                # it later to trim command output.  do this by sending a
                # \r and cultivating the bare prompt.
                self.spawnProc.sendline("")
                self.spawnProc.expect(self.prompt)
                self._extractPChunk(self.spawnProc.before)
                expList.remove(self.prompt)
	    
    	  # If timeout occured, raise Assertion error
        if (result == expList.index(pexpect.TIMEOUT)):
            raise AssertionError('TIME OUT : %s '%message)
    	  # If End of file received, raise Assertion error
        elif (result == expList.index(pexpect.EOF)):
            raise AssertionError('End Of file received: %s '%message)
	
    def _checkCommandStatus(self, lastCommand=False):
        """Get the status of the last command.
        """
        p = self.spawnProc
        p.sendline('echo $?')
        regex = re.compile('^[0-9]+',re.M)
        p.expect(regex, 2)
        msg = '_checkCommandStatus : Execution of command FAILED'
       	if lastCommand:
    	    msg = '_checkCommandStatus :Execution of command : "%s" FAILED' %lastCommand
        if p.after != '0' and p.after != '99':
            raise AssertionError(msg)
        
    def _connect(self):
        """
        Run the command or spawn the process that is the basis for the
        session.  If we are a parent session, then create the new
        spawned process.  If we are a child, send the command to the
        existing subprocess.

        """
        if not self.isChild:
            msg = "SessionManager._connect: failed to spawn %s, timeout is : %s" % (self.command, self.sshTimeout)
            try:
                self.spawnProc = pexpect.spawn(self.command,
                             self.args, self.sshTimeout)
                if not self.spawnProc:
                    raise SessionManagerException(msg)
                self._postConnect()
                self.isConnected = True
            except pexpect.TIMEOUT:
                raise SessionManagerException("Timeout while " + msg)
            except pexpect.EOF:
                raise SessionManagerException("SessionManager._connect :End of File condition while " + msg)
            except Exception, exc:
                raise SessionManagerException('SessionManager._connect: caught %s' % exc)
        else:
            cmdline = self.command + ' ' + string.join(self.args,' ')
            self.spawnProc.sendline(cmdline)
            self.isConnected = True
	    
	    
    def _extractPChunk(self, line):
        """ Extract the prompt from the program output.  This is for
        use with (expect) functions that determine end-of-output by
        waiting for the command prompt.  The problem is that the
        prompt (or a piece of it) is left in the output.  The
        extracted prompt chunk is used later in the trim functions.
        
        """
        chunk = string.split(line,'\n')[1]
        self.promptChunk = chunk

    def _postConnect(self):
        """ Do whatever expect operations necessary to establish
        positive contact with the command after connecting.  If
        overriding in a descendent, this method must set the
        promptChunk variable if using the default _sendAndTrim().
        """
        p = self.spawnProc
        msg = "SessionManager._postConnect: failed to get prompt"
        expList.append(self.prompt)
        match = p.expect(expList, self.sshTimeout)
        self._postCheck(match,msg,True)
    
    def _sendAndTrim(self, command, delim=None):
        """
        General-purpose method that will send the command and trim
        the prompt from the output. 
        """
        assertTimeout = int (globalVar.assertTimeout)
        p = self.spawnProc
        p.sendline(command)
        a=p.readline()
        #print a
	if (not delim):
	    prompt = self.prompt
	else:
	    prompt = delim

        expList.append(prompt) 
        
        result = p.expect(expList,assertTimeout)

        if (result != 2) :
            self._postCheck(result)
        # at this point, we have the output but also the command and
        # part of the prompt.  get rid of the prompt chunk.
        if (not delim):
	    promptChunk = self.promptChunk
	else:
	    promptChunk = delim

        output = re.sub(promptChunk, '', p.before)
        output = re.sub(command+'\r\n', '', output)
        return output

    
class SSH(SessionManager):
    """Set up an SSH session.


    Note that brackets ("[", "]") are NOT ALLOWED in the prompt string
    on the target host.  Brackets will screw up the trim functions
    because they are list operators in Python.  Beware of any other
    characters in the prompt that might confuse this class.

    The first argument should be in the format login@ip.

    The prompt MUST end with '$' or '#', followed by a space.  This is a
    typical default for most shells, except maybe the C-shell varieties,
    which are not endorsed by The Creator."""
    
    def __init__(self, args, parent=None,ctxt=None):
        if not args: args = []
        if type(args) is types.StringType:
	    # Code added for checking if the login 
	    # arguments are of the type "user@<remoteip>"
	    # if not then by default the user is taken as "root"
	    # and the login arguments become "root@<ip>

            #Added by ND
            # Commented by Akanksha
            # While loggin in to the local shell this isnt provided
            # Remove this or add better handling
            
	    #logindetails = args.split("@")
            #self.ipaddr = logindetails[1]
            args = [args]
            if (args[0].find('@') == -1):
                user = "root"
                login = user + '@' + args[0]
                args[0] = login

        self.longComand = None
        super(SSH, self).__init__("ssh", args, "[#$] ", parent,context=ctxt)
        
    def disconnect(self):
        """Send an exit to the remote shell and give it a chance to
        finish up before calling the parent disconnect, which closes
        the pexpect subprocess."""
        p = self.spawnProc
        p.sendline("exit")
        super(SSH, self).disconnect()

    def runLong(self, command):
        """Run a command that is expected to run for a long time,
        like 'tail -f'."""
        self.longCommand = command
        self.spawnProc.sendline(command)

    def stopLong(self, reject=False):
        """Stop a command started by runLongCmd.

        Returns any output generated by the command or a timeout
        string.  If reject is true, bail out after the command is
        stopped. 

        TODO  The '^C' string does not occur in terminal output on
        TODO  Linux, therefore the regex substitution will fail to find
        TODO  a match and you'll get the prompt in the output.  This can
        TODO  be fixed for Linux by doing a uname check and modifying
        TODO  the trailingJunk string accordingly.

        TODO  The output is not completely clean.  Tests have shown a
        TODO  leading space and a trailing newline.  Callers can
        TODO  strip() the output, so not a high priority.  Caveat
        TODO  emptor!
        """
        if self.longCommand:
            p = self.spawnProc
            #print 'stopLong: sending ctrl-c'
            p.send(CTRL_C)
            match = p.expect([self.prompt,
                              pexpect.TIMEOUT], 2)
            if match == 0:
		if reject: return
                trailingJunk = '\^C' + '\r\n' + self.promptChunk
                output = re.sub(self.longCommand+'\r\n', '', p.before)
                output = re.sub(trailingJunk, '', output)
                return output
            else:
                return "timed out"

    def _postConnect(self):
        """
        This function performs the error checking for the ssh specific 
        connections. 
	
        The matching of the prompt received when ssh command is executed is done against
        different pexpect error conditions.
        Exceptions are raised based on the error condition of SSH connection scenarios.
	
        """

        #timeout = 5
        p = self.spawnProc
        list = [self.prompt,"ssh:", "[Pp]assword: ", "\? ", 

	        "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 
        pexpect.EOF,pexpect.TIMEOUT]
         
        match = p.expect(list,self.sshTimeout )
        #prompt
        if (match == list.index(self.prompt)) :    
                # got a prompt, want to save the prompt chunk so we can use
                # it later to trim command output.  do this by sending a
                # \r and cultivating the bare prompt.
            p.sendline("")
            p.expect(self.prompt)
            self._extractPChunk(p.before)
	    # ssh error message
        elif (match == list.index("ssh:")): 
            # TODO: send the ssh error text in the exception
            msg = "Error occured while executing ssh command "
            raise SessionManagerException,msg
	    # passwd prompt
        elif match == 2: 
            
	    msg = "ssh command got 'Password:' prompt,"
            p.sendline("shipped!!")
	    try:
                p.expect(self.prompt,self.sshTimeout)
                self._extractPChunk(p.before)
	    except pexpect.TIMEOUT:
                print msg
                raise SessionManagerException,msg
        # connect confirmation prompt
        elif match == 3: 
            p.sendline("yes")
            p.expect(list[2])
            p.sendline("shipped!!")
	    try:
                p.expect(self.prompt,self.sshTimeout)
                self._extractPChunk(p.before)
	    except pexpect.TIMEOUT:
                msg = "ssh login confirmation problem"
                msg = msg + " Key exchange not successful "
		print msg
                raise SessionManagerException,msg

            self._extractPChunk(p.before)
	
        # Remote host identification change    
        elif match == 4:   
            msg = "Remote host identification change: check ~/.ssh/known_hosts file"
            raise SessionManagerException, msg
        # Unexpected Prompt while trying to connect    
        elif match == 5:   
            msg = "ssh got unexpected prompt, did not establish connection"
            raise SessionManagerException, msg
    
        # Timeout Error    
        elif (match == list.index(pexpect.TIMEOUT)):
            msg = 'ssh to %s timed out' % self.args
            raise SessionManagerException, msg

class LocalShell(SessionManager):
    """This class sets up a local shell session.

    The prompt MUST end with '$' or '#', followed by a space.  This is a
    typical default for most shells, except maybe the C-shell varieties,
    which are not endorsed by The Creator.
    """
    def __init__(self):
        super(LocalShell, self).__init__('bash', [], '[#$] ', None, context=None)
        
    def disconnect(self):
        """Send an exit to the remote shell and give it a chance to
        finish up before calling the parent disconnect, which closes
        the pexpect subprocess."""
        self.spawnProc.sendline("exit")
        super(LocalShell, self).disconnect()
	
    def waitForLongMessage(self, message):
        """ Waits for a message in runLong command and returns the index of the output"""
        index = self.spawnProc.expect([message, pexpect.TIMEOUT, pexpect.EOF], 65)
        return index


	
import unittest

class TestSSH(unittest.TestCase):
    def testSSHRemote(self):
        return 
	self.ip = 'root@172.16.45.25'
        s = SSH(self.ip)
        print "Connected"
        print "Testing commands"
        s.assertCommand("ifconfig")
        o = s.filter("ls -ltr")

        #print o
        s.issueCommand("ls")
        s.assertCommand("ls","# ")
        #s.assertOutput(":~ ")
        time.sleep(2)
        s.runLong("tail -f /tmp/gltest-debug.log")
        time.sleep(2)
        s.stopLong()
        s.disconnect()
        return

    def testNoUser(self):
        "Connect with local shell"
        return 
        pass
        s = LocalShell()
        s.assertCommand("mkdir abc")
        o = s.filter("ls -ltr abc")
        s.issueCommand("rm -r abc")
        print o
        s.disconnect()
    
    def testNoSshKeyUser(self):
        "Connect with local shell"
        return 
        pass
        self.ip = '172.16.45.215'
        s = SSH(self.ip)
        s.disconnect()

    def testLocalShell(self):
        "Connect with local shell"
        s = LocalShell()
	print "Test Filter command:"
	print s.filter("ls -ltr")
	print "Test Filter command:"
	#s.filter("sudo /usr/sbin/asterisk -c",delim='CLI>')
	#s.filter("stop gracefully")

    #def testSSHRemote(self):
    #    self.ip = 'root@172.16.43.129'
    #    s = SSH(self.ip)
    #    s.disconnect()
        
    #def testSSHRemote(self):
    #    self.ip = 'root@172.16.43.109'
    #    s = SSH(self.ip)
    #    s.disconnect()
        
if __name__ == '__main__':
    startLogger ('DEBUG')	
    unittest.main()
    
