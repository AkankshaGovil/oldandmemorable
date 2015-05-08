#!/usr/bin/perl

use English;

use XML::Simple;
use Data::Dumper;
use POSIX qw(tmpnam);


##
## Parses given config file and returns hashref pointing to data.
##
sub ParseConfigFile ($)
{
	my ($arg) = @_;
	## Basic engine for doing work.
	##
	my $xs = new XML::Simple();

	## Forcearray changes the whole paradigm.
	my $ref = $xs->XMLin( $arg, forcearray => 1 );

###	For debug only.
###	print Dumper ($ref);

	return $ref;
}

# Adapted from cgi-lib.pl by S.E.Brenner@bioc.cam.ac.uk 
# Copyright 1994 Steven E. Brenner 

sub ReadParse {
  local (*in) = @_ if @_;
  local ($i, $key, $val);

  if ( $ENV{'REQUEST_METHOD'} eq "GET" ) { 
    $in = $ENV{'QUERY_STRING'}; 
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  } else {
        # Added for command line debugging
        # Supply name/value form data as a command line argument
        # Format: name1=value1\&name2=value2\&... 
        # (need to escape & for shell)
        # Find the first argument that's not a switch (-)
        $in = ( grep( !/^-/, @ARGV )) [0];
        $in =~ s/\\&/&/g;
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert plus's to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value.
    ($key, $val) = split(/=/,$in[$i],2); # splits on the first =.

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;       
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associate key and value. \0 is the multiple separator
    $in{$key} .= "\0" if (defined($in{$key})); 
    $in{$key} .= $val;
  }
  return length($in);
}  
