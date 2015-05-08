#!/usr/local/bin/perl

use File::Copy;

# include the following files for the utility functions defined 
do './hdr.pl';

$opfile = $conffile.'.prev';

open(LOG, ">>$logfile")
	or die "Can't open $logfile file";

&ReadParse;

# Pre-process the tags to get the tags in the form in which we are going to write them
# in the conf file 

%conf = ();
PAIR:	while (($key, $val) = each %in) {
	next PAIR if ($val eq "");
	if ($val_tags{$key}) {
		$conf{$key} = $val;
	}
	elsif (($key =~ 'OPERATOR') && ($val !~ 'N/A' )) {
		$conf{uc $val} = $in{'OPERAND'};
	}
	elsif ($key =~ 'ACTION') {
		$conf{'ACTION'}{'NAME'} = $val;
	}
	elsif ((($act,$attr) = ($key =~ /^(\S+)_(\S+)/)) && $act_tags{$act}{$attr}) {
		$conf{'ACTION'}{$attr} = $val;
	}
	elsif ($ig_tags{$key}) {
#		Do Nothing 
	}
	else {
		print LOG "$PFIX unknown tag-value pair $key = $val\n";
	}
}

$i = 0;
$num = (keys %conf);
my $newstr ="";
while (($key, $val) = each %conf) {
	if ($i == 0 ) {
		$newstr .= "<EV>\n";
	}
	if ($key =~ 'ACTION') {
		$newstr .= "<$key";
		while (($attr, $atval) = each %{$conf{$key}}) {
			$newstr .= " $attr=\"$atval\"";
		}
		$newstr .= "></$key>\n"; 
	}
	elsif ($val_tags{$key} || $op_tags{$key}) {
		$newstr .= "<$key> $val </$key>\n";
	}

	$i += 1;

	if ($i == $num) {
		$newstr .= "<STATUS> ENABLED </STATUS>\n";
		$newstr .= "</EV>\n\n";
	}
}

my $newalarm = ParseConfigFile($newstr);

# We acquire a lock by renaming the file to filename.prev
# if we are succesful then we read the file, add the data set
# and write it back to the original file

&GetWLock;

copy("$conffile", "$opfile");

my $db = ParseConfigFile($conffile);

if (!($alarms = $db->{'EV'})) {
#	Initialize the first event
	$alarms = ($db->{'EV'} = {});
}

$ci = (keys %$alarms) +1;
$alarms->{$ci} = $newalarm;

if ($writeconf) {
	my $xs = new XML::Simple();
	$newdb = $xs->XMLout($db, noescape => 1, rootname => 'DB');

	open(CONF, ">$conffile")
		or die "Can't open $conffile file";

	print CONF "$newdb";

	if (!($newdb) && copy($opfile, $conffile)) {
		die "Couldn't add alarm. Restoring old configure file";	
	}

	close(CONF);
}

&RelLock;

do './show.cgi';
