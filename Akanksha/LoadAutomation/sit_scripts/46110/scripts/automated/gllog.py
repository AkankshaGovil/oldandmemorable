"""
File Name       :   gllog.py
File Owner      :   Nabanita Dutta 
Description     :   Implements the logging capability for globaltest. 
 
History         : 

Modified By                Version         Date                  Description
------------------        ----------      -----               ------------------

"""

"""
Import		: 
"""

import logging


"""
Global Variables :

"""

# The variable is bind to the instance of Logger class
gllog = logging.getLogger("gltest")


"""
Functions	:

"""

def startLogger(level='NONE'):
    """Starts the logger

    The method starts the logger and add two handlers. The handlers are then
    associated with files gltest-debug.log and gltest-error.log. It sets
    the trace level WARNING for gltest-error.log. It also sets the trace 
    level for gltest-debug.log depending upon the input to the method.

    arguments
    level: This is the trace level of the Logging.The valid values are
    DEBUG, INFO, WARNING and ERROR
    """

    if len(gllog.handlers) == 0:
        #handler responsible for dispatching error messages
        #errorLogHdlr=logging.FileHandler('/tmp/gltest-erorr.log')

        #handler responsible for dispatching debug messages
        commonLogHdlr=logging.FileHandler('/tmp/globaltest.log')

        #Format to log messages: Time, Module, Level and Message
        fmtr=logging.Formatter('%(asctime)s %(module)s %(lineno)s %(levelname)s \
%(message)s')

        #errorLogHdlr.setFormatter(fmtr)
        commonLogHdlr.setFormatter(fmtr)
        #errorLogHdlr.setLevel(logging.WARNING)

        #gllog.addHandler(errorLogHdlr)
        gllog.addHandler(commonLogHdlr)

        if level == 'NONE':
            #To be read from conf file
            gllog.setLevel(logging.DEBUG)     
        elif level in ('ERROR','WARNING','INFO','DEBUG'):
            loglevel='logging.'+level
            gllog.setLevel(eval(loglevel))
        else:
            #no valid input so get the level from conf file
            gllog.setLevel(logging.DEBUG)     
            print 'The Level specified is invalid, it should be one of ERROR,\
WARNING, INFO, DEBUG'


"""
Test code for this module. It is executed only when we run this file directly
"""
import unittest

class Loggertest(unittest.TestCase):
     
    def testInfoLogger(self):
        startLogger("INFO")
        gllog.info('Some information')
	
    def testErrorLogger(self):
        startLogger("Error")
        gllog.info('Some Error')

    def testDebugLogger(self):
        startLogger("DEBUG")
        gllog.debug('Some Debug Message')
        gllog.error('Some Error Message')

    def testInvalidLogger(self):
        startLogger("ASSDD")
        gllog.info('Some information')

if __name__ == "__main__":
    unittest.main()
