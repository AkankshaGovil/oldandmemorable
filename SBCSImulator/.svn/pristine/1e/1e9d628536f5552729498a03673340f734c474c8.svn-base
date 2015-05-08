package NexTone::Trapposter;

BEGIN
{
    if ($ENV{BASE})
    {
        push(@INC, "$ENV{BASE}/lib/perl5/site_perl");
    }

    my $CurrentVersion = sprintf "%vd", $^V;
    if ($CurrentVersion lt "5.6")
    {
        push(@INC, "/usr/local/narsagent/lib/perl5/site_perl/5.005");
    }
    else
    {
        push(@INC, "/usr/local/narsagent/lib/perl5/site_perl");
    }
}

use Config::Simple;
use NexTone::Logger; # nextone logger module
use Fcntl ':flock'; # import LOCK_* constants
use IO::File;
use File::Tail;
use File::Basename;
use Cwd;

my $rsmAgentTrapName = "NEXTONE-NOTIFICATION-MIB:rsmAgentEvent";
my $sbcManagementIP = "NEXTONE-NOTIFICATION-MIB:sbcManagementIPAddr";
my $rsmAgentId = "NEXTONE-NOTIFICATION-MIB:rsmAgentId";
my $rsmAgentState = "NEXTONE-NOTIFICATION-MIB:rsmAgentState";
my $rsmAgentFailDescription = "NEXTONE-NOTIFICATION-MIB:rsmAgentFailDescription";

# set up the logger
my $Logger;
my $LOGCONFFILE=getInstallLocation()."/narslog.cfg";
if (-f "$LOGCONFFILE")
{
    $Logger = NexTone::Logger->new("$LOGCONFFILE");
} else {
    # set up some default logger
    $Logger = NexTone::Logger->new("/tmp/narsagent.log", $NexTone::Logger::INFO, {maxSize => 1048576});
}
if (! defined($Logger))
{
    print "Cannot instantiate logger \n";
    exit 0;
}

my $XFILE=getInstallLocation()."/monitorInfo";
sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self={};
    bless $self => $class;
    return $self;
}

#################################
# send and log Trap
#################################
sub sendAndLogTrap() {
    my $class = shift;
    my ($state, $errorcode) = @_;
    $class = ref($class) || $class;

    my $ip = getMgmtIP();
    my $id=getInstallLocation();
    my $error = getErrorDescription($errorcode);
    
    logTrap(undef, $ip, $id, $state, $error);
    # read the nars config file
    my $CONFILE=getInstallLocation()."/nars.cfg";
    my $trap_enable = "true";
    if ( -f $CONFILE ) {
         $trap_enable=`cat $CONFILE|grep -v "#"|grep NotificationTrapsEnabled|grep -v -i FALSE`;
    } 
    my $ProcessRunningFine = getProcessRunningFineFlag();
    if ($state ne "0") {
        markProcessRunningFineAsNO(getInstallLocation());    
    } 
    if ("$trap_enable") {
        if (($ProcessRunningFine eq "NO") && ($state eq "1")) {
            $Logger->info("Error traps should not be sent again, until the running condition is achieved.");
        } elsif (($ProcessRunningFine eq "YES") && ($state eq "0")){
            $Logger->info("Clear traps should not be sent again.");          
        } else {
            return sendTrap( $ip, $id, $state, $error);
        }
    }
    return 0;
}

#################################
# get Management IP address
#################################


sub getMgmtIP() {
    my $myMSWName = `hostname`;
    chomp($myMSWName);
    ## exception handling done for Simulator
    eval{
	my $myMgmtIP = `/usr/local/nextone/bin/nxconfig.pl -S | grep -w mgmt-ip | grep $myMSWName | tr -s ' ' | cut -d ' ' -f4`;
    	chomp($myMgmtIP);
    	if ((!defined($myMgmtIP)) || ($myMgmtIP eq "")) {
           $myMgmtIP = `/usr/local/nextone/bin/nxconfig.pl -S | grep -w mgmt-ipv6 | grep $myMSWName | tr -s ' ' | cut -d ' ' -f4`;
           chomp($myMgmtIP);
	    }
	};
    if ($@){
	my $myMgmtIP = "127.0.0.1";
	};
    return $myMgmtIP;
}


#################################
# get RSM agent installation directory 
#################################
sub getInstallLocation() {
    my $cwd;
    if ($0 =~ m{^/}) {
        $cwd = dirname($0);
    } else {
        $cwd = getcwd();
        #$cwd = dirname("$dir/$0");
    }
    return $cwd;
}

#################################
# get Error Description
# populated error description in case of .failure. cdrserver status
# populated blank in case of .failure. cdrserver status
#################################
sub getErrorDescription() {
    my @arg = @_;
    my ( $errorcode, $errordes );
    my $errorfile = getInstallLocation()."/error.properites";
    unless(open( MYFILE, $errorfile )) {
        $Logger->info("Can not open error file $errorfile");
    }
    while (<MYFILE>) {
        ( $errorcode, $errordes ) = split( "=", $_ );
        chomp($errorcode);
        chomp($errordes);
        if ($errorcode eq $arg[0]){
                close(MYFILE);
                return $errordes;

            }
        }
        close(MYFILE);
        return "";
    }
    
