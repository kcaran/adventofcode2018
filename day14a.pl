#!/usr/bin/perl
#
use strict;
use warnings;

my $total = $ARGV[0] || 327901;

my @recipes = ( 3, 7 );

my $elf1 = 0;
my $elf2 = 1;

# Don't count first two recipes
while (@recipes < $total + 12) {
  my @new_recipes = split( '', $recipes[$elf1] + $recipes[$elf2] );
  push @recipes, @new_recipes;
  $elf1 = ($elf1 + $recipes[$elf1] + 1) % @recipes;
  $elf2 = ($elf2 + $recipes[$elf2] + 1) % @recipes;
print "$elf1, $elf2, ", scalar @recipes, "\n";
 }

print "The next 10 recipes after $total are ", join( '', @recipes[$total .. $total + 9] ), "\n";
exit;
