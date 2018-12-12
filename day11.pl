#!/usr/bin/perl
#
# Day 11 - I optimized finding the largest square by subtracing the last
# column and adding the new one. 
#
# The big puzzle is how to determine the solution is converging.
#
use strict;
use warnings;

my $serial = $ARGV[0] || 9445;
my $grid;

sub cell_power {
  my ($x, $y) = @_;

  my $rack_id = $x + 10;
  my $power = ($rack_id * $y + $serial) * $rack_id;
  $power = ($power / 100) % 10 - 5;

  return $power;
 }
 
sub next_col_diff {
  my ($x, $y, $size) = @_;
  my $diff = 0;

  for (my $i = 0; $i < $size; $i++) {
    $diff -= $grid->[$x + $i][$y - 1];
    $diff += $grid->[$x + $i][$y + $size - 1];
   }

  return $diff;
 }

sub square_power {
  my ($x, $y, $size) = @_;
  my $power = 0;

  for (my $row = 0; $row < $size; $row++) {
    for (my $col = 0; $col < $size; $col++) {
      $power += $grid->[$x + $row][$y + $col];
     }
   }

  return $power;
 }

for (my $row = 0; $row < 300; $row++) {
  for (my $col = 0; $col < 300; $col++) {
    $grid->[$row][$col] = cell_power( $row + 1, $col + 1 );
   }
  }


my $max_power = 0;
my $max_square = '';

=cut
for (my $row = 0; $row < 300 - 3; $row++) {
  for (my $col = 0; $col < 300 - 3; $col++) {
    my $power = square_power( $row, $col, 3 );
    if ($power > $max_power) {
      $max_power = $power;
      $max_square = ($row + 1) . ',' . ($col + 1);
     }
   }
 }

print "The square with the largest total power begins at ($max_square)\n";
=cut

$max_power = 0;
$max_square = '';
my $prev_max = '';
my $max_count = 1;

for (my $size = 1; $size <= 300; $size++) {
  print "Checking $size: $max_square\n";
  for (my $row = 0; $row < 300 - $size; $row++) {
    my $curr_power = square_power( $row, 0, $size );
    if ($curr_power > $max_power) {
      $max_power = $curr_power;
      $max_square = "$row,0,$size";
     }

    for (my $col = 1; $col < 300 - $size; $col++) {
      $curr_power += next_col_diff( $row, $col, $size );
      if ($curr_power > $max_power) {
        $max_power = $curr_power;
        $max_square = ($row + 1) . ',' . ($col + 1) . ",$size";
       }
     }
   }

  if ($max_square eq $prev_max) {
    $max_count++;
   }
  else {
    $prev_max = $max_square;
    $max_count = 1;
   }

  # How do I determine if this is really the maximum??
  last if ($max_count > 2);
 }
