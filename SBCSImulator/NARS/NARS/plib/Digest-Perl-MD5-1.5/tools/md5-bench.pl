#!/usr/local/bin/perl -w
# $Id: md5-bench.pl,v 1.1 2002/10/22 21:48:31 ptyagi Exp $
# Benchmark
# compares Digest::Perl::MD5 and Digest::MD5

use strict;
use Benchmark;
use Digest::MD5;
use lib '../lib';
use Digest::Perl::MD5;

timethese(250_000,{
	'MD5' => 'Digest::MD5::md5(q!delta!)',
	'Perl::MD5' => 'Digest::Perl::MD5::md5(q!delta!)',
});
