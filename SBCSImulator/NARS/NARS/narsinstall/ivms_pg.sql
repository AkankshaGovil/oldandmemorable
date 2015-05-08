DROP SCHEMA bn CASCADE;
CREATE SCHEMA bn;


SET search_path = bn, pg_catalog;


-- 
-- Alarm related tables
--
CREATE TABLE actions (
  ActionId BigSerial NOT NULL,
  Name varchar(32) NOT NULL default '',
  GroupId smallint NOT NULL default '-1',
  Type varchar(32) NOT NULL default '',
  Field1 varchar(254) default NULL,
  Field2 varchar(254) default NULL,
  Field3 varchar(254) default NULL,
  Field4 varchar(254) default NULL,
  Field5 varchar(254) default NULL,
  Field6 varchar(254) default NULL,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (ActionId),
  UNIQUE (Name)
);

CREATE TABLE alarms (
  AlarmId BigSerial NOT NULL,
  ActionId varchar(64) NOT NULL default '',
  GroupId smallint NOT NULL default '-1',
  Status smallint NOT NULL default '0',
  Type varchar(32) NOT NULL default '',
  Event bytea NOT NULL,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (AlarmId)
);

CREATE TABLE events (
  AlarmId bigint NOT NULL default '0',
  GroupId smallint NOT NULL default '-1',
  DateTime timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  Location varchar(254) default NULL,
  Inference varchar(254) default NULL,
  Description varchar(254) default NULL
);
CREATE INDEX DateTime ON events (DateTime);

--
-- rating information tables
--
CREATE TABLE ANI (
  ANIId BigSerial NOT NULL,
  GroupId smallint NOT NULL default '-1',
  ANI varchar(32) NOT NULL default '',
  CallNumber  varchar(32) NOT NULL default '',
  Prefix varchar(32) NOT NULL default '',
  PrefixLength int NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (ANIId),
  UNIQUE (ANI,CallNumber,GroupId)
) ;
CREATE INDEX ani_ANI ON ANI (ANI);

--
-- user access tables
--
CREATE TABLE groups (
  GroupId smallint NOT NULL default '-1',
  GroupName varchar(32) NOT NULL default '',
  Cap bytea,
  EnforceVPort smallint NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY (GroupId),
  UNIQUE (GroupName)
) ;

