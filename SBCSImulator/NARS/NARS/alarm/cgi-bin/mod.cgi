#!/usr/bin/perl

use File::Copy;

do './hdr.pl';

$name = `basename $0`;

open(LOG, ">>$logfile")
	or die "Can't open $logfile file";

&ReadParse;

# which keys have to be deleted

# Call the right function - Demultiplex based on the argument
my $choice = $in{'B1'};
delete $in{'B1'};

if ($choice =~ /[Dd]elete/) {
	delete_alarms(\%in);
}
elsif ($choice =~ /[Tt]oggle/) {
	toggle_alarms(\%in);
}

do './show.cgi';

################################################################################
# delete_alarms takes an argument of hash which are to be deleted. 
# The hash is keyed by the alarm number
################################################################################
sub delete_alarms($) {
	my ($input) = @_;
	my %in = %$input;

# which keys have to be deleted

@kes = sort (keys %in);


&GetWLock;

copy("$conffile", "$opfile");

my $db = ParseConfigFile($conffile);

if (!($alarms = $db->{'EV'})) {
	Initialize the first event
	$alarms = ($db->{'EV'} = {});
}

foreach $ke (@kes) {
	undef $alarms->{$ke}; 
}

$i=0;
for $ke (sort (keys %$alarms)) {
	if (defined $alarms->{$ke}) {
		$nke[$i] = $ke;
		$i++;
	}
}	

for $i (0 .. $#nke) {
	$nalarms->{$i+1} = $alarms->{$nke[$i]};
}

#for $ke (keys %$alarms) {
#	$nalarms->{$ke} = $alarms->{$ke} if defined $alarms->{$ke};
#}	

if ((scalar (keys %$nalarms)) > 0 ) {
	$db->{'EV'} = $nalarms;
}
else {
        $db = {};
}


#$ci = (keys %$alarms) +1;
#$alarms->{$ci} = $newalarm;

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
}

################################################################################
# toggle_alarms takes an argument of hash which are to be deleted. 
# The hash is keyed by the alarm number
################################################################################
sub toggle_alarms ($) {
	my ($input) = @_;
	my %in = %$input;

# which keys have to be toggled

@kes = sort (keys %in);

&GetWLock;

copy("$conffile", "$opfile");

my $db = ParseConfigFile($conffile);

if (!($alarms = $db->{'EV'})) {
	Initialize the first event
	$alarms = ($db->{'EV'} = {});
}

foreach $ke (@kes) {
	if ($alarms->{$ke}{'STATUS'}[0] =~ /DISABLED/) {
		$alarms->{$ke}{'STATUS'}[0] = 'ENABLED';
	}
	else {
		$alarms->{$ke}{'STATUS'}[0] = 'DISABLED';
	}
}

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
}