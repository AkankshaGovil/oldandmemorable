#!/usr/local/bin/perl

# include the following files for the utility functions defined 
do 'hdr.pl';

open(LOG,">>$logfile")
	or die "Can't open $logfile file\n";

&PrintAlarms;
#####
#####

sub PrintAlarms {
	
	my $parsed_data = ParseConfigFile($conffile);
	my $alarms = $parsed_data->{'EV'};

	&HTMLHeader;

	print "<form method=\"POST\" action=\"http://204.180.228.224/cgi-bin/mod.cgi\">\n";
	print "<table border=\"0\" align=\"center\" cellpadding=\"4\" cellspacing=0 bgcolor=\"999999\" width=\"100%\">\n";
	PrintTableHdr();
	for $i (1 .. (scalar (keys %$alarms))) {
		PrintAlarm($alarms->{$i}, $i);
	}
	print "</table>\n";
	print "<p><input type=\"submit\" name=\"B1\" value=\"Delete Selected Alarms\">";
	print "&nbsp;&nbsp;";
	print "<input type=\"submit\" name=\"B1\" value=\"Toggle Selected Alarms\">";
	print "&nbsp;&nbsp;<input type=\"reset\"></p>\n";
	print "</form>\n";

	&HTMLFooter;
}

sub PrintTableHdr {
	print "<tr bgcolor=\"999999\" align=\"center\" >\n";
	print "<th> &nbsp; </th>\n";
	print "<th> STATUS </th>\n";
	print "<th> NAME </th>\n";
	print "<th> TYPE </th>\n";
	print "<th> HOST </th>\n";
	print "<th> RESET </th>\n";
	print "<th> QUALIFIER </th>\n";
	print "<th> ACTION </th>\n";

	print "</tr>\n";
}

sub PrintAlarm ($ $) {
	my ($alarm, $a_id) = @_;
	my $str;
	my @color = ("cccccc", "dddddd");

	print "<tr bgcolor=\"$color[$a_id % 2]\" align=\"center\">\n";

	PrintCell("<input type=\"checkbox\" name=\"$a_id\">");

	if ($alarm->{'STATUS'}) {
		PrintCell($alarm->{'STATUS'}[0]); 
	}

	if ($alarm->{'EVENT'}) {
		PrintCell($alarm->{'EVENT'}[0]); 
	}

	if ($alarm->{'QUAL'}) {
		PrintCell($alarm->{'QUAL'}[0]); 
	}

	if ($alarm->{'HOST'}) {
		PrintCell($alarm->{'HOST'}[0]); 
	}

	if ($alarm->{'RESET'}) { 
		$str = $alarm->{'RESET'}[0];
		PrintCell($str); 
	}
	else { 
		PrintCell("No"); 
	}

	if ($alarm->{'EQUALS'}) { 
		$str = "STRING = \"".chip($alarm->{'EQUALS'}[0])."\"";
		PrintCell($str); 
	}
	elsif ($alarm->{'KEY'}) { 
		$str = "KEY = \"".chip($alarm->{'KEY'}[0])."\""; 
		$str .= findop($alarm);	
		$str .= " for $alarm->{'TIME_AVERAGE'}[0] min";
		PrintCell($str);
	}
	else {
		PrintCell("");
	}
	
	if ($alarm->{'ACTION'}) {
		PrintCell($alarm->{'ACTION'}[0]{'NAME'}); 
	}

	print "</tr>\n";
}

sub PrintCell ($) {
	my ($str) = @_;

	print "<td> $str </td>\n";
}

sub findop ($) {
	my ($alarm) = @_;
	my $str="";
	
	if ($alarm->{'LT'}) { $str = " < ".$alarm->{'LT'}[0]; }
	if ($alarm->{'GT'}) { $str = " > ".$alarm->{'LT'}[0]; }
	if ($alarm->{'EQ'}) { $str = " = ".$alarm->{'LT'}[0]; }
	if ($alarm->{'LE'}) { $str = " <= ".$alarm->{'LT'}[0]; }
	if ($alarm->{'GE'}) { $str = " >= ".$alarm->{'LT'}[0]; }

	return $str;
}

sub HTMLHeader {
	print "Content-type:text/html\n\n";

	print <<EOF;
<html>
<title> Submission Page </title>
<body bgcolor="cfcfcf">
<h4> Following alarms are configured </h4>
EOF
}

sub HTMLFooter {
	print "</body>\n</html>";
}

sub chip($) {
	my ($str) = @_;
	
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	return($str);
}
