#!/usr/bin/perl
#
use strict;
use warnings;

my $total = $ARGV[0] || "327901";

my @recipes = ( 3, 7 );

my $elf1 = 0;
my $elf2 = 1;

# Don't count first two recipes
my $length = length( $total );
while ( join( '', @recipes[-$length .. -1] ) ne $total
     && join( '', @recipes[-$length -1 .. -2] ) ne $total) {
  my @new_recipes = split( '', $recipes[$elf1] + $recipes[$elf2] );
  push @recipes, @new_recipes;
  $elf1 = ($elf1 + $recipes[$elf1] + 1) % @recipes;
  $elf2 = ($elf2 + $recipes[$elf2] + 1) % @recipes;
 }

my $count = @recipes - $length;
$count-- if (join( '', @recipes[-$length -1 .. -2] ) eq $total);
print "$total first appears after $count recipes\n";

exit;
