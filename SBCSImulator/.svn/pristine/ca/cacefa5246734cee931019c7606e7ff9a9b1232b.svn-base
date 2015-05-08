#####################################################
## Use this when upgrading from NARS 2.00d5 to 2.06c1
#####################################################

##
## Migrate data in carriers table
##

##
## Migrate data in carrierplans table
##

##
## Migrate data in regions table
##

##
## Migrate data in routes table
##

##
## Migrate data in newrates table
##

##
## Migrate data in cdrs table
##
select "" as "Adding indexes to cdr table";
alter table nars.cdrs change Err_Desc Err_Desc VARCHAR(96) NOT NULL default '', add column Created INTEGER NOT NULL default '0', add index Err_Desc (Err_Desc), add index Date_Time_Int (Date_Time_Int), add index Created (Created);
select "" as "Altered cdrs table data";

##
## Migrate data in ratedcdr table
##
select "" as "Altering columns in ratedcdr table";
alter table nars.ratedcdr change BuyRoundedSec BuyRoundedSec INTEGER NOT NULL default 0, change SellRoundedSec SellRoundedSec INTEGER NOT NULL default 0;
select "" as "Altered columns in ratedcdr table";

##
## Migrate data in groups table
##

##
## Migrate data in users table
##

##
## Migrate data in license table
##

##
## Migrate data in alarms table
##
select "" as "Adding column to alarms table";
alter table nars.alarms add column LastModified DATETIME NOT NULL default '0000-00-00 00:00:00';
select "" as "Added column to alarms table";

##
## Migrate data in actions table
##

##
## Migrate data in events table
##

##
## Migrate data in times table
##

##
## Swap the copied tables
##

##
## drop the bakup database if necessary
##

select "" as "Deleting backup database";
%COMMENT%drop database %DBBAKNAME%;

select "" as "Done upgrading NARS database";

