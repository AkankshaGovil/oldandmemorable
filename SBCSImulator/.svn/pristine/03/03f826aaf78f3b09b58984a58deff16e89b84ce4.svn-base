package NexTone::LM;

use Digest::Perl::MD5 qw(md5 md5_hex md5_base64);
use XML::Simple;
use Config::Simple;
use Time::Local;
use NexTone::Logger;
use NexTone::version;
use NexTone::Poster;
use NexTone::Constants;

BEGIN {
        use Exporter ();
        our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

        $VERSION 	= '2.1';
        @ISA        = qw(Exporter);
        @EXPORT     = qw(&Server_Licensed &Agent_Licensed);
        @EXPORT_OK  = qw(&encode &verify &expired &VersionMatch &ValidAgent
					 	&ValidServer &Read_License &GetLicensefromDB);
}
our @EXPORT_OK;

## There are globals
our $errstr = '';

our $LICENSE_FILE = 'bn.lc';
our $LICENSE_SERVER_FILE = 'bn.server.lc';

## These are private globals
#my $cryp=md5_hex('NexTone NARS License Manager works'), "\n";
#my $blur=md5_hex('Another wrapping Layer'), "\n";
my $selfHostid;
my @selfMac;
my @selfIp;

##
## encode ($)
## 		input - string to be encoded
## 		output - signature string
##
sub encode ($) {
	my ($str) = @_;
	my $sign;
	my $sbstr;
	my $strmain;
	my @sb=();
	my ($c, $i);
	my @iv = (104,107,71,135,118,205,144,120,155,127,134,224,21,79,47);
	foreach $i (@iv) {
		push(@sb, (sprintf "%x", $i));
	}

	$sbstr = join "", @sb;
	$strmain = $str.$sbstr;
	$sign = md5_hex($strmain);
	return "$sign";
}
##
## encode ($)
## 		input - string to be encoded
## 		output - signature string
##
##sub encode ($) {
##	my ($str) = @_;
##	my $sign;
##	my @tmpa;
##	my ($c, $f);

##	@input = split(//, md5_hex($str));
##	@crypt = split(//, $cryp);
##	@blurt = split(//, $blur);
##
##	foreach $c (@input) {
##		$f = shift(@blurt);
##		push(@tmpa, (sprintf "%x", hex($c)|hex($f)) );
##	}

##	while ($#tmpa or $#crypt) {
##		$sign = join('', $sign, shift(@tmpa), shift(@crypt));
##	}

##	return "$sign";
##}

##
## verify ($)
## 		input -  1: string to be verified
## 		      -  2: signature for the string 
## 		output - [0='not authenticated' / 1='authenticated']
##
sub verify ($$) {
	my ($str, $sign) = @_;
	my $nsign;

	$nsign=encode($str);	

	if ($nsign eq $sign) {
		return 1;
	}
	else {
		return 0;
	}
}

##
## VersionMatch ($)
## 		input -  1: License File Version
## 		      -  2: Product Name
## 		      -  2: Product Version 
## 		output - [0='false' / 1='true']
##
sub VersionMatch ($$$$) {
    my ($licenseVersion, $product, $version,$loggerref) = @_;

    # the license file version should always be 2.1
    if ($licenseVersion ne $VERSION)
    {
        $errstr = "$licenseVersion in the license is not a valid license version";
        return 0;
    }

    # the product should match
    if ($product ne $NexTone::version::Product)
    {
        $errstr = "$product in the license is not a valid product";
        return 0;
    }

	my $logger = $$loggerref;
    # the product version should match or should be less than RSM version
    my $agentVersion=$NexTone::version::Version;
	my $rsmVersion=$version;

    $logger->debug1("Agent version = $agentVersion");
    $logger->debug1("RSM version =  $rsmVersion");


	#
    # Removed the RSM license check so that RSM Agent will be working with Any version of
    # RSM Server 4.2 and above
    #if(($rsmVersion lt $agentVersion) && (index($agentVersion, $rsmVersion) != 0) )
    #{
    #    $errstr = "$version in the license is not a valid product version";
    #    return 0;
    #}
    #

    return 1;
}

