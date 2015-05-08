#!/usr/bin/perl

use DBI;
use Math::BigInt;

my $maxrows = 1000;                        # Read in atmost maxrows from DB
my $done = 0;                            # Wait in an infinite loop until done
my $last_rec = Math::BigInt->new(0);    # Rec_num of last record read
my $poll_int = 60;

# sql statements
#my $sql_read = "SELECT * FROM CD";
my $sql_read = "SELECT * FROM cdrs WHERE Processed=0 ORDER BY Rec_num LIMIT ";
my $sql_update = "UPDATE cdrs SET Processed=1 WHERE Rec_num<";

# It is important that the cdrfields be listed in the same order as 
# the actual cdr's as that is how they are constructed
            
my @cdrf = (
                'Date_Time',
                'Date_Time_Int',
                'Duration',
                'Orig_IP',
                'Orig_Line',
                'Term_IP',
                'Term_Line',
                'User_ID',
                'Call_E164',
                'Call_DTMF',
                'Call_Type',
                'Call_Parties',
                'Disc_Code',
                'Err_Type',
                'Err_Desc',
                'Fax_Pages',
                'Fax_Pri',
                'ANI',
                'DNIS',
                'Bytes_Sent',
                'Bytes_Recv',
                'Seq_Num',
                'GW_Stop',
                'Call_ID',
                'Hold_Time',
                'Orig_GW',
                'Orig_Port',
                'Term_GW',
                'Term_Port',
                'ISDN_Code',
                'Last_Call_Number'
            );

my %cdrfields = map { $_ => 1 } @cdrf;
$cdrfields{'Rec_num'} = 1;    # We want this internal value also

# Setup Signal Handlers
$SIG{CHLD} = 'IGNORE';
$SIG{TERM}=$SIG{HUP}=$SIG{INT}=$SIG{PIPE} = sub {$done = 1;};

$attr = {
            'PrintError' => 0,
            'RaiseError' => 0,
            'AutoCommit' => 0,
        };

my $dbh = DBI->connect('dbi:mysql:database=nars;host=204.180.228.32',"nars","nars",$attr) 
    or die "Client : Error connecting to database ... $DBI::errstr\n";

my $sth = $dbh->prepare($sql_read.$maxrows);
my $rth;

while (!$done) {

    ##### Read the data from the database

    if ($sth->execute()) {
        do  {
            $a = $sth->fetchall_arrayref(\%cdrfields, $maxrows);
            foreach $row (@$a) {
                my $cdr='';
    
                foreach $key (@cdrf) {
                    $cdr .= "$row->{$key}:";
                }
                chop($cdr);            # remove the last ':'
    
                print STDOUT $cdr . "\n";
            }
    
            $lastrec = $row->{'Rec_num'};
        } until (!@$a);
    }
    else {
        print "$DBI::errstr \n";
    }
    
    ##### Mark the cdr records read as processed    

    $rth = $dbh->prepare($sql_update.$lastrec);
    
    if ($rth->execute()) {
    }
    else {
        print "$DBI::errstr \n";
    }
    
    sleep $poll_int;
}

$dbh->disconnect;
