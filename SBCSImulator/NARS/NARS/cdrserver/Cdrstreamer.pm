package NexTone::Cdrstreamer;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION = 1.00;
@ISA = qw(Exporter);

use Carp;
use DBI;
use POSIX qw(strftime);
use XML::Parser;
use XML::Simple;
#use Data::Dumper;
use Time::Local;

# global variables
our $errstr = '';

my $oraDate = {	'%m' => 'MM',
		'%b' => 'MON',
		'%B' => 'MONTH',
		'%d' => 'DD',
		'%a' => 'DY',
		'%Y' => 'YYYY',
		'%y' => 'YY',
		'%I' => 'HH',
		'%H' => 'HH24',
		'%M' => 'MI',
		'%S' => 'SS'
		};

my $mysqlDate = { '%A' => '%W',
                  '%a' => '%a',
                  '%B' => '%M',
                  '%b' => '%b',
                  '%D' => '%m/%d/%y',
                  '%d' => '%d',
                  '%e' => '%e',
                  '%H' => '%H',
                  '%h' => '%b',
                  '%I' => '%I',
                  '%j' => '%j',
                  '%k' => '%k',
                  '%l' => '%l',
                  '%M' => '%i',
                  '%m' => '%m',
                  '%p' => '%p',
                  '%R' => '%H:%i',
                  '%r' => '%r',
                  '%S' => '%S',
                  '%T' => '%T',
                  '%U' => '%U',
                  '%V' => '%v',
                  '%v' => '%e-%b-%Y',
                  '%W' => '%u',
                  '%w' => '%w',
                  '%Y' => '%Y',
                  '%y' => '%y'
                  };

my $vars = { 'CDRFILE' => '',
             'CDRLINE' => '',
             'MSWID' => '',
             'DATETIME' => ''
             };

# Type of Streamer
my $StType = { 'DB' => 1,
			   'FL' => 2
			 };

sub _convert2OracleDate
{
    my ($fmt) = @_;

    foreach my $k (keys %$oraDate)
    {
        $fmt =~ s/$k/$oraDate->{$k}/;
    }

    return $fmt;
}


sub _convert2MysqlDate
{
    my ($fmt) = @_;

    foreach my $k (keys %$mysqlDate)
    {
        $fmt =~ s/$k/$mysqlDate->{$k}/;
    }

    return $fmt;
}


##########################################################
# create a new streamer object
# parse the configuration file and connect to the database
##########################################################
sub new
{
    my $class = shift;
    my ($configFile, $logger) = @_;

    $class = ref($class) || $class;

    my $self = {
		_type => undef,
        _config => undef,
        _transforms => undef,
        _indep => undef,
        _dbh => undef,
        _sth_insert => undef,
        _sth_delete => undef,
		_fh	=>	undef,
		_col_names => undef,
		_output_order => undef,
        _logger => $logger,
        errstr => '',
        id => '',
    };

    unless (-f $configFile)
    {
        $errstr = "Unable to read file: $configFile";
        return undef;
    }

    eval { _parseConfigFile($self, $configFile) };
    if ($@)
    {
        $errstr = $@;
        return undef;
    }

    unless (_validateConfigFile($self))
    {
        return undef;
    }

	if ($self->{_type} == $StType->{DB})
	{
		return undef unless _DBInit($self);
	}

	if ($self->{_type} == $StType->{FL})
	{
		return undef unless _FLInit($self);
	}

    bless $self => $class;

    return $self;
}

