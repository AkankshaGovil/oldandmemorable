#######################################################################################
#
# This file contains the table schemas used in NARS and the SQL commands to create them
# The SQL commands are mysql database compatible. Execute this file using:
#           mysql < nars-tables.sql
# to create the initial database structure.
#
# Use MyISAM table type for tables with frequent SELECTs than UPDATE/INSERTs
# Use InnoDB table type for tables with frequent UPDATE/INSERTs
#
#######################################################################################
#
#
# create the database
DROP DATABASE IF EXISTS %DBNAME%;
CREATE DATABASE %DBNAME%;
USE %DBNAME%;
#
#
# 1. CARRIERS
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       CarrierID               VARCHAR(32)             NOT NULL        KEY2
#       CarrierName             VARCHAR(64)             NOT NULL
#       Company                 VARCHAR(64)             NOT NULL
#       Cycle                   VARCHAR(16)             NOT NULL
#       LastBillDate            DATETIME                NOT NULL
#
#   Table Type: MyISAM
#
CREATE TABLE carriers (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  CarrierID VARCHAR(32) NOT NULL,
  CarrierName VARCHAR(64) NOT NULL,
  Company VARCHAR(64) NOT NULL,
  Cycle VARCHAR(16) NOT NULL,
  LastBillDate DATETIME NOT NULL,
  PRIMARY KEY (RecordNum),
  UNIQUE KEY CarrierId (CarrierId)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created carriers table";
#
#
# 2. CARRIERPLANS
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       Identifier              VARCHAR(64)             NOT NULL        KEY2
#       Port                    MEDIUMINT               NOT NULL        KEY2
#       BuySell                 CHAR                    NOT NULL        KEY2
#       CarrierID               VARCHAR(32)             NOT NULL        KEY3
#       RouteGroupID            VARCHAR(32)             NOT NULL        KEY4
#       PlanID                  VARCHAR(32)             NOT NULL        KEY5
#       CompanyID               VARCHAR(32)             NOT NULL
#       Description             VARCHAR(64)             NOT NULL
#       PrefixDigits            MEDIUMINT               NOT NULL
#       AddbackDigits           VARCHAR(16)             NOT NULL
#
#   Table Type: MyISAM
#
CREATE TABLE carrierplans (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  Identifier VARCHAR(64) NOT NULL,
  Port MEDIUMINT NOT NULL default '-1',
  BuySell CHAR NOT NULL,
  CarrierID VARCHAR(32) NOT NULL,
  RouteGroupID VARCHAR(32) NOT NULL,
  PlanID VARCHAR(32) NOT NULL,
  CompanyID VARCHAR(32) NOT NULL default '',
  Description VARCHAR(64) NOT NULL default '',
  PrefixDigits MEDIUMINT NOT NULL default '0',
  AddbackDigits VARCHAR(16) NOT NULL default '',
  PRIMARY KEY (RecordNum),
  UNIQUE KEY Id_Port_Flag (Identifier, Port, BuySell),
  KEY Carrier (CarrierID),
  KEY RouteGroup (RouteGroupId),
  KEY Plan (PlanID)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created carrierplans table";
#
#
# 3. REGIONS
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       RegionCode              VARCHAR(32)             NOT NULL        KEY2
#       DialCode                VARCHAR(64)             NOT NULL        KEY2, KEY3
#       Description             VARCHAR(64)             NOT NULL
#
#   Table Type: MyISAM
#
CREATE TABLE regions (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  RegionCode VARCHAR(32) NOT NULL,
  DialCode VARCHAR(64) NOT NULL,
  Description VARCHAR(64) NOT NULL default '',
  PRIMARY KEY (RecordNum),
  UNIQUE KEY Region_Dial (RegionCode, DialCode),
  KEY Dial (DialCode)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created regions table";
#
#
# 4. ROUTES    
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       RouteGroupID            VARCHAR(32)             NOT NULL        KEY2
#       RegionCode              VARCHAR(32)             NOT NULL        KEY2
#       CostCode                VARCHAR(32)             NOT NULL        KEY3
#       Description             VARCHAR(64)             NOT NULL
#
#   Table Type: MyISAM
#
CREATE TABLE routes (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  RouteGroupID VARCHAR(32) NOT NULL,
  RegionCode VARCHAR(32) NOT NULL,
  CostCode VARCHAR(32) NOT NULL,
  Description VARCHAR(64) NOT NULL default '',
  PRIMARY KEY (RecordNum),
  UNIQUE KEY Route_Region (RouteGroupID, RegionCode),
  KEY CostCode (CostCode)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created routes table";
#
#
# 4. NEWRATES
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       PlanID                  VARCHAR(32)             NOT NULL        KEY2
#       CostCode                VARCHAR(32)             NOT NULL        KEY2
#       DurMin                  MEDIUMINT               NOT NULL
#       DurIncr                 MEDIUMINT               NOT NULL
#       Rate                    FLOAT(10,4)             NOT NULL
#       Country                 VARCHAR(64)             NOT NULL
#       effectiveStartDate      DATETIME
#       effectiveStartZone      VARCHAR(16)
#       effectiveEndDate        DATETIME
#       effectiveEndZone        VARCHAR(16)
#       startTimeIndex          BIGINT                  NOT NULL        KEY2
#       endTimeIndex            BIGINT                  NOT NULL        KEY2
#       connectionCharge        FLOAT(10, 4)
#
#   Table Type: MyISAM
#
CREATE TABLE newrates (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  PlanID VARCHAR(32) NOT NULL,
  CostCode VARCHAR(32) NOT NULL,
  DurMin MEDIUMINT NOT NULL,
  DurIncr MEDIUMINT NOT NULL,
  Rate FLOAT(10, 4) NOT NULL,
  Country VARCHAR(64) NOT NULL default '',
  effectiveStartDate DATETIME,
  effectiveStartZone VARCHAR(16),
  effectiveEndDate DATETIME,
  effectiveEndZone VARCHAR(16),
  startTimeIndex BIGINT NOT NULL default '-1',
  endTimeIndex BIGINT NOT NULL default '-1',
  connectionCharge FLOAT(10, 4) NOT NULL default '0',
  PRIMARY KEY (RecordNum),
  KEY Plan_Cost_Time (PlanID, CostCode, startTimeIndex, endTimeIndex)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created newrates table";
#
#
# 5. CDRS   (~1282 bytes)
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       Src_File                VARCHAR(64)             NOT NULL        KEY3
#       Src_Line                INTEGER                 NOT NULL        KEY3
#       MSW_ID                  VARCHAR(64)             NOT NULL
#       Status                  VARCHAR(64)             NOT NULL        KEY9
#       Status_Desc             VARCHAR(96)             NOT NULL
#       Last_Modified           DATETIME                NOT NULL
#       Processed               SMALLINT                NOT NULL        KEY4, KEY5, KEY6
#       Date_Time               DATETIME                NOT NULL
#       Date_Time_Int           INTEGER                 NOT NULL	KEY15
#       Duration                INTEGER                 NOT NULL
#       Orig_IP                 VARCHAR(16)             NOT NULL        KEY5
#       Source_Q931_Port        MEDIUMINT               NOT NULL
#       Term_IP                 VARCHAR(16)             NOT NULL        KEY5, KEY8
#       User_ID                 VARCHAR(32)
#       Call_E164               VARCHAR(64)             NOT NULL        KEY12
#       Call_DTMF               VARCHAR(64)             NOT NULL        KEY10
#       Call_Type               VARCHAR(4)              NOT NULL
#       Disc_Code               VARCHAR(2)              NOT NULL        KEY4, KEY5, KEY6
#       Err_Type                MEDIUMINT
#       Err_Desc                VARCHAR(96)		NOT NULL	KEY14
#       ANI                     VARCHAR(64)
#       Seq_Num                 INTEGER
#       Call_ID                 VARCHAR(128)            NOT NULL        KEY2
#       Hold_Time               MEDIUMINT               NOT NULL
#       Orig_GW                 VARCHAR(64)             NOT NULL        KEY4
#       Orig_Port               SMALLINT                NOT NULL        KEY4, KEY5
#       Term_GW                 VARCHAR(64)             NOT NULL        KEY4, KEY7, KEY8
#       Term_Port               SMALLINT                NOT NULL        KEY4, KEY5, KEY7
#       ISDN_Code               MEDIUMINT               NOT NULL
#       Last_Call_Number        VARCHAR(64)             NOT NULL        KEY11
#       Err2_Type               MEDIUMINT
#       Err2_Desc               VARCHAR(96)
#       Last_Event              VARCHAR(96)
#       New_ANI                 VARCHAR(64)             NOT NULL
#       Region_Code             VARCHAR(32)             NOT NULL        KEY13
#
#    Table Type: InnoDB
#
CREATE TABLE cdrs (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  Src_File VARCHAR(64) NOT NULL default '',
  Src_Line INTEGER NOT NULL default '0',
  MSW_ID VARCHAR(64) NOT NULL default '',
  Status VARCHAR(64) NOT NULL default '',
  Status_Desc VARCHAR(96) NOT NULL default '',
  Last_Modified DATETIME NOT NULL default '0000-00-00 00:00:00',
  Processed SMALLINT NOT NULL default '0',
  Date_Time DATETIME NOT NULL default '0000-00-00 00:00:00',
  Date_Time_Int INTEGER NOT NULL default '0',
  Duration INTEGER NOT NULL default '0',
  Orig_IP VARCHAR(16) NOT NULL default '',
  Source_Q931_Port MEDIUMINT NOT NULL default '0',
  Term_IP VARCHAR(16) NOT NULL default '',
  User_ID VARCHAR(32) default NULL,
  Call_E164 VARCHAR(64) NOT NULL default '',
  Call_DTMF VARCHAR(64) NOT NULL default '',
  Call_Type VARCHAR(4) NOT NULL default '',
  Disc_Code VARCHAR(2) NOT NULL default '',
  Err_Type MEDIUMINT default NULL,
  Err_Desc VARCHAR(96) NOT NULL default '',
  ANI VARCHAR(64) default NULL,
  Seq_Num INTEGER default NULL,
  Call_ID VARCHAR(128) NOT NULL default '',
  Hold_Time MEDIUMINT NOT NULL default '0',
  Orig_GW VARCHAR(64) NOT NULL default '',
  Orig_Port SMALLINT NOT NULL default '0',
  Term_GW VARCHAR(64) NOT NULL default '',
  Term_Port SMALLINT NOT NULL default '0',
  ISDN_Code MEDIUMINT NOT NULL default '0',
  Last_Call_Number VARCHAR(64) NOT NULL default '',
  Err2_Type MEDIUMINT default NULL,
  Err2_Desc VARCHAR(96) default NULL,
  Last_Event VARCHAR(96) default NULL,
  New_ANI VARCHAR(64) NOT NULL default '',
  Region_Code VARCHAR(32) NOT NULL default '',
  PRIMARY KEY (RecordNum),
  UNIQUE KEY Call_ID (Call_ID),
  KEY Src_File (Src_File, Src_Line),
  KEY Orig_GW_Combo (Orig_GW, Orig_Port, Date_Time, Term_GW, Term_Port, Disc_Code),
  KEY Orig_IP_Combo (Orig_IP, Orig_Port, Date_Time, Term_IP, Term_Port, Disc_Code),
  KEY Date_Time_Disc (Date_Time, Disc_Code),
  KEY Term_Gw_Port (Term_GW, Term_Port),
  KEY Term_IP_Port (Term_IP,Term_Port),
  KEY Status (Status),
  KEY At_Src (Call_DTMF),
  KEY After_Srccp (Last_Call_Number),
  KEY At_Dest (Call_E164),
  KEY Region_Code (Region_Code),
  KEY Err_Desc (Err_desc),
  KEY Date_Time_Int (Date_Time_Int)
) TYPE=InnoDB PACK_KEYS=1;
select "" as "Created cdrs table";
#
# 6. RATEDCDR  (~1158 bytes)
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       Created                 DATETIME                NOT NULL
#       SrcFile                 VARCHAR(64)             NOT NULL        KEY16
#       SrcLine                 INTEGER                 NOT NULL        KEY16
#       Status                  VARCHAR(64)             NOT NULL
#       BillableFlag            CHAR(1)                 NOT NULL        KEY3, KEY4, KEY5
#       UniqueID                VARCHAR(128)            NOT NULL        KEY2
#       Duration                INTEGER                 NOT NULL
#       PDD                     MEDIUMINT               NOT NULL
#       DialedNum               VARCHAR(64)             NOT NULL        KEY17
#       ManipDialed             VARCHAR(64)             NOT NULL        KEY18
#       RegionCode              VARCHAR(32)             NOT NULL        KEY19
#       CallType                VARCHAR(4)              NOT NULL
#       DisconnectReason        VARCHAR(2)              NOT NULL
#       DateTime                DATETIME                NOT NULL        KEY3, KEY4, KEY5
#       OrigDesc                VARCHAR(64)             NOT NULL        KEY8
#       OrigIP                  VARCHAR(16)             NOT NULL        KEY4
#       OrigGW                  VARCHAR(64)             NOT NULL        KEY3
#       OrigPort                SMALLINT                NOT NULL        KEY3, KEY4
#       OrigCountry             VARCHAR(64)             NOT NULL        KEY9
#       DestDesc                VARCHAR(64)             NOT NULL        KEY6
#       DestIP                  VARCHAR(16)             NOT NULL        KEY4, KEY15
#       DestGW                  VARCHAR(64)             NOT NULL        KEY3, KEY14
#       DestPort                SMALLINT                NOT NULL        KEY3, KEY4, KEY14, KEY15
#       DestCountry             VARCHAR(64)             NOT NULL        KEY7
#       BuyCompanyID            VARCHAR(32)
#       BuyID                   VARCHAR(32)             NOT NULL        KEY11
#       BuyRate                 FLOAT(10, 4)            NOT NULL
#       BuyConnectCharge        FLOAT(10, 4)            NOT NULL
#       BuyRoundedSec           INTEGER                 NOT NULL
#       BuyPrice                FLOAT(10, 4)            NOT NULL
#       BuyPlanID               VARCHAR(32)             NOT NULL        KEY13
#       BuyRouteGroupID         VARCHAR(32)             NOT NULL
#       SellCompanyID           VARCHAR(32)
#       SellID                  VARCHAR(32)             NOT NULL        KEY10
#       SellRate                FLOAT(10, 4)            NOT NULL
#       SellConnectCharge       FLOAT(10, 4)            NOT NULL
#       SellRoundedSec          INTEGER                 NOT NULL
#       SellPrice               FLOAT(10, 4)            NOT NULL
#       SellPlanID              VARCHAR(32)             NOT NULL        KEY12
#       SellRouteGroupID        VARCHAR(32)             NOT NULL
#
#    Table Type: InnoDB
#
DROP TABLE IF EXISTS ratedcdr;
CREATE TABLE ratedcdr (
  RecordNum BIGINT NOT NULL auto_increment,
  Created DATETIME NOT NULL,
  SrcFile VARCHAR(64) NOT NULL,
  SrcLine INTEGER NOT NULL,
  Status VARCHAR(64) NOT NULL default '',
  BillableFlag CHAR(1) NOT NULL,
  UniqueID VARCHAR(128) NOT NULL,
  Duration INTEGER NOT NULL,
  PDD MEDIUMINT NOT NULL,
  DialedNum VARCHAR(64) NOT NULL,
  ManipDialed VARCHAR(64) NOT NULL,
  RegionCode VARCHAR(32) NOT NULL,
  CallType VARCHAR(4) NOT NULL,
  DisconnectReason VARCHAR(2) NOT NULL,
  DateTime DATETIME NOT NULL,
  OrigDesc VARCHAR(64),
  OrigIP VARCHAR(16) NOT NULL default '',
  OrigGW VARCHAR(64) NOT NULL default '',
  OrigPort SMALLINT NOT NULL default '-1',
  OrigCountry VARCHAR(64) default NULL,
  DestDesc VARCHAR(64) default NULL,
  DestIP VARCHAR(16) NOT NULL default '',
  DestGW VARCHAR(64) NOT NULL default '',
  DestPort SMALLINT NOT NULL default '-1',
  DestCountry VARCHAR(64) NOT NULL default '',
  BuyCompanyID VARCHAR(32),
  BuyID VARCHAR(32) NOT NULL default '',
  BuyRate FLOAT(10,4) NOT NULL default '0.0000',
  BuyConnectCharge FLOAT(10,4) NOT NULL default '0.0000',
  BuyRoundedSec INTEGER NOT NULL default '0',
  BuyPrice FLOAT(10,4) NOT NULL default '0.0000',
  BuyPlanID VARCHAR(32) NOT NULL default '',
  BuyRouteGroupID VARCHAR(32) NOT NULL default '',
  SellCompanyID VARCHAR(32),
  SellID VARCHAR(32) NOT NULL default '',
  SellRate FLOAT(10,4) NOT NULL default '0.0000',
  SellConnectCharge FLOAT(10,4) NOT NULL default '0.0000',
  SellRoundedSec INTEGER NOT NULL default '0',
  SellPrice FLOAT(10,4) NOT NULL default '0.0000',
  SellPlanID VARCHAR(32) NOT NULL default '',
  SellRouteGroupID VARCHAR(32) NOT NULL default '',
  PRIMARY KEY (RecordNum),
  UNIQUE KEY UniqueID (UniqueID),
  KEY OrigGW_Combo (OrigGW, OrigPort, DateTime, DestGW, DestPort, BillableFlag),
  KEY OrigIP_Combo (OrigIP, OrigPort, DateTime, DestIP, DestPort, BillableFlag),
  KEY DateTime_Bill (DateTime, BillableFlag),
  KEY DestDesc (DestDesc),
  KEY DestCountry (DestCountry),
  KEY OrigDesc (OrigDesc),
  KEY OrigCountry (OrigCountry),
  KEY SellID (SellID),
  KEY BuyID (BuyID),
  KEY SellPlanID (SellPlanID),
  KEY BuyPlanID (BuyPlanID),
  KEY DestGW_Port (DestGW, DestPort),
  KEY DestIP_Port (DestIP, DestPort),
  KEY SrcFile (SrcFile,SrcLine),
  KEY DialedNum (DialedNum),
  KEY ManipDialed (ManipDialed),
  KEY RegionCode (RegionCode)
) TYPE=InnoDB PACK_KEYS=1;
select "" as "Created ratedcdr table";
#
#
# 7. GROUPS
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       GroupID                 VARCHAR(32)             NOT NULL        KEY2, KEY3
#       Endpoint                VARCHAR(64)             NOT NULL        KEY2
#       Port                    SMALLINT                NOT NULL        KEY2
#
#    Table Type: MyISAM
#
CREATE TABLE groups (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  GroupID VARCHAR(32) NOT NULL,
  Endpoint VARCHAR(64) NOT NULL,
  Port SMALLINT NOT NULL,
  PRIMARY KEY (RecordNum),
  UNIQUE KEY Group_Ep_Port (GroupID, Endpoint, Port),
  KEY (GroupID)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created groups table";
#
#
# 8. USERS
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       UserID                  VARCHAR(32)             NOT NULL        KEY2, KEY3
#       GroupID                 VARCHAR(32)             NOT NULL        KEY2
#       Password                VARCHAR(32)             NOT NULL        KEY3
#       cap                     BLOB                    NOT NULL
#
#    Table Type: MyISAM
#
CREATE TABLE users (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  UserID VARCHAR(32) NOT NULL,
  GroupID VARCHAR(32) NOT NULL,
  Password VARCHAR(32),
  cap BLOB,
  PRIMARY KEY (RecordNum),
  UNIQUE KEY User_Group (UserID, GroupID),
  KEY (UserID, Password)
) TYPE = MyISAM PACK_KEYS = 1;
INSERT INTO users (UserID, GroupID, Password, cap) VALUES("root","admin","62b5fd9ba6a340dffbd5b5caa4bb6d09","<?xml version='1.0'?>\n<CAPABILITIES admin='true'>\n  <Report>\n  <Asr>\n      <Chromocode normal='60' questionable='58' />\n    </Asr>\n  <Business>\n      <Profit normal='5' questionable='0' />\n    </Business>\n    <Billing />\n  </Report>\n  <Alarm>\n    <Log read='false' readwrite='true' />\n    <CDR read='false' readwrite='true' />\n  </Alarm>\n</CAPABILITIES>");
select "" as "Created users table";
#
#
# 9. LICENSE
#       filename                VARCHAR(80)             NOT NULL        KEY1
#       file                    BLOB
#
#    Table Type: MyISAM
#
CREATE TABLE license (
  filename VARCHAR(80) NOT NULL,
  file BLOB,
  PRIMARY KEY (filename)
) TYPE = MyISAM PACK_KEYS = 1;
INSERT INTO license (filename, file) VALUES ('NARS.lc', '<LICENSE/>');
select "" as "Created license table";
#
#
# 10. Alarms
#       Id                BIGINT                NOT NULL        KEY1
#	ActionId	  VARCHAR(64)           NOT NULL
#	GroupId	    	  VARCHAR(32)           NOT NULL
#	Status  	  TINYINT(1)	        NOT NULL
#       Type              VARCHAR(32)           NOT NULL
#       Event             BLOB  
#
#    Table Type: MyISAM
#
CREATE TABLE alarms (
  Id BIGINT NOT NULL AUTO_INCREMENT,
  ActionId  VARCHAR(64) NOT NULL,
  GroupId VARCHAR(32) NOT NULL,
  Status TINYINT(1) NOT NULL,
  Type VARCHAR(32) NOT NULL,
  Event BLOB NOT NULL,
  PRIMARY KEY (Id)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created alarms table";
#
#
# 11. Actions
#       Id                      BIGINT               NOT NULL        KEY1
#       GroupId			VARCHAR(32)	     NOT NULL   
#	Type    		VARCHAR(32)	     NOT NULL   
#	Field1    		VARCHAR(254)	     
#	Field2    		VARCHAR(254)	     
#	Field3    		VARCHAR(254)	     
#	Field4    		VARCHAR(254)	     
#       Field5    		VARCHAR(254)	     
#       Field6    		VARCHAR(254)	     
#
#    Table Type: MyISAM
#
CREATE TABLE actions  (
  Id BIGINT NOT NULL AUTO_INCREMENT,
  GroupId VARCHAR(32) NOT NULL,
  Type VARCHAR(32) NOT NULL,
  Field1 VARCHAR(254),
  Field2 VARCHAR(254),
  Field3 VARCHAR(254),
  Field4 VARCHAR(254),
  Field5 VARCHAR(254),
  Field6 VARCHAR(254),
  PRIMARY KEY (Id)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created actions table";
#
#
# 12. Events
#       AlarmId           BIGINT                NOT NULL        
#       GroupId           VARCHAR(32)           NOT NULL   
#	DateTime          DATETIME              NOT NULL        KEY1
#       Location          VARCHAR(254)	     
#       Inference         VARCHAR(254)	     
#       Description       VARCHAR(254)	     
#
#    Table Type: MyISAM
#
CREATE TABLE events (
  AlarmId BIGINT NOT NULL,
  GroupId VARCHAR(32) NOT NULL,
  DateTime DATETIME NOT NULL,
  Location VARCHAR(254),
  Inference VARCHAR(254),
  Description VARCHAR(254),
  KEY (DateTime)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created events table";
#
#
# 13. Times
#       RecordNum       BIGINT          NOT NULL        AUTO_INCREMENT  KEY1
#       Seconds         TINYINT         NOT NULL        DEFAULT -1
#       Minutes         TINYINT         NOT NULL        DEFAULT -1
#       Hour            TINYINT         NOT NULL        DEFAULT -1
#       Mday            TINYINT         NOT NULL        DEFAULT -1
#       Month           TINYINT         NOT NULL        DEFAULT -1
#       Year            MEDIUMINT       NOT NULL        DEFAULT -1
#       Wday            TINYINT         NOT NULL        DEFAULT -1
#       Yday            MEDIUMINT       NOT NULL        DEFAULT -1
#       Dst             TINYINT         NOT NULL        DEFAULT -1
#
#    The fields are similar to those of unix mktime
#
#    Table Type: MyISAM
#
CREATE TABLE times (
  RecordNum BIGINT NOT NULL AUTO_INCREMENT,
  Seconds TINYINT(1) NOT NULL DEFAULT -1,
  Minutes TINYINT(1) NOT NULL DEFAULT -1,
  Hour TINYINT(1) NOT NULL DEFAULT -1,
  Mday TINYINT(1) NOT NULL DEFAULT -1,
  Month TINYINT(1) NOT NULL DEFAULT -1,
  Year MEDIUMINT(1) NOT NULL DEFAULT -1,
  Wday TINYINT(1) NOT NULL DEFAULT -1,
  Yday MEDIUMINT(1) NOT NULL DEFAULT -1,
  Dst TINYINT(1) NOT NULL DEFAULT -1,
  PRIMARY KEY (RecordNum)
) TYPE = MyISAM PACK_KEYS = 1;
select "" as "Created times table";
#
#
#
# 	Insert User Name and Password into user table in mysql database 
#    
#    
#
#    
#
#
%COMMENT%USE mysql;
%COMMENT%REPLACE INTO user VALUES('localhost','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0);
%COMMENT%REPLACE INTO user VALUES('127.0.0.1','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0);
%COMMENT%REPLACE INTO user VALUES('%','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0);
%COMMENT%FLUSH PRIVILEGES;
%COMMENT%select "" as "Updated mysql user table";

select "" as "Done creating new NARS database";
