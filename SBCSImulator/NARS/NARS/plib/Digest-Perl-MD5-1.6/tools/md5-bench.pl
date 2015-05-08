#!/usr/local/bin/perl -w
# $Id: md5-bench.pl,v 1.1 2004/06/02 17:31:22 santosh Exp $
# Benchmark
# compares Digest::Perl::MD5 and Digest::MD5

use strict;
use Benchmark;
use Digest::MD5;
use lib '../lib';
use Digest::Perl::MD5;

timethese(-60,{
	'MD5' => 'Digest::MD5::md5(q!delta!)',
	'Perl::MD5' => 'Digest::Perl::MD5::md5(q!delta!)',
});
