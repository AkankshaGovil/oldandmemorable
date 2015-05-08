package NexTone::Config;

#
# A module to read the nars.cfg and provide an interface to
# connect to the database and get other information
#
require 5.004;
use Config::Simple;

use vars qw($VERSION @ISA);
$VERSION = '0.01';
@ISA = qw(Exporter); 

=head1 NAME

NexTone::Config - NarsAgent Configuration information Module

=head1 SYNOPSIS

	use NexTone::Config;

=head1 DESCRIPTION

B<NexTone::Config> is the NarsAgent Configuration class.

=cut

### END - DEFINITIONS AND IMPORTS


### BEGIN - PARAMETER DEFS
my $CONFFILE = '/usr/local/narsagent/nars.cfg';

### END - PARAMETER DEFS


### BEGIN - FUNCTION DEFINITIONS 

=head1 CLASS METHODS

=head2 new ()

Returns a new B<NexTone::Config> object. 

=cut
sub new() {
	my $self;
	my $class = shift;
	my $varc;
	$class = ref($class) || $class;


    # read the nars config file
    my $config;

	$self =  { _narscfg => {} };
	$varc = $self->{'_narscfg'};
    if (-f "$CONFFILE" && -T "$CONFFILE") {
        $config = new Config::Simple(filename=>"$CONFFILE", mode=>'O_RDONLY');
		%$varc =  $config->param_hash();
    } else {
        warn("Cannot read config file $CONFFILE");
    }


	bless $self => $class;
    return $self;
}

=head2 get ($var1, $var2, ...)

Returns the values of variables requested. It can be called with 
a scalar argument or an array argument. If a variable is not found
in the configuration file, it returns undef value for that variable.

=cut
sub get {
	my $self = shift;
	my @args = @_;
	my @val;

	if ($#args == 1) {
		return $self->{'_narscfg'}->{$args[0]};
	}

	foreach (@args) {
	 	push(@val, $self->{'_narscfg'}->{$_});
	}
	return @val;
}

=head2 GetDBILogin ()

Returns the DBI Login information from the config file. So,
the user can call DBI connect with the return arguments

=cut
sub GetDBILogin() {
	my $self = shift;

	return $self->get('.dburl', '.dbuser', '.dbpass');
}

### END - FUNCTION DEFINITIONS

1;
