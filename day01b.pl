#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input01.txt';

my $frequency = 0;
my %freq_record = ();
my $dup_freq;

my @freq_changes = path( $input_file )->lines_utf8( { chomp => 1 } );

while (!defined $dup_freq) {
  for my $change (@freq_changes) {
    $freq_record{ $frequency } = 1;
    $frequency += $change;
    if ($freq_record{ $frequency }) {
      $dup_freq = $frequency;
      last;
     }
   }
 }

print "The first duplicate frequency is $dup_freq\n";
