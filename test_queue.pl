#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

my $possible = [ [ 0, 500 ] ];

for my $p (@{ $possible }) {
  print "\$p = [ $p->[0], $p->[1] ]\n";
  if ($p->[1] < 505) {
    my $x = $p->[1] + 1;
    $p->[1]++;
    push @{ $possible }, [ 1, $x ];
   }
 }
