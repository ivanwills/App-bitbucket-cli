#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

BEGIN {
    use_ok( 'App::BitBucketCli' );
}

diag( "Testing App::BitBucketCli $App::BitBucketCli::VERSION, Perl $], $^X" );
done_testing();
