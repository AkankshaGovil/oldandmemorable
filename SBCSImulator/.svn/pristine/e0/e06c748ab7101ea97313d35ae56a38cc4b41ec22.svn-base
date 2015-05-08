#####################################################
## Use this when upgrading from NARS 2.06t2 to 2.06t4
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
select "" as "Adding index to cdr table";
alter table nars.cdrs add column Created INTEGER NOT NULL default '0', add index Created (Created);
select "" as "Altered cdrs table data";

##
## Migrate data in ratedcdr table
##

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

