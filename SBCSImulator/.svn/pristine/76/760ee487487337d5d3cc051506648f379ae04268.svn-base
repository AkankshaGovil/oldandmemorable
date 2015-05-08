select "" as "Migrating rating tables from NARS to iVMS";

use bn;


select "" as "Migrating groups table...";
create table narsgroups select * from nars.groups;
set @gid = 1;
insert into groups (
  GroupId,
  GroupName,
  Created,
  LastModified
) select distinct
  (@gid:=@gid+1),
  GroupID,
  now(),
  now() 
from narsgroups where narsgroups.GroupID != 'admin';
select "" as "Migrated groups table";


select "" as "Migrating endpoints table...";
create table narscarrierplans select * from nars.carrierplans;
set @gid = 1;
insert into endpoints (
  EndpointId,
  GroupId,
  Realm,
  Endpoint,
  Port,
  Created,
  LastModified
) select 
  (@gid:=@gid+1),
  groups.GroupId,
  '',
  narsgroups.Endpoint,
  narsgroups.Port,
  now(),
  now() 
from narsgroups, groups where groups.groupName = narsgroups.GroupID and !(narsgroups.Endpoint = '*' and narsgroups.Port = -1 and narsgroups.GroupID = 'admin');
drop table narsgroups;
# now insert endpoints from old carrierplans that are missing here, they all should default to admin group
# if there was an overlap, the group gets changed to admin
create table tmpendpoints select * from endpoints;
replace into endpoints (
  EndpointId,
  GroupId,
  Realm,
  Endpoint,
  Port,
  Created,
  LastModified
) select
  (@gid:=@gid+1),
  1,
  '',
  narscarrierplans.Identifier,
  narscarrierplans.Port,
  now(),
  now() 
from narscarrierplans, tmpendpoints where !(tmpendpoints.Endpoint = narscarrierplans.Identifier and tmpendpoints.Port = narscarrierplans.Port);
drop table tmpendpoints;
select "" as "Migrated endpoints table";


select "" as "Migrating users table...";
create table narsusers select * from nars.users;
insert into users (
  UserId,
  User,
  GroupId,
  Password,
  Cap,
  Created,
  LastModified
) select 
  narsusers.RecordNum,
  narsusers.UserID,
  groups.GroupId,
  narsusers.Password,
  narsusers.cap,
  now(),
  now() 
from narsusers, groups where groups.GroupName = narsusers.GroupID and narsusers.userID != 'root';
drop table narsusers;
select "" as "Migrated users table";


select "" as "Migrating actions table...";
create table narsactions select * from nars.actions;
insert into actions (
  ActionId,
  GroupId,
  Type,
  Field1,
  Field2,
  Field3,
  Field4,
  Field5,
  Field6,
  Created,
  LastModified
) select
  narsactions.Id,
  groups.GroupId,
  narsactions.Type,
  narsactions.Field1,
  narsactions.Field2,
  narsactions.Field3,
  narsactions.Field4,
  narsactions.Field5,
  narsactions.Field6,
  now(),
  now() 
from narsactions, groups where groups.GroupName = narsactions.GroupId;
drop table narsactions;
select "" as "Migrated actions table";


select "" as "Migrating alarms table...";
create table narsalarms select * from nars.alarms;
insert into alarms (
  AlarmId,
  ActionId,
  GroupId,
  Status,
  Type,
  Event,
  Created,
  LastModified
) select 
  narsalarms.Id,
  narsalarms.ActionId,
  groups.GroupId,
  narsalarms.Status,
  narsalarms.Type,
  narsalarms.Event,
  now(),
  narsalarms.LastModified 
from narsalarms, groups where groups.GroupName = narsalarms.GroupId;
drop table narsalarms;
select "" as "Migrated alarms table";


select "" as "Migrating carrierplans table...";
insert into carrierplans (
  CarrierplanId,
  EndpointId,
  BuySell,
  Carrier,
  RouteGroup,
  Plan,
  Description,
  PrefixDigits,
  AddbackDigits,
  Created,
  LastModified
) select
  narscarrierplans.RecordNum,
  endpoints.EndpointId,
  narscarrierplans.BuySell,
  narscarrierplans.CarrierID,
  narscarrierplans.RouteGroupID,
  narscarrierplans.PlanID,
  narscarrierplans.Description,
  narscarrierplans.PrefixDigits,
  narscarrierplans.AddbackDigits,
  now(),
  now()
from narscarrierplans, endpoints where endpoints.Endpoint = narscarrierplans.Identifier and endpoints.Port = narscarrierplans.Port;
drop table narscarrierplans;
select "" as "Migrated carrierplans table";


select "" as "Migrating routes table...";
insert into routes (
  RouteId,
  GroupId,
  RouteGroup,
  RegionCode,
  CostCode,
  Description,
  Created,
  LastModified
) select
  RecordNum,
  1,
  RouteGroupID,
  RegionCode,
  CostCode,
  Description,
  now(),
  now()
from nars.routes;
select "" as "Migrated routes table";


select "" as "Migrating regions table...";
insert into regions (
  RegionId,
  GroupId,
  RegionCode,
  DialCode,
  Description,
  Created,
  LastModified
) select
  RecordNum,
  1,
  RegionCode,
  DialCode,
  Description,
  now(),
  now()
from nars.regions;
select "" as "Migrated regions table";


select "" as "Migrating newrates table to periods table...";
set @pid = 0;
insert into periods (
  PeriodId,
  GroupId,
  Period,
  StartWeekDays,
  EndWeekDays,
  StartTime,
  EndTime,
  Created,
  LastModified
) select
  (@pid:=@pid+1),
  1,
  @pid,
  127,
  127,
  '00:00:00',
  '23:59:59',
  now(),
  now()
from nars.newrates where effectiveStartZone != NULL or effectiveStartZone != '' or effectiveStartDate != NULL or effectiveStartDate != '' or effectiveEndDate != NULL or effectiveEndDate != '';
select "" as "Migrated portions of newrates table to periods table, times table will not be migrated";


select "" as "Migrating newrates table to plans table...";
insert into plans (
  PlanId,
  GroupId,
  Plan,
  CostCode,
  DurMin,
  DurIncr,
  Rate,
  Country,
  ConnectionCharge,
  EffectiveStartDate,
  EffectiveEndDate,
  PeriodId,
  Created,
  LastModified
) select
  RecordNum,
  1,
  PlanID,
  CostCode,
  DurMin,
  DurIncr,
  Rate,
  Country,
  connectionCharge,
  effectiveStartDate,
  effectiveEndDate,
  -1,
  now(),
  now()
from nars.newrates;
create table narsperiods select RecordNum, effectiveStartZone, effectiveStartDate, effectiveEndDate from nars.newrates;
update plans, narsperiods, periods set
  plans.periodId = periods.periodId
where plans.PlanId = narsperiods.RecordNum and (narsperiods.effectiveStartZone <=> periods.Zone) and (narsperiods.effectiveStartDate <=> plans.EffectiveStartDate) and (narsperiods.effectiveEndDate <=> plans.EffectiveEndDate);
drop table narsperiods;
select "" as "Migrated newrates to plans table";
select "" as ">>>>>The Time-Of-Day rate setting will not be migrated, please migrate them manually<<<<<";

