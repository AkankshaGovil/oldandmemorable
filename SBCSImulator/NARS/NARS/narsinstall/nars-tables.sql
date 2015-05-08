#######################################################################################
#
# DO NOT USE THIS FILE ANY LONGER
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
#       Rec_Num                 BIGINT                  NOT NULL        AUTO_INCREMENT          KEY1
#       Src_File                VARCHAR(64)             NOT NULL        KEY3
#       Src_Line                INTEGER                 NOT NULL        KEY3
#       MSW_ID                  VARCHAR(128)            NOT NULL
#       Status                  VARCHAR(64)             NOT NULL
#       Status_Desc             VARCHAR(128)            NOT NULL
#       Last_Modified           DATETIME                NOT NULL
#       Processed               SMALLINT                NOT NULL
#       Date_Time               DATETIME                NOT NULL        KEY4, KEY5
#       Date_Time_Int           INTEGER                 NOT NULL
#       Duration                INTEGER                 NOT NULL
#       Orig_IP                 VARCHAR(16)             NOT NULL        KEY9
#       Orig_Line               INTEGER                 NOT NULL
#       Term_IP                 VARCHAR(16)             NOT NULL        KEY8
#       Term_Line               INTEGER                 NOT NULL
#       User_ID                 VARCHAR(128)
#       Call_E164               VARCHAR(128)            NOT NULL
#       Call_DTMF               VARCHAR(128)            NOT NULL
#       Call_Type               VARCHAR(8)              NOT NULL
#       Call_Parties            MEDIUMINT               NOT NULL
#       Disc_Code               VARCHAR(16)             NOT NULL        KEY4
#       Err_Type                MEDIUMINT
#       Err_Desc                VARCHAR(128)
#       Fax_Pages               MEDIUMINT
#       Fax_Pri                 SMALLINT
#       ANI                     VARCHAR(128)
#       DNIS                    VARCHAR(128)
#       Bytes_Sent              INTEGER
#       Bytes_Recv              INTEGER
#       Seq_Num                 INTEGER
#       GW_Stop                 DATETIME
#       Call_ID                 VARCHAR(128)            NOT NULL        KEY2
#       Hold_Time               MEDIUMINT               NOT NULL
#       Orig_GW                 VARCHAR(128)            NOT NULL        KEY4, KEY7
#       Orig_Port               SMALLINT                NOT NULL
#       Term_GW                 VARCHAR(128)            NOT NULL        KEY4, KEY6
#       Term_Port               SMALLINT                NOT NULL
#       ISDN_Code               MEDIUMINT               NOT NULL
#       Last_Call_Number        VARCHAR(128)            NOT NULL
#       Err2_Type               MEDIUMINT
#       Err2_Desc               VARCHAR(128)
#       Last_Event              VARCHAR(128)
#       New_ANI                 VARCHAR(128)            NOT NULL
#       Duration_Sec            INTEGER                 NOT NULL
#
#    Table Type: InnoDB
#
CREATE TABLE cdrs (Rec_Num BIGINT NOT NULL AUTO_INCREMENT, Src_File VARCHAR(64) NOT NULL, Src_Line INTEGER NOT NULL, MSW_ID VARCHAR(128) NOT NULL, Status VARCHAR(64) NOT NULL, Status_Desc VARCHAR(128) NOT NULL, Last_Modified DATETIME NOT NULL, Processed SMALLINT NOT NULL, Date_Time DATETIME NOT NULL, Date_Time_Int INTEGER NOT NULL, Duration INTEGER NOT NULL, Orig_IP VARCHAR(16) NOT NULL, Orig_Line INTEGER NOT NULL, Term_IP VARCHAR(16) NOT NULL, Term_Line INTEGER NOT NULL, User_ID VARCHAR(128), Call_E164 VARCHAR(128) NOT NULL, Call_DTMF VARCHAR(128) NOT NULL, Call_Type VARCHAR(8) NOT NULL, Call_Parties MEDIUMINT NOT NULL, Disc_Code VARCHAR(16) NOT NULL, Err_Type MEDIUMINT, Err_Desc VARCHAR(128), Fax_Pages MEDIUMINT, Fax_Pri SMALLINT, ANI VARCHAR(128), DNIS VARCHAR(128), Bytes_Sent INTEGER, Bytes_Recv INTEGER, Seq_Num INTEGER, GW_Stop DATETIME, Call_ID VARCHAR(128) NOT NULL, Hold_Time MEDIUMINT NOT NULL, Orig_GW VARCHAR(128) NOT NULL, Orig_Port SMALLINT NOT NULL, Term_GW VARCHAR(128) NOT NULL, Term_Port SMALLINT NOT NULL, ISDN_Code MEDIUMINT NOT NULL, Last_Call_Number VARCHAR(128) NOT NULL, Err2_Type MEDIUMINT, Err2_Desc VARCHAR(128), Last_Event VARCHAR(128), New_ANI VARCHAR(128) NOT NULL, Duration_Sec INTEGER NOT NULL, PRIMARY KEY (Rec_Num), UNIQUE (Call_ID), KEY (Src_File, Src_Line), KEY (Orig_GW, Date_Time, Term_GW, Disc_Code), KEY (Date_Time), KEY (Term_GW), KEY (Orig_GW), KEY (Term_IP), KEY (Orig_IP)) TYPE = InnoDB PACK_KEYS = 1;
#
# 6. RATEDCDR
#
#       Created                 DATETIME                NOT NULL
#       SrcFile                 VARCHAR(64)             NOT NULL                KEY8
#       SrcLine                 INTEGER                 NOT NULL                KEY8
#       Status                  VARCHAR(64)             NOT NULL
#       BillableFlag            CHAR                    NOT NULL
#       UniqueID                VARCHAR(128)            NOT NULL                KEY1, KEY2
#       SellCompanyID           VARCHAR(128)
#       BuyCompanyID            VARCHAR(128)
#       Duration                INTEGER                 NOT NULL
#       PDD                     MEDIUMINT               NOT NULL
#       DialedNum               VARCHAR(128)            NOT NULL
#       ManipDialed             VARCHAR(128)            NOT NULL
#       CallType                VARCHAR(8)              NOT NULL
#       DisconnectReason        VARCHAR(16)             NOT NULL
#       Date_Time               DATETIME                NOT NULL                KEY2, KEY3
#       OrigDesc                VARCHAR(128)            NOT NULL
#       OrigIP                  VARCHAR(16)             NOT NULL                KEY2
#       OrigGW                  VARCHAR(128)            NOT NULL                KEY6
#       OrigPort                SMALLINT                NOT NULL        DEFAULT -1
#       OrigCountry             VARCHAR(64)             NOT NULL
#       DestDesc                VARCHAR(128)            NOT NULL                KEY2, KEY4
#       TermIP                  VARCHAR(16)             NOT NULL
#       TermGW                  VARCHAR(128)            NOT NULL                KEY7
#       TermPort                SMALLINT                NOT NULL        DEFAULT -1
#       DestinationCountry      VARCHAR(64)             NOT NULL                KEY5
#       BuyerID                 VARCHAR(64)             NOT NULL
#       BuyRate                 FLOAT(10, 4)          NOT NULL
#       BuyConnectCharge        FLOAT(10, 4)            NOT NULL
#       BuyRoundedSec           SMALLINT                NOT NULL
#       BuyPrice                FLOAT(10, 4)          NOT NULL
#       BuyPlanID               VARCHAR(64)             NOT NULL
#       BuyRouteGroupID         VARCHAR(64)             NOT NULL
#       SellID                  VARCHAR(64)             NOT NULL
#       SellRate                FLOAT(10, 4)          NOT NULL
#       SellConnectCharge       FLOAT(10, 4)            NOT NULL
#       SellRoundedSeconds      SMALLINT                NOT NULL
#       SellPrice               FLOAT(10, 4)          NOT NULL
#       SellPlanID              VARCHAR(64)             NOT NULL
#       SellRouteGroupID        VARCHAR(64)             NOT NULL
#
#    Table Type: InnoDB
#
CREATE TABLE ratedcdr (Created DATETIME NOT NULL, SrcFile VARCHAR(64) NOT NULL, SrcLine INTEGER NOT NULL, Status VARCHAR(64) NOT NULL, BillableFlag CHAR NOT NULL, UniqueID VARCHAR(128) NOT NULL, SellCompanyID VARCHAR(128), BuyCompanyID VARCHAR(128), Duration INTEGER NOT NULL, PDD MEDIUMINT NOT NULL, DialedNum VARCHAR(128) NOT NULL, ManipDialed VARCHAR(128) NOT NULL, CallType VARCHAR(8) NOT NULL, DisconnectReason VARCHAR(16) NOT NULL, Date_Time DATETIME NOT NULL, OrigDesc VARCHAR(128),  OrigIP VARCHAR(16) NOT NULL, OrigGW VARCHAR(128) NOT NULL, OrigPort SMALLINT NOT NULL DEFAULT -1, OrigCountry VARCHAR(64), DestDesc VARCHAR(128), TermIP VARCHAR(16) NOT NULL, TermGW VARCHAR(128) NOT NULL, TermPort SMALLINT NOT NULL DEFAULT -1, DestinationCountry VARCHAR(64) NOT NULL, BuyerID VARCHAR(64) NOT NULL, BuyRate FLOAT(10, 4) NOT NULL, BuyConnectCharge FLOAT(10, 4) NOT NULL, BuyRoundedSec SMALLINT NOT NULL, BuyPrice FLOAT(10, 4) NOT NULL, BuyPlanID VARCHAR(64) NOT NULL, BuyRouteGroupID VARCHAR(64) NOT NULL, SellID VARCHAR(64) NOT NULL, SellRate FLOAT(10, 4) NOT NULL, SellConnectCharge FLOAT(10, 4) NOT NULL, SellRoundedSeconds SMALLINT NOT NULL, SellPrice FLOAT(10, 4) NOT NULL, SellPlanID VARCHAR(64) NOT NULL, SellRouteGroupID VARCHAR(64) NOT NULL, PRIMARY KEY (UniqueID), KEY (OrigIP, Date_Time, DestDesc, UniqueID), KEY (Date_Time), KEY (DestDesc), KEY (DestinationCountry), KEY (OrigGW), KEY (TermGW), KEY (SrcFile, SrcLine)) TYPE = InnoDB PACK_KEYS = 1;
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
REPLACE INTO user VALUES('%','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','N','N','N','N','N','N','N','','','','',0,0,0);
FLUSH PRIVILEGES;
