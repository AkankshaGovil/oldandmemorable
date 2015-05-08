#!/usr/local/bin/python

import MySQLdb
from utility import *

class Import: 
    def __init__(self, importTable, partition, fileName, delimiter, rsmDBUser, rsmDBPassword, rsmHost="127.0.0.1"):
        self.myDB = MySQLdb.connect(host=rsmHost, port=3306, user=rsmDBUser, passwd=rsmDBPassword, db="bn")
        self.cHandler=self.myDB.cursor()
        self.fh = open(fileName, "r")
        if (importTable == "Region"):
            self.deleteRegionData()
        elif (importTable == "CustomerRate"):
            self.deleteCustomerRateData()
        elif (importTable == "CustomerRoute"):
            self.deleteCustomerRouteData()
        elif (importTable == "SupplierRate"):
            self.deleteSupplierRateData()
        elif (importTable == "SupplierRoute"):
            self.deleteSupplierRouteData()
        else:                 
            print ("There is no table %s\n", (importTable))  

    def readData(self):
 
        self.lines = self.fh.readlines()
        for line in self.lines: 
            line = line.strip(';\n')
            fields = line.split(delimiter)
            if (importTable == "Region"):
                self.insertRegionData(fields)
            elif (importTable == "CustomerRate"):
                self.insertCustomerRateData(fields)
            elif (importTable == "CustomerRoute"):
                self.insertCustomerRouteData(fields)
            elif (importTable == "SupplierRate"):
                self.insertSupplierRateData(fields)
            elif (importTable == "SupplierRoute"):
                self.insertSupplierRouteData(fields)
            else:                 
                print ("There is no table %s\n", (importTable))  

    def deleteRegionData(self): 
        self.cHandler.execute("DELETE from regions;")

    def insertRegionData(self, fields): 
        self.cHandler.execute("insert into regions(PartitionId, RegionCode, DialCode, ProfitThreshold, Description) values((select partitionid from groups where groupName = %s), %s, %s, %s, %s);",(partition, fields[0], fields[1], fields[2], fields[3]))
    def deleteCustomerRateData(self): 
        self.cHandler.execute("DELETE from rates_1 where buysell = 2;")
        self.cHandler.execute("DELETE from carriers_1 where buysell = 2;")

    def insertCustomerRateData(self, fields): 
        self.cHandler.execute("insert into carriers_1(Carrier, RegionCode, ServiceType, BuySell) values(%s, %s, %s, 2);", (fields[0], fields[1], fields[2]))
        self.cHandler.execute("insert into rates_1(CarrierId, Carrier, RegionCode, ServiceType, BuySell, Priority, ProfitThreshold, DurMin, DurIncr, Rate, Country, ConnectionCharge, EffectiveStartDate, EffectiveEndDate, PeriodId, status, Created, LastModified) values((select CarrierId from carriers_1 where Carrier = %s), %s, %s, %s, 2, %s, %s, %s, %s, %s, %s, %s, UNIX_TIMESTAMP(%s), UNIX_TIMESTAMP(%s), -1, 0, NOW(), NOW());",(fields[0], fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], fields[6], fields[7], fields[8], fields[9], changeDateFormat(fields[10]), changeDateFormat(fields[11])))
        self.myDB.commit()

    def deleteCustomerRouteData(self): 
        self.cHandler.execute("DELETE from routes_1 where buysell = 2;")

    def insertCustomerRouteData(self, fields): 
        endpoint = fields[8].split("/")
        self.cHandler.execute("insert into routes_1(CarrierId, Carrier, RegionCode, ServiceType, BuySell, ANI, StripPrefix, PrefixDigits, AddbackDigits, RatingAddback, ClusterId, EndpointId, flag, status, Created, LastModified) values((select CarrierId from carriers_1 where Carrier = %s), %s, %s, %s, 2, %s, %s, %s, %s, %s, 1, (select id from endpoints where serialnumber = %s), 1, 1, NOW(), NOW());",(fields[0], fields[0], fields[6], fields[7], fields[1], fields[2], fields[4], fields[3], fields[5], endpoint[0]))
        self.myDB.commit()

    def deleteSupplierRateData(self): 
        self.cHandler.execute("DELETE from rates_1 where buysell = 1;")
        self.cHandler.execute("DELETE from carriers_1 where buysell = 1;")

    def insertSupplierRateData(self, fields): 
        self.cHandler.execute("insert into carriers_1(Carrier, RegionCode, ServiceType, BuySell) values(%s, %s, %s, 1);",(fields[0], fields[1], fields[2]))
        self.cHandler.execute("insert into rates_1(CarrierId, Carrier, RegionCode, ServiceType, BuySell, Priority, ProfitThreshold, DurMin, DurIncr, Rate, Country, ConnectionCharge, EffectiveStartDate, EffectiveEndDate, PeriodId, status, Created, LastModified) values((select CarrierId from carriers_1 where Carrier = %s), %s, %s, %s, 1, %s, %s, %s, %s, %s, %s, %s, UNIX_TIMESTAMP(%s), UNIX_TIMESTAMP(%s), -1, 1, NOW(), NOW());",(fields[0], fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], fields[6], fields[7], fields[8], fields[9], fields[10], fields[11]))
        self.myDB.commit()

    def deleteSupplierRouteData(self): 
        self.cHandler.execute("DELETE from rates_1 where buysell = 1;")

    def insertSupplierRouteData(self, fields): 
        endpoint = fields[8].split("/")
        self.cHandler.execute("insert into routes_1(CarrierId, Carrier, RegionCode, ServiceType, BuySell, ANI, StripPrefix, PrefixDigits, AddbackDigits, RatingAddback, ClusterId, EndpointId, flag, status, Created, LastModified) values((select CarrierId from carriers_1 where Carrier = %s), %s, %s, %s, 1, %s, %s, %s, %s, %s, 1, (select id from endpoints where serialnumber = %s), 1, 1, NOW(), NOW());",(fields[0], fields[0], fields[6], fields[7], fields[1], fields[2], fields[4], fields[3], fields[5], endpoint[0]))
        self.myDB.commit()

     
if __name__ == '__main__':

    rsmDBUser = 'root'
    rsmDBPassword = 'shipped!!'
    delimiter = ';';
    partition = 'admin'

    importTable = "Region"
    fileName = "/root/46110/data/20-1/Regions.txt"
    regimp = Import(importTable, partition, fileName, delimiter, rsmDBUser, rsmDBPassword)
    regimp.readData()
    importTable = "CustomerRate"
    fileName = "/root/46110/data/20-1/Customer-Rate.txt"
    cusrateimp = Import(importTable, partition, fileName, delimiter, rsmDBUser, rsmDBPassword)
    cusrateimp.readData()
    importTable = "SupplierRate"
    fileName = "/root/46110/data/20-1/Supplier-Rate.txt"
    suprateimp = Import(importTable, partition, fileName, delimiter, rsmDBUser, rsmDBPassword)
    suprateimp.readData()
    importTable = "CustomerRoute"
    fileName = "/root/46110/data/20-1/Customer-Route.txt"
    cusrouteimp = Import(importTable, partition, fileName, delimiter, rsmDBUser, rsmDBPassword)
    cusrouteimp.readData()
    importTable = "SupplierRoute"
    fileName = "/root/46110/data/20-1/Supplier-Route.txt"
    suprouteimp = Import(importTable, partition, fileName, delimiter, rsmDBUser, rsmDBPassword)
    suprouteimp.readData()
