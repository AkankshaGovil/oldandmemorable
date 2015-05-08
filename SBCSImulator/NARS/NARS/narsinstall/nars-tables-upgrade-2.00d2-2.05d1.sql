#####################################################
## Use this when upgrading from NARS 2.00d2 to 2.05d1
#####################################################

##
## Migrate data in carriers table
##
select "" as "Copying carriers table data...";
insert into %DBBAKNAME%.carriers (
  CarrierID,
  CarrierName,
  Company,
  Cycle,
  LastBillDate
) select 
  CarrierID,
  CarrierName,
  Company,
  Cycle,
  LastBillDate
from nars.carriers;
select "" as "Copied carriers table data";

##
## Migrate data in carrierplans table
##
select "" as "Copying carrierplans table data...";
insert into %DBBAKNAME%.carrierplans (
  Identifier,
  Port,
  BuySell,
  CarrierID,
  RouteGroupID,
  PlanID,
  CompanyID,
  Description,
  PrefixDigits,
  AddbackDigits
) select
  Identifier,
  Port,
  BuySell,
  CarrierID,
  RouteGroupID,
  PlanID,
  CompanyID,
  Description,
  PrefixDigits,
  AddbackDigits
from nars.carrierplans;
select "" as "Copied carrierplans table data";

##
## Migrate data in regions table
##
select "" as "Creating regions table data";
insert ignore into %DBBAKNAME%.regions (
  RegionCode,
  DialCode
) select 
  DestCode,
  KeyValue
from nars.routes;
rename table %DBBAKNAME%.regions to nars.regions;
select "" as "Created regions table data";

##
## Migrate data in routes table
##
select "" as "Copying routes table data...";
insert ignore into %DBBAKNAME%.routes (
  RouteGroupID,
  RegionCode,
  CostCode,
  Description
) select
  RouteGroupID,
  DestCode,
  DestCode,
  Description
from nars.routes group by DestCode, RouteGroupID;
select "" as "Copied routes table data";

##
## Migrate data in newrates table
##
select "" as "Copying newrates table data...";
insert into %DBBAKNAME%.newrates (
  PlanID,
  CostCode,
  DurMin,
  DurIncr,
  Rate,
  Country,
  effectiveStartDate,
  effectiveStartZone,
  effectiveEndDate,
  effectiveEndZone,
  startTimeIndex,
  endTimeIndex,
  connectionCharge
) select 
  PlanID,
  DestCode,
  DurMin,
  DurIncr,
  Rate,
  Country,
  effectiveStartDate,
  effectiveStartZone,
  effectiveEndDate,
  effectiveEndZone,
  startTimeIndex,
  endTimeIndex,
  connectionCharge
from nars.newrates;
select "" as "Copied newrates table data";

##
## Migrate data in cdrs table
##
select "" as "Copying cdrs table data...";
insert into %DBBAKNAME%.cdrs (
  Src_File,
  Src_Line,
  MSW_ID,
  Status,
  Status_Desc,
  Last_Modified,
  Processed,
  Date_Time,
  Date_Time_Int,
  Duration,
  Orig_IP,
  Source_Q931_Port,
  Term_IP,
  User_ID,
  Call_E164,
  Call_DTMF,
  Call_Type,
  Disc_Code,
  Err_Type,
  Err_Desc,
  ANI,
  Seq_Num,
  Call_ID,
  Hold_Time,
  Orig_GW,
  Orig_Port,
  Term_GW,
  Term_Port,
  ISDN_Code,
  Last_Call_Number,
  Err2_Type,
  Err2_Desc,
  Last_Event,
  New_ANI
) select
  Src_File,
  Src_Line,
  MSW_ID,
  Status,
  Status_Desc,
  Last_Modified,
  Processed,
  Date_Time,
  Date_Time_Int,
  Duration,
  Orig_IP,
  Source_Q931_Port,
  Term_IP,
  User_ID,
  Call_E164,
  Call_DTMF,
  Call_Type,
  Disc_Code,
  Err_Type,
  Err_Desc,
  ANI,
  Seq_Num,
  Call_ID,
  Hold_Time,
  Orig_GW,
  Orig_Port,
  Term_GW,
  Term_Port,
  ISDN_Code,
  Last_Call_Number,
  Err2_Type,
  Err2_Desc,
  Last_Event,
  New_ANI
from nars.cdrs;
select "" as "Copied cdrs table data";

