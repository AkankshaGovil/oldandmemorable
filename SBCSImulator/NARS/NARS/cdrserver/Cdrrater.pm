package NexTone::Cdrrater;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION = 1.00;
@ISA = qw(Exporter);

use Carp;
use DBI;
use POSIX qw(strftime);

use NexTone::Sqlstatements;  # import sql statements from a different module


# some global variables
our $errstr = "";
our $cacheReloadInterval = 30;

our %callNumberTypes = ( 'FROMSRC' => 0,
                         'AFTERSRCCP' => 1,
                         'ATDEST' => 2,
                         );
our $TM_ANY = -1;


# module private variables

# the field number index for each of the called number types
my @calledNumberField = (9, 30, 8);

# cache containing destination codes
my %destcache = ();

# some temporary variables used
my ($newstatus, $statusdesc, $manip_dialed, $region_code);
my ($raw_destcode, $raw_destdesc, $raw_rounded_dur, $raw_ppm, $raw_cc, $raw_price) = ('', '', 0, 0, 0, 0);
my ($raw_carrierid, $raw_mindur, $raw_increment, $raw_routegroupid, $raw_planid) = ('', 0, 0, '', '');
my ($raw_companyid) = '';
my ($lastCacheCheckTime) = 0;   # last time we checked for updates in the db
my ($lastCacheUpdateTime1, $lastCacheUpdateTime2) = (0, 0);    # update time the dbs reported the last time we checked


