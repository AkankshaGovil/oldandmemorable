package NexTone::Sqlstatements;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION = 1.00;
@ISA = qw(Exporter);

use Carp;


# used to insert cdrs table entries
our $SQL_insertcdr = "INSERT INTO cdrs (" .
    "Src_File, Src_Line, MSW_ID, Status, Last_Modified, Date_Time, Date_Time_Int," .
    "Duration, Orig_IP, Source_Q931_Port, Term_IP, User_ID, Call_E164," .
    "Call_DTMF, Call_Type, Disc_Code, Err_Type, Err_Desc," .
    "ANI, Seq_Num, Call_ID, Hold_Time," .
    "Orig_GW, Orig_Port, Term_GW, Term_Port, ISDN_Code, Last_Call_Number, Err2_Type," .
    "Err2_Desc, Last_Event, New_ANI, Created)" .
    " VALUES (" .
    "?, ?, ?, ?, UNIX_TIMESTAMP(), ?, ?," .
    "?, ?, ?, ?, ?, ?," .
    "?, ?, ?, ?, ?," .
    "?, ?, ?, ?," .
    "?, ?, ?, ?, ?, ?, ?," .
    "?, ?, ?, UNIX_TIMESTAMP())";


# used to get info from carrierplans given the carrierplans.identifier
our $SQL_price = "SELECT ROUTEGROUPID, CARRIERID, PLANID, COMPANYID," .
    "PREFIXDIGITS, ADDBACKDIGITS " .
    "FROM carrierplans " .
    "WHERE IDENTIFIER = ? AND (PORT = ? OR PORT = -1) AND BUYSELL = ? ORDER BY PORT DESC";


# used to get rate information for the given planid and destcode
our $SQL_rate = "SELECT DURMIN, DURINCR, RATE, COUNTRY, " .
    "effectiveStartDate, effectiveStartZone, effectiveEndDate, effectiveEndZone, " .
    "startTimeIndex, endTimeIndex, connectionCharge " .
    "FROM newrates " .
    "WHERE PLANID = ? AND COSTCODE = ? "; 


# used to get the time from the times table
our $SQL_time = "SELECT Seconds, Minutes, Hour, Mday, Month," .
    "Year, Wday, Yday, Dst FROM times " .
    "WHERE RecordNum = ?";


# used to update the cdr table with the new processed status
our $SQL_updatecdr =  "UPDATE cdrs " .
    "SET STATUS = ?, LAST_MODIFIED = UNIX_TIMESTAMP(), STATUS_DESC = ?, REGION_CODE = ? " .
    "WHERE CALL_ID = ?"; 


# used to insert rated cdr entries
our $SQL_insertrated = "INSERT INTO ratedcdr (" .
    "UNIQUEID, BILLABLEFLAG, SELLCOMPANYID, BUYCOMPANYID, DURATION, PDD," .
    "DIALEDNUM, DESTDESC, ORIGDESC, SRCFILE, SRCLINE," .
    "CALLTYPE, ORIGIP, ORIGGW, ORIGPORT, DESTIP, DESTGW, DESTPORT," .
    "DISCONNECTREASON, DESTCOUNTRY, ORIGCOUNTRY," .
    "BUYID, BUYRATE, BUYCONNECTCHARGE, BUYROUNDEDSEC, BUYPRICE, SELLID," .
    "SELLRATE, SELLCONNECTCHARGE, SELLROUNDEDSEC, SELLPRICE, CREATED, " .
    "DATETIME, BUYPLANID, BUYROUTEGROUPID, SELLPLANID," .
    "SELLROUTEGROUPID, MANIPDIALED, REGIONCODE) " .
    "VALUES (" .
    "?, ?, ?, ?, ?, ?," .
    "?, ?, ?, ?, ?," .
    "?, ?, ?, ?, ?, ?, ?," .
    "?, ?, ?," .
    "?, ?, ?, ?, ?, ?," .
    "?, ?, ?, ?, UNIX_TIMESTAMP()," .
    "?, ?, ?, ?," .
    "?, ?, ?)";


# used to read routes and regions and create dest code cache
our $SQL_destcodecache1 = "SELECT ROUTEGROUPID, REGIONCODE," .
    "COSTCODE, DESCRIPTION " .
    "FROM routes " .
    "ORDER BY ROUTEGROUPID, REGIONCODE";
our $SQL_destcodecache2 = "SELECT DIALCODE FROM regions WHERE REGIONCODE = ?";


# used to find the last update time of the routes/regions table
our $SQL_destcodecachetime1 = "SHOW TABLE STATUS FROM nars LIKE 'routes'";
our $SQL_destcodecachetime2 = "SHOW TABLE STATUS FROM nars LIKE 'regions'";


# the column names of called number fields in a cdr entry (at source, after src cp, at dest)
our @calledNumberColumnNames = ('Call_DTMF', 'Last_Call_Number', 'Call_E164');
our $UNRATED_CDR_LIMIT = 100;
# used to get unrated cdr entries
sub getUnratedSQL
{
    my ($colName) = @_;

    return "SELECT RecordNum, Date_Time, Date_Time_Int, Orig_GW, Orig_Port, Orig_IP, Term_GW, Term_Port, Term_IP," .
        $colName .
        ", Duration, Hold_Time, Disc_Code, Call_ID, Src_File, Src_Line, Call_Type, Status " .
        "FROM cdrs WHERE STATUS != 'Rated' AND STATUS != 'DontRate'" .
        "AND RecordNum >= ? ORDER BY RecordNum LIMIT $UNRATED_CDR_LIMIT";
}


# used to get cdr entry for the given uniqueid
our $SQL_checkcdr = "SELECT RecordNum FROM cdrs WHERE Call_ID = ?"; 


# used to get the rated cdr entry for the given uniqueid
our $SQL_checkratedcdr = "SELECT Created FROM ratedcdr WHERE UniqueID = ?";


# used to update rated cdr entries
our $SQL_updateratedcdr = "UPDATE ratedcdr " .
    "SET BILLABLEFLAG = ?, SELLCOMPANYID = ?, BUYCOMPANYID = ?, DURATION = ?, PDD = ?," .
    "DIALEDNUM = ?, DESTDESC = ?, ORIGDESC = ?, SRCFILE = ?, SRCLINE = ?," .
    "CALLTYPE = ?, ORIGIP = ?, ORIGGW = ?, ORIGPORT = ?, DESTIP = ?, DESTGW = ?, DESTPORT = ?," .
    "DISCONNECTREASON = ?, DESTCOUNTRY = ?, ORIGCOUNTRY = ?," .
    "BUYID = ?, BUYRATE = ?, BUYCONNECTCHARGE = ?, BUYROUNDEDSEC = ?, BUYPRICE = ?, SELLID = ?," .
    "SELLRATE = ?, SELLCONNECTCHARGE = ?, SELLROUNDEDSEC = ?, SELLPRICE = ?, CREATED = UNIX_TIMESTAMP()," .
    "DATETIME = ?, BUYPLANID = ?, BUYROUTEGROUPID = ?, SELLPLANID = ?," .
    "SELLROUTEGROUPID = ?, MANIPDIALED = ?, REGIONCODE = ? " .
    "WHERE UNIQUEID = ?";


1;