#################################
# send Notification trap to SNMP Agent
#################################    
sub sendTrap() {

    my ($ip, $id, $state, $error) = @_;
    
    my $snmpconf = "/etc/snmp/snmp.conf";
    my $snmpdconf = "/etc/snmp/snmpd.conf";
    my $snmptrap = "/usr/bin/snmptrap";
    

    if ( !-f $snmpconf ) {
        $Logger->info("Can not open snmp configuration file $snmpconf");
        return 1;
    }
    if ( !-f $snmpdconf ) {
        $Logger->info("Can not open snmpd configuration file $snmpdconf");
        return 1;
    }

    #get SNMP version number
    my $status =0;
    my $engineid = "";
    my $version = `grep -s "^defversion" $snmpconf | tr -s ' ' | cut -d ' ' -f2`;
    chomp($version);
    if ( !defined($version) ) {
        $Logger->info("Can not get defversion from snmpd configuration file $snmpdconf");
        return 1;
    }
    elsif ( $version eq "3" ) {
        $engineid = `grep -s "^engineID" $snmpdconf | tr -s ' ' | cut -d ' ' -f2`;
        chomp($engineid);
    }

    my @hosts = `egrep "^trap2sink|^trapsess" $snmpdconf`;
    chomp(@hosts);
    if ( !defined(@hosts) ) {
        $Logger->info("Can not get hosts from snmpd configuration file $snmpdconf");
        return 1;
    }
    
    my $value = "$sbcManagementIP s '$ip' $rsmAgentId s '$id' $rsmAgentState i '$state' $rsmAgentFailDescription s '$error'";
    my $result = 0;
    foreach my $host (@hosts) {
        $host=substr($host, rindex($host, " ")+1);
        $host=substr($host, 0, rindex($host, ":"));
        if(index($host,"[")>=0 && index($host, "]")>=0){
             $host=substr($host, index($host,"[")+1);
             $host=substr($host, 0, index($host,"]"));
        }
        chomp($host);

        if ( $version eq "1" ) {
            `$snmptrap $host NEXTONE-NOTIFICATION-MIB::nexToneTraps '' 25 25 '' $value`;
        }
        elsif ( $version eq "3" ) {
            `$snmptrap -l authNoPriv $host '' $rsmAgentTrapName $value`;
        }
        elsif ( $version eq "2c" ) {
            `$snmptrap $host '' $rsmAgentTrapName $value`;
        }
        if ($? != 0){
            $Logger->info("Failed to send trap to $host.");
            $result = 1;
        } else {
            logTrap($host, $ip, $id, $state, $error);
        }
    }

    return $result;

}

#################################
# Log Notification trap into narsagent.log
#################################    
sub logTrap() {
    my ($host, $ip, $id, $state, $error) = @_;
    if (defined($host)) {
        $Logger->info("Send Notification Trap($rsmAgentTrapName) to $host: $sbcManagementIP=$ip,$rsmAgentId=$id,$rsmAgentState=$state,$rsmAgentFailDescription=$error");    
    } else {
        $Logger->info("Log Notification Trap($rsmAgentTrapName): $sbcManagementIP=$ip,$rsmAgentId=$id,$rsmAgentState=$state,$rsmAgentFailDescription=$error");
    }
}

sub getProcessRunningFineFlag() {
    if ( -f $XFILE ) {
        my $flag=`cat $XFILE|grep -i ProcessRunningFine=NO`;
        if( $flag) {
            #only exist file and fine = no, flag = no
            return "NO";
        }
    }
    return "YES";
}

######################################
## mark ProcessRunningFine As NO
######################################
sub markProcessRunningFineAsNO() {
	my @arg          = @_;
	my $path         = $arg[0];
	my $MONITOR_FILE = "monitorInfo";
	if ( -e "$path/$MONITOR_FILE" ) {
		my $monitorinfo = `cat "$path/$MONITOR_FILE"`;
		$Logger->error("aaaaaa $monitorinfo");
		
		my $state = `head -1 "$path/$MONITOR_FILE"|grep YES`;
		if ($state) {
			my $tmp = `cat "$path/$MONITOR_FILE"|grep -v =YES`;

			if (sysopen( FILE, "$path/$MONITOR_FILE", O_WRONLY | O_APPEND | O_CREAT))
			{
				if ( flock( FILE, LOCK_EX | LOCK_NB ) ) {
					sysseek( FILE, 0, 0 );
					truncate( FILE, 0 );
					$Logger->error("aaaaaa ProcessRunningFine=NO\n$tmp");
					syswrite( FILE, "ProcessRunningFine=NO\n$tmp" );
					close(FILE);
				}
				else {
					$Logger->info("Unable to get a lock on Monitor info file:$path/$MONITOR_FILE $!");
				}
			}
			else {
				$Logger->info("Could not open Monitor info file:$path/$MONITOR_FILE $!");
			}
		}
	}
}

1;