###################################################################
# create and return a new rater object
# connect to the given database and prepare required SQL statements
###################################################################
sub new
{
    my $class = shift;
    my ($dbname, $user, $pass, $options, $logger, $rateCalledNumberIndex, $epl, $excludeFilter) = @_;

    $class = ref($class) || $class;

    my $self = {
        _dbh => undef,
        _sth_insertcdr => undef,
	_sth_price => undef,
	_sth_rate => undef,
        _sth_time => undef,
	_sth_updatecdr => undef,
	_sth_insertrated => undef,
	_sth_destcodecache1 => undef,
	_sth_destcodecache2 => undef,
        _sth_destcodecachetime1 => undef,
        _sth_destcodecachetime2 => undef,
        _sth_unrated => undef,
        _unratedRecNum => 0,
        _sth_checkcdr => undef,
        _sth_checkratedcdr => undef,
        _sth_updateratedcdr => undef,
        _logger => $logger,
        _calledNumberToRate => $rateCalledNumberIndex,
        _excludeEPList => undef,
        _excludeFilter => undef,
    };

    # tie the dest cache to a disk file
    eval {dbmopen(%destcache, "nars-routes", 0666)};
    if ($@)
    {
        _printError($self, "Unable to open or create the route cache on disk");
        return undef;
    }
    _printDebug($self, "created route cache on disk", $NexTone::Logger::DEBUG1);

    # connect to the database
    eval {$self->{_dbh} = DBI->connect($dbname, $user, $pass, $options)};
    if ($@)
    {
	_printError($self, "Cannot connect to the database: $DBI::errstr");
        return undef;
    }

    # prepare all the statements
    unless ($self->{_sth_insertcdr} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_insertcdr))
    {
	_printError($self, "Cannot prepare CDR insert statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
        return undef;
    }

    unless ($self->{_sth_price} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_price))
    {
	_printError($self, "Cannot prepare carrierplans statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_rate} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_rate))
    {
	_printError($self, "Cannot prepare rate statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_time} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_time))
    {
	_printError($self, "Cannot prepare time statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_updatecdr} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_updatecdr))
    {
	_printError($self, "Cannot prepare cdr update statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_insertrated} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_insertrated))
    {
	_printError($self, "Cannot prepare insert rated statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_destcodecache1} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_destcodecache1))
    {
	_printError($self, "Cannot prepare destcode cache1 statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_destcodecache2} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_destcodecache2))
    {
	_printError($self, "Cannot prepare destcode cache2 statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_destcodecachetime1} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_destcodecachetime1))
    {
	_printError($self, "Cannot prepare destcode cache time1 statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_destcodecachetime2} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_destcodecachetime2))
    {
	_printError($self, "Cannot prepare destcode cache time2 statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    my $colname = $NexTone::Sqlstatements::calledNumberColumnNames[$rateCalledNumberIndex];
    _printDebug($self, "" . (caller(0))[3] . ": will use called number in field '$colname' for rating", $NexTone::Logger::DEBUG1);
    unless ($self->{_sth_unrated} = $self->{_dbh}->prepare(NexTone::Sqlstatements::getUnratedSQL($colname)))
    {
	_printError($self, "Cannot prepare get unrated statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_checkcdr} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_checkcdr))
    {
	_printError($self, "Cannot prepare get checkcdr statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_checkratedcdr} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_checkratedcdr))
    {
	_printError($self, "Cannot prepare get checkratedcdr statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    unless ($self->{_sth_updateratedcdr} = $self->{_dbh}->prepare($NexTone::Sqlstatements::SQL_updateratedcdr))
    {
	_printError($self, "Cannot prepare cdr update statement: $DBI::errstr");
	$self->{_dbh}->disconnect;
	return undef;
    }

    # create the destination code cache
    unless (_reloadDestCodeCache($self))
    {
	_printError($self, "unable to build destination code cache");

	$self->{_dbh}->disconnect;

	return undef;
    }

    if (defined($epl)) {
        $self->{_excludeEPList} = $epl;
    }

    if (defined($excludeFilter)) {
        $self->{_excludeFilter} = $excludeFilter;
    }

    bless $self => $class;

    return $self;
}


#########################################################################
# process an individual CDR entry
#
# CDR Table Record Format:
#   Record Number (Auto incremented) - Rec_Num
#   Source CDR file name - Src_File
#   Source CDR line number - Src_Line
#   MSW ID - hostname of the machine running the agent
#   Entry Status - Status
#   Status Description - Status_Desc
#   Last Modified Date - Last_Modified
#   Processed flag (used by cdrmon) - Processed
#
# CDR Format:
#    0 - Start Date and Time of call (YYYY-MM-DD HH:MM:SS) - Date_Time
#    1 - Start Date and Time of call (in int format) - Date_Time_Int
#    2 - Duration of the call (HHH:MM:SS) - Duration
#    3 - Originator IP - Orig_IP
#    4 - Source Q.931 port - Source_Q931_Port
#    5 - Terminator IP - Term_IP
#    6 - <empty>
#    7 - Originator user ID - User_ID
#    8 - Called E.164 Number - Call_E164
#    9 - Called Number as dialed - Call_DTMF
#   10 - Call Type - Call_Type
#   11 - <empty>
#   12 - Call Disconnect Code - Disc_Code
#   13 - Error Type - Err_Type (error sent out)
#   14 - Error Description - Err_Desc
#   15 - <empty>
#   16 - <empty>
#   17 - Originator ANI - ANI  (calling party number)
#   18 - <empty>
#   19 - <empty>
#   20 - <empty>
#   21 - Sequence Number - Seq_Num
#   22 - <empty>
#   23 - Call ID - Call_ID
#   24 - Hold Time of the call (HHH:MM:SS) - Hold_Time
#   25 - Origination GW Regid - Orig_GW
#   26 - Origination GW Uport - Orig_Port
#   27 - Termination GW Regid - Term_GW
#   28 - Termination GW Uport - Term_Port
#   29 - ISDN Cause Code - ISDN_Code
#   30 - Called Number prior to destination selection - Last_Call_Number
#   31 - Leg 2 Error Type - Err2_Type (error received)
#   32 - Leg 2 Error Description - Err2_Desc
#   33 - Last Event String (<string>#<string>) - Last_Event
#   34 - New ANI - New_ANI  (calling party sent out)
#   35 - Duration of the call (in seconds) - Duration_Sec
#
#########################################################################
# return undef if the CDR entry could not be inserted, 1 otherwise
#########################################################################
sub processCDREntry
{
    my $self = shift;

    # arguments passed are (cdr entry, cdr file, cdr line number, unique callid extension, rate cdr flag, normal call duration, error call duration)
    my ($cdrEntry, $cdrFile, $cdrLine, $uniqueExt, $mswId, $rateCdrs, $normalDuration, $errorDuration) = @_;

    chomp($cdrEntry);

    my ($filtered, @filterCriteria) = _filterEntry($self, $cdrEntry);
    if ($filtered)
    {
        _printDebug($self, "" . (caller(0))[3] . ": entry filtered [$cdrFile:$cdrLine]: @filterCriteria", $NexTone::Logger::DEBUG3);
        return 1;
    }

    my @fields = split(/\;/, $cdrEntry);

    #my $hold = _tosec($fields[24]);
    my $hold = $fields[41];

    # put some value in phone number fields
    if ($fields[8] eq "")
    {
        $fields[8] = "Invalid Phone";
    }
    if ($fields[9] eq "")
    {
        $fields[9] = "Invalid Phone";
    }
    if ($fields[30] eq "")
    {
        $fields[30] = "Invalid Phone";
    }

    # make the callid unique, if needed
    if ($uniqueExt)
    {
        $fields[23] = $fields[23] . '-' . $uniqueExt;
    }

    # set defaults on any other fields that has no values
    if ($fields[25] eq "")
    {
        $fields[25] = "Unavailable";
    }
    if ($fields[27] eq "")
    {
        $fields[27] = "Unavailable";
    }
    if ($fields[34] eq "")
    {
        $fields[34] = "Unavailable";
    }

    # force a normal call
    if ($normalDuration > 0 && $fields[12] ne 'N' && $fields[35] >= $normalDuration)
    {
        _printDebug($self, "" . (caller(0))[3] . ": forcing disconnect code to normal ($cdrFile:$cdrLine), duration $fields[35]", $NexTone::Logger::DEBUG1);
        $fields[12] = 'N';
    }

    # force an error call
    if ($errorDuration > -1 && $fields[12] eq 'N' && $fields[35] <= $errorDuration)
    {
        _printDebug($self, "" . (caller(0))[3] . ": forcing disconnect code to error ($cdrFile:$cdrLine), duration $fields[35]", $NexTone::Logger::DEBUG1);
        $fields[12] = 'E';
        $fields[14] .= '(forced error, duration $fields[35])';
    }

    # set error description if none available
    if ($fields[14] eq "")
    {
        if ($fields[12] eq 'A')
        {
            $fields[14] = 'abandoned';
        }
        elsif ($fields[12] eq 'B')
        {
            $fields[14] = 'busy';
        }
        elsif ($fields[12] eq 'E')
        {
            $fields[14] = 'no-route';
        }
        else
        {
            $fields[14] = "NA";
        }
    }

    my $init_stat = _checkEPRatingStatus($self, $fields[25], $fields[26], $fields[27], $fields[28]);

    # insert the cdr into the cdrs table
    # see if the cdr is already in the table
    eval {$self->{_sth_checkcdr}->execute($fields[23])};
    if ($@)
    {
        _printError($self, "" . (caller(0))[3] . ": unable to check for existing cdr entry ($cdrFile:$cdrLine): $DBI::errstr");
        return undef;
    }
    else
    {
        # only insert if the entry is not there
        if (my (@entry) = $self->{_sth_checkcdr}->fetchrow_array)
        {
            _printWarn($self, "" . (caller(0))[3] . ": will not process duplicate cdr ($cdrFile:$cdrLine)");
        }
        else
        {
            # insert the cdr
            eval {$self->{_sth_insertcdr}->execute(
                  $cdrFile, $cdrLine, $mswId, $init_stat, $fields[0], $fields[1],
                  $fields[35], $fields[3], $fields[4], $fields[5], $fields[7], $fields[8],
                  $fields[9], $fields[10], $fields[12], $fields[13], $fields[14],
                  $fields[17], $fields[21], $fields[23], $hold,
                  $fields[25], $fields[26], $fields[27], $fields[28], $fields[29], $fields[30], $fields[31],
                  $fields[32], $fields[33], $fields[34])};
            if ($@)
            {
                _printError($self, "" . (caller(0))[3] . ": unable to insert cdr entry ($cdrFile:$cdrLine): $DBI::errstr");
                return undef;
            }
        }

        $self->{_sth_checkcdr}->finish();
    }

    $self->{_sth_insertcdr}->finish();

    # only rate cdrs if we are asked to
    if ($rateCdrs and ($init_stat ne 'DontRate'))
    {
        # check to see if we need to reload the destination code cache
        _reloadDestCodeCache($self);

        # now rate this cdr and insert it in the ratedcdr table
        _rateCdr($self, $fields[0], $fields[1], $fields[25], $fields[26], $fields[3], $fields[27], $fields[28], $fields[5], $fields[$calledNumberField[$self->{_calledNumberToRate}]], $fields[35], $hold, $fields[12], $fields[23], $cdrFile, $cdrLine, $fields[10]);
    }
    else
    {
        _printDebug($self, "" . (caller(0))[3] . ": rating disabled, will not rate cdr entry ($cdrFile:$cdrLine)", $NexTone::Logger::DEBUG3);
    }

    return 1;
}


# rate unrated cdrs from the cdr table
sub rateUnrated
{
    my $self = shift;
    my $cdrCount = 0;
    my $oldRecNum = $self->{_unratedRecNum};

    _printDebug($self, "" . (caller(0))[3] . ": rating existing unrated cdrs", $NexTone::Logger::DEBUG2);

    eval {$self->{_sth_unrated}->execute($self->{_unratedRecNum})};
    if ($@)
    {
        _printError($self, "" . (caller(0))[3] . ": unable to get unrated cdrs: $DBI::errstr");
        return undef;
    }

    while (my ($rec_num, $date_time, $date_time_int, $orig_gw, $orig_port, $orig_ip, $term_gw, $term_port, $term_ip, $calledNumber, $duration, $pdd, $disc_code, $uniqueid, $src_file, $src_line, $calltype, $status) = $self->{_sth_unrated}->fetchrow_array)
    {
        if (($status eq 'Rated') or 
			($status eq 'DontRate')) 
        {
            next;
        }
		if ((_checkEPRatingStatus($self, $orig_gw, $orig_port, $term_gw, $term_port) eq 'DontRate'))
		{
    		# update the cdr table
    		unless (_updateRawCdr($self, 'DontRate', $uniqueid, "|src:$orig_gw:$orig_port|<==>|dst:$term_gw:$term_port|", ''))
    		{
				_printError($self, "" . (caller(0))[3] . ": unable to update raw cdr: $DBI::errstr");
    		}

			next;	
		}
        _rateCdr($self, $date_time, $date_time_int, $orig_gw, $orig_port, $orig_ip, $term_gw, $term_port, $term_ip, $calledNumber, $duration, $pdd, $disc_code, $uniqueid, $src_file, $src_line, $calltype);
        $cdrCount++;
        $self->{_unratedRecNum} = $rec_num;
    }

    # if we read less than what we wanted, start from the beginning next time
    if ($cdrCount < $NexTone::Sqlstatements::UNRATED_CDR_LIMIT)
    {
        $self->{_unratedRecNum} = 0;
    }

    _printDebug($self, "" . (caller(0))[3] . ": processed $cdrCount entries bwteeen record numbers $oldRecNum and $self->{_unratedRecNum}", $NexTone::Logger::DEBUG2);

    $self->{_sth_unrated}->finish();

    return $cdrCount;
}


# reload the destination code cache is necessary
sub _reloadDestCodeCache
{
    my $self = shift;

    # see if we need to reload the destination code cache before rating the entry
    if ((time - $lastCacheCheckTime) > $cacheReloadInterval)
    {
        # update this first so that, if errors happen, we don't keep doing this
        # over and over
        $lastCacheCheckTime = time; 

        # get the update time of the routes table
        my ($updateTime1, $updateTime2) = _getRoutesTableUpdateTime($self);
        if (!defined($updateTime1) || !defined($updateTime2))
        {
            return undef;
        }

        if ($updateTime1 ne $lastCacheUpdateTime1 ||
            $updateTime2 ne $lastCacheUpdateTime2) # if the update time is different...
        {
            _printWarn($self, "need to rebuild destination cache code, old = $lastCacheUpdateTime1/$lastCacheUpdateTime2, new = $updateTime1/$updateTime2");
            unless (_buildDestCodeCache($self))
            {
                _printError($self, "unable to build new destination code cache");
                return undef;
            }

            $lastCacheUpdateTime1 = $updateTime1;
            $lastCacheUpdateTime2 = $updateTime2;
        }
    }

    return 1;
}


# find the buy price for the call
sub _getBuyPrice
{
    my $self = shift;
    my ($date_time_int, $term_ip, $term_gw, $term_port, $calledNumber, $duration) = @_;

    _printDebug($self, "" . (caller(0))[3] . ": getting buy price for $term_ip", $NexTone::Logger::DEBUG3);

    $newstatus .= 'dst:';
    $statusdesc .= 'dst:';
    my $found_buy_price = _getPrice($self, 'B', $date_time_int, $term_ip, $term_gw, $term_port, $calledNumber, $duration);

    return ($found_buy_price, $raw_destcode, $raw_destdesc, $raw_ppm, $raw_cc, $raw_rounded_dur, $raw_price, $raw_carrierid, $raw_routegroupid, $raw_planid, $raw_companyid);
}


# find the sell price for the call
sub _getSellPrice
{
    my $self = shift;
    my ($date_time_int, $orig_ip, $orig_gw, $orig_port, $calledNumber, $duration) = @_;

    _printDebug($self, "" . (caller(0))[3] . ": getting sell price for $orig_ip", $NexTone::Logger::DEBUG3);

    $newstatus .= 'src:';
    $statusdesc .= 'src:';
    my $found_sell_price = _getPrice($self, 'S', $date_time_int, $orig_ip, $orig_gw, $orig_port, $calledNumber, $duration);

    return ($found_sell_price, $raw_destcode, $raw_destdesc, $raw_ppm, $raw_cc, $raw_rounded_dur, $raw_price, $raw_carrierid, $raw_routegroupid, $raw_planid, $raw_companyid);
}


# rate the cdr and insert it into the ratedcdr table
sub _rateCdr
{
    my $self = shift;
    my ($date_time, $date_time_int, $orig_gw, $orig_port, $orig_ip, $term_gw, $term_port, $term_ip, $calledNumber, $duration, $pdd, $disc_code, $uniqueid, $src_file, $src_line, $calltype) = @_;

    my ($found_buy_price, $found_sell_price) = (0, 0);
    my $billable_flag;
    my ($buy_dest_code, $buy_dest_desc, $buy_ppm, $buy_cc, $buy_duration, $buy_price, $buy_carrierid, $buy_routegroupid, $buy_planid, $buy_companyid);
    my ($sell_dest_code, $sell_dest_desc, $sell_ppm, $sell_cc, $sell_duration, $sell_price, $sell_carrierid, $sell_routegroupid, $sell_planid, $sell_companyid);

#    print "Will rate cdr for " . $uniqueid . "\n";
#    return 1;

    $newstatus = '|';
    $statusdesc = '|';
    _resetGlobals();
    $manip_dialed = '';
    $region_code = '';

    if ($self->{_calledNumberToRate} == $callNumberTypes{'ATDEST'})
    {
        # the number requested to be rated is ATDEST, so we need to apply the
        # prefix/addback from the destination gateway to create 'manip_dialed'
        #
        # find the buy price first, so that the manip_dialed will be set
        # based on the prefix/addback from the destination gateway
        ($found_buy_price, $buy_dest_code, $buy_dest_desc, $buy_ppm, $buy_cc, $buy_duration, $buy_price, $buy_carrierid, $buy_routegroupid, $buy_planid, $buy_companyid) = _getBuyPrice($self, $date_time_int, $term_ip, $term_gw, $term_port, $calledNumber, $duration);

        $newstatus .= '|<==>|';
        $statusdesc .= '|<==>|';
        _resetGlobals();

        # find the sell price second so that it uses the previously calculated manip_dialed
        ($found_sell_price, $sell_dest_code, $sell_dest_desc, $sell_ppm, $sell_cc, $sell_duration, $sell_price, $sell_carrierid, $sell_routegroupid, $sell_planid, $sell_companyid) = _getSellPrice($self, $date_time_int, $orig_ip, $orig_gw, $orig_port, $calledNumber, $duration);
    }
    else
    {
        # the number requested to be rated is either FROMSRC or AFTERSRCCP, so
        # we need to apply the prefix/addback from the source gateway
        #
        # find the sell price first, so that the manip_dialed will be set
        # based on the prefix/addback from the source gateway
        ($found_sell_price, $sell_dest_code, $sell_dest_desc, $sell_ppm, $sell_cc, $sell_duration, $sell_price, $sell_carrierid, $sell_routegroupid, $sell_planid, $sell_companyid) = _getSellPrice($self, $date_time_int, $orig_ip, $orig_gw, $orig_port, $calledNumber, $duration);

        $newstatus .= '|<==>|';
        $statusdesc .= '|<==>|';
        _resetGlobals();

        # find the buy price seconds so that it used the previously calculated manip_dialed
        ($found_buy_price, $buy_dest_code, $buy_dest_desc, $buy_ppm, $buy_cc, $buy_duration, $buy_price, $buy_carrierid, $buy_routegroupid, $buy_planid, $buy_companyid) = _getBuyPrice($self, $date_time_int, $term_ip, $term_gw, $term_port, $calledNumber, $duration);
    }

    $newstatus .= '|';
    $statusdesc .= '|';

    _printDebug($self, "" . (caller(0))[3] . ": found_buy_price = $found_buy_price   found_sell_price = $found_sell_price", $NexTone::Logger::DEBUG2);

    if ($disc_code eq 'N')
    {
        if ($found_buy_price && $found_sell_price)
        {
            $billable_flag = 'Y';
            $newstatus = 'Rated';  # successful rating
        }
        else
        {
            _printDebug($self, "" . (caller(0))[3] . ": unable to rate cdr (not enough customer/route info) for |$uniqueid| from $src_file:$src_line ($newstatus)", $NexTone::Logger::DEBUG1);
            $billable_flag = 'E';
        }
    }
    else
    {
        _printDebug($self, "" . (caller(0))[3] . ": unable to rate cdr (incomplete call) for |$uniqueid| from $src_file:$src_line ($disc_code:$newstatus)", $NexTone::Logger::DEBUG1);
        $billable_flag = 'N';
        $newstatus = 'Rated';  # no use rating error calls again
        $statusdesc .= '-Error Call';
    }

    unless (_insertRatedCdr($self,
                            $uniqueid, $billable_flag, $sell_companyid, $buy_companyid, $duration, $pdd,
                            $calledNumber, $sell_dest_desc, $buy_dest_desc, $src_file, $src_line, $calltype,
                            $orig_ip, $orig_gw, $orig_port, $term_ip, $term_gw, $term_port, $disc_code,
                            $sell_dest_code, $buy_dest_code, $buy_carrierid, $buy_ppm, $buy_cc,
                            $buy_duration, $buy_price, $sell_carrierid, $sell_ppm, $sell_cc,
                            $sell_duration, $sell_price, $date_time,
                            $buy_planid, $buy_routegroupid, $sell_planid, $sell_routegroupid, $region_code))
    {
        _printError($self, "" . (caller(0))[3] . ": unable to insert rated cdr for: |$uniqueid| from $src_file:$src_line");
        $errstr = $DBI::errstr;
        return undef;
    }

    # update the cdr table
    unless (_updateRawCdr($self, $newstatus, $uniqueid, $statusdesc, $region_code))
    {
	_printError($self, "" . (caller(0))[3] . ": unable to update raw cdr: $DBI::errstr");
    }

    #----------do we need to commit here?
#    $self->{_dbh}->commit();

    return 1;
}


sub _getPriceForIdentifier
{
    my $self = shift;
    my ($BSFlag, $ip, $regid, $port) = @_;
    my ($routegroupid, $carrierid, $planid, $companyid, $prefixdigits, $addback);

    # first lookup ip/port
    eval {$self->{_sth_price}->execute($ip, $port, $BSFlag)};
    if ($@)
    {
        _printError($self, "" . (caller(0))[3] . ": unable to get carrierplans for $ip/$port: $DBI::errstr");
        $self->{_sth_price}->finish();
        return undef;
    }

    # if there is an entry for the ip/port, return it
    if (($routegroupid, $carrierid, $planid, $companyid, $prefixdigits, $addback) = $self->{_sth_price}->fetchrow_array)
    {
        $self->{_sth_price}->finish();
        return ($routegroupid, $carrierid, $planid, $companyid, $prefixdigits, $addback);
    }

    # if there is no entry for the ip, lookup the regid/port
    eval {$self->{_sth_price}->execute($regid, $port, $BSFlag)};
    if ($@)
    {
        _printError($self, "" . (caller(0))[3] . ": unable to get carrierplans for $regid/$port: $DBI::errstr");
        $self->{_sth_price}->finish();
        return undef;
    }

    # if there is an entry for the regid, return it
    if (($routegroupid, $carrierid, $planid, $companyid, $prefixdigits, $addback) = $self->{_sth_price}->fetchrow_array)
    {
        $self->{_sth_price}->finish();
        return ($routegroupid, $carrierid, $planid, $companyid, $prefixdigits, $addback);
    }

    # unable to find any matching carrier plan entries
    $self->{_sth_price}->finish();
    return undef;
}


sub _getPrice
{
    my $self = shift;
    my ($BSFlag, $datetime, $ip, $regid, $port, $dialednum, $dur) = @_;
    my ($price_retval) = 0;

    my ($routegroupid, $carrierid, $planid, $companyid, $prefixdigits, $addback) = _getPriceForIdentifier($self, $BSFlag, $ip, $regid, $port);
    if (defined($routegroupid))
    {
        # carrierplan entry found
        $raw_routegroupid = $routegroupid;
        $raw_carrierid = $carrierid;
        $raw_planid = $planid;
        $raw_companyid = $companyid;

        my $retv = _getDestCode($self, $routegroupid, $dialednum, $prefixdigits, $addback);
        _printDebug($self, "" . (caller(0))[3] . ": _getDestCode returning $retv", $NexTone::Logger::DEBUG3);
        if($retv)
        {
            _printDebug($self, "" . (caller(0))[3] . ": planid = $planid  destcode = $raw_destcode", $NexTone::Logger::DEBUG3);

            $retv = _getRate($self, $datetime, $planid, $raw_destcode);
            if (! defined($retv))
            {
                $newstatus .= 'RT';
                $statusdesc .= 'dberr|';
                return undef;
            }
            elsif ($retv)
            {
                $price_retval = _calculatePrice($dur, $raw_ppm, $raw_cc, $raw_increment, $raw_mindur);
                _printDebug($self, "" . (caller(0))[3] . ": price_retval = $price_retval\n", $NexTone::Logger::DEBUG3);
            }
            else
            {
                _printDebug($self, "" . (caller(0))[3] . ": RT Carrierid:$carrierid  Plan:$planid  destcode:$raw_destcode", $NexTone::Logger::DEBUG3);
                $newstatus .= 'RT';
                $statusdesc .= "$planid|$raw_destcode|";
            }
        }
        else
        {
            _printDebug($self, "" . (caller(0))[3] . ": DC Carrierid:$carrierid  Routegroup:$routegroupid  dialed:$dialednum", $NexTone::Logger::DEBUG3);
            $newstatus .= 'DC';
            $statusdesc .= "$routegroupid|$dialednum|";
        }

    }
    else
    {
        # no carrierplan entry
        _printDebug($self, "" . (caller(0))[3] . ": CP Regid:$regid  IP:$ip  BS:$BSFlag", $NexTone::Logger::DEBUG3);
        $newstatus .= 'CP';
        $statusdesc .= "$regid|$ip|$BSFlag|";		
        $raw_routegroupid = "";
        $raw_carrierid = "";
        $raw_planid = "";
        $raw_companyid = "";
    }

    return $price_retval;
}


sub _getDestCode
{
    my $self = shift;
    my ($dest_routegroupid, $dialednum, $prefixdigits, $addbackdigits) = @_;

    my ($trimmed_dialed) = _manipDialed($self, $dialednum, $prefixdigits, $addbackdigits);
    my ($buildkey, $subtrim, $cache_value, $digit_count) = ("", "", "", 0);
    my $xdestcode = 0;
    my $stop = 0;
    my $tryingcount = 0;
    my $regioncode = '';

    $raw_destcode = '';
    $raw_destdesc = '';
    _printDebug($self, "" . (caller(0))[3] . ": getting Destcode for $dest_routegroupid and $trimmed_dialed from dialed: $dialednum", $NexTone::Logger::DEBUG2);

    my $get_routes_time = (times)[0];

    $digit_count = length($trimmed_dialed);
    until (($digit_count == 0) || ($stop))
    {
        $subtrim = _getLeft($trimmed_dialed, $digit_count);
        $buildkey = $dest_routegroupid . "-" . $subtrim;
        $cache_value = $destcache{$buildkey};
        _printDebug($self, "" . (caller(0))[3] . ": looking at $buildkey", $NexTone::Logger::DEBUG3);
        if ($cache_value)
        {
            ($raw_destcode, $regioncode, $raw_destdesc) = split(/,/, $cache_value);
            _printDebug($self, "" . (caller(0))[3] . ": raw cachevalue = $cache_value  destcode = $raw_destcode  regioncode = $regioncode  destdesc = $raw_destdesc  with buildkey = $buildkey", $NexTone::Logger::DEBUG3);
            $stop = 1;
            if ($region_code eq '')
            {
                $region_code = $regioncode;
            }
        }
        $digit_count--;
        $tryingcount++;
    }
    $get_routes_time = (times)[0] - $get_routes_time;

    _printDebug($self, "" . (caller(0))[3] . ": evaluate routes: $get_routes_time    evaluated: $tryingcount", $NexTone::Logger::DEBUG3);

    if ($raw_destcode eq '')
    {
        _printDebug($self, "" . (caller(0))[3] . ": OrigNum=$dialednum  Trimmed=$trimmed_dialed", $NexTone::Logger::DEBUG3);
        return 0; 
    }

    _printDebug($self, "" . (caller(0))[3] . ": leaving destcode successfully with $raw_destcode", $NexTone::Logger::DEBUG2); 
    return 1; 
}


sub _getRate
{
    my $self = shift;
    my ($datetime, $planid, $destcode) = @_;
    my ($retval) = 0;	

    _printDebug($self, "" . (caller(0))[3] . ": getting ppm with $datetime/$planid/$destcode", $NexTone::Logger::DEBUG3);

    eval {$self->{_sth_rate}->execute($planid, $destcode)};
    if ($@)
    {
        _printError($self, "" . (caller(0))[3] . ": unable to get rate: $DBI::errstr");
        return undef;
    }

    while (my ($ppm_mindur, $ppm_durincr, $ppm_rate, $ppm_country, $startDate, $startZone, $endDate, $endZone, $startTime, $endTime, $connectionCharge) = $self->{_sth_rate}->fetchrow_array)
    {
        my $curTz = $ENV{TZ};

        # check if the start date (if one specified) makes this entry applicable
        if ($startDate) {
            if ($startZone) {
                $ENV{TZ} = $startZone;
                POSIX::tzset();
            }
            my ($y, $m, $d, $H, $M, $S) = split(/[- :]/, $startDate);
            my $st = POSIX::mktime($S, $M, $H, $d, $m-1, $y-1900);
            if ($startZone) {
                $ENV{TZ} = $curTz;
                POSIX::tzset();
            }
            if (!defined($st)) {
                _printDebug($self, "". (caller(0))[3] . ": cannot determine effective start date: $startDate", $NexTone::Logger::DEBUG3);
                next;
            }
            if ($st > $datetime) {
                _printDebug($self, "" . (caller(0))[3] . ": start date $startDate is greater than $datetime", $NexTone::Logger::DEBUG3);
                next;
            }
        }

        # check if the end date (if one specified) makes this entry applicable
        if ($endDate) {
           if ($endZone) {
                $ENV{TZ} = $endZone;
                POSIX::tzset();
            }
            my ($y, $m, $d, $H, $M, $S) = split(/[- :]/, $endDate);
            my $et = POSIX::mktime($S, $M, $H, $d, $m-1, $y-1900);
            if ($endZone) {
                $ENV{TZ} = $curTz;
                POSIX::tzset();
            }
            if (!defined($et)) {
                _printDebug($self, "". (caller(0))[3] . ": cannot determine effective end date: $endDate", $NexTone::Logger::DEBUG3);
                next;
            }
            if ($et < $datetime) {
                _printDebug($self, "" . (caller(0))[3] . ": end date $endDate is less than $datetime", $NexTone::Logger::DEBUG3);
                next;
            }
        }

        # now see if the time-of-day is applicable for this route
        my ($curSec, $curMin, $curHour, $curMday, $curMon, $curYear, $curWday, $curYday, $curDst) = localtime($datetime);
        $curYear += 1900;
        $curMon++;
        my ($st, $et) = (undef, undef);
        my ($ssec, $smin, $shour, $smday, $smonth, $syear, $swday, $syday, $sdst) = ($TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY);
        my ($esec, $emin, $ehour, $emday, $emonth, $eyear, $ewday, $eyday, $edst) = ($TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY, $TM_ANY);

        # check the start time
        if ($startTime == $TM_ANY)
        {
            $st = $datetime;
        }
        else
        {
            eval {$self->{_sth_time}->execute($startTime)};
            if ($@)
            {
                _printError($self, "" . (caller(0))[3] . ": error getting start time for index $startTime: $DBI::errstr");
                next;
            }

            if (($ssec, $smin, $shour, $smday, $smonth, $syear, $swday, $syday, $sdst) = $self->{_sth_time}->fetchrow_array)
            {
                $ssec = ($ssec == $TM_ANY)?$curSec:$ssec;
                $smin = ($smin == $TM_ANY)?$curMin:$smin;
                $shour = ($shour == $TM_ANY)?$curHour:$shour;
                $smday = ($smday == $TM_ANY)?$curMday:$smday;
                $smonth = ($smonth == $TM_ANY)?$curMon:$smonth;
                $syear = ($syear == $TM_ANY)?$curYear:$syear;
                $st = POSIX::mktime($ssec, $smin, $shour, $smday, ($smonth - 1), ($syear - 1900), $curWday, $curYday, $sdst);
                _printError($self, "" . (caller(0))[3] . ": mktime1 failed: $ssec, $smin, $shour, $smday, ($smonth - 1), ($syear - 1900), $curWday, $curYday, $sdst") unless $st;
                $self->{_sth_time}->finish();
            }
            else
            {
                _printError($self, "" . (caller(0))[3] . ": unable to get start time for index $startTime");
                $self->{_sth_time}->finish();
                next;
            }
        }

        # check the end time
        if ($endTime == $TM_ANY)
        {
            $et = $datetime;
        }
        else
        {
            eval {$self->{_sth_time}->execute($endTime)};
            if ($@)
            {
                _printError($self, "" . (caller(0))[3] . ": error getting end time for index $endTime: $DBI::errstr");
                next;
            }

            if (($esec, $emin, $ehour, $emday, $emonth, $eyear, $ewday, $eyday, $edst) = $self->{_sth_time}->fetchrow_array)
            {
                $esec = ($esec == $TM_ANY)?$curSec:$esec;
                $emin = ($emin == $TM_ANY)?$curMin:$emin;
                $ehour = ($ehour == $TM_ANY)?$curHour:$ehour;
                $emday = ($emday == $TM_ANY)?$curMday:$emday;
                $emonth = ($emonth == $TM_ANY)?$curMon:$emonth;
                $eyear = ($eyear == $TM_ANY)?$curYear:$eyear;
                $et = POSIX::mktime($esec, $emin, $ehour, $emday, ($emonth - 1), ($eyear - 1900), $curWday, $curYday, $edst);
                _printError($self, "" . (caller(0))[3] . ": mktime2 failed: $esec, $emin, $ehour, $emday, " . ($emonth - 1) . ", " . ($eyear -1900) . ", $curWday, $curYday, $edst") unless $et;
                $self->{_sth_time}->finish();
            }
            else
            {
                _printError($self, "" . (caller(0))[3] . ": unable to get start time for index $startTime");
                $self->{_sth_time}->finish();
                next;
            }
        }

        if (!defined($st) || !defined($et))
        {
            _printError($self, "" . (caller(0))[3] . ": error in mktime for start=$st/end=$et $startTime/$endTime");
            next;
        }

        # see if weekday and year-day criteria matches
        if ($swday != $TM_ANY)
        {
            $st += ($swday - $curWday)*24*60*60;
        }
        if ($ewday != $TM_ANY)
        {
            $et += ($ewday - $curWday)*24*60*60;
        }
        if ($syday != $TM_ANY)
        {
            $st += ($syday - $curYday)*24*60*60;
        }
        if ($eyday != $TM_ANY)
        {
            $et += ($eyday - $curYday)*24*60*60;
        }

        # see if call time is between start/end time
        if ( ($st < $et && ($datetime < $st || $datetime > $et)) ||
             ($st >= $et && $datetime < $st && $datetime > $et) )
        {
            _printDebug($self, "" . (caller(0))[3] . ": rate for $planid/$destcode/$startTime/$endTime/$st/$et/$datetime is currently not in a valid time period", $NexTone::Logger::DEBUG3);
            next;
        }

        # set all the global variables to use in pricing calculation
        $raw_ppm = $ppm_rate;
        $raw_cc = $connectionCharge;
        $raw_destdesc = $ppm_country;
        $raw_mindur = $ppm_mindur;
        $raw_increment = $ppm_durincr;
        $retval = 1;
        _printDebug($self, "" . (caller(0))[3] . ": found rate for $destcode/$raw_destdesc: $raw_ppm", $NexTone::Logger::DEBUG3);
        last;
    }

    $self->{_sth_rate}->finish();
    return $retval;
}


sub _calculatePrice
{
    my ($totalseconds, $ppm, $cc, $incr, $mindur) = @_;

    # calculate the rounded duration
    if ($totalseconds <= $mindur)
    {
        # this is a minimum duration call
        $raw_rounded_dur = $mindur;
    }
    else
    {
        # round this to the next increment level
        my $tmp = ($incr == 0)?0:$totalseconds % $incr;
        if ($tmp > 0)
        {
            $raw_rounded_dur = $totalseconds + $incr - $tmp;
        }
        else
        {
            $raw_rounded_dur = $totalseconds;
        }
    }

    # final price
    $raw_price = $cc + ($ppm * ($raw_rounded_dur / 60));

    return 1;
}


sub _insertRatedCdr
{
    my $self = shift;

    my ($uniqueid, $billable_flag, $sell_companyid, $buy_companyid, $duration, $pdd,
        $calledNumber, $sell_dest_desc, $buy_dest_desc, $src_file, $src_line, $calltype,
        $orig_ip, $orig_gw, $orig_port, $term_ip, $term_gw, $term_port, $disc_code,
        $sell_dest_code, $buy_dest_code, $buy_carrierid, $buy_ppm, $buy_cc,
        $buy_duration, $buy_price, $sell_carrierid, $sell_ppm, $sell_cc,
        $sell_duration, $sell_price, $date_time,
        $buy_planid, $buy_routegroupid, $sell_planid, $sell_routegroupid, $regioncode) = @_;

    _printDebug($self, "" . (caller(0))[3] . ": writing rated cdr", $NexTone::Logger::DEBUG2);

    eval {$self->{_sth_checkratedcdr}->execute($uniqueid)};
    if ($@)
    {
        _printError($self, "" . (caller(0))[3] . ": unable to check for existing rated cdr entry ($src_file:$src_line): $DBI::errstr");
        $self->{_sth_checkratedcdr}->finish();
        return undef;
    }
    else
    {
        # update if it is there, insert if it is not there
        if (my (@entry) = $self->{_sth_checkratedcdr}->fetchrow_array)
        {
            # update entry
            _printDebug($self, "" . (caller(0))[3] . ": updating cdr ($src_file:$src_line)", $NexTone::Logger::DEBUG2);

            eval {$self->{_sth_updateratedcdr}->execute(
                $billable_flag, $sell_companyid, $buy_companyid, $duration, $pdd,
                $calledNumber, $sell_dest_desc, $buy_dest_desc, $src_file, $src_line, $calltype,
                $orig_ip, $orig_gw, $orig_port, $term_ip, $term_gw, $term_port, $disc_code,
                $sell_dest_code, $buy_dest_code, $buy_carrierid, $buy_ppm, $buy_cc,
                $buy_duration, $buy_price, $sell_carrierid, $sell_ppm, $sell_cc,
                $sell_duration, $sell_price, $date_time,
                $buy_planid, $buy_routegroupid, $sell_planid, $sell_routegroupid, $manip_dialed, $regioncode, $uniqueid)};
            if ($@)
            {
                _printError($self, "" . (caller(0))[3] . ": error updating rated cdr: $DBI::errstr");
                $self->{_sth_checkratedcdr}->finish();
                return undef;
            }

            $self->{_sth_updateratedcdr}->finish();
        }
        else
        {
            # insert entry
            eval {$self->{_sth_insertrated}->execute(
                $uniqueid, $billable_flag, $sell_companyid, $buy_companyid, $duration, $pdd,
                $calledNumber, $sell_dest_desc, $buy_dest_desc, $src_file, $src_line, $calltype,
                $orig_ip, $orig_gw, $orig_port, $term_ip, $term_gw, $term_port, $disc_code,
                $sell_dest_code, $buy_dest_code, $buy_carrierid, $buy_ppm, $buy_cc,
                $buy_duration, $buy_price, $sell_carrierid, $sell_ppm, $sell_cc,
                $sell_duration, $sell_price, $date_time,
                $buy_planid, $buy_routegroupid, $sell_planid, $sell_routegroupid, $manip_dialed, $regioncode)};
            if ($@)
            {
                _printError($self, "" . (caller(0))[3] . ": error inserting rated cdr: $DBI::errstr");
                $self->{_sth_checkratedcdr}->finish();
                return undef;
            }

            $self->{_sth_insertrated}->finish();
        }
    }

    $self->{_sth_checkratedcdr}->finish();
    return 1;
}


sub _updateRawCdr
{
    my $self = shift;
    my ($update_status, $update_uniqueid, $statdesc, $regioncode) = @_;

    eval {$self->{_sth_updatecdr}->execute($update_status, $statdesc, $regioncode, $update_uniqueid)};
    if ($@)
    {
        _printError($self, "" . (caller(0))[3] . "error updating $update_uniqueid with $update_status/$statdesc/$regioncode: $DBI::errstr");
        return undef;
    }

    $self->{_sth_updatecdr}->finish();

    return 1;
}


sub _getLeft
{
    my ($str, $len) = @_;
    my ($newlen) = (length($str) - $len) * -1;
	
    if ($newlen < 0)
    {
        substr($str, $newlen) = '';
        return $str;
    }
    else
    {
        return $str;
    }
}


sub _getRight
{
    my ($str, $ind) = @_;

    $ind = $ind * -1;

    return substr($str, $ind);
}


sub _manipDialed
{
    my $self = shift;
    my ($dialed, $trim, $add) = @_;
    my $result = "";

    if (length($manip_dialed))
    {
        # if digit manipulation has already been done then just return that result
        $result = $manip_dialed;
    }
    else
    {
        if((length($dialed) == 11) && (_getLeft($dialed, 1) eq "1"))
        {
            $result = $dialed;
        }
        else
        {
            $result = _getRight($dialed, (length($dialed) - $trim));
            if ($add ne "NA")
            {
                if (!((length($result) == 11) && (_getLeft($result, 1) eq "1")))
                {
                    $result = $add . $result;
                }
            }
        }
        $manip_dialed = $result;
    }

    _printDebug($self, "" . (caller(0))[3] . ": before: |$dialed|  after: |$result|", $NexTone::Logger::DEBUG3);

    return $result;
}


sub _resetGlobals
{
    ($raw_destcode, $raw_destdesc, $raw_rounded_dur, $raw_ppm, $raw_cc, $raw_price) = ('', '', 0, 0, 0, 0);
    ($raw_carrierid, $raw_mindur, $raw_increment, $raw_routegroupid, $raw_planid, $raw_companyid) = ('', 0, 0, '', '', '');

    return 1;
}


# build a destination code cache
sub _buildDestCodeCache
{
    my $self = shift;

    my ($cache_rgroupid, $cache_keyvalue, $cache_regioncode, $cache_destcode, $cache_desc, $cache_key) = ("", "", "", "", "", "");

    _printDebug($self, "Building Destcode Cache", $NexTone::Logger::DEBUG1);
    
#    eval {$self->{_sth_destcodecache1}->execute()};
    $self->{_sth_destcodecache1}->execute();
#    if ($@)
#    {
#	_printError($self, "Cannot execute destcode cache1: $DBI::errstr");
#	return undef;
#    }

    # reset the cache
    %destcache = ();
    my $cacheCount = 0;

    while (($cache_rgroupid, $cache_regioncode, $cache_destcode, $cache_desc) = $self->{_sth_destcodecache1}->fetchrow_array)
    {
        _printDebug($self, "Getting dial codes for region = $cache_regioncode", $NexTone::Logger::DEBUG4);
        $self->{_sth_destcodecache2}->execute($cache_regioncode);
        my $cache_value = "";
        while (($cache_keyvalue) = $self->{_sth_destcodecache2}->fetchrow_array)
        {
            $cacheCount++;
            $cache_key = $cache_rgroupid . "-" . $cache_keyvalue;
            $cache_value = $cache_destcode . "," . $cache_regioncode . "," . $cache_desc;
            _printDebug($self, "Assigning: $cache_key = $cache_value", $NexTone::Logger::DEBUG4);
            $destcache{$cache_key} = $cache_value;
        }
        $self->{_sth_destcodecache2}->finish();
    }

    $self->{_sth_destcodecache1}->finish();

    _printDebug($self, "Loaded $cacheCount records in destcode cache", $NexTone::Logger::DEBUG2);

    return 1;
}


# return the update time of the routes and regions tables, empty strings on error
sub _getRoutesTableUpdateTime
{
    my $self = shift;

    eval {$self->{_sth_destcodecachetime1}->execute};
    if ($@)
    {
        _printError($self, "unable to execute dest code cache update time1: $DBI::errstr");
        $self->{_sth_destcodecachetime1}->finish();
        return undef;
    }

    my @tableInfo1 = $self->{_sth_destcodecachetime1}->fetchrow_array;
    $self->{_sth_destcodecachetime1}->finish();

    eval {$self->{_sth_destcodecachetime2}->execute};
    if ($@)
    {
        _printError($self, "unable to execute dest code cache update time2: $DBI::errstr");
        $self->{_sth_destcodecachetime2}->finish();
        return undef;
    }

    my @tableInfo2 = $self->{_sth_destcodecachetime2}->fetchrow_array;
    $self->{_sth_destcodecachetime2}->finish();

    return ($tableInfo1[11], $tableInfo2[11]);
}


sub _checkEPRatingStatus
{
	my $self = shift;
	my ($ogw, $op, $tgw, $tp) = @_;

	my $init_stat = "Unprocessed";
	my $epl = $self->{_excludeEPList};

	return $init_stat unless(defined($epl));

	foreach my $i (0..$#$epl) {
		if (	($epl->[$i]{regid} eq $ogw and (($epl->[$i]{port} eq $op) or ($epl->[$i]{port} == -1))) or 
		  		($epl->[$i]{regid} eq $tgw and (($epl->[$i]{port} eq $tp) or ($epl->[$i]{port} == -1)))) {
			return 'DontRate';
		}
	}	
	
	return $init_stat;
}


sub _filterEntry
{
    my $self = shift;
    my ($entry) = @_;

    my $filtered = 0;
    my @filterCriteria = ();

    if (defined($self->{_excludeFilter}))
    {
        my @cfs = split(/\;/, $entry);

        # first separate all the OR conditions
        my @efs = split(/[,]/, $self->{_excludeFilter});

      orfilterloop:
        foreach my $ef (@efs)
        {
            # for each OR condition, get the AND condition
            my @cond = split(/[&:]/, $ef);
            $filtered = 1;
          andfilterloop:
            for (my $i = 0; $i <= $#cond; $i += 2)
            {
                my $cdrField = $cond[$i]-1;
                my $value = $cond[$i+1];
                if ($cfs[$cdrField] ne $value)
                {
                    $filtered = 0;
                    last andfilterloop;
                }
            }

            if ($filtered == 1)
            {
                @filterCriteria = @cond;
                last orfilterloop;
            }
        }
    }

    return ($filtered, @filterCriteria);
}


#####################################
# convert HHH:MM:SS format to seconds
#####################################
sub _tosec
{
    my ($hr, $min, $sec) = split(/\:/, shift(@_));
    return ($hr*3600)+($min*60)+$sec;
}


# log an error message and set the errstr
sub _printError
{
    my $self = shift;
    $errstr = shift;

    if (defined($self->{_logger}))
    {
	$self->{_logger}->error($errstr, (caller(0)));
    }
    else
    {
        carp "" . (caller(0))[3] . ": $errstr";
    }

    return 1;
}


# log an warning message and set the errstr
sub _printWarn
{
    my $self = shift;
    $errstr = shift;

    if (defined($self->{_logger}))
    {
	$self->{_logger}->warn($errstr, (caller(0)));
    }
    else
    {
        carp "" . (caller(1))[3] . ": $errstr";
    }

    return 1;
}


# log a debug message
sub _printDebug
{
    my $self = shift;
    my $msg = shift;
    my $level = shift;

    if (defined($self->{_logger}))
    {
	$self->{_logger}->debug($msg, $level, (caller(0)));
    }

    return 1;
}

####################################################
# finish statements and disconnect from the database
####################################################
sub DESTROY
{
    my $self = shift;

    dbmclose(%destcache);

	foreach my $hdl (grep { /^_sth_/ } keys(%$self) ){
		$self->{$hdl}->finish();
	}

    $self->{_dbh}->disconnect;
}


1;

