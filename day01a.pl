#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input01.txt';

my $frequency = 0;

for (path( $input_file )->lines_utf8) {
  $frequency += $_;
 }

print "The final frequency is $frequency\n";