CREATE TABLE endpoints (
  Id BigSerial NOT NULL,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Flag smallint NOT NULL default '0',
  Realmname varchar(31) NOT NULL default '',
  SerialNumber varchar(67)  NOT NULL default '',
  Port int NOT NULL default '0',
  ExtNumber varchar(63) NOT NULL default '',
  Phone varchar(63) NOT NULL default '',
  FirstName varchar(27) NOT NULL default '',
  LastName varchar(27) NOT NULL default '',
  Location varchar(27) NOT NULL default '',
  Country varchar(27) NOT NULL default '',
  Comments varchar(27) NOT NULL default '',
  CustomerId varchar(27) NOT NULL default '',
  TrunkGroup varchar(63) NOT NULL default '',
  Zone varchar(29) NOT NULL default '',
  Email varchar(79) NOT NULL default '',
  ForwardedPhone varchar(63) NOT NULL default '',
  ForwardedVpnPhone varchar(63) NOT NULL default '',
  CallingPlanName varchar(59) NOT NULL default '',
  H323Id varchar(127) NOT NULL default '',
  SipUri bytea,
  SipContact bytea,
  TechPrefix varchar(63) NOT NULL default '',
  PeerGkId bytea,
  H235Password varchar(64) NOT NULL default '',
  VpnName varchar(27) NOT NULL default '',
  Ogp varchar(63) NOT NULL default '',
  IsCallRollover smallint default NULL,
  DevType int default NULL,
  Ipaddr bigint default '0',
  ForwardedVpnExtLen int default NULL,
  MaxCalls int default NULL,
  MaxInCalls int default NULL,
  MaxOutCalls int default NULL,
  Priority int default NULL,
  RasPort int default NULL,
  Q931Port int default NULL,
  CallpartyType int default NULL,
  Vendor int default NULL,
  ExtLen int default NULL,
  Subnetip bigint default NULL,
  Subnetmask bigint default NULL,
  MaxHunts int default NULL,
  ExtCaps int default NULL,
  Caps int default NULL,
  StateFlags int default NULL,
  Layer1Protocol int default NULL,
  InceptionTime bigint default NULL,
  RefreshTime bigint default NULL,
  Infotranscap int default NULL,
  Srcingresstg varchar(63) NOT NULL default '',
  IgrpName varchar(31) NOT NULL default '',
  Dtg varchar(63) NOT NULL default '',
  Newsrcdtg varchar(63) NOT NULL default '',
  NatIp bigint default NULL,
  NatPort int default NULL,
  CallIdBlock smallint default NULL,
  Bandwidth int NOT NULL default 0,
  MSWName varchar(255) NOT NULL default  '',
  CrId int,
  RealmId int,
  Redirectprotocol int,
  CallingpartyType int default NULL,
  SFlags int NOT NULL default '0',
  NSFlags int NOT NULL default '0',
  RejectTime timestamp without time zone NOT NULL default '1971-01-01 00:00:00',
  RasIp int ,
  Ports bytea default NULL,
  NPorts int ,
  CfgPorts bytea default NULL,
  NCfgPorts int ,
  QVal varchar(31) NOT NULL default '',
  Dfags int NOT NULL default '0',
  MirrorProxyToHost varchar(255) NOT NULL default '',
  MirrorProxyFromHost varchar(255) NOT NULL default '',
  OBPHost varchar(255) ,
  OBPRegistrationTime int,
  OBPRegistrationXFactor int ,
  ResolvedUriIps bytea,
  CdcPrflName varchar(32) ,
  Pt2833 int ,
  AgeTime int ,
  MpxyNonRegToHost varchar(255),
  MpxyNonRegFromHost varchar(255),
  PolicyKey int ,
  ElemKey int ,
  Ecaps2 int ,
  ClirData char(1) ,
  CallDuration int ,
  Version int NOT NULL DEFAULT 0,  
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00', 
  PRIMARY KEY  (Id),  
  UNIQUE (clusterId,serialNumber,Port),
  FOREIGN KEY (PartitionId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX endpoints_PartitionId ON endpoints (PartitionId);


CREATE TABLE users (
  UserId BigSerial NOT NULL,
  UserName varchar(32) NOT NULL default '',
  GroupId smallint NOT NULL default '-1',
  PasswordId varchar(32) default NULL,
  Cap bytea,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (UserId),
  UNIQUE (UserName), 
  UNIQUE (UserName,GroupId),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX users_GroupId ON users (GroupId);
CREATE INDEX User_Pass ON users (UserName,PasswordId);


CREATE TABLE filters (
  FilterId BigSerial,
  GroupId smallint NOT NULL default '-1',
  FilterName varchar(80) NOT NULL default '',
  UserName varchar(32) NOT NULL default '',
  TableName varchar(32) NOT NULL default '',
  Filter bytea,
  PRIMARY KEY  (FilterId),
  UNIQUE (GroupId, UserName, FilterName),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (UserName) REFERENCES users(UserName) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX UserName ON filters (UserName);


CREATE TABLE accesslist (
  ListId BigSerial,
  GroupId smallint NOT NULL default '-1',
  OwnerGroupId smallint NOT NULL default '-1',
  Realm varchar(31) NOT NULL default '',
  Endpoint varchar(67) NOT NULL default '',
  port int NOT NULL default '-1',
  RegionCode  varchar(32) NOT NULL default '',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY (ListId),
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON DELETE CASCADE,
  FOREIGN KEY (OwnerGroupId) REFERENCES groups(GroupId) ON DELETE CASCADE
) ;
CREATE INDEX OwnerGroupId ON accesslist (OwnerGroupId);


--
-- cdr table
--
CREATE TABLE cdrlogs (
  CDRLogId BigSerial NOT NULL ,
  CDRTableName varchar(32) NOT NULL default '',
  StartDateInt int NOT NULL default '0',
  EndDateInt int default '0',
  TotalCDRs int default '0',
  Status int NOT NULL default '-1',
  CreatedInt int NOT NULL default '0',
  LastInsertionInt int NOT NULL default '0',
  LastModifiedInt int NOT NULL default '0',
  PRIMARY KEY (CDRLogID),
  UNIQUE (CDRTableName)
) ;

CREATE TABLE cdrfiles (
  CDRFileId BigSerial NOT NULL,
  SrcFileName varchar(255) NOT NULL default '',
  CDRStartDateInt int NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY (CDRFileId)
) ;
CREATE INDEX SrcFileName ON cdrfiles (SrcFileName);


CREATE TABLE cdr (
  CDRId BigSerial,
  CDRLogId int NOT NULL default '0',
  MSWId smallint NOT NULL default '0',
  CDRFileId int  NOT NULL default '0',
  SrcLine int NOT NULL default '0',
  DateTimeInt int NOT NULL default '0',
  CallId varchar(128) NOT NULL default '',
  OrigGw varchar(64) NOT NULL default '',
  OrigIp bigint NOT NULL default '0',
  OrigPort smallint NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermIp bigint  NOT NULL default '0',
  TermPort smallint NOT NULL default '0',
  Duration int NOT NULL default '0',
  CallDTMF varchar(64) NOT NULL default '',
  CallE164 varchar(64) NOT NULL default '',
  LastCallNumber varchar(64) NOT NULL default '',
  NumberAfterTransit varchar(64) NOT NULL default '',
  CallType varchar(4) NOT NULL default '',
  DiscCode char(2) NOT NULL default '',
  HoldTime int NOT NULL default '0',
  PDD int NOT NULL default '0',
  Ani varchar(64) default NULL,
  NewANI varchar(64) NOT NULL default '',
  ISDNCode int NOT NULL default '0',
  ErrorIDLeg1 int default NULL,
  ErrorIDLeg2 int default NULL,
  LastEvent varchar(96) default NULL,
  SeqNum int default NULL,
  SourceQ931Port int NOT NULL default '0',
  UserId varchar(32) default NULL,
  IncomingCallId varchar(128) NOT NULL default '',
  Protocol smallint NOT NULL default '0',
  CdrType smallint NOT NULL default '0',
  HuntAttempts int NOT NULL default '0',
  OrigTG varchar(32) NOT NULL default '',
  TermTG varchar(32) NOT NULL default '',
  H323RASError int NOT NULL default '0',
  H323H225Error int NOT NULL default '0',
  SipFinalResponseCode int NOT NULL default '0',
  TZ varchar(16) NOT NULL default '',
  OrigNumberType smallint NOT NULL default '0',
  TermNumberType smallint NOT NULL default '0',
  DurationMsec bigint NOT NULL default '0',
  OrigRealm varchar(32) NOT NULL default '',
  TermRealm varchar(32) NOT NULL default '',
  CallRoute varchar(64) NOT NULL default '',
  Status smallint NOT NULL default '-1',
  StatusDesc varchar(96) NOT NULL default '',
  RegionCode varchar(32) default NULL,
  BillableFlag char(1) NOT NULL default '',
  ManipDialed varchar(64) NOT NULL default '',
  OrigDesc varchar(64) NOT NULL default '',
  OrigCountry varchar(64) NOT NULL default '',
  DestDesc varchar(64) NOT NULL default '',
  DestCountry varchar(64) NOT NULL default '',
  BuyCarrier varchar(32) NOT NULL default '',
  BuyRate numeric(10,4) NOT NULL default '0.0000',
  BuyConnectCharge numeric(10,4) NOT NULL default '0.0000',
  BuyRoundedSec int NOT NULL default '0',
  BuyPrice numeric(10,4) NOT NULL default '0.0000',
  BuyPlan varchar(32) NOT NULL default '',
  BuyRouteGroup varchar(32) NOT NULL default '',
  SellCarrier varchar(32) NOT NULL default '',
  SellRate numeric(10,4) NOT NULL default '0.0000',
  SellConnectCharge numeric(10,4) NOT NULL default '0.0000',
  SellRoundedSec int NOT NULL default '0',
  SellPrice numeric(10,4) NOT NULL default '0.0000',
  SellPlan varchar(32) NOT NULL default '',
  SellRouteGroup varchar(32) NOT NULL default '',
  UserAuth varchar(2) CHECK (UserAuth IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64')) default NULL,
  CallDstCustId varchar(64) NOT NULL default '',
  CallZoneData  varchar(64) NOT NULL default '',
  CallDstNumType varchar(64) NOT NULL default '',
  CallSrcNumType varchar(64) NOT NULL default '',
  OrigISDNCauseCode varchar(64) NOT NULL default '',
  SrcPacketsReceived int NOT NULL default '0',
  SrcPacketsLost int NOT NULL default '0',
  SrcPacketsDiscarded int NOT NULL default '0',
  SrcPDV int NOT NULL default '0',
  SrcCodec varchar(24) NOT NULL default '',
  SrcLatency int NOT NULL default '0',
  SrcRFactor smallint NOT NULL default '0',
  DstPacketsReceived int NOT NULL default '0',
  DstPacketsLost int NOT NULL default '0',
  DstPacketsDiscarded int NOT NULL default '0',
  DstPDV int NOT NULL default '0',
  DstCodec varchar(24) NOT NULL default '',
  DstLatency int NOT NULL default '0',
  DstRFactor smallint NOT NULL default '0',
  SrcSipRespcode smallint NOT NULL default '0',
  PeerProtocol varchar(24) NOT NULL default '',
  SrcPrivateIp bigint NOT NULL default '0',
  DstPrivateIp bigint NOT NULL default '0',
  SrcIgrpName varchar(24) NOT NULL default '',
  DstIgrpName varchar(24) NOT NULL default '',
  CreatedInt int NOT NULL default '0',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (CDRId),
  UNIQUE (CallId)
) ;
CREATE INDEX CDRLogId ON cdr (CDRLogId);
CREATE INDEX cdr_CDRFileId ON cdr (CDRFileId);
CREATE INDEX cdr_DateTimeInt ON cdr (DateTimeInt);


CREATE TABLE CollectorType (
  CollectorType varchar(45) NOT NULL default '',
  TransportType smallint NOT NULL default '0',
  DescriptiveName varchar(64) default NULL,
  JavaClass varchar(225) NOT NULL default '',
  PRIMARY KEY  (CollectorType)
) ;


CREATE TABLE ConsumerType (
  ConsumerType varchar(45) NOT NULL default '',
  DescriptiveName varchar(64) default NULL,
  JavaClass varchar(255) NOT NULL default '',
  PRIMARY KEY  (ConsumerType)
) ;


CREATE TABLE MappingType (
  MappingID BigSerial NOT NULL,
  MappingXMLLocation varchar(255) NOT NULL default '',
  DescriptiveName varchar(100) default NULL,
  PRIMARY KEY  (MappingID)
) ;


CREATE TABLE PipeLine (
  PipeLineID BigSerial NOT NULL,
  PipeLineDescription varchar(45) default NULL,
  PipeLineDebugLevel varchar(10) NOT NULL default '',
  CollectorType varchar(45) NOT NULL default '',
  ConsumerType varchar(45) NOT NULL default '',
  DeploymentStatus varchar(20) NOT NULL default '0',
  MappingID int NOT NULL default '0',
  NextStartTime timestamp without time zone default NULL,
  IntervalValue int default NULL,
  CreateTime timestamp without time zone default NULL,
  ModifiedTime timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  SchedulerName varchar(100) default NULL,
  AutomaticStart smallint NOT NULL default '0',
  StreamType varchar(45) NOT NULL default '',
  LastCDRProcessed timestamp without time zone default NULL,
  LastExecStatus int default 0,
  PRIMARY KEY  (PipeLineID)
) ;


CREATE TABLE CollectorParams (
  PipeLineID int NOT NULL default '0',
  Name varchar(45) NOT NULL default '',
  Value varchar(255) NOT NULL default '',
  UNIQUE (PipeLineID,Name,Value)
);


CREATE TABLE ConsumerParams (
  PipeLineID int NOT NULL default '0',
  Name varchar(45) NOT NULL default '',
  Value varchar(255) NOT NULL default '',
  UNIQUE (PipeLineID,Name,Value)
) ;


--
-- summary tables
--
CREATE TABLE cdrsummary (
  CdrSummaryId BigSerial,
  MSWId smallint NOT NULL default '0',
  CDRFileId int NOT NULL default '0',
  DateTimeInt int NOT NULL default '0',
  OrigIp bigint NOT NULL default '0',
  OrigGw varchar(64) NOT NULL default '',
  OrigPort smallint NOT NULL default '0',
  TermIp bigint NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermPort smallint NOT NULL default '0',
  DiscCode char(2) NOT NULL default '',
  RegionCode varchar(32) default NULL,
  ErrorIdLeg1 int default NULL,
  ISDNCode int NOT NULL default '0',
  CallCount int NOT NULL default '0',
  Duration bigint NOT NULL default '0',
  PDD int NOT NULL default '0',
  BuyCarrier varchar(32) NOT NULL default '',
  SellCarrier varchar(32) NOT NULL default '',
  MaxDateTimeInt int NOT NULL default '0',
  MinDateTimeInt int NOT NULL default '0',
  UserAuth varchar(2) CHECK (UserAuth IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64')) default NULL,
  SrcPacketsReceived int NOT NULL default '0',
  SrcPacketsLost int NOT NULL default '0',
  SrcPDV int NOT NULL default '0',
  SrcRFactor smallint NOT NULL default '0',
  DstPacketsReceived int NOT NULL default '0',
  DstPacketsLost int NOT NULL default '0',
  DstPDV int NOT NULL default '0',
  DstRFactor smallint NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (CdrSummaryId)
) ;
CREATE INDEX cdrsummary_DateTimeInt ON cdrsummary (DateTimeInt);
CREATE INDEX cdrsummary_CDRFileId ON cdrsummary (CDRFileId);


CREATE TABLE sellsummary (
  SellSummaryId BigSerial,
  MSWId smallint NOT NULL default '0',
  DateTimeInt int NOT NULL default '0',
  OrigDesc varchar(64) NOT NULL default '',
  RegionCode varchar(32) NOT NULL default '',
  DestCountry varchar(64) NOT NULL default '',
  SellCarrier varchar(32) NOT NULL default '',
  SellPlan varchar(32) NOT NULL default '',
  OrigIp bigint NOT NULL default '0',
  OrigGw varchar(64) NOT NULL default '',
  OrigPort smallint NOT NULL default '0',
  TermIp bigint NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermPort smallint NOT NULL default '0',
  Duration bigint NOT NULL default '0',
  PDD int NOT NULL default '0',
  SellRate numeric(10,4) NOT NULL default '0.0000',
  BuyPrice real NOT NULL default '0.0000',
  SellPrice real not null default '0.0000',
  CallCount int NOT NULL default '0',
  BillableCount int NOT NULL default '0',
  SellConnectCharge numeric(10,4) NOT NULL default '0.0000',
  SellRoundedSec bigint NOT NULL default '0',
  BuyConnectCharge numeric(10,4) NOT NULL default '0.0000',
  BuyRoundedSec bigint NOT NULL default '0',
  MaxDateTimeInt int NOT NULL default '0',
  MinDateTimeInt int NOT NULL default '0',
  UserAuth varchar(2) CHECK (UserAuth IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64')) default NULL, 
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (SellSummaryId)
);
CREATE INDEX sellsummary_DateTimeInt ON sellsummary (DateTimeInt);


CREATE TABLE buysummary (
  BuySummaryId BigSerial,
  MSWId smallint NOT NULL default '0',
  DateTimeInt int NOT NULL default '0',
  DestDesc varchar(64) NOT NULL default '',
  RegionCode varchar(32) NOT NULL default '',
  OrigCountry varchar(64) NOT NULL default '',
  BuyCarrier varchar(32) NOT NULL default '',
  BuyPlan varchar(32) NOT NULL default '',
  OrigIp bigint NOT NULL default '0',
  OrigGw varchar(64) NOT NULL default '',
  OrigPort smallint NOT NULL default '0',
  TermIp bigint NOT NULL default '0',
  TermGw varchar(64) NOT NULL default '',
  TermPort smallint NOT NULL default '0',
  Duration bigint NOT NULL default '0',
  PDD int NOT NULL default '0',
  BuyRate numeric(10,4) NOT NULL default '0.0000',
  BuyPrice real NOT NULL default '0.0000',
  SellPrice real NOT NULL default '0.0000',
  CallCount int NOT NULL default '0',
  BillableCount int NOT NULL default '0',
  BuyConnectCharge numeric(10,4) NOT NULL default '0.0000',
  BuyRoundedSec bigint NOT NULL default '0',
  SellConnectCharge numeric(10,4) NOT NULL default '0.0000',
  SellRoundedSec bigint NOT NULL default '0',
  MaxDateTimeInt int NOT NULL default '0',
  MinDateTimeInt int NOT NULL default '0',
  UserAuth varchar(2) CHECK (UserAuth IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64')) default NULL,  
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY (BuySummaryId)
) ;
CREATE INDEX buysummary_DateTimeInt ON buysummary (DateTimeInt);


--
-- other tables - license, errors and msws
--
CREATE TABLE license (
  Filename varchar(80) NOT NULL default '',
  File bytea,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (filename)
) ;


CREATE TABLE errors (
  ErrorId int NOT NULL default '0',
  ErrDesc varchar(64) NOT NULL default '',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (ErrorId)
) ;
CREATE INDEX ErrDesc ON errors (ErrDesc);


CREATE TABLE msws (
  MSWId Serial NOT NULL ,
  ClusterId smallint NOT NULL,
  MSWName varchar(32) NOT NULL default '',
  MSWIp bigint NOT NULL default '0',
  ReadPassword varchar(16) NOT NULL default '',
  WritePassword varchar(16) NOT NULL default '', 	
  Flag  smallint NOT NULL default '0',
  Description varchar(64) NOT NULL default '',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  MswUsername varchar (16),
  MswPassword varchar (16),
  MswPort int default '3306',
  MswDB varchar (32) default '127.0.0.1',
  PRIMARY KEY  (MSWId),
  UNIQUE (MSWName)
) ;


CREATE TABLE activitylogs (
  ActivityLogId BigSerial NOT NULL,
  ServiceName varchar(32) NOT NULL default '',
  ServiceId int NOT NULL,
  Reason varchar(64) NOT NULL,
  ProcessStartDate timestamp without time zone NOT NULL,
  ProcessEndDate timestamp without time zone NOT NULL,
  CdrLogId int NOT NULL,
  MaxCdrDateInt int NOT NULL default '0',
  MinCdrDateInt int NOT NULL default '0',
  TotalCDRs int NOT NULL default '0',
  AdditionalInfo bytea,
  PRIMARY KEY (ActivityLogId)
) ;
CREATE INDEX ProcessStartDate ON activitylogs (ProcessStartDate );


CREATE TABLE sessions (
  UserName varchar(32) NOT NULL,
  GroupId smallint NOT NULL default '-1',
  SessionId varchar(64) NOT NULL,
  ip bigint default '0',
  Created timestamp without time zone NOT NULL,
  PRIMARY KEY (SessionId)
) ;


CREATE TABLE tablestatus (
  tablename varchar(32) NOT NULL default '',
  status smallint NOT NULL default 0,
  PRIMARY KEY  (tablename)
) ;


CREATE TABLE routesnames (
  GroupId smallint NOT NULL default '-1',
  CallPlanNames bytea,
  CallRouteNames bytea,
  CallBindingNames bytea,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY (GroupId)
) ;


CREATE TABLE services (
  ServiceId BigSerial,
  Name varchar(32) NOT NULL,
  Type varchar(32) NOT NULL,
  Parameters bytea,
  GroupId smallint NOT NULL default '-1',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (ServiceId)
) ;


CREATE TABLE realms(
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(31) NOT NULL default '',
  IfName varchar(16) NOT NULL default '',
  VipName varchar(16) NOT NULL default '',
  RealmId bigint,
  Rsa bigint default NULL,
  Mask bigint default NULL,
  SigPoolId int default NULL,
  MedPoolId int default NULL,
  AddrType int default NULL,
  AdminStatus int default NULL,
  OpStatus int default NULL,
  Imr smallint default NULL,
  Emr smallint default NULL,
  SipAuth int default NULL,
  CidBlock varchar(15) NOT NULL default '',
  CidUnBlock varchar(15) NOT NULL default '',
  ProxyRegId varchar(67) NOT NULL default '',
  ProxyPort int NOT NULL default '0',
  VnetName varchar(16) NOT NULL default '',
  Flags int,
  RealmPanasonic int,
  Sig1qPriority int ,
  Med1qPriority  int ,
  SigIPTOS int ,
  MedIPTOS bytea ,
  Version int NOT NULL DEFAULT 0,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (Id),
  UNIQUE (ClusterId,Name),
  FOREIGN KEY (PartitionId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX realms_PartitionId ON realms (PartitionId);

CREATE TABLE trails (
  TrailId BigSerial,
  UserName varchar(32) NOT NULL default '',
  GroupId smallint NOT NULL default '-1',
  ClientAddr varchar(32) NOT NULL default '',
  DBAction varchar(32) NOT NULL default '',
  DBKey varchar(32) default NULL,
  Status varchar(32) default NULL,
  Detail bytea,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  sid varchar(64) NOT NULL default '',
  PRIMARY KEY  (TrailId)
) ;

CREATE TABLE iedgegroups (
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(31) NOT NULL default '',
  MaxIn int NOT NULL default '0',
  MaxOut int NOT NULL default '0',
  MaxTotal int NOT NULL default '0',
  MaxBwIn int NOT NULL default '0',
  MaxBwOut int NOT NULL default '0',
  MaxBwTotal int NOT NULL default '0',
  Timeout int NOT NULL default '0',
  Imr smallint NOT NULL default '-1',
  Emr smallint NOT NULL default '-1',
  XFactor smallint NOT NULL default '0',  
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (Id),
  UNIQUE (ClusterId,Name),
  FOREIGN KEY (PartitionId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX iedgegroups_PartitionId ON iedgegroups (PartitionId);


CREATE TABLE subnets(
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(67) NOT NULL default '',
  IPaddress bigint  NOT NULL default '0',
  Mask bigint  NOT NULL default '0',
  IEdgeGroupName varchar(31) NOT NULL default '',
  RealmName varchar(31) NOT NULL default '',
  Version int NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (id),
  UNIQUE (ClusterId,Name),
  FOREIGN KEY (PartitionId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX subnet_PartitionId ON subnets (PartitionId);


CREATE TABLE callingplans (
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(59) NOT NULL default '',
  Vpng varchar(79) NOT NULL default '',
  RefreshTime bigint NOT NULL default '0',
  PcpName varchar(59) NOT NULL default ' ',
  Version int NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (Id),
  UNIQUE (ClusterId,Name),
  FOREIGN KEY (PartitionId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX callingplans_PartitionId ON callingplans (PartitionId);


CREATE TABLE cpbindings (
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  CPName varchar(59) NOT NULL default '',
  CRName varchar(59) NOT NULL default '',
  RefreshTime bigint default NULL,
  StartSec int NOT NULL default '0',
  StartMin int NOT NULL default '0',
  StartHour int  NOT NULL default '0',
  StartMDay int  NOT NULL default '0',
  StartMon int  NOT NULL default '0',
  StartYear int  NOT NULL default '0',
  StartWDay int  NOT NULL default '0',
  StartYDay int  NOT NULL default '0',
  StartIsDst int  NOT NULL default '0',
  EndSec int  NOT NULL default '0',
  EndMin int  NOT NULL default '0',
  EndHour int  NOT NULL default '0',
  EndMDay int  NOT NULL default '0',
  EndMon int  NOT NULL default '0',
  EndYear int  NOT NULL default '0',
  EndWDay int  NOT NULL default '0',
  EndYDay int  NOT NULL default '0',
  EndIsDst int  NOT NULL default '0',
  Priority int  NOT NULL default '0',
  Flag int  NOT NULL default '0',
  Version int NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (Id),
  UNIQUE (ClusterId,CPName,CRName),
  FOREIGN KEY (PartitionId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX cpbindings_PartitionId ON cpbindings (PartitionId);
CREATE INDEX CPName ON cpbindings (CPName);
CREATE INDEX cpbindings_CRName ON cpbindings (CRName);


CREATE TABLE callingroutes(
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(59) NOT NULL default '',
  RefreshTime bigint NOT NULL default '0',
  Dest varchar(63) NOT NULL default '',
  Prefix varchar(63) NOT NULL default '',
  SrcPrefix varchar(63) NOT NULL default '',
  SrcPresent smallint NOT NULL default '0',
  Src varchar(63) NOT NULL default '',
  SrcLen int  NOT NULL default '0',
  DestLen int  NOT NULL default '0',
  RouteFlags int  NOT NULL default '0',
  TmpsrcPrefix varchar(47) default NULL,
  LastUseTime bigint default NULL,
  CPName varchar(59) default '',
  TRName varchar(27) default '',
  StartTime bigint,
  EndTime bigint,
  Version int NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (Id),
  UNIQUE (ClusterId,name),
  FOREIGN KEY (PartitionId) REFERENCES groups(groupId) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX callingroutes_PartitionId ON callingroutes (PartitionId);
CREATE INDEX callingroutes_CRName ON callingroutes (Name,Src,Dest);


CREATE TABLE carrierplans (
  CarrierplanId BigSerial,
  GroupId smallint NOT NULL default '-1',
  Id bigint NOT NULL default '-1',
  BuySell char(1) NOT NULL default '',
  Carrier varchar(32) NOT NULL default '',
  RouteGroup varchar(32) NOT NULL default '',
  Plan varchar(32) NOT NULL default '',
  Description varchar(64) NOT NULL default '',
  ANI varchar(32) NOT NULL default '',
  StripPrefix varchar(32) NOT NULL default '',
  PrefixDigits int NOT NULL default '0',
  AddbackDigits varchar(16) NOT NULL default '',
  RatingAddback varchar(16) NOT NULL default '',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (CarrierplanId),
  UNIQUE (Id,BuySell),
  FOREIGN KEY (Id) REFERENCES endpoints(Id) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX Carrier ON carrierplans (Carrier);
CREATE INDEX Route ON carrierplans (RouteGroup);
CREATE INDEX Plan ON carrierplans (Plan);


CREATE TABLE routes (
  RouteId BigSerial,
  GroupId smallint NOT NULL default '-1',
  RouteGroup varchar(32) NOT NULL default '',
  RegionCode  varchar(32) NOT NULL default '',
  CostCode varchar(64) NOT NULL default '',
  Description varchar(64) NOT NULL default '',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (RouteId),
  UNIQUE (GroupId,RouteGroup,RegionCode)
) ;
CREATE INDEX CostCode ON routes (CostCode );


CREATE TABLE regions (
  RegionId BigSerial,
  GroupId smallint NOT NULL default '-1',
  RegionCode varchar(32) NOT NULL default '',
  DialCode varchar(64) NOT NULL default '',
  Description varchar(64) NOT NULL default '',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (RegionId),
  UNIQUE (GroupId,RegionCode,DialCode)
) ;
CREATE INDEX DialCode ON regions (DialCode);
CREATE INDEX regions_GroupId ON regions (GroupId);


CREATE TABLE periods (
  PeriodId BigSerial,
  GroupId smallint NOT NULL default '-1',
  Period varchar(32) NOT NULL default '',
  Zone varchar(32) default NULL,
  StartWeekDays int NOT NULL default '-1',
  EndWeekDays int NOT NULL default '-1',
  StartTime TIME default NULL,
  EndTime TIME default NULL,
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY (PeriodId),
  UNIQUE (GroupId,Period)
) ;


CREATE TABLE plans (
  PlanId BigSerial,
  GroupId smallint NOT NULL default '-1',
  Plan varchar(32) NOT NULL default '',
  CostCode varchar(64) NOT NULL default '',
  DurMin int NOT NULL default '0',
  DurIncr int NOT NULL default '0',
  Rate numeric(10,4) NOT NULL default '0.0000',
  Country varchar(64) NOT NULL default '',
  ConnectionCharge numeric(10,4) NOT NULL default '0.0000',
  EffectiveStartDate timestamp without time zone default NULL,
  EffectiveEndDate timestamp without time zone default NULL,
  PeriodId bigint NOT NULL default '-1',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (PlanId),
  UNIQUE  (GroupId,Plan,CostCode,EffectiveStartDate,EffectiveEndDate,PeriodId),
  FOREIGN KEY (PeriodId) REFERENCES periods(PeriodId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX Plan_Cost_Time ON plans (Plan,CostCode,PeriodId);


CREATE TABLE ratesummary (
  RateSummaryId BigSerial,
  GroupId smallint NOT NULL default -1,
  CarrierplanId bigint NOT NULL default -1, 
  EndpointId bigint NOT NULL default '-1',
  RouteId bigint NOT NULL default -1, 
  PlanId bigint NOT NULL default -1, 
  RouteGroup varchar(32) NOT NULL default '',
  Plan varchar(32) NOT NULL default '',
  RegionCode varchar(32) NOT NULL default '',
  Carrier varchar(32) NOT NULL default '',
  CostCode varchar(64) NOT NULL default '',
  BuySell char(1) NOT NULL default '',
  Rate numeric(10,4) NOT NULL default '0.0000',
  EffectiveStartDate timestamp without time zone default NULL,
  EffectiveEndDate timestamp without time zone default NULL,
  PeriodId bigint NOT NULL default '-1',
  Period varchar(32) NOT NULL default '',
  Zone varchar(32) default NULL,
  StartWeekDays int NOT NULL default '-1',
  EndWeekDays int NOT NULL default '-1',
  StartTime TIME default NULL,
  EndTime TIME default NULL,
  Realmname varchar(31) NOT NULL default '',
  SerialNumber varchar(67) NOT NULL default '',
  port int NOT NULL default '0',
  flag smallint NOT NULL default '0',
  StripPrefix varchar(32) NOT NULL default '',
  AddbackDigits varchar(16) NOT NULL default '',
  ANI varchar(32) NOT NULL default '',
  Valid smallint NOT NULL default '1',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (RateSummaryId),
  UNIQUE (GroupId,RegionCode,EndpointId,BuySell,RouteGroup,Plan,PeriodId),  
  FOREIGN KEY (GroupId) REFERENCES groups(GroupId) ON DELETE CASCADE,
  FOREIGN KEY (CarrierplanId) REFERENCES carrierplans(CarrierplanId) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (EndpointId) REFERENCES endpoints(Id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (RouteId) REFERENCES routes(RouteId) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (PlanId) REFERENCES plans(PlanId) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (PeriodId) REFERENCES periods(PeriodId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX ratesummary_Carrier ON ratesummary (Carrier);
CREATE INDEX ratesummary_Region ON ratesummary (RegionCode);
CREATE INDEX ratesummary_CostCode ON ratesummary (CostCode);
CREATE INDEX ratesummary_Plan ON ratesummary (Plan);
CREATE INDEX Period ON ratesummary (Period);
CREATE INDEX ratesummary_GroupId ON ratesummary (GroupId);
CREATE INDEX CarrierPlanId ON ratesummary (CarrierPlanId);
CREATE INDEX Endpoint ON ratesummary (EndpointId);
CREATE INDEX PeriodId ON ratesummary (PeriodId);
CREATE INDEX RouteId ON ratesummary (RouteId);
CREATE INDEX PlanId ON ratesummary (PlanId);


CREATE TABLE vnet (
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(31) NOT NULL default '',
  IfName varchar(16) NOT NULL default '',
  VnetId bigint default NULL,
  RtgTblId bigint default NULL,
  Gateway varchar(67) NOT NULL default '',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  Version int NOT NULL default '0',
  PRIMARY KEY (Id),
  UNIQUE (ClusterId,Name),
  FOREIGN KEY (PartitionId) REFERENCES groups(groupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX vnet_PartitionId ON vnet (PartitionId);

CREATE TABLE triggers (
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(27) NOT NULL default '',
  Event int default NULL,
  Data varchar(27) NOT NULL default '',
  SrcVendor int default NULL,
  DstVendor int default NULL,
  Action int default NULL, 
  Actionflags int default NULL,
  Version int NOT NULL default '0',
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY (Id),
  UNIQUE (ClusterId,Name),
  FOREIGN KEY (PartitionId) REFERENCES groups(groupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX triggers_PartitionId ON triggers (PartitionId);
CREATE INDEX name ON triggers (Name);


CREATE TABLE cdcprofiles (
  Id BigSerial,
  PartitionId smallint NOT NULL default '-1',
  ClusterId smallint NOT NULL default '-1',
  Name varchar(31) NOT NULL,
  NumPreferred int,
  Preferrred bytea NOT NULL,
  NumProhibited int,
  Prohibited bytea NOT NULL, 
  Version int NOT NULL default '0',  
  Created timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  LastModified timestamp without time zone NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (Id),
  UNIQUE (ClusterId,Name),
  FOREIGN KEY (PartitionId) REFERENCES groups(GroupId) ON UPDATE CASCADE ON DELETE CASCADE
) ;
CREATE INDEX PartitionId ON cdcprofiles (PartitionId);

--
-- The following lines create the default entries required in iVMS tables
--
INSERT INTO groups (GroupId, GroupName, Cap, EnforceVPort, Created, LastModified ) VALUES (1,'admin','<?xml version=\'1.0\'?>\n<CAPABILITIES admin=\'true\' root=\'true\'>\n  <Report>\n  <Asr>\n      <Chromocode normal=\'60\' questionable=\'58\' />\n    </Asr>\n  <Business>\n      <Profit normal=\'5\' questionable=\'0\' />\n    </Business>\n    <Billing />\n  </Report>\n  <Endpoints read=\'false\' readwrite=\'true\' />\n  <Routes read=\'false\' readwrite=\'true\'>\n    <DialPlans readwrite=\'true\' />\n  </Routes>\n  <Rates read=\'false\' readwrite=\'true\' />\n  <Alarm ARM=\'true\'>\n    <Log read=\'false\' readwrite=\'true\' />\n    <CDR read=\'false\' readwrite=\'true\' />\n    <Actions read=\'false\' ARM=\'true\' script=\'true\' generic=\'true\' />\n  </Alarm>\n  <TimeZone>local</TimeZone>\n</CAPABILITIES>',0,now(),now());
INSERT INTO groups (GroupId, GroupName, Cap, EnforceVPort, Created, LastModified ) VALUES (-1,'','<?xml version=\'1.0\'?>\n<CAPABILITIES admin=\'true\' root=\'true\'>\n  <Report>\n  <Asr>\n      <Chromocode normal=\'60\' questionable=\'58\' />\n    </Asr>\n  <Business>\n      <Profit normal=\'5\' questionable=\'0\' />\n    </Business>\n    <Billing />\n  </Report>\n  <Endpoints read=\'false\' readwrite=\'true\' />\n  <Routes read=\'false\' readwrite=\'true\'>\n    <DialPlans readwrite=\'true\' />\n  </Routes>\n  <Rates read=\'false\' readwrite=\'true\' />\n  <Alarm ARM=\'true\'>\n    <Log read=\'false\' readwrite=\'true\' />\n    <CDR read=\'false\' readwrite=\'true\' />\n    <Actions read=\'false\' ARM=\'true\' script=\'true\' generic=\'true\' />\n  </Alarm>\n  <TimeZone>local</TimeZone>\n</CAPABILITIES>',0,now(),now());
INSERT INTO groups (GroupId, GroupName, Cap, EnforceVPort, Created, LastModified ) VALUES (-2,'*','<?xml version=\'1.0\'?>\n<CAPABILITIES admin=\'true\' root=\'true\'>\n  <Report>\n  <Asr>\n      <Chromocode normal=\'60\' questionable=\'58\' />\n    </Asr>\n  <Business>\n      <Profit normal=\'5\' questionable=\'0\' />\n    </Business>\n    <Billing />\n  </Report>\n  <Endpoints read=\'false\' readwrite=\'true\' />\n  <Routes read=\'false\' readwrite=\'true\'>\n    <DialPlans readwrite=\'true\' />\n  </Routes>\n  <Rates read=\'false\' readwrite=\'true\' />\n  <Alarm ARM=\'true\'>\n    <Log read=\'false\' readwrite=\'true\' />\n    <CDR read=\'false\' readwrite=\'true\' />\n    <Actions read=\'false\' ARM=\'true\' script=\'true\' generic=\'true\' />\n  </Alarm>\n  <TimeZone>local</TimeZone>\n</CAPABILITIES>',0,now(),now());

INSERT INTO users (UserId, UserName, GroupId, PasswordId, Cap, Created, LastModified ) VALUES (1,'root',1,'hGyVtnlrHBskPMTU5frLr59NWpU=','<?xml version=\'1.0\'?>\n<CAPABILITIES admin=\'true\' sysadmin=\'true\' root=\'true\'>\n  <Report>\n  <Asr>\n      <Chromocode normal=\'60\' questionable=\'58\' />\n    </Asr>\n  <Business>\n      <Profit normal=\'5\' questionable=\'0\' />\n    </Business>\n    <Billing />\n  </Report>\n  <Endpoints read=\'false\' readwrite=\'true\' />\n  <Routes read=\'false\' readwrite=\'true\'>\n    <DialPlans readwrite=\'true\' />\n  </Routes>\n  <Rates read=\'false\' readwrite=\'true\' />\n  <Alarm ARM=\'true\'>\n    <Log read=\'false\' readwrite=\'true\' />\n    <CDR read=\'false\' readwrite=\'true\' />\n    <Actions read=\'false\' ARM=\'true\' script=\'true\' generic=\'true\' />\n  </Alarm>\n  <TimeZone>local</TimeZone>\n</CAPABILITIES>',now(),now());

INSERT INTO endpoints (Id, PartitionId, realmname, serialNumber, port, created, lastmodified) VALUES (-1,1,'','*',-1,now(),now());

-- Insert and delete an endpoint to get around the -1 endpointid problem
-- in mysql
INSERT INTO endpoints (serialnumber, port, PartitionId, clusterid, flag) VALUES ('ep1', 0, 1, 4, 1);
DELETE FROM endpoints where serialnumber='ep1' and port=0;


INSERT INTO actions (ActionId, Name, GroupId,Type, Field1, Field2, Field3, Field4, Field5, Field6, Created,  LastModified ) VALUES (-1, 'None Action', -1, 'none', '', '', '', '', '', '', now(), now());

INSERT INTO periods (PeriodId, GroupId, Period, Zone, StartWeekDays, EndWeekDays, StartTime, EndTime, Created, LastModified ) VALUES (-1,'-1','DefaultPlan',NULL,127,127,'00:00:00','23:59:59',now(),now());

---- PIPELINE QUERIES

INSERT INTO CollectorType (CollectorType, TransportType, DescriptiveName, JavaClass ) VALUES('ExportCollector',0,'Collector agent for export stream','com.nextone.bn.cdrstream.collection.ExportCollectorAgent');

INSERT INTO CollectorType (CollectorType, TransportType, DescriptiveName, JavaClass ) VALUES('DB',0,'','com.nextone.bn.cdrstream.collection.DBCollectorAgent');

INSERT INTO CollectorType (CollectorType, TransportType, DescriptiveName, JavaClass ) VALUES('DelimitedFileType',0,'Collector Agent for delimited file','com.nextone.bn.cdrstream.collection.DelimitedFileCollectorAgent');

INSERT INTO ConsumerType (ConsumerType, DescriptiveName, JavaClass ) VALUES('Rater','Default Consumer for Import Pipeline','com.nextone.bn.cdrstream.consumer.RaterConsumer');

INSERT INTO ConsumerType (ConsumerType, DescriptiveName, JavaClass ) VALUES('CDRFileConsumer','File Consumer for CDR data','com.nextone.bn.cdrstream.consumer.CDRFileConsumer');

INSERT INTO ConsumerType (ConsumerType, DescriptiveName, JavaClass ) VALUES('CDRDBConsumer','Database Consumer for CDR data','com.nextone.bn.cdrstream.consumer.CDRDBConsumer');

