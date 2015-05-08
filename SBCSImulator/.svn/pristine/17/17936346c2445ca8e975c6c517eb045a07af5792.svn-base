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
DROP DATABASE IF EXISTS nars;
CREATE DATABASE nars;
USE nars;
#
#
# 1. CARRIERS
#
#       CarrierID               VARCHAR(64)             NOT NULL        KEY1
#       CarrierName             VARCHAR(64)             NOT NULL
#       Company                 VARCHAR(64)             NOT NULL
#       Cycle                   VARCHAR(16)             NOT NULL
#       LastBillDate            DATETIME                NOT NULL
#
#   Table Type: MyISAM
#
CREATE TABLE carriers (CarrierID VARCHAR(64) NOT NULL, CarrierName VARCHAR(64) NOT NULL, Company VARCHAR(64) NOT NULL, Cycle VARCHAR(16) NOT NULL, LastBillDate DATETIME NOT NULL, PRIMARY KEY (CarrierId)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 2. CARRIERPLANS
#
#       Identifier              VARCHAR(64)             NOT NULL        KEY1
#       Port                    MEDIUMINT               NOT NULL        DEFAULT -1  KEY1
#       BuySell                 CHAR                    NOT NULL        KEY1
#       CarrierID               VARCHAR(64)             NOT NULL
#       RouteGroupID            VARCHAR(64)             NOT NULL        KEY2
#       PlanID                  VARCHAR(64)             NOT NULL
#       CompanyID               VARCHAR(128)            NOT NULL
#       Description             VARCHAR(255)            NOT NULL
#       PrefixDigits            MEDIUMINT               NOT NULL
#       AddbackDigits           VARCHAR(32)             NOT NULL
#
#   Table Type: MyISAM
#
CREATE TABLE carrierplans (Identifier VARCHAR(64) NOT NULL, Port MEDIUMINT NOT NULL DEFAULT -1, BuySell CHAR NOT NULL, CarrierID VARCHAR(64) NOT NULL, RouteGroupID VARCHAR(64) NOT NULL, PlanID VARCHAR(64) NOT NULL, CompanyID VARCHAR(128) NOT NULL, Description VARCHAR(255) NOT NULL, PrefixDigits MEDIUMINT NOT NULL, AddbackDigits VARCHAR(32) NOT NULL, PRIMARY KEY (Identifier, Port, BuySell), KEY (RouteGroupId)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 3. ROUTES    
#
#       RouteGroupID            VARCHAR(64)             NOT NULL        KEY1
#       KeyValue                VARCHAR(64)             NOT NULL        KEY1
#       DestCode                VARCHAR(32)             NOT NULL
#       Description             VARCHAR(255)            NOT NULL
#
#   Table Type: MyISAM
#
CREATE TABLE routes (RouteGroupID VARCHAR(64) NOT NULL, KeyValue VARCHAR(64) NOT NULL, DestCode VARCHAR(32) NOT NULL, Description VARCHAR(255) NOT NULL, PRIMARY KEY (RouteGroupID, KeyValue)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 4. NEWRATES
#
#       RecordNum               BIGINT                  NOT NULL        KEY1
#       PlanID                  VARCHAR(64)             NOT NULL        KEY2  KEY3
#       DestCode                VARCHAR(32)             NOT NULL        KEY2  KEY3
#       DurMin                  MEDIUMINT               NOT NULL
#       DurIncr                 MEDIUMINT               NOT NULL
#       Rate                    FLOAT(10,4)           NOT NULL
#       Country                 VARCHAR(64)             NOT NULL
#       effectiveStartDate      DATETIME
#       effectiveStartZone      VARCHAR(16)
#       effectiveEndDate        DATETIME
#       effectiveEndZone        VARCHAR(16)
#       startTimeIndex          BIGINT                  NOT NULL        DEFAULT -1  KEY3
#       endTimeIndex            BIGINT                  NOT NULL        DEFAULT -1  KEY3
#       connectionCharge        FLOAT(10, 4)
#
#   Table Type: MyISAM
#
CREATE TABLE newrates (RecordNum BIGINT NOT NULL AUTO_INCREMENT, PlanID VARCHAR(64) NOT NULL, DestCode VARCHAR(32) NOT NULL, DurMin MEDIUMINT NOT NULL, DurIncr MEDIUMINT NOT NULL, Rate FLOAT(10, 4) NOT NULL, Country VARCHAR(64) NOT NULL, effectiveStartDate DATETIME, effectiveStartZone VARCHAR(16), effectiveEndDate DATETIME, effectiveEndZone VARCHAR(16), startTimeIndex BIGINT NOT NULL DEFAULT -1, endTimeIndex BIGINT NOT NULL DEFAULT -1, connectionCharge FLOAT(10, 4) NOT NULL, PRIMARY KEY (RecordNum), KEY (PlanID, DestCode), KEY (PlanID, DestCode, startTimeIndex, endTimeIndex)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 5. CDRS
#       Rec_Num                 BIGINT                  NOT NULL        AUTO_INCREMENT    KEY1
#       Src_File                VARCHAR(64)             NOT NULL        KEY3
#       Src_Line                INTEGER                 NOT NULL        KEY3
#       MSW_ID                  VARCHAR(64)             NOT NULL
#       Status                  VARCHAR(64)             NOT NULL        KEY15
#       Status_Desc             VARCHAR(96)             NOT NULL
#       Last_Modified           DATETIME                NOT NULL
#       Processed               SMALLINT                NOT NULL
#       Date_Time               DATETIME                NOT NULL        KEY4, KEY5, KEY6
#       Date_Time_Int           INTEGER                 NOT NULL
#       Duration                INTEGER                 NOT NULL
#       Orig_IP                 VARCHAR(16)             NOT NULL        KEY5, KEY13, KEY14
#       Source_Q931_Port        MEDIUMINT               NOT NULL
#       Orig_Line               INTEGER                 NOT NULL
#       Term_IP                 VARCHAR(16)             NOT NULL        KEY5, KEY11, KEY12
#       User_ID                 VARCHAR(32)
#       Call_E164               VARCHAR(64)             NOT NULL
#       Call_DTMF               VARCHAR(64)             NOT NULL
#       Call_Type               VARCHAR(4)              NOT NULL
#       Disc_Code               VARCHAR(2)              NOT NULL        KEY4, KEY5
#       Err_Type                MEDIUMINT
#       Err_Desc                VARCHAR(96)
#       ANI                     VARCHAR(64)
#       Seq_Num                 INTEGER
#       Call_ID                 VARCHAR(128)            NOT NULL        KEY2
#       Hold_Time               MEDIUMINT               NOT NULL
#       Orig_GW                 VARCHAR(72)             NOT NULL        KEY4, KEY9, KEY10
#       Orig_Port               SMALLINT                NOT NULL        KEY4, KEY5, KEY10, KEY14
#       Term_GW                 VARCHAR(72)             NOT NULL        KEY4, KEY7, KEY8
#       Term_Port               SMALLINT                NOT NULL        KEY4, KEY5, KEY8, KEY12
#       ISDN_Code               MEDIUMINT               NOT NULL
#       Last_Call_Number        VARCHAR(64)             NOT NULL
#       Err2_Type               MEDIUMINT
#       Err2_Desc               VARCHAR(96)
#       Last_Event              VARCHAR(96)
#       New_ANI                 VARCHAR(64)             NOT NULL
#
#    Table Type: InnoDB
#
CREATE TABLE cdrs (
  Rec_Num BIGINT NOT NULL auto_increment,
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
  Err_Desc VARCHAR(96) default NULL,
  ANI VARCHAR(64) default NULL,
  Seq_Num INTEGER default NULL,
  Call_ID VARCHAR(128) NOT NULL default '',
  Hold_Time MEDIUMINT NOT NULL default '0',
  Orig_GW VARCHAR(72) NOT NULL default '',
  Orig_Port SMALLINT NOT NULL default '0',
  Term_GW VARCHAR(72) NOT NULL default '',
  Term_Port SMALLINT NOT NULL default '0',
  ISDN_Code MEDIUMINT NOT NULL default '0',
  Last_Call_Number VARCHAR(64) NOT NULL default '',
  Err2_Type MEDIUMINT default NULL,
  Err2_Desc VARCHAR(96) default NULL,
  Last_Event VARCHAR(96) default NULL,
  New_ANI VARCHAR(64) NOT NULL default '',
  PRIMARY KEY (Rec_Num),
  UNIQUE KEY Call_ID (Call_ID),
  KEY Src_File (Src_File, Src_Line),
  KEY Orig_GW_Combo (Orig_GW, Orig_Port, Date_Time, Term_GW, Term_Port, Disc_Code),
  KEY Orig_IP_Combo (Orig_IP, Orig_Port, Date_Time, Term_IP, Term_Port, Disc_Code),
  KEY Date_Time_Disc (Date_Time, Disc_Code),
  KEY Term_Gw_Port (Term_GW, Term_Port),
  KEY Term_IP_Port (Term_IP,Term_Port),
  KEY Status (Status)
) TYPE=InnoDB PACK_KEYS=1;
#
# 6. RATEDCDR
#
#       Rec_Num                 BIGINT                  NOT NULL        AUTO_INCREMENT    KEY1
#       Created                 DATETIME                NOT NULL
#       SrcFile                 VARCHAR(64)             NOT NULL                KEY20
#       SrcLine                 INTEGER                 NOT NULL                KEY20
#       Status                  VARCHAR(64)             NOT NULL
#       BillableFlag            CHAR(1)                 NOT NULL                KEY2, KEY3, KEY5
#       UniqueID                VARCHAR(128)            NOT NULL                KEY1, KEY2
#       SellCompanyID           VARCHAR(64)
#       BuyCompanyID            VARCHAR(64)
#       Duration                INTEGER                 NOT NULL
#       PDD                     MEDIUMINT               NOT NULL
#       DialedNum               VARCHAR(64)             NOT NULL
#       ManipDialed             VARCHAR(64)             NOT NULL
#       CallType                VARCHAR(4)              NOT NULL
#       DisconnectReason        VARCHAR(2)              NOT NULL
#       Date_Time               DATETIME                NOT NULL                KEY2, KEY3, KEY4, KEY5
#       OrigDesc                VARCHAR(128)            NOT NULL                KEY8
#       OrigIP                  VARCHAR(16)             NOT NULL                KEY3, KEY16, KEY17
#       OrigGW                  VARCHAR(72)             NOT NULL                KEY2, KEY12, KEY13
#       OrigPort                SMALLINT                NOT NULL  DEFAULT -1    KEY2, KEY3, KEY13, KEY17
#       OrigCountry             VARCHAR(64)             NOT NULL                KEY9
#       DestDesc                VARCHAR(128)            NOT NULL                KEY6
#       TermIP                  VARCHAR(16)             NOT NULL                KEY3, KEY18, KEY19
#       TermGW                  VARCHAR(72)             NOT NULL                KEY2, KEY14, KEY15
#       TermPort                SMALLINT                NOT NULL  DEFAULT -1    KEY2, KEY3, KEY14, KEY19
#       DestinationCountry      VARCHAR(64)             NOT NULL                KEY7
#       BuyerID                 VARCHAR(64)             NOT NULL                KEY11
#       BuyRate                 FLOAT(10, 4)            NOT NULL
#       BuyConnectCharge        FLOAT(10, 4)            NOT NULL
#       BuyRoundedSec           SMALLINT                NOT NULL
#       BuyPrice                FLOAT(10, 4)            NOT NULL
#       BuyPlanID               VARCHAR(64)             NOT NULL
#       BuyRouteGroupID         VARCHAR(64)             NOT NULL
#       SellID                  VARCHAR(64)             NOT NULL                KEY10
#       SellRate                FLOAT(10, 4)            NOT NULL
#       SellConnectCharge       FLOAT(10, 4)            NOT NULL
#       SellRoundedSeconds      SMALLINT                NOT NULL
#       SellPrice               FLOAT(10, 4)            NOT NULL
#       SellPlanID              VARCHAR(64)             NOT NULL
#       SellRouteGroupID        VARCHAR(64)             NOT NULL
#
#    Table Type: InnoDB
#
DROP TABLE IF EXISTS ratedcdr;
CREATE TABLE ratedcdr (
  Rec_Num BIGINT NOT NULL auto_increment,
  Created DATETIME NOT NULL default '0000-00-00 00:00:00',
  SrcFile VARCHAR(64) NOT NULL default '',
  SrcLine INTEGER NOT NULL default '0',
  Status VARCHAR(64) NOT NULL default '',
  BillableFlag CHAR(1) NOT NULL default '',
  UniqueID VARCHAR(128) NOT NULL default '',
  SellCompanyID VARCHAR(64) default NULL,
  BuyCompanyID VARCHAR(64) default NULL,
  Duration INTEGER NOT NULL default '0',
  PDD MEDIUMINT NOT NULL default '0',
  DialedNum VARCHAR(64) NOT NULL default '',
  ManipDialed VARCHAR(64) NOT NULL default '',
  CallType VARCHAR(4) NOT NULL default '',
  DisconnectReason VARCHAR(2) NOT NULL default '',
  Date_Time DATETIME NOT NULL default '0000-00-00 00:00:00',
  OrigDesc VARCHAR(128) default NULL,
  OrigIP VARCHAR(16) NOT NULL default '',
  OrigGW VARCHAR(72) NOT NULL default '',
  OrigPort SMALLINT NOT NULL default '-1',
  OrigCountry VARCHAR(64) default NULL,
  DestDesc VARCHAR(128) default NULL,
  TermIP VARCHAR(16) NOT NULL default '',
  TermGW VARCHAR(72) NOT NULL default '',
  TermPort SMALLINT NOT NULL default '-1',
  DestinationCountry VARCHAR(64) NOT NULL default '',
  BuyerID VARCHAR(64) NOT NULL default '',
  BuyRate FLOAT(10,4) NOT NULL default '0.0000',
  BuyConnectCharge FLOAT(10,4) NOT NULL default '0.0000',
  BuyRoundedSec SMALLINT NOT NULL default '0',
  BuyPrice FLOAT(10,4) NOT NULL default '0.0000',
  BuyPlanID VARCHAR(64) NOT NULL default '',
  BuyRouteGroupID VARCHAR(64) NOT NULL default '',
  SellID VARCHAR(64) NOT NULL default '',
  SellRate FLOAT(10,4) NOT NULL default '0.0000',
  SellConnectCharge FLOAT(10,4) NOT NULL default '0.0000',
  SellRoundedSeconds SMALLINT NOT NULL default '0',
  SellPrice FLOAT(10,4) NOT NULL default '0.0000',
  SellPlanID VARCHAR(64) NOT NULL default '',
  SellRouteGroupID VARCHAR(64) NOT NULL default '',
  PRIMARY KEY (Rec_Num),
  UNIQUE KEY UniqueID (UniqueID),
  KEY OrigGW_Combo (OrigGW, OrigPort, Date_Time, TermGW, TermPort, BillableFlag),
  KEY OrigIP_Combo (OrigIP, OrigPort, Date_Time, TermIP, TermPort, BillableFlag),
  KEY Date_Time_Bill (Date_Time, BillableFlag),
  KEY DestDesc (DestDesc),
  KEY DestinationCountry (DestinationCountry),
  KEY OrigDesc (OrigDesc),
  KEY OrigCountry (OrigCountry),
  KEY SellID (SellID),
  KEY BuyerID (BuyerID),
  KEY SellPlanID (SellPlanID),
  KEY BuyPlanID (BuyPlanID),
  KEY TermGW_Port (TermGW, TermPort),
  KEY TermIP_Port (TermIP, TermPort),
  KEY SrcFile (SrcFile,SrcLine)
) TYPE=InnoDB PACK_KEYS=1;
#
#
# 7. GROUPS
#       GroupID                 VARCHAR(64)             NOT NULL        KEY1    KEY2
#       Endpoint                VARCHAR(128)            NOT NULL        KEY1
#       Port                    SMALLINT                NOT NULL        KEY1
#
#    Table Type: MyISAM
#
CREATE TABLE groups (GroupID VARCHAR(64) NOT NULL, Endpoint VARCHAR(128) NOT NULL,Port SMALLINT NOT NULL, PRIMARY KEY (GroupID, Endpoint, Port), KEY (GroupID)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 8. USERS
#       UserID                  VARCHAR(64)             NOT NULL        KEY1
#       GroupID                 VARCHAR(64)             NOT NULL        KEY1
#       Password                VARCHAR(64)             NOT NULL
#       cap                     BLOB                    NOT NULL
#
#    Table Type: MyISAM
#
CREATE TABLE users (UserID VARCHAR(64) NOT NULL, GroupID VARCHAR(64) NOT NULL,Password VARCHAR(64),cap BLOB,  PRIMARY KEY (UserID, GroupID), KEY (UserID, Password)) TYPE = MyISAM PACK_KEYS = 1;
INSERT INTO users VALUES("root","admin","62b5fd9ba6a340dffbd5b5caa4bb6d09","<?xml version='1.0'?>\n<CAPABILITIES admin='true'>\n  <Report>\n  <Asr>\n      <Chromocode normal='60' questionable='58' />\n    </Asr>\n  <Business>\n      <Profit normal='5' questionable='0' />\n    </Business>\n    <Billing />\n  </Report>\n  <Alarm>\n    <Log read='false' readwrite='true' />\n    <CDR read='false' readwrite='true' />\n  </Alarm>\n</CAPABILITIES>");
#
#
# 9. LICENSE
#       filename                VARCHAR(80)             NOT NULL        KEY1
#       file                    BLOB
#
#    Table Type: MyISAM
#
CREATE TABLE license (filename VARCHAR(80) NOT NULL, file BLOB, PRIMARY KEY(filename)) TYPE = MyISAM PACK_KEYS = 1;
INSERT INTO license (filename, file) VALUES ('NARS.lc', '<LICENSE/>');
#
#
# 10. Alarms
#       Id                BIGINT             NOT NULL        KEY1
#	ActionId	  VARCHAR(64)	
#	GroupId	    	  VARCHAR(64)	
#	Status  	  BOOL	
#       Type              VARCHAR(64)
#       Event             BLOB  
#
#    Table Type: MyISAM
#
CREATE TABLE alarms (Id BIGINT NOT NULL AUTO_INCREMENT, ActionId  VARCHAR(64) NOT NULL,  GroupId VARCHAR(64) NOT NULL, Status BOOL NOT NULL, Type VARCHAR(64) NOT NULL,Event BLOB NOT NULL,PRIMARY KEY(id)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 11. Actions
#       Id                      BIGINT               NOT NULL        KEY1
#       GroupId			VARCHAR(64)	     NOT NULL   
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
CREATE TABLE actions  (Id BIGINT NOT NULL AUTO_INCREMENT, GroupId VARCHAR(64) NOT NULL, Type VARCHAR(32) NOT NULL, Field1 VARCHAR(254),Field2 VARCHAR(254),Field3 VARCHAR(254),Field4 VARCHAR(254),Field5 VARCHAR(254),Field6 VARCHAR(254), PRIMARY KEY(Id)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 12. Events
#       AlarmId           BIGINT             NOT NULL        
#       GroupId           VARCHAR(64)	     NOT NULL   
#	DateTime          DATETIME    		 NOT NULL 
#       Location          VARCHAR(254)	     
#       Inference         VARCHAR(254)	     
#       Description       VARCHAR(254)	     
#
#    Table Type: MyISAM
#
CREATE TABLE events (AlarmId BIGINT NOT NULL , GroupId VARCHAR(64) NOT NULL, DateTime DATETIME NOT NULL, Location VARCHAR(254),Inference VARCHAR(254), Description VARCHAR(254), KEY (DateTime)) TYPE = MyISAM PACK_KEYS = 1;
#
#
# 13. Times
#       RecordNum       BIGINT          NOT NULL        AUTO_INCREMENT
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
REPLACE INTO user VALUES('localhost','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','N','N','N','N','N','N','N','','','','',0,0,0);
REPLACE INTO user VALUES('127.0.0.1','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','N','N','N','N','N','N','N','','','','',0,0,0);
REPLACE INTO user VALUES('%','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','N','N','N','N','N','N','N','','','','',0,0,0);
FLUSH PRIVILEGES;
