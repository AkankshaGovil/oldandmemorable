#!/usr/bin/perl

use DBI;
use Config::Simple;

my $CONFFILE = 'nars.cfg';
my $LicenseFile = 'NARS.lc';

my $attr = {
			'PrintError' => 0,
			'RaiseError' => 0,
			'AutoCommit' => 0,
			};

my @dbi_login = GetDBILogin();
my $dbh = DBI->connect(@dbi_login)
	or die "Error connecting to database ... $DBI::errstr\n";

open(LIC, "<$LicenseFile")
	or die "Cannot open file $LicenseFile\n";

read(LIC, $blob, 100000);

close(LIC);

$sth = $dbh->prepare("UPDATE license SET file = ? WHERE filename = ?");
 
$sth->execute($dbh->quote($blob), $LicenseFile)
	or print "Couldn't install License File - $DBI::errstr\n";

$dbh->disconnect;


################################################################################
# Get the server name from the $CONFFILE file 
################################################################################
sub GetDBILogin() {
	# read the nars config file
	my $config;

	if (-f "$CONFFILE" && -T "$CONFFILE") {
    	$config = new Config::Simple(filename=>"$CONFFILE", mode=>O_RDONLY);
	} else {
   		die("Cannot read config file $CONFFILE");
	}

	my %cfgh = $config->param_hash();

	# if the password is just a '.', it means password is empty
	$cfgh{'.dbpass'} = "" if ($cfgh{'.dbpass'} eq '.');

	return ($cfgh{'.dburl'}, $cfgh{'.dbuser'}, $cfgh{'.dbpass'});
}

