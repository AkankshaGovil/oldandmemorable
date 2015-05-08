package NexTone::Cdrfilter;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION = 1.00;
@ISA = qw(Exporter);

use Carp;

# some global variables

# module private variables

###################################################################
# create and return a new cdrfilter object
###################################################################
sub new
{
    my $class = shift;
    my ($loggerref, $epl, $exf, $inf) = @_;

    $class = ref($class) || $class;

    my $self = {
        _logger => $$loggerref,
		_excludeEPList => [],
        _excludeFilter => $exf,
        _includeFilter => $inf,
        _timeSize =>0	#if set to '1' then the CDR entry will be treated as time-size type CDR's first or last entry and will be filtered out
    };

    if (defined($epl))
    {
        my @EPList = split(',', $epl);
        my $logmsg = "Excluded end points:\n";
        my $xEP = [];
        foreach my $EP (@EPList)
        {
            my $h = {};
            ($h->{regid}, $h->{port}) = split(':', $EP);
            push(@$xEP, $h);
            $logmsg .= "\tregid = $h->{regid}, port = $h->{port}\n";
        }
        $self->{_logger}->debug1($logmsg);
        $self->{_excludeEPList} = $xEP;
    }

    $self->{_logger}->debug1("excludeFilter = $self->{_excludeFilter}");
    $self->{_logger}->debug1("includeFilter = $self->{_includeFilter}");
    $self->{_logger}->debug1("timeSize = $self->{_timeSize}");
    if (defined($self->{_includeFilter}) && (defined($self->{_excludeFilter}) || defined($epl)))
    {
        $self->{_logger}->info("Both an exclude filter and an include filter defined, the include filter criteria will override the exclude filter criteria");
    }

    bless $self => $class;

    return $self;
}


#########################################################################
# filter an individual CDR entry
#
# if the entry matches the includeFilter, return 0
# if a includeFilter is specified and entry does not match the criteria, return 1
#
# if the entry matches the excludeFilter or the excludeEPList, return 1
# if no match found, return 0
#
# return 1 if the CDR entry needs to be filtered out, 0 otherwise
# (also returns the filter criteria used in the decision)
#########################################################################
sub filterEntry
{
    my $self = shift;
    my ($entry) = @_;

    my $filtered = 0;
    my @filterCriteria = ();

    my @cfs = split(/\;/, $entry);
    
    #Time-Size type CDR's first or last entry will be filtered out
    if($self->{_timeSize}==1)
    {
    	return (1,"Time-Size CDR: First or Last line entry.");
    }

    # apply the include filter
    if (defined($self->{_includeFilter}))
    {
        # first separate all the OR conditions
        my @efs = split(/[,]/, $self->{_includeFilter});

      inc_orfilterloop:
        foreach my $ef (@efs)
        {
            # for each OR condition, get the AND condition
            my @cond = split(/[&:]/, $ef);
            $filtered = 1;
          inc_andfilterloop:
            for (my $i = 0; $i <= $#cond; $i += 2)
            {
                my $cdrField = $cond[$i]-1;
                my $value = $cond[$i+1];
                if ($cfs[$cdrField] ne $value)
                {
                    $filtered = 0;
                    last inc_andfilterloop;
                }
            }

            if ($filtered == 1)
            {
                @filterCriteria = @cond;
                last inc_orfilterloop;
            }
        }

        return (0, @filterCriteria) if ($filtered == 1);
        return (1, ("cdr does not match include filter ", $self->{_includeFilter}));
    }

    if (defined($self->{_excludeFilter}))
    {
        # first separate all the OR conditions
        my @efs = split(/[,]/, $self->{_excludeFilter});

      exc_orfilterloop:
        foreach my $ef (@efs)
        {
            # for each OR condition, get the AND condition
            my @cond = split(/[&:]/, $ef);
            $filtered = 1;
          exc_andfilterloop:
            for (my $i = 0; $i <= $#cond; $i += 2)
            {
                my $cdrField = $cond[$i]-1;
                my $value = $cond[$i+1];
                if ($cfs[$cdrField] ne $value)
                {
                    $filtered = 0;
                    last exc_andfilterloop;
                }
            }

            if ($filtered == 1)
            {
                @filterCriteria = @cond;
                last exc_orfilterloop;
            }
        }
    }

    if ($filtered == 0 && defined($self->{_excludeEPList}))
    {
        # check if the endpoint exclusion list is specified
        my $ogw = $cfs[25];
        my $op = $cfs[26];
        my $tgw = $cfs[27];
        my $tp = $cfs[28];
        my $epl = $self->{_excludeEPList};

        foreach my $i (0..$#$epl)
        {
            if (($epl->[$i]{regid} eq $ogw and (($epl->[$i]{port} eq $op) or ($epl->[$i]{port} == -1))) or 
                ($epl->[$i]{regid} eq $tgw and (($epl->[$i]{port} eq $tp) or ($epl->[$i]{port} == -1))))
            {
                $filtered = 1;
                @filterCriteria = ($epl->[$i]{regid}, $epl->[$i]{port});
                last;
            }
        }
    }

    return ($filtered, @filterCriteria);
}

1;