##
## Migrate data in ratedcdr table
##
select "" as "Copying ratedcdr table data...";
insert into %DBBAKNAME%.ratedcdr (
  Created,
  SrcFile,
  SrcLine,
  Status,
  BillableFlag,
  UniqueID,
  Duration,
  PDD,
  DialedNum,
  ManipDialed,
  CallType,
  DisconnectReason,
  DateTime,
  OrigDesc,
  OrigIP,
  OrigGW,
  OrigPort,
  OrigCountry,
  DestDesc,
  DestIP,
  DestGW,
  DestPort,
  DestCountry,
  BuyCompanyID,
  BuyID,
  BuyRate,
  BuyConnectCharge,
  BuyRoundedSec,
  BuyPrice,
  BuyPlanID,
  BuyRouteGroupID,
  SellCompanyID,
  SellID,
  SellRate,
  SellConnectCharge,
  SellRoundedSec,
  SellPrice,
  SellPlanID,
  SellRouteGroupID
) select
  Created,
  SrcFile,
  SrcLine,
  Status,
  BillableFlag,
  UniqueID,
  Duration,
  PDD,
  DialedNum,
  ManipDialed,
  CallType,
  DisconnectReason,
  Date_Time,
  OrigDesc,
  OrigIP,
  OrigGW,
  OrigPort,
  OrigCountry,
  DestDesc,
  TermIP,
  TermGW,
  TermPort,
  DestinationCountry,
  BuyCompanyID,
  BuyerID,
  BuyRate,
  BuyConnectCharge,
  BuyRoundedSec,
  BuyPrice,
  BuyPlanID,
  BuyRouteGroupID,
  SellCompanyID,
  SellID,
  SellRate,
  SellConnectCharge,
  SellRoundedSeconds,
  SellPrice,
  SellPlanID,
  SellRouteGroupID
from nars.ratedcdr;
select "" as "Copied ratedcdr table data";

##
## Migrate data in groups table
##
select "" as "Copying groups table data...";
insert into %DBBAKNAME%.groups (
  GroupID,
  Endpoint,
  Port
) select
  GroupID,
  Endpoint,
  Port
from nars.groups;
select "" as "Copied groups table data";

##
## Migrate data in users table
##
select "" as "Copying users table data...";
truncate %DBBAKNAME%.users;
insert into %DBBAKNAME%.users (
  UserID,
  GroupID,
  Password,
  cap
) select
  UserID,
  GroupID,
  Password,
  cap
from nars.users;
select "" as "Copied users table data";

##
## Migrate data in license table
##
# nothing to do, table remains the same
select "" as "Leaving license table as is";

##
## Migrate data in alarms table
##
alter table nars.alarms change GroupId GroupId VARCHAR(32) NOT NULL;
alter table nars.alarms change Type Type VARCHAR(32) NOT NULL;
select "" as "Altered alarms table data";

##
## Migrate data in actions table
##
alter table nars.actions change GroupId GroupId VARCHAR(32) NOT NULL;
select "" as "Altered actions table data";

##
## Migrate data in events table
##
alter table nars.events change GroupId GroupId VARCHAR(32) NOT NULL;
select "" as "Altered events table data";

##
## Migrate data in times table
##
# nothing to do, table remains the same
select "" as "Leaving times table as is";

##
## Swap the copied tables
##
select "" as "Migrating carriers table data";
rename table nars.carriers to nars.carrierstmp, %DBBAKNAME%.carriers to nars.carriers, nars.carrierstmp to %DBBAKNAME%.carriers;
select "" as "Migrated carriers table data";

select "" as "Migrating carrierplans table data";
rename table nars.carrierplans to nars.carrierplanstmp, %DBBAKNAME%.carrierplans to nars.carrierplans, nars.carrierplanstmp to %DBBAKNAME%.carrierplans;
select "" as "Migrated carrierplans table data";

select "" as "Migrating routes table data";
rename table nars.routes to nars.routestmp, %DBBAKNAME%.routes to nars.routes, nars.routestmp to %DBBAKNAME%.routes;
select "" as "Migrated routes table data";

select "" as "Migrating newrates table data";
rename table nars.newrates to nars.newratestmp, %DBBAKNAME%.newrates to nars.newrates, nars.newratestmp to %DBBAKNAME%.newrates;
select "" as "Migrated newrates table data";

select "" as "Migrating cdrs table data";
rename table nars.cdrs to nars.cdrstmp, %DBBAKNAME%.cdrs to nars.cdrs, nars.cdrstmp to %DBBAKNAME%.cdrs;
select "" as "Migrated cdrs table data";

select "" as "Migrating ratedcdr table data";
update %DBBAKNAME%.ratedcdr set BillableFlag = 'E' where BillableFlag = 'N' and DisconnectReason = 'N';
rename table nars.ratedcdr to nars.ratedcdrtmp, %DBBAKNAME%.ratedcdr to nars.ratedcdr, nars.ratedcdrtmp to %DBBAKNAME%.ratedcdr;
select "" as "Migrated ratedcdr table data";

select "" as "Migrating groups table data";
rename table nars.groups to nars.groupstmp, %DBBAKNAME%.groups to nars.groups, nars.groupstmp to %DBBAKNAME%.groups;
select "" as "Migrated groups table data";

select "" as "Migrating users table data";
rename table nars.users to nars.userstmp, %DBBAKNAME%.users to nars.users, nars.userstmp to %DBBAKNAME%.users;
select "" as "Migrated users table data";

##
## drop the bakup database if necessary
##
select "" as "Deleting backup database";
%COMMENT%drop database %DBBAKNAME%;

select "" as "Done upgrading NARS database";

