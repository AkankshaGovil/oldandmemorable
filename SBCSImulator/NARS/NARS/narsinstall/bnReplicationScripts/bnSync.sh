#!/bin/sh -x
# Slony script to add "bn" schema to "msw" set of tables for replication
# @author: Abhishek Agrawal
# @date: Feb-16-2006

#include "CommonFunctions" script
. ./CommonFunctions.sh

bn_rep_init()
{
# initializing the  variables
CMasterNode=
TBMasterNode=
export MACHINEID=`hostname`
export CLUSTERNAME=`GetDbClusterName`
export LOCALDBNAME=`GetLocalDbName`
export REMOTEDBNAME=`GetRemoteDbName`
export CONTROLHOST=`GetLocalDbHost`
export PEERHOST=`GetRemoteDbHost`
export LOCALDBNODE=`GetLocalDbNode`
export REMOTEDBNODE=`GetRemoteDbNode`
export LOCALDBA=`GetLocalDbUser`
export REMOTEDBA=`GetRemoteDbUser`
export MASTERPORT=5432
export SLAVEPORT=5432

# determine the Master Node
DbGetRedundancyType $LOCALDBNODE $CONTROLHOST
X=$?
if [ $X -eq 1 ]; then
		CMasterNode=$LOCALDBNODE
		TBMasterNode=$REMOTEDBNODE	
		M_CONTROLHOST=$CONTROLHOST
else
	DbGetRedundancyType $REMOTEDBNODE $PEERHOST
	X=$?
	if [ $X -eq 1 ]; then
		CMasterNode=$REMOTEDBNODE
		TBMasterNode=$LOCALDBNODE
		M_CONTROLHOST=$PEERHOST
                echo "Error: The Slony script needs to run on master"
                ## In case of the installation is done on salve then this script should not continue
                return -1
  	fi
fi

# define the namespace for the replication system
slonik <<_EOF_
cluster name = $CLUSTERNAME;
# admin conninfo's are used by slonik to connect to the nodes one for each
# node on each side of the cluster.

	node 1 admin conninfo = 'dbname=$LOCALDBNAME host=$CONTROLHOST port=$MASTERPORT user=$LOCALDBA';
	node 2 admin conninfo = 'dbname=$REMOTEDBNAME host=$PEERHOST port=$SLAVEPORT user=$REMOTEDBA';

# Create a new SET for "bn" schema. MERGE it to the set defining "msw" replication set.

	try {
		create set (id=2, origin=$CMasterNode, comment='All bn tables');
	} on error {
		echo 'Could not create subscription  for replication for bn schema!';
		exit -1;
	}

#	Adding tables for replication to the set
	set add table (set id=2, origin=$CMasterNode, id=501, fully qualified name = 'bn.actions', comment='');
	set add table (set id=2, origin=$CMasterNode, id=502, fully qualified name = 'bn.alarms', comment='');
	set add table (set id=2, origin=$CMasterNode, id=503, fully qualified name = 'bn.systemalarms', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=505, fully qualified name = 'bn.ANI', comment='');
	set add table (set id=2, origin=$CMasterNode, id=506, fully qualified name = 'bn.groups', comment='');
	set add table (set id=2, origin=$CMasterNode, id=507, fully qualified name = 'bn.endpoints', comment='');
	set add table (set id=2, origin=$CMasterNode, id=508, fully qualified name = 'bn.users', comment='');
	set add table (set id=2, origin=$CMasterNode, id=509, fully qualified name = 'bn.filters', comment='');
	set add table (set id=2, origin=$CMasterNode, id=510, fully qualified name = 'bn.accesslist', comment='');
	set add table (set id=2, origin=$CMasterNode, id=511, fully qualified name = 'bn.cdrlogs', comment='');
	set add table (set id=2, origin=$CMasterNode, id=512, fully qualified name = 'bn.cdrfiles', comment='');
	set add table (set id=2, origin=$CMasterNode, id=513, fully qualified name = 'bn.cdr', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=516, fully qualified name = 'bn.MappingType', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=517, fully qualified name = 'bn.PipeLine', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=518, fully qualified name = 'bn.CollectorParams', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=519, fully qualified name = 'bn.ConsumerParams', comment='');
	set add table (set id=2, origin=$CMasterNode, id=520, fully qualified name = 'bn.cdrsummary', comment='');
	set add table (set id=2, origin=$CMasterNode, id=521, fully qualified name = 'bn.sellsummary', comment='');
	set add table (set id=2, origin=$CMasterNode, id=522, fully qualified name = 'bn.buysummary', comment='');
	set add table (set id=2, origin=$CMasterNode, id=523, fully qualified name = 'bn.license', comment='');
	set add table (set id=2, origin=$CMasterNode, id=524, fully qualified name = 'bn.errors', comment='');
	set add table (set id=2, origin=$CMasterNode, id=525, fully qualified name = 'bn.msws', comment='');
	set add table (set id=2, origin=$CMasterNode, id=526, fully qualified name = 'bn.activitylogs', comment='');
	set add table (set id=2, origin=$CMasterNode, id=527, fully qualified name = 'bn.sessions', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=528, fully qualified name = 'bn.IF NOT EXISTS tablestatus', comment='');
	set add table (set id=2, origin=$CMasterNode, id=529, fully qualified name = 'bn.services', comment='');
	set add table (set id=2, origin=$CMasterNode, id=530, fully qualified name = 'bn.realms', comment='');
	set add table (set id=2, origin=$CMasterNode, id=531, fully qualified name = 'bn.trails', comment='');
	set add table (set id=2, origin=$CMasterNode, id=532, fully qualified name = 'bn.iedgegroups', comment='');
	set add table (set id=2, origin=$CMasterNode, id=533, fully qualified name = 'bn.subnets', comment='');
	set add table (set id=2, origin=$CMasterNode, id=534, fully qualified name = 'bn.callingplans', comment='');
	set add table (set id=2, origin=$CMasterNode, id=535, fully qualified name = 'bn.callingroutes', comment='');
	set add table (set id=2, origin=$CMasterNode, id=536, fully qualified name = 'bn.cpbindings', comment='');
	set add table (set id=2, origin=$CMasterNode, id=537, fully qualified name = 'bn.routes', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=538, fully qualified name = 'bn.rates', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=539, fully qualified name = 'bn.carriers', comment='');
	set add table (set id=2, origin=$CMasterNode, id=540, fully qualified name = 'bn.regions', comment='');
	set add table (set id=2, origin=$CMasterNode, id=541, fully qualified name = 'bn.periods', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=542, fully qualified name = 'bn.ANIroutenames', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=543, fully qualified name = 'bn.iDNISroutenames', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=544, fully qualified name = 'bn.eDNISroutenames', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=545, fully qualified name = 'bn.deletedcallplans', comment='');
	set add table (set id=2, origin=$CMasterNode, id=546, fully qualified name = 'bn.vnet', comment='');
	set add table (set id=2, origin=$CMasterNode, id=547, fully qualified name = 'bn.triggers', comment='');
	set add table (set id=2, origin=$CMasterNode, id=548, fully qualified name = 'bn.cdcprofiles', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=549, fully qualified name = 'bn.dbdiff', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=550, fully qualified name = 'bn.1carriers', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=551, fully qualified name = 'bn.1routes', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=552, fully qualified name = 'bn.1rates', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=553, fully qualified name = 'bn.1carriers_old', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=554, fully qualified name = 'bn.1routes_old', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=555, fully qualified name = 'bn.1rates_old', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=556, fully qualified name = 'bn.1ANIroutenames', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=557, fully qualified name = 'bn.1iDNISroutenames', comment='');
#	set add table (set id=2, origin=$CMasterNode, id=558, fully qualified name = 'bn.1eDNISroutenames', comment='');

#	Add any sequences here. for example:
#	set add sequence (set id=2, origin=$CMasterNode, id=51, fully qualified name = 'msw.alarm_info_id_seq', comment='alarm_info_Seq table');
        subscribe set (id=2, provider=$CMasterNode,receiver=$TBMasterNode, forward=yes);

     MERGE SET ( ID = 1, ADD ID = 2, ORIGIN = $CMasterNode );
_EOF_

return $?
}
