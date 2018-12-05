#!/usr/bin/perl

use strict;
use warnings;

use Path::Tiny;

sub reactions {
  my ($polymer_ref) = @_;
  my $new = '';

  my $idx = 0;
  while ($idx < length( $$polymer_ref )) {
    my $letter = substr( $$polymer_ref, $idx, 1 );
    my $next = substr( $$polymer_ref, $idx + 1, 1 );
    if (($letter =~ /[a-z]/ && $next eq uc( $letter ))
     || ($letter =~ /[A-Z]/ && $next eq lc( $letter ))) {
      $idx++;
     }
    else {
      $new .= $letter;
     }
    $idx++;
   }

  my $had_reaction = ($new ne $$polymer_ref);
  $$polymer_ref = $new;

  return $had_reaction;
 }

sub shortest_polymer {
  my ($polymer) = @_;

  while (reactions( \$polymer )) {
   }

  return length( $polymer );
 }

my $input_file = $ARGV[0] || 'input05.txt';

my $polymer = path( $input_file )->slurp_utf8();
chomp $polymer;

my $original_shortest = shortest_polymer( $polymer );
print "After reactions, the original has $original_shortest characters.\n";

my $shortest = $original_shortest;

for my $let ('a' .. 'z') {
  my $test = $polymer;
  $test =~ s/$let//ig;
  my $test_length = shortest_polymer( $test );
  if ($test_length < $shortest) {
    $shortest = $test_length;
   }
 }

print "After removal of one unit and reactions, the shortest polymer has $shortest characters.\n";

