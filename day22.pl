#!/usr/bin/env perl
#
# Testing arguments:
# $ day22.pl 510 10,10
#
#
use strict;
use warnings;

use Data::Printer;
use Path::Tiny;

{ package Cave;

  my @invalid = ( 'X', 'T', 'C' );

  sub index {
    my ($self, $x, $y) = @_;
    my $index;

    # Have we already calculated it?
    return $self->{ grid }[$x][$y] if (defined $self->{ grid }[$x][$y]);

    if ($x == 0) {
      $index = $y * 48271;
     }
    elsif ($y == 0) {
      $index = $x * 16807;
     }
    else {
      $index = $self->erosion( $self->index( $x-1, $y ) ) * $self->erosion( $self->index( $x, $y-1 ) );
     }

    $index = 0 if ($x == $self->{ targx } && $y == $self->{ targy });

    $self->{ grid }[$x][$y] = $index;

    return $index;
   }

  sub erosion {
    my ($self, $index) = @_;

    return ($index + $self->{ depth }) % 20183;
   }

  sub risk_level {
    my ($self) = @_;
    my $risk = 0;
    for (my $x = 0; $x < $self->{ targx } + 1; $x++) {
      for (my $y = 0; $y < $self->{ targy } + 1; $y++) {
        $risk += $self->erosion( $self->{ grid }[$x][$y] ) % 3;
       }
     }

    return $risk;
   }

  sub fill_grid {
    my ($self) = @_;

    for (my $x = 0; $x < $self->{ targx } + 1; $x++) {
      for (my $y = 0; $y < $self->{ targy } + 1; $y++) {
        $self->index( $x, $y );
       }
     }

    return $self;
   }

  sub moves {
    my ($self) = @_;
    $self->{ moves }++;

    my $next_moves = [];
    for my $move (@{ $self->{ move_list } }) {
      push @{ $next_moves }, $self->next_move( $move );
     }

    $self->{ move_list } = $next_moves;

    return !$self->{ reached };
   }

  sub next_move {
    my ($self, $move) = @_;

    my @next_moves;

    # Can't do anything else if switching tools
    if ($move->{ switch }) {
      $move->{ switch }--;
      if ($move->{ x } == $self->{ targx } && $move->{ y } == $self->{ targy } && $move->{ tool } eq 'T' && $move->{ switch } == 0) {
        $self->{ reached }++;
       }
      return $move;
     }

    my $x = $move->{ x };
    my $y = $move->{ y };

    # Switch tools - This is the first minute out of 7
    for my $tool (qw( T C X )) {
      push @next_moves, $self->test_move( { x => $x, y => $y, tool => $tool, switch => 6 } );
     }

    # Test moves
    push @next_moves, $self->test_move( { x => $x - 1, y => $y, tool => $move->{ tool }, switch => 0 } );
    push @next_moves, $self->test_move( { x => $x + 1, y => $y, tool => $move->{ tool }, switch => 0 } );
    push @next_moves, $self->test_move( { x => $x, y => $y - 1, tool => $move->{ tool }, switch => 0 } );
    push @next_moves, $self->test_move( { x => $x, y => $y + 1, tool => $move->{ tool }, switch => 0 } );

    return @next_moves;
   }

  # Make sure move is valid
  sub test_move {
    my ($self, $move) = @_;

    my $hist_idx = "$move->{ x },$move->{ y },$move->{ tool }";
    return () if $self->{ history }{ $hist_idx };

    return () if ($move->{ x } < 0);
    return () if ($move->{ y } < 0);

    my $region = $self->erosion( $self->index( $move->{ x }, $move->{ y } ) ) % 3;
    return () if ($invalid[$region] eq $move->{ tool });

    # NOTE: It is possible to reach the same spot with a tool later but faster
    # than getting there and then switching tools!
    $self->{ history }{ $hist_idx } = 1 if ($move->{ switch } == 0);

    if ($move->{ x } == $self->{ targx } && $move->{ y } == $self->{ targy } && $move->{ tool } eq 'T' && $move->{ switch } == 0) {
      $self->{ reached }++;
     }

    return ( $move );
   }

  sub new {
    my ($class, $depth, $target) = @_;
    my ($x, $y) = split /,/, $target;
    my $self = { 
		grid => [],
		depth => $depth,
        targx => $x,
        targy => $y,
        moves => 0,
        move_list => [ { x => 0, y => 0, tool => 'T', switch => 0 } ],
        history => { "0,0,T" => 1 },
        reached => 0,
		};
    bless $self, $class;

    $self->index( 10, 10 );
    $self->fill_grid();

    return $self;
  }
}

my $depth = $ARGV[0] || 8787;
my $target = $ARGV[1] || '10,725';

my $cave = Cave->new( $depth, $target );

print "The risk level is ", $cave->risk_level(), "\n";

while ($cave->moves()) {};

print "The minimum moves to the target is ", $cave->{ moves }, "\n";
