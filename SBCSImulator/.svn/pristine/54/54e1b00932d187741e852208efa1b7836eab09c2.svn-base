#######################################################################################
#
#   THIS FILE IS NOT USED ANY LONGER
#
# This file contains sql commands that modify the tables that were created by an old
# server,
# The SQL commands are mysql database compatible. Execute this file using:
#           mysql < nars-tables-upgrade.sql
# to modify the initial database structure.
#
#######################################################################################
#
#
# use the database
USE nars;
#
# 2. CARRIERPLANS
#
alter table carrierplans add column Port MEDIUMINT NOT NULL DEFAULT -1 AFTER Identifier;
alter table carrierplans drop primary key;
alter table carrierplans add primary key (Identifier, Port, BuySell);
#
# 4. NEWRATES
#
alter table newrates add column (effectiveStartDate DATETIME, effectiveStartZone VARCHAR(16), effectiveEndDate DATETIME, effectiveEndZone VARCHAR(16), startTimeIndex BIGINT NOT NULL DEFAULT -1, endTimeIndex BIGINT NOT NULL DEFAULT -1, connectionCharge FLOAT(10, 4) NOT NULL);
alter table newrates drop primary key;
alter table newrates add index (PlanID, DestCode);
alter table newrates add index (PlanID, DestCode, startTimeIndex, endTimeIndex);
alter table newrates add column (RecordNum BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY);
#
#
# 6. RATEDCDR
#
# 
alter table ratedcdr add column BuyConnectCharge FLOAT(10, 4) NOT NULL AFTER BuyRate;
alter table ratedcdr add column SellConnectCharge FLOAT(10, 4) NOT NULL AFTER SellRate;
alter table ratedcdr add column PDD MEDIUMINT NOT NULL AFTER Duration;
update ratedcdr, cdrs set ratedcdr.PDD = cdrs.Hold_Time where ratedcdr.uniqueid = cdrs.call_id;
alter table ratedcdr add column OrigPort SMALLINT NOT NULL DEFAULT -1 AFTER OrigGW;
alter table ratedcdr add column TermPort SMALLINT NOT NULL DEFAULT -1 AFTER TermGW;
update ratedcdr, cdrs set ratedcdr.OrigPort = cdrs.Orig_Port, ratedcdr.TermPort = cdrs.Term_Port where ratedcdr.uniqueid = cdrs.call_id;
alter table ratedcdr change CompanyID SellCompanyID VARCHAR(128);
alter table ratedcdr add column BuyCompanyID VARCHAR(128) AFTER SellCompanyID;
update ratedcdr, carrierplans set ratedcdr.buycompanyid = carrierplans.companyid where (ratedcdr.termip = carrierplans.identifier OR ratedcdr.termgw = carrierplans.identifier) AND carrierplans.buysell = 'B';
#
#
# 7. GROUPS
#
CREATE TABLE groups (GroupID VARCHAR(64) NOT NULL, Endpoint VARCHAR(128) NOT NULL,Port SMALLINT NOT NULL, PRIMARY KEY (GroupID, Endpoint, Port), KEY (GroupID)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 8. USERS
#
CREATE TABLE users (UserID VARCHAR(64) NOT NULL, GroupID VARCHAR(64) NOT NULL,Password VARCHAR(64),cap BLOB,  PRIMARY KEY (UserID, GroupID), KEY (UserID, Password)) TYPE = MyISAM PACK_KEYS = 1;
INSERT INTO users VALUES("root","admin","62b5fd9ba6a340dffbd5b5caa4bb6d09","<?xml version='1.0'?>\n<CAPABILITIES admin='true'>\n  <Report>\n  <Asr>\n      <Chromocode normal='60' questionable='58' />\n    </Asr>\n  <Business>\n      <Profit normal='5' questionable='0' />\n    </Business>\n    <Billing />\n  </Report>\n  <Alarm>\n    <Log read='false' readwrite='true' />\n    <CDR read='false' readwrite='true' />\n  </Alarm>\n</CAPABILITIES>");
#
#
# 10. Alarms
#
CREATE TABLE alarms (Id BIGINT NOT NULL AUTO_INCREMENT, ActionId  VARCHAR(64) NOT NULL,  GroupId VARCHAR(64) NOT NULL, Status BOOL NOT NULL, Type VARCHAR(64) NOT NULL,Event BLOB NOT NULL,PRIMARY KEY(id)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 11. Actions
#
CREATE TABLE actions  (Id BIGINT NOT NULL AUTO_INCREMENT, GroupId VARCHAR(64) NOT NULL, Type VARCHAR(32) NOT NULL, Field1 VARCHAR(254),Field2 VARCHAR(254),Field3 VARCHAR(254),Field4 VARCHAR(254),Field5 VARCHAR(254),Field6 VARCHAR(254), PRIMARY KEY(Id)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 12. Events
#
CREATE TABLE events (AlarmId BIGINT NOT NULL , GroupId VARCHAR(64) NOT NULL, DateTime DATETIME NOT NULL, Location VARCHAR(254),Inference VARCHAR(254), Description VARCHAR(254), KEY (DateTime)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 13. Times
#
CREATE TABLE times (RecordNum BIGINT NOT NULL AUTO_INCREMENT, Seconds TINYINT(1) NOT NULL DEFAULT -1, Minutes TINYINT(1) NOT NULL DEFAULT -1, Hour TINYINT(1) NOT NULL DEFAULT -1, Mday TINYINT(1) NOT NULL DEFAULT -1, Month TINYINT(1) NOT NULL DEFAULT -1, Year MEDIUMINT(1) NOT NULL DEFAULT -1, Wday TINYINT(1) NOT NULL DEFAULT -1, Yday MEDIUMINT(1) NOT NULL DEFAULT -1, Dst TINYINT(1) NOT NULL DEFAULT -1, PRIMARY KEY (RecordNum)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 	Insert User Name and Password into user table in mysql database 
#    
#    
#
#    
#

USE mysql;
REPLACE INTO USER VALUES('localhost','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','N','N','N','N','N','N','N','','','','',0,0,0);
REPLACE INTO USER VALUES('%','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','N','N','N','N','N','N','N','','','','',0,0,0);
FLUSH PRIVILEGES;
