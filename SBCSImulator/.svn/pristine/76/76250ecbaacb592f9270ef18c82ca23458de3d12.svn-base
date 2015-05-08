#!/usr/local/bin/perl

use Fcntl qw(:flock);

$name=`basename $0`;

# include the following files for the utility functions defined 
do './common.pl';

# val_tags - valid tags which can be printed directly in the conf file 
# ig_tags - valid tags which are ignored because they are accessed by another tag 
# act_tags - action tags which may require to be united

# Some Constants
%val_tags = map { $_ => 1 } (EVENT, QUAL, EQUALS, RESET, KEY, DESC, TIME_AVERAGE, HOST, 'LT', 'GT', 'EQ', 'LE', 'GE');
%ig_tags = map { $_ => 1 } (OPERAND);
%none_tags = map { $_ => 1 } ();
%mail_tags = map { $_ => 1 } (TO, FROM, SUBJ, CC, BCC);
%log_tags = map { $_ => 1 } (FILE);
$act_tags{'NONE'} = { %none_tags };
$act_tags{'MAIL'} = { %mail_tags };
$act_tags{'LOG'} = { %log_tags };

$APACHE = "/usr/local/apache";
$PFIX = "Nextone:$name:: ";

$conffile = "alarms.conf";
# We use the same log file as apache for now. 
#$logfile = "$APACHE/logs/error_log";
$logfile = "error.log";
$lockfile = "alarm.lock";
$writeconf = 1;

sub GetRLock {

	my $attempts = 5;
	my $stat = 0;

	open(LCK, ">>$lockfile")
		or die "Can't open $lockfile lockfile\n";

	while ((!$stat) && $attempts > 0 ) {
		$stat = flock(LCK, LOCK_SH|LOCK_NB);
		$attempts--;
	}

	return $stat;
}

sub GetWLock {

	my $attempts = 5;
	my $stat = 0;

	my $attempts = 5;
	my $stat = 0;
	open(LCK, ">>$lockfile")
		or die "Can't open $lockfile lockfile\n";

	while ((!$stat) && $attempts > 0 ) {
		$stat = flock(LCK, LOCK_EX|LOCK_NB);
		$attempts--;
	}

	return $stat;
}

sub RelLock {
	flock(LCK, LOCK_UN|LOCK_NB); 
	close(LCK);
}
