#!/usr/bin/perl

#######################################################
#######################################################
###
### mail.pl
###
### Mail based notification program for use 
### with cdrpp.
###
### (c) 1998 - 2009 GENBAND Inc.
#######################################################
#######################################################
#######################################################
### $Log:
###  v0.1: Simple  mailer.
###
###  v0.2: Added sending attachments. Using MIME.
###
###  v0.21: Added interactive mode. Completed first draft of doc.
###
###  v0.22: Added library search support for Perl v5.005
###
###  v0.23: Added -s option for Subject line.
###
###  v0.24: Added -tfcb option for To:From:CC:BCC:line.
#######################################################


## Preliminary
use English;

my $CurrentVersion = sprintf "%vd", $PERL_VERSION;

if ($CurrentVersion lt "5.6")
{
	use lib "/usr/local/nextone/lib/perl5/site_perl/5.005";
}
else
{
	use lib "/usr/local/nextone/lib/perl5/site_perl";
}

#use lib "/usr/local/nextone/lib/perl5/site_perl";

if ($ENV{BASE})
{
	use lib "$ENV{BASE}/lib/perl5/site_perl";
}

use Mail::Sendmail;
use Getopt::Std;
use MIME::QuotedPrint;
use MIME::Base64;
$date = `date`;
chomp $date;

#######################################################
#######################################################
## Setup mail variables here.
#######################################################
#######################################################

##
## Who the message is from
##
$MailFrom = 'root';

##
## Subject of the mail.
##
$MailSubject = "Report " . $date;

##
## List of Receipients (comma separated list of e-mail ids)
##
$MailList = 'support@genband.com';

##
## CC list (comma separated list of e-mail ids)
##
$MailCC = '';

##
## BCC list (comma separated list of e-mail ids)
##
$MailBCC = '';

##
## Filename of attachment (optional)
##
$Attachment = "";

##
## Filename of main body
##
$InFile = "output";


#######################################################
#######################################################
## start
#######################################################
#######################################################

$mProgName = "mail.pl";
$mVersion = "v0.23, 05/08/2002";

getopts "a:b:c:f:hs:t:v";

$Attachment = $opt_a ? $opt_a : $Attachment;
$MailBCC = $opt_b ? $opt_b : $MailBCC;
$MailCC = $opt_c ? $opt_c : $MailCC;
$MailFrom = $opt_f ? $opt_f : $MailFrom;
$MailSubject = $opt_s ? $opt_s : $MailSubject;
$MailList = $opt_t ? $opt_t : $MailList;

if ($opt_v)
{
	PrintVersion ();
	exit (0);
}

if ($opt_h)
{
	PrintHelp ();
	exit (0);
}

if (!$ARGV[0])
{
	PrintVersion ();
	print "Entering interactive mode...\n";

	InteractiveLoop ();
}

##############################
## Process Mail message.
##############################
$InFile = $ARGV[0];

process:
open (INF, $InFile) or die "Cannot open $InFile \n";

$MailMessage = "";

while (<INF>)
{
	$MailMessage .= $_;
}

close (INF);

$QpMessage = encode_qp ($MailMessage);

## Setup the mail structure.
##


%mail = (
		To      => $MailList,
		From    => $MailFrom,
		Cc      => $MailCC,
		Bcc     => $MailBCC,
		Subject => $MailSubject,
	);

#####		Message => $MailMessage,

## Now process attachments...
##
if ($Attachment)
{
	$boundary = "====" . time() . "====";

	$mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";

	## Assume that attachment is a file
	open (F, $Attachment) or die "Cannot open $Attachment: $!";
	binmode F; undef $/;  # slurpee
	$MailInput = encode_base64 (<F>);
	close F;

	$boundary = '--'.$boundary;
	$mail{body} = <<END_OF_BODY;
$boundary
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$QpMessage
$boundary
Content-Type: application/octet-stream; name="$Attachment"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="$Attachment"

$MailInput
$boundary--
END_OF_BODY

}
else	## No attachments.
{
	$mail{Message} = $QpMessage;
}


##############################
## Send the mail.
##############################
print "Using default server: $Mail::Sendmail::mailcfg{smtp}->[0] \n";
print "Using default sender: $Mail::Sendmail::mailcfg{from} \n";

if (sendmail(%mail))
{
	print "Mail sent ok\n";
}
else
{
	print "Error sending mail: $Mail::Sendmail::error \n";
}

print "OK. Log says $Mail::Sendmail::log \n";


sub PrintHelp ()
{
	print <<eEOF
$mProgName, $mVersion
Usage:
$mProgName -a <attachment> -b <bcc_list> -c <cc_list> -f <from> -s <subject> 
-t <to> [message_body_file]
Options are:
-a <attachment>   - send mail using body and <attachment> as MIME encoded attachment.
-b <bcc1,..,bcc2> - bcc to the list
-c <cc1,..,cc2>   - cc to the list
-f <from>   	  - sender's email address
-s <subject>	  - sets the "Subject:" line of the e-mail.
-t <to>			  - recipient of the email message
-h                - prints this
-v                - prints out version
eEOF
;
}

sub PrintVersion ()
{
	print "$mProgName, $mVersion \n";
	print "Copyright 1998-2009, GENBAND Inc.\n";
}

sub InteractiveLoop ()
{
	## Autoflush
	$| = 1;
	print "From [$MailFrom]: ";

	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$MailFrom = $resp;
	}

	print "To [$MailList]: ";
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$MailList = $resp;
	}

	## Subject
	print "Subject [$MailSubject]: ";

	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$MailSubject = $resp;
	}

	## CC list
	print "CC list [$MailCC]: ";
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$MailCC = $resp;
	}


	## Bcc list
	print "BCC list [$MailBCC]: ";
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$MailBCC = $resp;
	}


	## Body file
	print "Main Body file [$InFile]: ";
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$InFile = $resp;
	}

	## Attachment file

	print "Attachment file [$Attachment]: ";
	$resp = <>;
	chop $resp;
	if ($resp ne "")
	{
		$Attachment = $resp;
	}

	goto process;
}


__END__




=head1 NAME

mail.pl - simple mailer

=head1 SYNOPSIS


B<mail.pl> [B<-h>] [B<-v>] [B<-a attachment>] B<body_text_file>


=head1 DESCRIPTION

mail.pl is a simple mailer that utilizes SMTP to send out mail. mail.pl can be operated
in several modes:

=head2 BATCH MODE

In this mode, modify the header section of mail.pl to put in values for the various
variables. These variables include 'From', 'To', 'CC', 'BCC', 'Subject'. This allows mail.pl
to be run automatically from cron, for instance, or as notification programs for
other associated programs such as "cdrpp".

=head2 INTERACTIVE MODE

In this mode, just start mail.pl and it prompts for various parameters.

=head1 OPTIONS

B<-h> 		Prints out help and exits.

B<-v>  		Version. Print out version and exit.

B<-a attachment> Process B<attachment> and then send as MIME-Base 64 encoded.

B<body_text_file> Process text file as body of message.

=head1 FILES

B</usr/local/nextone>

=head1 SEE ALSO

L<iServer>, L<iView>


=head1 AUTHORS

Copyright (C) 1998 - 2009, GENBAND Inc.

=cut

