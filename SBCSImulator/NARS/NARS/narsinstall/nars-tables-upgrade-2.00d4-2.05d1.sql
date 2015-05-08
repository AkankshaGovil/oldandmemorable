#####################################################
## Use this when upgrading from NARS 2.00d4 to 2.05d1
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
select "" as "No data migration necessary";

select "" as "Deleting backup database";
%COMMENT%drop database %DBBAKNAME%;

select "" as "Done upgrading NARS database";

