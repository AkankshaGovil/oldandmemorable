
#######################################################################################
#
# This file contains the table schemas used in ivms and the SQL commands to create them
# The SQL commands are mysql database compatible. Execute this file using:
#           mysql < ivms-tables.sql
# to create the initial database structure.
#
# Use MyISAM table type for tables with frequent SELECTs than UPDATE/INSERTs
# Use InnoDB table type for tables with frequent UPDATE/INSERTs
#
#######################################################################################
#
#
#
DROP DATABASE IF EXISTS %DBNAME%;
CREATE DATABASE %DBNAME%;
use %DBNAME%;

# 
# Alarm related tables
#
DROP TABLE IF EXISTS actions;
CREATE TABLE actions (
  ActionId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  Type varchar(32) NOT NULL default '',
  Field1 varchar(254) default NULL,
  Field2 varchar(254) default NULL,
  Field3 varchar(254) default NULL,
  Field4 varchar(254) default NULL,
  Field5 varchar(254) default NULL,
  Field6 varchar(254) default NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (ActionId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS alarms;
CREATE TABLE alarms (
  AlarmId bigint(20) NOT NULL auto_increment,
  ActionId varchar(64) NOT NULL default '',
  GroupId tinyint(1) NOT NULL default '-1',
  Status tinyint(1) NOT NULL default '0',
  Type varchar(32) NOT NULL default '',
  Event blob NOT NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (AlarmId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS events;
CREATE TABLE events (
  AlarmId bigint(20) NOT NULL default '0',
  GroupId tinyint(1) NOT NULL default '-1',
  DateTime datetime NOT NULL default '0000-00-00 00:00:00',
  Location varchar(254) default NULL,
  Inference varchar(254) default NULL,
  Description varchar(254) default NULL,
  KEY DateTime (DateTime)
) TYPE=MyISAM PACK_KEYS=DEFAULT;



#
# rating information tables
#

DROP TABLE IF EXISTS ANI;
CREATE TABLE ANI (
  ANIId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  ANI varchar(32) NOT NULL default '',
  CallNumber  varchar(32) NOT NULL default '',
  Prefix varchar(32) NOT NULL default '',
  PrefixLength mediumint(9) NOT NULL default '0',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (ANIId),
  UNIQUE KEY ANI_Call_GroupId (ANI,CallNumber,GroupId),
  KEY ANI (ANI)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS carrierplans;
CREATE TABLE carrierplans (
  CarrierplanId bigint(20) NOT NULL auto_increment,
  EndpointId bigint(20) NOT NULL default '-1',
  BuySell char(1) NOT NULL default '',
  Carrier varchar(32) NOT NULL default '',
  RouteGroup varchar(32) NOT NULL default '',
  Plan varchar(32) NOT NULL default '',
  Description varchar(64) NOT NULL default '',
  ANI varchar(32) NOT NULL default '',
  StripPrefix varchar(32) NOT NULL default '',
  PrefixDigits mediumint(9) NOT NULL default '0',
  AddbackDigits varchar(16) NOT NULL default '',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (CarrierplanId),
  UNIQUE KEY EpId_Flag (EndpointId,BuySell),
  KEY Carrier (Carrier),
  KEY Route (RouteGroup),
  KEY Plan (Plan),
  FOREIGN KEY (EndpointId) REFERENCES endpoints(EndpointId) ON UPDATE CASCADE ON DELETE CASCADE
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS routes;
CREATE TABLE routes (
  RouteId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  RouteGroup varchar(32) NOT NULL default '',
  RegionCode  varchar(32) NOT NULL default '',
  CostCode varchar(32) NOT NULL default '',
  Description varchar(64) NOT NULL default '',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (RouteId),
  UNIQUE KEY Group_Route_Region (GroupId,RouteGroup,RegionCode),
  KEY CostCode (CostCode)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS regions;
CREATE TABLE regions (
  RegionId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  RegionCode varchar(32) NOT NULL default '',
  DialCode varchar(64) NOT NULL default '',
  Description varchar(64) NOT NULL default '',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (RegionId),
  UNIQUE KEY Group_Region_Dial (GroupId,RegionCode,DialCode),
  KEY Dial (DialCode),
  KEY GroupId (GroupId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS plans;
CREATE TABLE plans (
  PlanId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  Plan varchar(32) NOT NULL default '',
  CostCode varchar(32) NOT NULL default '',
  DurMin mediumint(9) NOT NULL default '0',
  DurIncr mediumint(9) NOT NULL default '0',
  Rate float(10,4) NOT NULL default '0.0000',
  Country varchar(64) NOT NULL default '',
  ConnectionCharge float(10,4) NOT NULL default '0.0000',
  EffectiveStartDate datetime default NULL,
  EffectiveEndDate datetime default NULL,
  PeriodId bigint(20) NOT NULL default '-1',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (PlanId),
  UNIQUE KEY Group_Plan_CostCode_StartDate_EndDate_Period (GroupId,Plan,CostCode,EffectiveStartDate,EffectiveEndDate,PeriodId),
  FOREIGN KEY (PeriodId) REFERENCES periods(PeriodId) ON UPDATE CASCADE ON DELETE CASCADE,
  KEY Plan_Cost_Time (Plan,CostCode,PeriodId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS periods;
CREATE TABLE periods (
  PeriodId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  Period varchar(32) NOT NULL default '',
  Zone varchar(32) default NULL,
  StartWeekDays mediumint(9) NOT NULL default '-1',
  EndWeekDays mediumint(9) NOT NULL default '-1',
  StartTime TIME default NULL,
  EndTime TIME default NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY (PeriodId),
  UNIQUE KEY Group_Period (GroupId,Period)
) TYPE=MyISAM PACK_KEYS=DEFAULT;



#
# user access tables
#
DROP TABLE IF EXISTS groups;
CREATE TABLE groups (
  GroupId tinyint(1) NOT NULL default '-1',
  GroupName varchar(32) NOT NULL default '',
  Cap blob,
  EnforceVPort tinyint(1) NOT NULL default '0',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY (GroupId),
  UNIQUE KEY GroupName (GroupName)
) TYPE=InnoDB PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS endpoints;
CREATE TABLE endpoints (
  EndpointId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  MSWId smallint(6) NOT NULL default '-1',
  flag tinyint(1) NOT NULL default '0',
  realmname varchar(31) binary NOT NULL default '',
  serialNumber varchar(67) binary NOT NULL default '',
  port int(11) NOT NULL default '0',
  extNumber varchar(63) binary NOT NULL default '',
  phone varchar(63) binary NOT NULL default '',
  firstName varchar(27) binary NOT NULL default '',
  lastName varchar(27) binary NOT NULL default '',
  location varchar(27) binary NOT NULL default '',
  country varchar(27) binary NOT NULL default '',
  comments varchar(27) binary NOT NULL default '',
  customerId varchar(27) binary NOT NULL default '',
  trunkGroup varchar(63) binary NOT NULL default '',
  zone varchar(29) binary NOT NULL default '',
  email varchar(79) binary NOT NULL default '',
  forwardedPhone varchar(63) binary NOT NULL default '',
  forwardedVpnPhone varchar(63) binary NOT NULL default '',
  callingPlanName varchar(59) binary NOT NULL default '',
  h323Id varchar(127) binary NOT NULL default '',
  sipUri blob NOT NULL,
  sipContact blob NOT NULL,
  techPrefix varchar(63) binary NOT NULL default '',
  peerGkId blob NOT NULL,
  h235Password varchar(64) binary NOT NULL default '',
  vpnName varchar(27) binary NOT NULL default '',
  ogp varchar(63) binary NOT NULL default '',
  proxyValid tinyint(4) default NULL,
  isProxied tinyint(4) default NULL,
  isProxying tinyint(4) default NULL,
  callForwarded tinyint(4) default NULL,
  isCallRollover tinyint(4) default NULL,
  devType int(11) default NULL,
  ipaddr int(11) unsigned default '0',
  forwardedVpnExtLen int(11) default NULL,
  maxCalls int(11) default NULL,
  maxInCalls int(11) default NULL,
  maxOutCalls int(11) default NULL,
  priority int(11) default NULL,
  rasPort int(11) default NULL,
  q931Port int(11) default NULL,
  callpartyType int(11) default NULL,
  currentCalls int(11) default NULL,
  vendor int(11) default NULL,
  extLen int(11) default NULL,
  subnetip int(11) default NULL,
  subnetmask int(11) default NULL,
  maxHunts int(11) default NULL,
  extCaps int(11) default NULL,
  caps int(11) default NULL,
  stateFlags int(11) default NULL,
  layer1Protocol int(11) default NULL,
  inceptionTime bigint(20) default NULL,
  refreshTime bigint(20) default NULL,
  infotranscap int(11) default NULL,
  srcingresstg varchar(63) binary NOT NULL default '',
  igrpname varchar(31) binary NOT NULL default '',
  dtg varchar(63) binary NOT NULL default '',
  newsrcdtg varchar(63) binary NOT NULL default '',
  natip int(11) default NULL,
  natport int(11) default NULL,
  callIdBlock smallint(6) default NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00', 
  PRIMARY KEY  (EndpointId),  
  UNIQUE KEY Ep_Port (serialNumber,Port),
  INDEX GroupId (GroupId),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) TYPE=InnoDB PACK_KEYS=DEFAULT;


DROP TABLE IF EXISTS users;
CREATE TABLE users (
  UserId bigint(20) NOT NULL auto_increment,
  User varchar(32) NOT NULL default '',
  GroupId tinyint(1) NOT NULL default '-1',
  Password varchar(32) default NULL,
  Cap blob,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (UserId),
  KEY User_Pass (User,Password),
  UNIQUE KEY User_Group (User,GroupId),
  INDEX GroupId (GroupId),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) TYPE=InnoDB PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS filters;
CREATE TABLE filters (
  FilterId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  FilterName varchar(80) NOT NULL default '',
  User varchar(32) NOT NULL default '',
  TableName varchar(32) NOT NULL default '',
  Filter blob,
  PRIMARY KEY  (FilterId),
  UNIQUE KEY Group_User_Name (GroupId, User, FilterName),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX User (User),
  FOREIGN KEY (User) REFERENCES users(User) ON UPDATE CASCADE ON DELETE CASCADE
) TYPE=InnoDB PACK_KEYS=DEFAULT;


#
# cdr table
#
DROP TABLE IF EXISTS cdrlogs;
CREATE TABLE cdrlogs (
CDRLogId smallint(6) NOT NULL auto_increment,
  CDRTableName varchar(32) NOT NULL default '',
  StartDateInt int(11) NOT NULL default '0',
  EndDateInt int(11) default '0',
  TotalCDRs int(11) default '0',
  Status int(11) NOT NULL default '-1',
  CreatedInt int(11) NOT NULL default '0',
  LastInsertionInt int(11) NOT NULL default '0',
  LastModifiedInt int(11) NOT NULL default '0',
  PRIMARY KEY  (CDRLogID),
  UNIQUE KEY CDRTableName (CDRTableName)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS cdrfiles;
CREATE TABLE cdrfiles (
  CDRFileId smallint(6) NOT NULL auto_increment,
  SrcFileName varchar(255) NOT NULL default '',
  CDRStartDateInt int(11) NOT NULL default '0',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY (CDRFileId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS cdr;
CREATE TABLE cdr (
  CDRId bigint(20) NOT NULL auto_increment,
  CDRLogId smallint(6) NOT NULL default '0',
  MSWId smallint(6) NOT NULL default '0',
  CDRFileId smallint(6) NOT NULL default '0',
  SrcLine int(11) NOT NULL default '0',
  DateTimeInt int(11) NOT NULL default '0',
  CallId varchar(128) NOT NULL default '',
  OrigGw varchar(64) NOT NULL default '',
  OrigIp int(11) unsigned NOT NULL default '0',
  OrigPort smallint(6) NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermIp int(11) unsigned NOT NULL default '0',
  TermPort smallint(6) NOT NULL default '0',
  Duration int(11) NOT NULL default '0',
  CallDTMF varchar(64) NOT NULL default '',
  CallE164 varchar(64) NOT NULL default '',
  LastCallNumber varchar(64) NOT NULL default '',
  NumberAfterTransit varchar(64) NOT NULL default '',
  CallType varchar(4) NOT NULL default '',
  DiscCode char(2) NOT NULL default '',
  HoldTime mediumint(9) NOT NULL default '0',
  PDD mediumint(9) NOT NULL default '0',
  Ani varchar(64) default NULL,
  NewANI varchar(64) NOT NULL default '',
  ISDNCode mediumint(9) NOT NULL default '0',
  ErrorIDLeg1 mediumint(9) default NULL,
  ErrorIDLeg2 mediumint(9) default NULL,
  LastEvent varchar(96) default NULL,
  SeqNum int(11) default NULL,
  SourceQ931Port mediumint(9) NOT NULL default '0',
  UserId varchar(32) default NULL,
  IncomingCallId varchar(128) NOT NULL default '',
  Protocol smallint(6) NOT NULL default '0',
  CdrType smallint(6) NOT NULL default '0',
  HuntAttempts mediumint(9) NOT NULL default '0',
  OrigTG varchar(32) NOT NULL default '',
  TermTG varchar(32) NOT NULL default '',
  H323RASError mediumint(9) NOT NULL default '0',
  H323H225Error mediumint(9) NOT NULL default '0',
  SipFinalResponseCode mediumint(9) NOT NULL default '0',
  TZ varchar(16) NOT NULL default '',
  OrigNumberType smallint(6) NOT NULL default '0',
  TermNumberType smallint(6) NOT NULL default '0',
  DurationMsec bigint(20) NOT NULL default '0',
  OrigRealm varchar(32) NOT NULL default '',
  TermRealm varchar(32) NOT NULL default '',
  CallRoute varchar(64) NOT NULL default '',
  Status tinyint(1) NOT NULL default '-1',
  StatusDesc varchar(96) NOT NULL default '',
  RegionCode varchar(32) default NULL,
  BillableFlag char(1) NOT NULL default '',
  ManipDialed varchar(64) NOT NULL default '',
  OrigDesc varchar(64) NOT NULL default '',
  OrigCountry varchar(64) NOT NULL default '',
  DestDesc varchar(64) NOT NULL default '',
  DestCountry varchar(64) NOT NULL default '',
  BuyCarrier varchar(32) NOT NULL default '',
  BuyRate float(10,4) NOT NULL default '0.0000',
  BuyConnectCharge float(10,4) NOT NULL default '0.0000',
  BuyRoundedSec int(11) NOT NULL default '0',
  BuyPrice float(10,4) NOT NULL default '0.0000',
  BuyPlan varchar(32) NOT NULL default '',
  BuyRouteGroup varchar(32) NOT NULL default '',
  SellCarrier varchar(32) NOT NULL default '',
  SellRate float(10,4) NOT NULL default '0.0000',
  SellConnectCharge float(10,4) NOT NULL default '0.0000',
  SellRoundedSec int(11) NOT NULL default '0',
  SellPrice float(10,4) NOT NULL default '0.0000',
  SellPlan varchar(32) NOT NULL default '',
  SellRouteGroup varchar(32) NOT NULL default '',
  UserAuth set('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64') default NULL,
  CreatedInt int(11) NOT NULL default '0',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (CDRId),
  UNIQUE KEY CallId (CallId),
  KEY CDRLogId (CDRLogId),
  KEY CDRFileId (CDRFileId),
  KEY DateTimeInt (DateTimeInt)
) TYPE=InnoDB PACK_KEYS=DEFAULT;



#
# summary tables
#
DROP TABLE IF EXISTS cdrsummary;
CREATE TABLE cdrsummary (
  CdrSummaryId bigint(20) NOT NULL auto_increment,
  MSWId smallint(6) NOT NULL default '0',
  CDRFileId smallint(6) NOT NULL default '0',
  DateTimeInt int(11) NOT NULL default '0',
  OrigIp int(11) unsigned NOT NULL default '0',
  OrigGw varchar(64) NOT NULL default '',
  OrigPort smallint(6) NOT NULL default '0',
  TermIp int(11) unsigned NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermPort smallint(6) NOT NULL default '0',
  DiscCode char(2) NOT NULL default '',
  RegionCode varchar(32) default NULL,
  ErrorIdLeg1 mediumint(9) default NULL,
  ISDNCode mediumint(9) NOT NULL default '0',
  CallCount int(11) NOT NULL default '0',
  Duration int(11) NOT NULL default '0',
  PDD int(11) NOT NULL default '0',
  BuyCarrier varchar(32) NOT NULL default '',
  SellCarrier varchar(32) NOT NULL default '',
  MaxDateTimeInt int(11) NOT NULL default '0',
  MinDateTimeInt int(11) NOT NULL default '0',
  UserAuth set('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64') default NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (CdrSummaryId),
  KEY DateTimeInt (DateTimeInt),
  KEY CDRFileId (CDRFileId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;



DROP TABLE IF EXISTS sellsummary;
CREATE TABLE sellsummary (
  SellSummaryId bigint(20) NOT NULL auto_increment,
  MSWId smallint(6) NOT NULL default '0',
  DateTimeInt int(11) NOT NULL default '0',
  OrigDesc varchar(64) NOT NULL default '',
  RegionCode varchar(32) NOT NULL default '',
  OrigCountry varchar(64) NOT NULL default '',
  SellCarrier varchar(32) NOT NULL default '',
  SellPlan varchar(32) NOT NULL default '',
  OrigIp int(11) unsigned NOT NULL default '0',
  OrigGw varchar(64) NOT NULL default '',
  OrigPort smallint(6) NOT NULL default '0',
  TermIp int(11) unsigned NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermPort smallint(6) NOT NULL default '0',
  Duration float(10,4) NOT NULL default '0.0000',
  PDD int(11) NOT NULL default '0',
  SellRate float(10,4) NOT NULL default '0.0000',
  BuyPrice float(10,4) NOT NULL default '0.0000',
  SellPrice float(10,4) NOT NULL default '0.0000',
  CallCount int(11) NOT NULL default '0',
  BillableCount int(11) NOT NULL default '0',
  SellConnectCharge float(10,4) NOT NULL default '0.0000',
  SellRoundedSec float(10,4) NOT NULL default '0.0000',
  BuyConnectCharge float(10,4) NOT NULL default '0.0000',
  BuyRoundedSec float(10,4) NOT NULL default '0.0000',
  MaxDateTimeInt int(11) NOT NULL default '0',
  MinDateTimeInt int(11) NOT NULL default '0',
  UserAuth set('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64') default NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  SellSummaryId (SellSummaryId),
  KEY DateTimeInt (DateTimeInt)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS buysummary;
CREATE TABLE buysummary (
  BuySummaryId bigint(20) NOT NULL auto_increment,
  MSWId smallint(6) NOT NULL default '0',
  DateTimeInt int(11) NOT NULL default '0',
  DestDesc varchar(64) NOT NULL default '',
  RegionCode varchar(32) NOT NULL default '',
  DestCountry varchar(64) NOT NULL default '',
  BuyCarrier varchar(32) NOT NULL default '',
  BuyPlan varchar(32) NOT NULL default '',
  OrigIp int(11) unsigned NOT NULL default '0',
  OrigGw varchar(64) NOT NULL default '',
  OrigPort smallint(6) NOT NULL default '0',
  TermIp int(11) unsigned NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermPort smallint(6) NOT NULL default '0',
  Duration float(10,4) NOT NULL default '0.0000',
  PDD int(11) NOT NULL default '0',
  BuyRate float(10,4) NOT NULL default '0.0000',
  BuyPrice float(10,4) NOT NULL default '0.0000',
  SellPrice float(10,4) NOT NULL default '0.0000',
  CallCount int(11) NOT NULL default '0',
  BillableCount int(11) NOT NULL default '0',
  BuyConnectCharge float(10,4) NOT NULL default '0.0000',
  BuyRoundedSec float(10,4) NOT NULL default '0.0000',
  SellConnectCharge float(10,4) NOT NULL default '0.0000',
  SellRoundedSec float(10,4) NOT NULL default '0.0000',
  MaxDateTimeInt int(11) NOT NULL default '0',
  MinDateTimeInt int(11) NOT NULL default '0',
  UserAuth set('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64') default NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  BuySummaryId (BuySummaryId),
  KEY DateTimeInt (DateTimeInt)
) TYPE=MyISAM PACK_KEYS=DEFAULT;



#
# other tables - license, errors and msws
#
DROP TABLE IF EXISTS license;
CREATE TABLE license (
  Filename varchar(80) NOT NULL default '',
  File blob,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (filename)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS errors;
CREATE TABLE errors (
  ErrorId mediumint(9) NOT NULL default '0',
  ErrDesc varchar(64) NOT NULL default '',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (ErrorId),
  KEY ErrDesc (ErrDesc)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS msws;
CREATE TABLE msws (
  MSWId smallint(6) NOT NULL auto_increment,
  ClusterId smallint(6) NOT NULL,
  MSWName varchar(32) NOT NULL default '',
  MSWIp int(11) unsigned NOT NULL default '0',
  ReadPassword varchar(16) NOT NULL default '',
  WritePassword varchar(16) NOT NULL default '', 
  Flag  smallint(6) NOT NULL default '0',	
  Description varchar(64) NOT NULL default '',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (MSWId),
  UNIQUE KEY MSWName (MSWName)
  ) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS activitylogs;
CREATE TABLE activitylogs (
  ActivityLogId int(11) NOT NULL auto_increment,
  ServiceName varchar(32) NOT NULL default '',
  ServiceId int(11) NOT NULL,
  Reason varchar(64) NOT NULL,
  ProcessStartDate datetime NOT NULL,
  ProcessEndDate datetime NOT NULL,
  CdrLogId smallint(6) NOT NULL,
  MaxCdrDateInt int(11) NOT NULL default '0',
  MinCdrDateInt int(11) NOT NULL default '0',
  TotalCDRs int(11) NOT NULL default '0',
  AdditionalInfo blob,
  PRIMARY KEY (ActivityLogId),
  KEY ProcessStartDate (ProcessStartDate)
) TYPE=MyISAM PACK_KEYS=DEFAULT;


DROP TABLE IF EXISTS sessions;
CREATE TABLE sessions (
  User varchar(32) NOT NULL,
  GroupId tinyint(1) NOT NULL default '-1',
  SessionId varchar(64) NOT NULL,
  Created datetime NOT NULL,
  PRIMARY KEY (User,GroupId),
  UNIQUE KEY SessionId (SessionId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;


DROP TABLE IF EXISTS services;
CREATE TABLE services (
  ServiceId bigint(20) NOT NULL auto_increment,
  Type varchar(32) NOT NULL,
  Parameters blob,
  GroupId tinyint(1) NOT NULL default '-1',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (ServiceId)
) TYPE=MyISAM PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS realms;
CREATE TABLE realms(
  RealmId bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  MSWId smallint(6) NOT NULL default '-1',
  Name varchar(31) binary NOT NULL default '',
  IfName varchar(16) binary NOT NULL default '',
  VipName varchar(16) binary NOT NULL default '',
  Id bigint(20) default NULL,
  Rsa bigint(20) default NULL,
  Mask bigint(20) default NULL,
  SigPoolId int(11) default NULL,
  MedPoolId int(11) default NULL,
  AddrType int(11) default NULL,
  AdminStatus int(11) default NULL,
  OpStatus int(11) default NULL,
  Imr smallint(6) default NULL,
  Emr smallint(6) default NULL,
  SipAuth int(11) default NULL,
  CidBlock varchar(15) binary NOT NULL default '',
  CidUnBlock varchar(15) binary NOT NULL default '',
  ProxyRegId varchar(67) binary NOT NULL default '',
  ProxyPort int(11) NOT NULL default '0',
  VnetName varchar(16) binary NOT NULL default '',
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',

  PRIMARY KEY  (RealmId),
  UNIQUE KEY RealmName (Name),
  INDEX GroupId (GroupId),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) TYPE=MyISAM  PACK_KEYS=DEFAULT;


DROP TABLE IF EXISTS trails;
CREATE TABLE trails (
  TrailId bigint(20) NOT NULL auto_increment,
  UserName varchar(32) NOT NULL default '',
  GroupId tinyint(1) NOT NULL default '-1',
  ClientAddr varchar(32) NOT NULL default '',
  DBAction varchar(32) NOT NULL default '',
  DBKey varchar(32) default NULL,
  Status varchar(32) default NULL,
  Detail blob,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (TrailId)
) TYPE=InnoDB PACK_KEYS=DEFAULT;

DROP TABLE IF EXISTS iedgegroups;
CREATE TABLE iedgegroups (
  Id bigint(20) NOT NULL auto_increment,
  GroupId tinyint(1) NOT NULL default '-1',
  Name varchar(31) binary NOT NULL default '',
  MaxIn int(11) default NULL,
  MaxOut int(11) default NULL,
  MaxTotal int(11) default NULL,
  CallsIn int(11) default NULL,
  CallsOut int(11) default NULL,
  CallsTotal int(11) default NULL,
  DndTime bigint(20) default NULL,
  Created datetime NOT NULL default '0000-00-00 00:00:00',
  LastModified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (Id),
  UNIQUE KEY IEdgeGroupName (Name),
  INDEX GroupId (GroupId),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) TYPE=MyISAM PACK_KEYS=DEFAULT;

#
# The following lines create the default entries required in iVMS tables
#


REPLACE INTO groups VALUES (1,'admin',"<?xml version='1.0'?>\n<CAPABILITIES admin='true'>\n  <Report>\n  <Asr>\n      <Chromocode normal='60' questionable='58' />\n    </Asr>\n  <Business>\n      <Profit normal='5' questionable='0' />\n    </Business>\n    <Billing />\n  </Report>\n  <Alarm>\n    <Log read='false' readwrite='true' />\n    <CDR read='false' readwrite='true' />\n  </Alarm>\n</CAPABILITIES>",0,now(),now());
REPLACE INTO groups VALUES (-1,'',"<?xml version='1.0'?>\n<CAPABILITIES admin='true'>\n  <Report>\n  <Asr>\n      <Chromocode normal='60' questionable='58' />\n    </Asr>\n  <Business>\n      <Profit normal='5' questionable='0' />\n    </Business>\n    <Billing />\n  </Report>\n  <Alarm>\n    <Log read='false' readwrite='true' />\n    <CDR read='false' readwrite='true' />\n  </Alarm>\n</CAPABILITIES>",0,now(),now());
REPLACE INTO groups VALUES (-2,'*',"<?xml version='1.0'?>\n<CAPABILITIES admin='true'>\n  <Report>\n  <Asr>\n      <Chromocode normal='60' questionable='58' />\n    </Asr>\n  <Business>\n      <Profit normal='5' questionable='0' />\n    </Business>\n    <Billing />\n  </Report>\n  <Alarm>\n    <Log read='false' readwrite='true' />\n    <CDR read='false' readwrite='true' />\n  </Alarm>\n</CAPABILITIES>",0,now(),now());

REPLACE INTO users VALUES (1,'root',1,'hGyVtnlrHBskPMTU5frLr59NWpU=',"<?xml version='1.0'?>\n<CAPABILITIES admin='true'>\n  <Report>\n  <Asr>\n      <Chromocode normal='60' questionable='58' />\n    </Asr>\n  <Business>\n      <Profit normal='5' questionable='0' />\n    </Business>\n    <Billing />\n  </Report>\n  <Alarm>\n    <Log read='false' readwrite='true' />\n    <CDR read='false' readwrite='true' />\n  </Alarm>\n</CAPABILITIES>",now(),now());

REPLACE INTO endpoints (EndpointId, GroupId, realmname, serialNumber, port, created, lastmodified) VALUES (-1,1,'','*',-1,now(),now());
REPLACE INTO actions VALUES (-1, -1, 'none', '', '', '', '', '', '', now(), now());

REPLACE INTO periods VALUES (-1,'-1','DefaultPlan',NULL,127,127,'00:00:00','23:59:59',now(),now());

#
# The following lines create the default entries required in iVMS tables
#
#       Insert User Name and Password into user table in mysql database
#
#
%COMMENT%USE mysql; %COMMENT%REPLACE INTO user VALUES('localhost','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0); %COMMENT%REPLACE INTO user VALUES('127.0.0.1','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0); %COMMENT%REPLACE INTO user VALUES('%','USERNAME',PASSWORD('USERPASSWORD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0);
%COMMENT%UPDATE user SET password = PASSWORD('USERPASSWORD') where User = '';
%COMMENT%FLUSH PRIVILEGES;
%COMMENT%select "" as "Updated mysql user table";
                                                                                                                             
select "" as "Done creating new Blue Neon database";

