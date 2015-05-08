package NexTone::validate;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION = 1.00;
@ISA = qw(Exporter);

our $errstr = '';


# see if the given directory contains any valid .CDR/.CDT files
sub validDir
{
    my ($cdr_dir) = @_;
    my $status = 0;

    $errstr = '';

    unless (opendir(CDR_DIR, $cdr_dir))
    {
        $errstr = "Cannot open directory: $!";
        return $status;
    }

    my @files = grep { /\.CD[RT]$/ } readdir(CDR_DIR);

    if (@files)
    {
	foreach my $file(@files) {
		if($status eq 0)
		{
		        $status = validFile("$cdr_dir/$file");
		}
		else
		{
			last;
		}
	}
    }
    else
    {
        $errstr = "Cannot find any CDR files";
    }

    closedir(CDR_DIR);

    return $status;
}

# see if the given file contains CDR entries that we are prepared to process
# (do this by looking at the first entry in the file)
sub validFile
{
    my $emptyAllowed=0;
    my ($file) = @_;
    if(defined($_[1]))
    {
	$emptyAllowed=$_[1];
    }
    my $status = 0;

    $errstr = '';

    # if the file has nothing, return 0
    if (((stat "$file")[7] == 0) && $emptyAllowed == 0)
    {
        $errstr = "file size zero";
        return $status;
    }

    unless (open(CDRFILE, "< $file"))
    {
        $errstr = "unable to open file ($file): $!";
        return $status;
    }

    while (my $line = <CDRFILE>)
    {
        chomp($line);
        if ($line ne '')
        {
            $status = validEntry($line);
            last;
        }
    }

    close(CDRFILE);

    return $status;
}


# see if the given cdr entry has enough fields for us to process it
sub validEntry
{
    my ($entry) = @_;

    $errstr = '';

    chomp($entry);
    my @fields = split(/\;/, $entry);

    # we need atleast these many fields to process
    if (@fields < 36&&@fields!=8)
    {
        $errstr = "number of CDR fields (" . @fields . ") less than required (36) or not equal to (8)";
        return 0;
    }

    return 1;
}

1;