##
## ValidAgent ($$)
## 		input -  Arrayref to a list of agent hashes
## 		output - [0='false' / 1='true']
##
sub ValidAgent ($$) {
	my ($agents, $loggerref) = @_;
        my $logger = $$loggerref;
	my ($hostvalid, $macvalid, $ipvalid) = (1, 1, 1);


	if (ref($agents) eq 'ARRAY')
	{
		foreach $ind (0..$#$agents)
		{
			($hostvalid, $macvalid, $ipvalid) = (1, 1, 1);
			$hostvalid = CheckHostId($agents->[$ind]{'hostid'}, $loggerref) if defined($agents->[$ind]{'hostid'});
			$macvalid = CheckMac($agents->[$ind]{'mac'}, $loggerref) if ($hostvalid && defined($agents->[$ind]{'mac'}));
			$ipvalid = CheckIp($agents->[$ind]{'ip'}, $loggerref) if ($hostvalid && $macvalid && defined($agents->[$ind]{'ip'}));
			return 1 if ($hostvalid & $macvalid & $ipvalid);
		}
	}
	else
	{
		$hostvalid = CheckHostId($agents->{'hostid'}, $loggerref) if defined($agents->{'hostid'});
		$macvalid = CheckMac($agents->{'mac'}, $loggerref) if ($hostvalid && defined($agents->{'mac'}));
		$ipvalid = CheckIp($agents->{'ip'}, $loggerref) if ($hostvalid && $macvalid && defined($agents->{'ip'}));
		return ($hostvalid & $macvalid & $ipvalid);
	}

	return 0;
}


sub CheckHostId ($@) {
	my ($licHostid, $loggerref) = @_;
        my $logger = $$loggerref;

	my $hostid = SelfHostID($loggerref);
	$logger->debug1("Checking licensed hostid ($licHostid) against local hostid ($hostid)");

	return 1 if ($licHostid =~ /^$hostid$/i);
	return 1 if ($licHostid =~ /^unbound$/i);

	$logger->info("Agent not licensed for this hostid");
	return 0;
}


sub CheckMac ($@) {
	my ($licMac, $loggerref) = @_;
        my $logger = $$loggerref;

	my @macs = SelfMac($loggerref);
	$logger->debug1("Checking licensed mac ($licMac) against local mac (@macs)");

	foreach $mac (@macs)
	{
		return 1 if ($licMac =~ /^$mac$/i);
		return 1 if ($licMac =~ /^unbound$/i);
	}

	$logger->info("Agent not licensed for this mac");
	return 0;
}


sub CheckIp ($@) {
	my ($licIp, $loggerref) = @_;
        my $logger = $$loggerref;

	my @ips = SelfIp($loggerref);
	$logger->debug1("Checking licensed ip ($licIp) against local ip (@ips)");

	foreach $ip (@ips)
	{
		return 1 if ($ip =~ /^$licIp$/);
		return 1 if ($licIp =~ /^unbound$/i);
	}

	$logger->info("Agent not licensed for this ip");
	return 0;
}


##
## ValidServer ($)
## 		input -  Server hashref
## 		output - [0='false' / 1='true']
##
sub ValidServer ($) {
	my ($server) = @_;
	my ($srvrid, $ind);

	my $hostid = SelfHostID();

	if (ref($server) eq 'ARRAY')
	{
		foreach $ind (0..$#$agents) {
			$srvrid = $server->[$ind]{'hostid'};
			return 1 if ($srvrid =~ /^$hostid$/);
			return 1 if ($srvrid =~ /^unbound$/);
		}
	}
	else
	{
		$srvrid = $server->{'hostid'};
		return 1 if ($srvrid =~ /^$hostid$/);
		return 1 if ($srvrid =~ /^unbound$/);

	}

	return 0;
}

##
## expired ($)
## If current time is more than the expiry_date the license expired
## 		input -  expiry_date in ctime() format
## 		output - [0='false' / 1='true']
##
sub expired ($) {
	my ($expiry_date) = @_;
	my $expiry_time;

	return 0 if ($expiry_date =~ /timeless/);

	my $MONTH = {	'Jan' => 0,
					'Feb' => 1,
					'Mar' => 2,
					'Apr' => 3,
					'May' => 4,
					'Jun' => 5,
					'Jul' => 6,
					'Aug' => 7,
					'Sep' => 8,
					'Oct' => 9,
					'Nov' => 10,
					'Dec' => 11
					};

	my ($dum, $mon_name, $mday, $ts, $year) = split(/\s+/, $expiry_date);
	my ($hours, $min, $sec) = split(/:/, $ts);

	my $mon = $MONTH->{$mon_name};
        unless ($mon >= 0 and $mon <= 11)
        {
            $errstr = "Expiry Date not in identifiable format";
            return 1;
        }

	$expiry_time = timelocal($sec, $min, $hours, $mday, $mon, $year);

	if ($expiry_time <= time()) {
            $errstr = "License Expired";
            return 1;
	}
	else {
            return 0;
	}
}

## Read the license file
## returns undef on error or a valid value when everything is ok
sub Read_License ($$$) {
	my ($fname, $role, $loggerref) = @_;
	my ($line, $sign, $data, $sign_calc, $sig_line);
	my ($xs, $Lic);
        my $logger = $$loggerref;

	unless (open(LIC, "<$fname"))
        {
            $errstr = "Error opening $fname: $!";
	    $logger->error("Error opening $fname: $!");
            return undef;
        }

	$xs = XML::Simple->new();

	while (<LIC>) {
		$line = $_;
		if ($line !~ /\<SIGNATURE/) {
			$data = join('', $data, $line);
		}
		else {
                        chop($sig_line = $line);
                        eval
                        {
                            $Lic = $xs->XMLin($fname);
                        };
                        if ($@)
                        {
                            $errstr = "$@";
                            return undef;
                        }
			$sign = $Lic->{'SIGNATURE'}{'id'};
		}
	}


   if ($line =~ m/not managed/i) # case insensitive search
	{
       $errstr =$line;
       $logger->error($line);
       return undef;
	}

	unless ($sign)
        {
        $errstr = "Signature not found in license file $fname";
	    $logger->error("Signature not found in license file $fname");
            return undef;
        }

        unless (verify($data, $sign))
        {
            $errstr = "Could not verify license file $fname";
	    $logger->error("Could not verify license file $fname");
            return undef;
        }

	## Check whether the license version matches our own here
        unless (VersionMatch($Lic->{'VERSION'}, $Lic->{'PRODUCT'}, $Lic->{'PRODUCTVERSION'},$loggerref))
        {
	    $logger->debug1("License version=$Lic->{'VERSION'}, Product Version=$Lic->{'PRODUCTVERSION'}, Product=$Lic->{'PRODUCT'}");
	    $logger->error("License version/product/productversion does not match");
            return undef;
        }

	## Check the Expiry Date 
        if (expired($Lic->{'EXPIRES'}))
	{
	    $logger->error("License expired");
	    return undef;
	}

	## Check our hostid
	if ($role eq 'AGENT') {
            unless (ValidAgent($Lic->{'AGENT'}, $loggerref))
            {
		$errstr = "License Failed";
		$logger->error("License check failed");
                return undef;
            }
	}
	elsif ($role eq 'SERVER') {
            unless (ValidServer($Lic->{'SERVER'}))
            {
		$errstr = "License Failed";
                return undef;
            }
	}
	
	## Now proceed to the [hopefully] paying customers
	return $Lic;
}

# Parses given config file and returns hashref pointing to data.
sub ParseConfigFile ($ $) {
    my ($class) = shift;
    my ($arg) = shift;
    ## Basic engine for doing work.
    ##
    my $xs = new XML::Simple();

    ## Forcearray changes the whole paradigm.
    my $ref = $xs->XMLin( $arg, forcearray => 1 );

#    For debug only.
#    print Dumper ($ref);

    return $ref;
}

##
## Agent_Licensed is called by daemons on NARS Agent 
## Input - 	Configuration file where dbi information is present (nars.cfg)
##          List of features whose licensing information is asked.
## Output - List of licenses for features. non-zero value implies access granted, undef on errors
##
sub Agent_Licensed ($@) {
##	my ($narscfg, $loggerref, @Features) = @_;
##	my $LicenseFile = $LICENSE_FILE;
##	my @License_list;
##        my $logger = $$loggerref;

	return 1;

##	if (-f $LicenseFile)
##	{
##		$LicenseFile = $LICENSE_FILE;
##	}
##	elsif (GetLicensefromLS($narscfg, $loggerref))
##	{
##		$LicenseFile = $LICENSE_SERVER_FILE;
##	}
##	else
##	{
##		return undef;
##	}
##	$logger->debug2("Using license file $LicenseFile");
##
##	my $Lic = Read_License($LicenseFile, 'AGENT', $loggerref);
##        return undef unless ($Lic);
##
##	foreach $feature (@Features) {
##		if (defined(@License_list)) {
##			push(@License_list, $Lic->{'FEATURES'}{$feature});
##		}
##		else {
##			@License_list = ($Lic->{'FEATURES'}{$feature});
##		}
##	}
##	$logger->debug2("Licensed features: @Features = @License_list");
##
##	return($#License_list ? @License_list : $License_list[0]);
}

##
## Server_Licensed is called by daemons on NARS Server 
## Input - 	Configuration file where dbi information is present (nars.cfg)
##          List of features whose licensing information is asked.
## Output - List of licenses for features. non-zero value implies access granted, 
##			undef on errors
##
sub Server_Licensed ($@) {
	my ($narscfg, $loggerref, @Features) = @_;
	my $LicenseFile = $LICENSE_FILE;
	my @License_list;

	if (-f $LicenseFile)
	{
		$LicenseFile = $LICENSE_FILE;
	}
	elsif (GetLicensefromLS($narscfg, $loggerref))
	{
		$LicenseFile = $LICENSE_SERVER_FILE;
	}
	else
	{
		return undef;
	}
	my $Lic = Read_License($LicenseFile, 'SERVER', $loggerref);
        return undef unless ($Lic);

	foreach $feature (@Features) {
		if (defined(@License_list)) {
			push(@License_list, $Lic->{'FEATURES'}{$feature});
		}
		else {
			@License_list = ($Lic->{'FEATURES'}{$feature});
		}
	}
	return($#License_list ? @License_list : $License_list[0]);
}


## return 1 on success, undef on error
sub GetLicensefromLS ($) {
    my ($conffile, $loggerref) = @_;
    my $licfile = $LICENSE_SERVER_FILE;
    my $logger = $$loggerref;

    my @ls_login = GetLSLoginInfo($conffile,$loggerref);
    unless (@ls_login)
    {
        $errstr = "LM::GetLicensefromLs() Couldn't obtain License Servlet Login Info ";
	$logger->error("LM::GetLicensefromLs() Couldn't obtain License Servlet Login Info");
        return undef;
    }

    my $Poster = undef;
	push(@ls_login, $loggerref);
	my $Poster = undef;
        eval {$Poster = NexTone::Poster->new(@ls_login);};
        if ($@)
        {
            $logger->error("Unable to connect to the license servlet for license check ,$@, will try again");
            return undef;
        }

    unless ($Poster)
    {
	$logger->error("Unable to obtain NexTone::Poster object");
	$errstr = "Unable to obtain NexTone::Poster object";
        return undef;
    }

    my $postData = "";

	my $blob = $Poster->post($postData);
    if ($@)
    {
	$logger->error("Unable to post to the license servlet");
	$errstr = "Unable to post to the license servlet";
        return undef;
    }
    $blob =~ s/^\'/\"/;
    $blob =~ s/\'$/\"/;
    unless (open(DATA, ">$licfile"))
    {
	$logger->error("Cannot open file $licfile: $!");
        $errstr = "Cannot open file $licfile: $!";
        return undef;
    }

    print DATA $blob;

    close(DATA);

    return 1;
}





################################################################################
# Get the license servlet url name from the $conffile file
################################################################################
sub GetLSLoginInfo ($) {
    my ($conffile,$loggerref) = @_;

    # read the nars config file
    my $config;

    if (-f "$conffile" && -T "$conffile") {
        $config = new Config::Simple(filename=>"$conffile", mode=>O_RDONLY);
    } else {
        $errstr = "Cannot read config file $conffile";
        return undef;
    }

    my %cfghash = $config->param_hash();

    # if the password is just a '.', it means password is empty
    $cfghash{'default.pass'} = "" if ($cfghash{'default.pass'} eq '.');
    my $host = $cfghash{'default.host'};
    my $url = GetLicenseUrl($host);
    return ($cfghash{'default.user'}, $cfghash{'default.pass'}, $url);
}





################################################################################
# Get hostid of self 
################################################################################
sub SelfHostID ($@) {
	my ($loggerref) = @_;
        my $logger = $$loggerref;
	my $osn=$;
	my ($line, $data, $tag, $addr, $junk, $mac);

	if (!defined($selfHostid))
	{
		if ($osn =~ /mswin32/i) {
			$logger->debug2("Computing hostid on windows OS, will use the mac");
			system("nbtstat -n > tout");
			open(LIC, "<tout");
			while ($line = <LIC>) {
				$data = join('', $data, $line);
				if ($line =~ /IpAddress/) {
					($tag, $addr, $junk) = split(':', $line);
					$addr =~ s/^\s+\[//; $addr =~ s/\].*$//;
				}
			}
			close(LIC);
			$logger->info("$data");
			$logger->info("\nAddress is $addr\n");
			system("nbtstat -A $addr > tout");
			open(LIC, "<tout");
			while ($line = <LIC>) {
				$data = join('', $data, $line);
				if ($line =~ /MAC Address/) {
					($tag, $addr) = split('=', $line);
					$addr =~ s/^\s+//; $addr =~ s/\s+$//;
					($mac = $addr) =~ s/-//g;
				}
			}
			close(LIC);
			unlink("tout");
			$selfHostid = $mac;
		}
		elsif ($osn =~ /solaris/i) {
			$logger->debug2("Computing hostid on solaris OS");
			$selfHostid = `/usr/bin/hostid`;
		}
		elsif ($osn =~ /linux/i) {
			$logger->debug2("Computing hostid on linux OS");
			$selfHostid = `/usr/bin/hostid`;
		}
		elsif ($osn =~ /darwin/i) {
			$logger->debug2("Computing hostid on MacOS X");
			$selfHostid = 'unbound';
		}
		else {
			$logger->error("Unknown OS $osn not suppported yet");
		}

		chomp($selfHostid);
	}

	$logger->info("Local hostid is $selfHostid");

	return $selfHostid;
}


# given a mac address, make sure they are padded so that every octet is two chars
# i.e., 0:d:60:6a:ad:99 becomes 00:0d:60:6a:ad:99
sub PadMac ($@) {
	my ($macline) = @_;
	my @paddedmac = ();

	foreach $octet (split(':', $macline))
	{
		push(@paddedmac, (length($octet) == 1)?"0$octet":$octet);
	}

	return join(':', @paddedmac);
}


# given a set of lines, extract the mac addresses from them
sub ExtractMac ($@) {
	my ($loggerref, $grep, @lines) = @_;
	my $logger = $$loggerref;
	my @mac;
	my $macline;

	foreach $macline (@lines)
	{
		if ($macline =~ /$grep/)
		{
			chomp($macline);
			$macline =~ s/^\s+//;
			$macline =~ s/\s+$//;
			($dummy, $macline) = split(' ', $macline);
			$macline = PadMac($macline);
			$logger->debug4("'$macline'");
			push(@mac, $macline);
		}
	}

	return @mac;
}


################################################################################
# Get all mac addresses of self 
################################################################################
sub SelfMac ($@) {
	my ($loggerref) = @_;
        my $logger = $$loggerref;
	my $osn=$;

	if (!defined(@selfMac))
	{
		if ($osn =~ /solaris/i) {
			$logger->debug2("Computing mac on solaris OS");
			@selfMac = ExtractMac(\$logger, 'ether', `ifconfig -a`);
		}
		elsif ($osn =~ /linux/i) {
			$logger->debug2("Computing mac on linux OS");
			@selfMac = ExtractMac(\$logger, 'ether', `ip -f link addr`);
		}
		elsif ($osn =~ /darwin/i) {
			$logger->debug2("Computing mac on MacOS X");
			@selfMac = ExtractMac(\$logger, 'ether', `ifconfig -a`);
		}
		else {
			$logger->error("Unknown OS $osn not suppported yet");
		}	
	}

	$logger->info("Local mac is @selfMac");

	return @selfMac;
}


# given a set of lines, extract the IP addresses from them
sub ExtractIp ($@) {
        my ($loggerref, $grep, @lines) = @_;
        my $logger = $$loggerref;
        my @ip;
        my $ipline;

        foreach $ipline (@lines)
        {
                if ($ipline =~ /$grep/)
                {
                        chomp($ipline);
                        $ipline =~ s/^\s+//;
                        $ipline =~ s/\s+$//;
                        ($dummy, $ipline) = split(' ', $ipline);
			next if ($ipline =~ /^127/);  # ignore 127.0.0.1
                        ($ipline, $dummy) = split('/', $ipline);
                        $logger->debug4("'$ipline'");
                        push(@ip, $ipline);
                }
        }

        return @ip;
}


################################################################################
# Get all IP addresses of self
################################################################################
sub SelfIp ($@) {
        my ($loggerref) = @_;
        my $logger = $$loggerref;
        my $osn=$^O;

        if (!defined(@selfIp))
        {
                if ($osn =~ /solaris/i) {
                        $logger->debug2("Computing IP on solaris OS");
                        @selfIp = ExtractIp(\$logger, 'inet ', `ifconfig -a`);
                }
                elsif ($osn =~ /linux/i) {
                        $logger->debug2("Computing IP on linux OS");
                        @selfIp = ExtractIp(\$logger, 'inet', `ip -f inet addr`);
                }
                elsif ($osn =~ /darwin/i) {
                        $logger->debug2("Computing IP on MacOS X");
                        @selfIp = ExtractIp(\$logger, 'inet ', `ifconfig -a`);
                }
                else {
                        $logger->error("Unknown OS $osn not suppported yet");
                }
        }

        $logger->info("Local ip is @selfIp");

        return @selfIp;
}
sub GetLicenseUrl ($) {
	my($host) = @_;
	my $url =  $NexTone::Constants::LICENSE_URL_PREFIX . $host . $NexTone::Constants::LICENSE_URL_SUFFIX . "?" . $NexTone::Constants::LICENSE_ACTION_CLASS;
	return $url;
}

1;


#
# main entry point, just to test
#
#my $l = NexTone::Logger->new("/tmp/narsagentlc.log", $NexTone::Logger::DEBUG4, {maxSize => 1048576}, 'CONSOLE');
#my $tt = SelfHostID(\$l);
#print "Hostid = $tt\n";
#my @tt = SelfMac(\$l);
#print "Mac = @tt\n";
#my @tt = SelfIp(\$l);
#print "IP = @tt\n";
#if (Agent_Licensed(undef, \$l, "RAM"))
#{
#	print "-------Agent licensed\n";
#}
#else
#{
#	print "-------Agent not licensed\n";
#}



1;

