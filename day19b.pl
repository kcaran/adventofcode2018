#!/usr/bin/perl
#
# Advent of Code 2018 - Day 19
#
# The program finds all of the factors of the number and sums them. By
# brute force and print statements, I found the numbers to be 954 in part 1
# and 10551354 in part 2
#
use strict;
use warnings;

my $number = $ARGV[0] || "10551354";

my $factor = 1;

# Include the number itself as a factor
my $total = $number;

while ($factor <= $number / 2) {
  if (int( $number / $factor ) == ($number / $factor)) {
    $total += $factor;
   }
  $factor++;
 }

print "The total of all factors is $total\n";
