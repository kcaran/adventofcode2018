#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use List::Util qw( max min );
use Path::Tiny;

my $overlap_claims = {};

{ package Claim;

  sub new {
    my $class = shift;
    my $input = shift;

    my ($id, $left, $top, $width, $height) = $input =~ /^\#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/;
    my $self = {
      id => $id,
      map => [ [ $left, $left + $width - 1 ], [ $top, $top + $height - 1 ] ],
      has_overlap=> 0,
    };
   bless $self, $class;

   return $self;
  }
};

sub test_overlaps {
  my ($claim1, $claim2) = @_;

  my $min_x = max( $claim1->{ map }[0][0], $claim2->{ map }[0][0] );
  my $max_x = min( $claim1->{ map }[0][1], $claim2->{ map }[0][1] );
  my $min_y = max( $claim1->{ map }[1][0], $claim2->{ map }[1][0] );
  my $max_y = min( $claim1->{ map }[1][1], $claim2->{ map }[1][1] );

  return unless ($min_x <= $max_x && $min_y <= $max_y);

  $claim1->{ has_overlap } = 1;
  $claim2->{ has_overlap } = 1;

  for (my $x = $min_x; $x <= $max_x; $x++) {
    for (my $y = $min_y; $y <= $max_y; $y++) {
       $overlap_claims->{ "$x,$y" } = 1;
     }
   }

  return;
 }

my @elves;
my $input_file = $ARGV[0] || 'input03.txt';

my @claim_input = path( $input_file )->lines_utf8( { chomp => 1 } );

for my $input (@claim_input) {
  my $new_elf = Claim->new( $input );
  for my $elf (@elves) {
    test_overlaps( $elf, $new_elf );
   }
  push @elves, $new_elf;
 }

print "There is ", scalar keys %{ $overlap_claims }, " sq in. of overlap.\n";

for my $elf (@elves) {
  if (!$elf->{ has_overlap }) {
    print "Elf #$elf->{ id } does not have an overlap\n";
   }
 }
