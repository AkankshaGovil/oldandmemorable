use strict;
use Test;
use Config::Simple;
use File::Spec;

BEGIN { plan tests => 29 }

ok(1);

my $filename = File::Spec->catfile("t", "sample.cfg");
my $cfg = new Config::Simple(filename=>$filename, mode=>O_RDONLY|O_CREAT) or die $Config::Simple::errstr;

ok($cfg);
ok(scalar($cfg->param()), 9);
ok($cfg->param("module.name"), "Config::Simple");
ok($cfg->param(-name=>"author.f_name"), "Sherzod"); # test 5

my $module = $cfg->param(-block=>"module");
my $author = $cfg->param(-block=>"author");

ok($module->{author}, "sherzodR");
ok($author->{url}, "http://www.ultracgis.com");
ok($author->{nick}, $module->{author});

my %Config = $cfg->param_hash();

ok($Config{'author.f_name'}, "Sherzod");
ok($Config{'module.name'}, "Config::Simple");   # test 10
ok($Config{'module.name'}, $cfg->param(-name=>"module.name"));

$cfg->param(-block=>"test-results", -values => {
    tests   => 29,
    succeeded=>29,
    failed  => "n/a"});

$filename = File::Spec->catfile("t", "mod-sample.cfg");
ok( $cfg->write($filename) ) or die $cfg->error();

$cfg = new Config::Simple(filename=>$filename, mode=>O_RDONLY) or die $Config::Simple::errstr;

ok($cfg);
ok(scalar($cfg->param()), 12);
ok($cfg->param("module.name"), "Config::Simple");   # test 15
ok($cfg->param(-name=>"author.f_name"), "Sherzod");
ok($cfg->param(-name=>"test-results.succeeded"), 29);
ok($cfg->param(-name=>"test-results.failed"), "n/a");

$module = $cfg->param(-block=>"module");
$author = $cfg->param(-block=>"author");
my $test   = $cfg->param(-block=>"test-results");

ok($module->{author}, "sherzodR");
ok($author->{url}, "http://www.ultracgis.com"); # test 20
ok($author->{nick}, $module->{author});
ok($test->{failed}, "n/a");
ok($test->{succeeded}, 29);

%Config = $cfg->param_hash();

ok($Config{'author.f_name'}, "Sherzod");
ok($Config{'module.name'}, "Config::Simple");   # test 25
ok($Config{'module.name'}, $cfg->param(-name=>"module.name"));
ok($Config{"test-results.succeeded"}, 29);


ok($Config{'author.email'}, 'sherzodr@cpan.org');
ok($Config{'author.url'}, 'http://www.ultracgis.com');