sub _DBInit
{
	my $self = shift;

    my $insertStmt = undef;
    my $deleteStmt = undef;
    ($insertStmt, $deleteStmt) = _createSQLStatement($self);
    unless ($insertStmt)
    {
        return undef;
    }

    # connect to the database
	my $dbconf = $self->{_config}->{db}[0];
	unless ($dbconf) {
		$errstr = "Cannot find Database configuration";
		return undef;
	}

    unless ($self->{_dbh} = DBI->connect($dbconf->{dburl}, $dbconf->{dbuser}, $dbconf->{dbpass},
                                         {PrintError => 1,
                                          RaiseError => 1,
                                          AutoCommit => 1}))
    {
        $errstr = "Cannot connect to the database: $DBI::errstr";
        return undef;
    }

    # prepare the statements
    unless ($self->{_sth_insert} = $self->{_dbh}->prepare($insertStmt))
    {
        $errstr = "Cannot prepare insert statement: $DBI::errstr";
        $self->{_dbh}->disconnect();
        return undef;
    }
    if ($deleteStmt)
    {
        unless ($self->{_sth_delete} = $self->{_dbh}->prepare($deleteStmt))
        {
            $errstr = "Cannot prepare delete statement: $DBI::errstr";
            $self->{_sth_insert}->finish();
            $self->{_dbh}->disconnect();
            return undef;
        }
    }
    else
    {
        $self->{_sth_delete} = undef;
    }

	return 1;
}

sub _FLInit
{
	my $self = shift;

	unless (@_) {
		# we should get here only the first time
    	my $coln = _createSQLStatement($self, 1);
		return undef unless ($coln);
		$self->{_col_names} = $coln;
		
		my $colo = _getOutputFormat($self);
		return undef unless ($colo);
		$self->{_output_order} = $colo;
		return 1;
	}

	# passed a filename to it	
	my $cdrf = shift;
	my $outf = "";

	if ($cdrf =~ /(\d+)/) {
		$outf = $1;
	}
	else {
		$self->{_logger}->warn($self->{id} . ": Unknown input CDR filename format for $cdrf. Writing to fixed format file\n");
	}

	my $fh;
   	my $filec = $self->{_config}->{file}[0];
	$outf = $filec->{dir} . "/" . $filec->{prefix} . $outf .$filec->{suffix};
	if (-f $outf) {
       	$self->{_logger}->warn($self->{id} . ": CDR outfile $outf already exists\n");
	}
	unless (open($fh, ">>", $outf)) {
      	$errstr = "Cannot open file $outf: $!";
       	return undef;
   	}
	autoflush $fh 1;

	close($self->{_fh}) if ($self->{_fh});
	$self->{_fh} = $fh;

	return 1;
}

sub _getOutputFormat
{
	my $self = shift;
	my $col = [];

	my $numfmts = $self->{_config}->{OUTPUT};
	if ($#$numfmts != 0) {
        $errstr = "Need one (and only one) <OUTPUT> element, found $#$numfmts";
		return undef;
	}

	unless ($self->{_col_names}) {
		$errstr = "the column names are not defined";
		return undef;
	}
	
	my $of = $numfmts->[0]{field};
	foreach my $k (keys(%$of)) {
		if (defined($of->{$k}{subfield})) {
			# this one has subfield
			my $cf = [];
			my $sf = $of->{$k}{subfield};
			foreach my $j (keys(%$sf)) {
				$cf->[$sf->{$j}{no} - 1] = $self->{_col_names}{$j};	
			}
			$col->[$of->{$k}{no} - 1] = { 'separator' => $of->{$k}{separator}, 'subfield' => $cf};
		}
		else {
			$col->[$of->{$k}{no} - 1] = $self->{_col_names}{$k}; 
		}
	}

	return $col;
}

sub _parseConfigFile
{
    my ($self, $configFile) = @_;

    my $xs = new XML::Simple();
    $self->{_config} = $xs->XMLin($configFile, forcearray => 1, KeyAttr => []);
}

