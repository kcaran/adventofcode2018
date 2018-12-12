#!/usr/bin/perl
#
#
use strict;
use warnings;

my @marbles = ( 0 );
my %scores;

my $curr_marble = 0;

sub place_marble {
  my ($marble) = @_;

  $curr_marble = ($curr_marble + 1) % @marbles;
  splice( @marbles, $curr_marble + 1, 0, $marble );
  $curr_marble++;
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
    # Account for wrap-arounds
    $curr_marble = ($curr_marble + @marbles - 7) % @marbles;
    $scores{ $player } += $i + $marbles[$curr_marble];
print "$curr_marble: $player scores $i + $marbles[$curr_marble]\n";
    splice( @marbles, $curr_marble, 1 );
   }
  $player = ($player + 1) % $num_players;
 }

my $highest = (sort { $b <=> $a } (values %scores))[0];

print "The highest score is $highest\n";
