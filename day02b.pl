#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

sub compare_boxes
 {
  my ($box1, $box2) = @_;

  die "Invalid ID input" if ($box1 eq $box2 || length( $box1 ) != length( $box2 ));

  my @letters1 = split( '', $box1 );
  my @letters2 = split( '', $box2 );

  my $idx = 0;
  my $differ_idx = -1;
  while ($idx < @letters1) {
    if ($letters1[$idx] ne $letters2[$idx]) {
      return unless ($differ_idx < 0);
      $differ_idx = $idx;
     }
    $idx++;
   }

  # Rejoin letters without difference
  $letters1[$differ_idx] = '';

  return join( '', @letters1 );
 }

my $input_file = $ARGV[0] || 'input02.txt';

my @box_input = path( $input_file )->lines_utf8( { chomp => 1 } );

my @boxes_seen = ();

my $common;

for my $box (@box_input) {
  for my $seen (@boxes_seen) {
    last if ($common = compare_boxes( $box, $seen ));
   }
  last if ($common);

  push @boxes_seen, $box;
 }

print "The common letters are: $common\n";
