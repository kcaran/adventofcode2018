#!/usr/bin/perl
#
# It took me a few days, but I finally realized... "It's a linked list!!!"
#
use strict;
use warnings;

my %scores;

my $curr_marble = { num => 0 };
$curr_marble->{ prev } = $curr_marble;
$curr_marble->{ next } = $curr_marble;

sub place_marble {
  my ($num) = @_;

  $curr_marble = $curr_marble->{ next };
  my $next = $curr_marble->{ next };

  my $marble = { num => $num, prev => $curr_marble, next => $next };
  $curr_marble->{ next } = $marble;
  $next->{ prev } = $marble;
  $curr_marble = $marble;
  
  return;
 }

my $num_players = $ARGV[0] || die "Enter number of players\n";
my $last_marble = $ARGV[1] || die "Enter score of last marble\n";

my $player = 0;
for (my $i = 1; $i <= $last_marble; $i++) {
  if ($i % 23) {
    place_marble( $i );
   }
  else {
    # Back up 7
    for (my $p = 0; $p < 7; $p++) {
      $curr_marble = $curr_marble->{ prev };
     }

    $scores{ $player } += $i + $curr_marble->{ num };
#print "$curr_marble->{ prev }{ num }: $player scores $i + $curr_marble->{ num }\n";
    $curr_marble->{ prev }{ next } = $curr_marble->{ next };
    $curr_marble->{ next }{ prev } = $curr_marble->{ prev };
    $curr_marble = $curr_marble->{ next };
   }
  $player = ($player + 1) % $num_players;
 }

my $highest = (sort { $b <=> $a } (values %scores))[0];

print "The highest score is $highest\n";
