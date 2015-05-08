#!/usr/local/bin/python

from NexToneGenerateRoutes_services import *
from ZSI.client import NamedParamBinding as NPBinding
import sys,time

def generateRoute(deviceName, user="root", password="nextone"):

    genRouteconfig = []

    serv = nextoneImportLCRLocator()
    port = serv.getgenerateRoutePortType()

    req = generateRoutesRequest()
    generateroutereq = req.new_generateRoutesRequest()
    config = generateroutereq.new_config()
    credential = config.new_credential()
    credential.set_element_user(user)
    credential.set_element_password(password)
    credential.set_element_partition('admin')

    genRouteconfig.append(config.new_generateRouteConfig())
    genRouteconfig[0].set_element_deviceName(deviceName) 
    genRouteconfig[0].set_element_partition('admin') 
    config.set_element_credential(credential)
    config.set_element_generateRouteConfig(genRouteconfig[0])

    generateroutereq.set_element_config(config)
    generateroutereq.set_element_errorOption("stop-on-error")

    req.set_element_generateRoutesRequest(generateroutereq)
    resp = port.generateRoutes(req)

def main(argv):
    device=argv[1]
    passwd=argv[2]

    generateRoute(device, password=passwd)

main(sys.argv)
# End of script