sub _validateConfigFile
{
    my $self = shift;

    # need one CDR element
    my $numCDRs = $self->{_config}->{CDR};
    if ($#$numCDRs != 0)
    {
        $errstr = "Need one (and only one) <CDR> element, found $#$numCDRs";
        return undef;
    }

    # need one db element
	# or one file element
    my $numDbs = $self->{_config}->{db};
    my $numFiles = $self->{_config}->{file};
    unless (($#$numDbs == 0) xor ($#$numFiles == 0))
    {
        $errstr = "Need one (and only one) <db> or <file> element, found $#$numDbs <db> and $#$numFiles <file>";
        return undef;
    }

	if ($#$numDbs == 0) {
		# Streaming to a database 
		$self->{_type} = $StType->{DB};

		return undef unless _validateDBConfig($self);
	}

	if ($#$numFiles == 0) {
		# Streaming to a File 
		$self->{_type} = $StType->{FL};

		return undef unless _validateFLConfig($self);
	}

	return 1;
}

sub _validateDBConfig
{
	my $self = shift;

	# validate database information
    my $dbc = $self->{_config}->{db}[0];
	
    $dbc->{dbuser} = 'root'		unless ($dbc->{dbuser});
    $dbc->{dbpass} = ''			unless ($dbc->{dbpass});

	unless ($dbc->{dburl}) {	
    	if ($dbc->{dbtype} =~ /mysql/i) 
		{
			unless($dbc->{dbname})
    		{
				$errstr = 'Need to specify a database name';
				return undef;
			}
		}
    	if ($dbc->{dbtype} =~ /oracle/i)
		{
			unless ($dbc->{dbsid})
			{
				$errstr = 'Need to specify a sid';
				return undef;
			}
		}

	    	$dbc->{dbhost} = '127.0.0.1' unless ($dbc->{dbhost});
    	$dbc->{dbtype} = 'mysql'	unless ($dbc->{dbtype});

		### Create the url right here
		$dbc->{dburl} = "DBI:$dbc->{dbtype}:host=$dbc->{dbhost}";
    	if ($dbc->{dbtype} =~ /mysql/i)
		{
			$dbc->{dburl} = "$dbc->{dburl};database=$dbc->{dbname}";
		}
    	if ($dbc->{dbtype} =~ /oracle/i) 
			{
			$dbc->{dburl} = "$dbc->{dburl};sid=$dbc->{dbsid}";
		}
	}

    unless ($dbc->{dbtable})
    {
        $errstr = 'Need to specify a database table name';
        return undef;
	}
	
    $self->{id} = "$dbc->{dburl}:$dbc->{dbtable}";
	
	return 1;
}

sub _validateFLConfig
{
	my $self = shift;

    # validate output file information
    my $filec = $self->{_config}->{file}[0];

    $filec->{dir} = '.'				unless ($filec->{dir});
    $filec->{separator} = ':'		unless ($filec->{separator});
    $filec->{prefix} = 'P'			unless ($filec->{prefix});
    $filec->{suffix} = '.CDR'		unless ($filec->{suffix});

	return undef unless (-d $filec->{dir});	

	$self->{id} = $filec->{dir};	
	
	return 1;
}

sub _createSQLStatement
{
    my $self = shift;
	
	# If no database defined then _createSQLStatement creates an array of column
	# names instead of the statement
	my $nodb;
	$nodb = 1 if (@_);
	$self->{_transforms} = ();

    my $insertStmt = 'INSERT INTO ';
    my $insertValue = '';
    my $deleteStmt = 'DELETE FROM ';

	my $colnames = {};
	my $col_ind = 0;

    # append table name
    $insertStmt .= $self->{_config}->{db}[0]->{dbtable};
    $deleteStmt .= $self->{_config}->{db}[0]->{dbtable};

    $insertStmt .= ' (';
    $deleteStmt .= ' WHERE ';

    # append field names
    my $fields = $self->{_config}->{CDR}[0]->{field};
    my $insertFieldCount = 0;
    my $deleteFieldCount = 0;

    # first append fields that are transformed from the cdr fields
    for (my $i = 0; $i <= $#$fields; $i++)
    {
        # fields that are in our cdr will have a 'no' tag in it
        # and we are only interested in fields with a transformation assigned
        if (@$fields[$i]->{no} && @$fields[$i]->{transform})
        {
            my $trs = @$fields[$i]->{transform};
            my $oldDeleteFieldCount = $deleteFieldCount;

            for (my $j = 0; $j <= $#$trs; $j++)
            {
                unless (@$trs[$j]->{outname})
                {
                    $errstr = 'Field number ' . @$fields[$i]->{no} . ' missing outname parameter';
                    return undef;
                }

                if (@$trs[$j]->{type} ne 'keep' &&
                    @$trs[$j]->{type} ne 'date' &&
                    @$trs[$j]->{type} ne 'time' &&
                    @$trs[$j]->{type} ne 'condition' &&
                    @$trs[$j]->{type} ne 'expr')
                {
                    $errstr = 'Field number ' . @$fields[$i]->{no} . ' contains invalid transformation type';
                    return undef;
                }

                if (@$trs[$j]->{type} eq 'date')
                {
                    if (!defined(@$trs[$j]->{format}))
                    {
                        $errstr = 'Field number ' . @$fields[$i]->{no} . ' does not contain a format for date transformation';
                        return undef;
                    }

                    # check if the format requested is supported by the database
                    my $conv = undef;
                    if ($self->{_config}->{db}[0]->{dbtype} =~ /oracle/i)
                    {
                        $conv = _convert2OracleDate(@$trs[$j]->{format});
                        if ($conv =~ /%/)
                        {
                            $errstr = 'Field number ' . @$fields[$i]->{no} . ' contains a date format that cannot be readily converted to Oracle format: ' . $conv;
                            return undef;
                        }
                    }
                    else
                    {
                        $conv = _convert2MysqlDate(@$trs[$j]->{format});
                    }
                }

                if (@$trs[$j]->{type} eq 'time')
                {
                    if (@$fields[$i]->{fmt} ne 'HH:MM:SS')
                    {
                        $errstr = 'Field number ' . @$fields[$i]->{no} . ' is not in a valid format for time transformation (need HH:MM:SS)';
                        return undef;
                    }
                    if (!defined(@$trs[$j]->{format}))
                    {
                        $errstr = 'Field number ' . @$fields[$i]->{no} . ' does not contain a format for time transformation';
                        return undef;
                    }
                    if (!defined(@$trs[$j]->{value}) ||
                        (@$trs[$j]->{value} ne 'min' &&
                         @$trs[$j]->{value} ne 'sec' &&
                         @$trs[$j]->{value} ne 'hour'))
                    {
                        $errstr = 'Field number ' . @$fields[$i]->{no} . ' does not contain a valid value for time transformation';
                        return undef;
                    }
                }

                if (@$trs[$j]->{type} eq 'expr')
                {
                    if (!defined(@$trs[$j]->{format}))
                    {
                        $errstr = 'Field number ' . @$fields[$i]->{no} . ' does not contain a format for expr transformation';
                        return undef;
                    }
                    if (defined(@$trs[$j]->{expr}) && !defined(@$trs[$j]->{matchkey}))
                    {
                        $errstr = 'Field number ' . @$fields[$i]->{no} . ' does not contain a matchkey for expr transformation';
                        return undef;
                    }
                }

                if (@$trs[$j]->{type} eq 'condition')
                {
                    if (!defined(@$trs[$j]->{ifempty}))
                    {
                        $errstr = 'Field number ' . @$fields[$i]->{no} . ' does not contain an ifempty clause';
                        return undef;
                    }
                }

                if ($insertFieldCount > 0)
                {
                    $insertStmt .= ', ';
                    $insertValue .= ', ';
                }
                $insertStmt .= @$trs[$j]->{outname};
				if ($nodb) {
					$colnames->{@$trs[$j]->{outname}} = $col_ind++;
				}
                if (@$trs[$j]->{type} eq 'date')
                {
                    if ($self->{_config}->{db}[0]->{dbtype} =~ /oracle/i)
                    {
                        $insertValue .= 'TO_DATE(?, \'';
                        $insertValue .= _convert2OracleDate(@$trs[$j]->{format});
                        $insertValue .= '\')';
                    }
                    else
                    {
                        $insertValue .= '?';
#                        $insertValue .= 'DATE_FORMAT(?, \'';
#                        $insertValue .= _convert2MysqlDate(@$trs[$j]->{format});
#                        $insertValue .= '\')';
                    }
                }
                else
                {
                    $insertValue .= '?';
                }
                $insertFieldCount++;

                if (@$trs[$j]->{unique} =~ /true/i)
                {
                    if ($deleteFieldCount > 0)
                    {
                        $deleteStmt .= ' AND ';
                    }
                    $deleteStmt .= @$trs[$j]->{outname};
                    $deleteStmt .= ' = ?';
                    $deleteFieldCount++;
                }
            }

            # add this field number to our transformation list
            push(@{$self->{_transforms}}, $i);
        }
    }

    # next append fields that are independant of cdr fields
    for (my $i = 0; $i <= $#$fields; $i++)
    {
        my $oldDeleteFieldCount = $deleteFieldCount;

        # fields that are not in our cdr will not have 'no' tag in it
        unless (@$fields[$i]->{no})
        {
            unless (@$fields[$i]->{outname})
            {
                # these fields must have an outname tag
                $errstr = 'Field number ' . ($i+1) . ' missing outname parameter';
                return undef;
            }

            if (@$fields[$i]->{type} ne 'constant' &&
                @$fields[$i]->{type} ne 'variable')
            {
                # we only know 'constant' and 'variable' types
                $errstr = 'Field number ' . ($i+1) . ' contains invalid type';
                return undef;
            }

            unless (defined(@$fields[$i]->{value}))
            {
                # these fields must have an value tag
                $errstr = 'Field number ' . ($i+1) . ' missing value parameter';
                return undef;
            }

            if (@$fields[$i]->{type} eq 'variable')
            {
                # validate the kind of variable values we can handle
                my $notfound = 1;
                foreach my $var (keys %$vars)
                {
                    if (@$fields[$i]->{value} eq $var)
                    {
                        $notfound = 0;
                        last;
                    }
                }
                if ($notfound)
                {
                    $errstr = 'Field number ' . ($i+1) . ' contains invalid value';
                    return undef;
                }

                if (@$fields[$i]->{value} eq 'DATETIME')
                {
                    if (defined(@$fields[$i]->{format}))
                    {
                        my $conv = undef;
                        if ($self->{_config}->{db}[0]->{dbtype} =~ /oracle/i)
                        {
                            $conv = _convert2OracleDate(@$fields[$i]->{format});
                            if ($conv =~ /%/)
                            {
                                $errstr = 'Field number ' . ($i+1) . ' contains a date format that cannot be readily converted to Oracle format: ' . $conv;
                                return undef;
                            }
                        }
                        else
                        {
                            $conv = _convert2MysqlDate(@$fields[$i]->{format});
                        }
                    }
                    else
                    {
                        $errstr = 'Field number ' . ($i+1) . ' needs a format to be specified';
                        return undef;
                    }
                }
            }

            if ($insertFieldCount > 0)
            {
                $insertStmt .= ', ';
                $insertValue .= ', ';
            }
            $insertStmt .= @$fields[$i]->{outname};
			if ($nodb) {
				$colnames->{@$fields[$i]->{outname}} = $col_ind++;
			}
            if (@$fields[$i]->{type} eq 'variable' &&
                @$fields[$i]->{value} eq 'DATETIME')
            {
                if ($self->{_config}->{db}[0]->{dbtype} =~ /oracle/i)
                {
                    $insertValue .= 'TO_DATE(?, \'';
                    $insertValue .= _convert2OracleDate(@$fields[$i]->{format});
                    $insertValue .= '\')';
                }
                else
                {
                    $insertValue .= '?';
#                    $insertValue .= 'DATE_FORMAT(?, \'';
#                    $insertValue .= _convert2MysqlDate(@$fields[$i]->{format});
#                    $insertValue .= '\')';
                }
            }
            else
            {
                $insertValue .= '?';
            }
            $insertFieldCount++;

            if (@$fields[$i]->{unique} =~ /true/i)
            {
                if (@$fields[$i]->{type} ne 'variable')
                {
                    $errstr = 'Field number ' . ($i+1) . ' cannot be a unique key';
                    return undef;
                }
                if ($deleteFieldCount > 0)
                {
                    $deleteStmt .= ' AND ';
                }
                $deleteStmt .= @$fields[$i]->{outname};
                $deleteStmt .= ' = ?';
                $deleteFieldCount++;
            }

            # add this field number to our list
            push(@{$self->{_indep}}, $i);
        }
    }

    $insertStmt .= ') ';

    if ($insertFieldCount == 0)
    {
        $errstr = 'Need atleast one field with <transform> or \'value\'';
        return undef;
    }

    if ($self->{_config}->{db}[0]->{replace} =~ /true/i)
    {
        if ($deleteFieldCount == 0)
        {
            $errstr = 'Need atleast one field to be a unique key to replace entries';
            return undef;
        }
        $self->{_logger}->debug2($self->{id} . ": Delete Statement = $deleteStmt");
    }
    else
    {
        $deleteStmt = undef;
        if ($deleteFieldCount != 0)
        {
            $self->{_logger}->warn($self->{id} . ": unique key specified, but replace entries not requested");
        }
    }

    # append values
    $insertStmt .= 'VALUES (';
    $insertStmt .= $insertValue;
    $insertStmt .= ')';

    $self->{_logger}->debug2($self->{id} . ": Insert Statement = $insertStmt");

#    print Dumper($self->{_transforms});
#    print Dumper($self->{_indep});

    return ($insertStmt, $deleteStmt) unless ($nodb);
	return ($colnames) if ($nodb);
}


sub processCDREntry
{
    my $self = shift;

    (my ($cdrEntry, $uniqueExt, $fname), $vars->{'CDRLINE'}, $vars->{'MSWID'}) = @_;

	unless ($vars->{'CDRFILE'} eq $fname)
	{
		# We are processing a new file
		if ($self->{_type} == $StType->{FL}) 
		{
			return undef unless ($self->_FLInit($fname));
		}
			
		$vars->{'CDRFILE'} = $fname;
	}

    my @cdrFields = split(/\;/, $cdrEntry);
    # make the callid unique, if needed
    if ($uniqueExt)
    {
        $cdrFields[23] = $cdrFields[23] . '-' . $uniqueExt;
    }

    my @deleteArgs = ();
    my @insertArgs = ();

    my $fields = $self->{_config}->{CDR}[0]->{field};

    # process transformations
    for (my $i = 0; $i <= $#{$self->{_transforms}}; $i++)
    {
        my $trs = @$fields[$self->{_transforms}[$i]]->{transform};
        for (my $j = 0; $j <= $#$trs; $j++)
        {
            if (@$trs[$j]->{type} eq 'date')
            {
                # handle date transformations
                my $settime = undef;
                if (@$fields[$self->{_transforms}[$i]]->{fmt} eq 'uint32')
                {
                    # handle input date in uint32 format (secs since epoch)
                    $settime = $cdrFields[@$fields[$self->{_transforms}[$i]]->{no} - 1];
                }
                elsif (@$fields[$self->{_transforms}[$i]]->{fmt} eq 'string')
                {
                    # convert date string in YY-MM-DD %H:%M:%S format to integer time
                    my ($year, $month, $day, $hour, $min, $sec) = split(/[ :-]+/, $cdrFields[@$fields[$self->{_transforms}[$i]]->{no} - 1]);
                    $settime = Time::Local::timelocal($sec, $min, $hour, $day, $month-1, $year);
                }
                else
                {
                    $self->{errstr} = $errstr = $self->{id} . ': Don\'t know the input date format: ' . @$fields[$self->{_transforms}[$i]]->{fmt} . "($i)";
                    $self->{_logger}->warn($self->{errstr});
                }

                if ($settime)
                {
                    my $oldzone = $ENV{TZ};
                    if (@$trs[$j]->{zone})
                    {
                        $ENV{TZ} = @$trs[$j]->{zone};
                        POSIX::tzset();
                    }
                    push(@insertArgs, strftime(@$trs[$j]->{format}, localtime($settime)));
#                    push(@insertArgs, strftime("%Y-%m-%d %T", localtime($settime)));
                    if (@$trs[$j]->{zone})
                    {
                        $ENV{TZ} = $oldzone;
                        POSIX::tzset();
                    }
                }
                else
                {
                    push(@insertArgs, '');
                    $self->{_logger}->warn($self->{id} . ': unable to transform datetime');
                }
            }
            elsif (@$trs[$j]->{type} eq 'keep')
            {
                # no transformation, pass through
                push(@insertArgs, $cdrFields[@$fields[$self->{_transforms}[$i]]->{no} - 1]);
            }
            elsif (@$trs[$j]->{type} eq 'time')
            {
                my ($hr, $mn, $sc) = split(/:/, $cdrFields[@$fields[$self->{_transforms}[$i]]->{no} - 1]);
                my $value = 0;
                if (@$trs[$j]->{value} eq 'min')
                {
                    $value = ($hr*60) + $mn + ($sc/60);
                }
                elsif (@$trs[$j]->{value} eq 'sec')
                {
                    $value = ($hr*3600) + ($mn*60) + $sc;
                }
                elsif (@$trs[$j]->{value} eq 'hour')
                {
                    $value = $hr + ($mn/60) + ($sc/3600);
                }
                else
                {
                    $self->{errstr} = $errstr = $self->{id} . ': Cannot handle this value for time transformation: ' . @$trs[$j]->{value} . "($i)";
                    $self->{_logger}->warn($self->{errstr});
                }
                push(@insertArgs, sprintf(@$trs[$j]->{format}, $value));
            }
            elsif (@$trs[$j]->{type} eq 'expr')
            {
                # (perl) expression transformation (i.e., add/substract/multiple/divide)
                my $value = $cdrFields[@$fields[$self->{_transforms}[$i]]->{no} - 1];
                my $expr = @$trs[$j]->{value};
                if ($expr)
                {
                    # the key to match on
                    my $match = @$trs[$j]->{matchkey};
                    # if there was a perl expression, evaluate it
                    $expr =~ s/($match)/$value/g;
                    my $val = eval $expr;
                    if (defined($val))
                    {
                        $value = $val;
                    }
                    else 
                    {
                        $self->{errstr} = $errstr = $self->{id} . ': Evaluated expression resulted in undefined value: ' . $expr . ': ' . @$fields[$self->{_transforms}[$i]]->{fmt} . "($i)";
                        $self->{_logger}->warn($self->{errstr});
                    }
                }
                push(@insertArgs, sprintf(@$trs[$j]->{format}, $value));
            }
            elsif (@$trs[$j]->{type} eq 'condition')
            {
                # conditional transformation
                my $value = $cdrFields[@$fields[$self->{_transforms}[$i]]->{no} - 1];
                if (!defined($value) || $value eq '')
                {
                    $value = $cdrFields[@$trs[$j]->{ifempty} - 1];
                }
                push(@insertArgs, $value);
            }
            else
            {
                $self->{errstr} = $errstr = $self->{id} . ': Don\'t know the type: ' . @$trs[$j]->{type} . "($i, $j)";
                $self->{_logger}->warn($self->{errstr});
            }

            if (@$trs[$j]->{unique} =~ /true/i)
            {
                push(@deleteArgs, $cdrFields[@$fields[$self->{_transforms}[$i]]->{no} - 1]);
            }
        }
    }

    # process independant fields
    for (my $i = 0; $i <= $#{$self->{_indep}}; $i++)
    {
        if (@$fields[$self->{_indep}[$i]]->{type} eq 'constant')
        {
            push(@insertArgs, @$fields[$self->{_indep}[$i]]->{value});
        }
        elsif (@$fields[$self->{_indep}[$i]]->{type} eq 'variable')
        {
            if (@$fields[$self->{_indep}[$i]]->{value} eq 'DATETIME')
            {
                $vars->{@$fields[$self->{_indep}[$i]]->{value}} = strftime(@$fields[$self->{_indep}[$i]]->{format}, localtime);
            }
            push (@insertArgs, $vars->{@$fields[$self->{_indep}[$i]]->{value}});
        }
        else
        {
            $self->{errstr} = $errstr = $self->{id} . ': Don\'t know the type: ' . @$fields[$self->{_indep}[$i]]->{type} . "($i)";
            $self->{_logger}->warn($self->{errstr});
        }

        if (@$fields[$self->{_indep}[$i]]->{unique} =~ /true/i)
        {
            push(@deleteArgs, $vars->{@$fields[$self->{_indep}[$i]]->{value}});
        }
    }


    # delete the previous entry from the database if needed
    if ($self->{_sth_delete})
    {
#        print Dumper(@deleteArgs);

        eval {$self->{_sth_delete}->execute(@deleteArgs)};
        if ($@)
        {
            $self->{_logger}->debug2($self->{id} . ": Unable to delete entry: $DBI::errstr");
        }
        $self->{_sth_delete}->finish();
    }

#    print Dumper(@insertArgs);

    # if database is configured insert into the database
	if ($self->{_type} == $StType->{DB})
	{
    	eval {$self->{_sth_insert}->execute(@insertArgs)};
    	if ($@)
    	{
       		$self->{errstr} = $errstr = "Unable to insert entry: $DBI::errstr";
        	return undef;
    	}

    	$self->{_sth_insert}->finish();
	}

    # if file is configured write into the file
	if ($self->{_type} == $StType->{FL})
	{
		my $cdrline; 
	
		if ((!defined($self->{_col_names})) || (!defined($self->{_output_order}))) {
			$self->{errstr} = "Could not determine the output format of cdr entry";
			return undef;
		}
	
		foreach (my $i = 0; $i <= $#{$self->{_output_order}}; $i++) {
			my $ind = $self->{_output_order}[$i];
			$cdrline .= $self->{_config}{file}[0]->{separator} unless ($i == 0);

			if (ref($ind)) {
				# There are subfields here
				foreach (my $j = 0; $j <= $#{$ind->{subfield}}; $j++) {
					$cdrline .= $ind->{separator} unless ($j == 0);
					$cdrline .= $insertArgs[$ind->{subfield}[$j]];
				}
			}
			else {
				if (defined($ind)) {
					$cdrline .= $insertArgs[$ind];
				}
			}
		}

		my $fh = $self->{_fh};
		my $rc = print $fh "$cdrline\n";
		unless ($rc)
		{
			$self->{errstr} = "$self->{id}: Unable to write cdr - $!\n";
			return undef;
		}
	}

    return 1;
}


sub dumpConfig
{
    my $self = shift;

#    print Dumper($self->{_config});
}


##############################
# disconnect from the database
##############################
sub DESTROY
{
    my $self = shift;

	if ($self->{_type} == $StType->{DB})
	{
    	if ($self->{_sth_delete})
    	{
       	 $self->{_sth_delete}->finish();
    	}
    	$self->{_sth_insert}->finish();
    	$self->{_dbh}->disconnect();
	}

	if ($self->{_type} == $StType->{FL})
	{
		close($self->{_fh}) if (defined($self->{_fh}));
	}
}


1;

