#!/usr/bin/perl
#
# Note: With a boost of 20, both sides are immune to the others' attacks!
# No one wins!
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Star;

  sub in_constellation {
    my ($self, $const) = @_;

    for my $star (@{ $const }) {
      if ($self->dist( $star ) <= 3) {
        push @{ $const }, $self;
        return 1;
       }
     }

    return;
   }

  sub dist {
    my ($self, $star) = @_;
 
    return abs( $self->{ a } - $star->{ a } )
		+ abs( $self->{ b } - $star->{ b } )
		+ abs( $self->{ c } - $star->{ c } )
		+ abs( $self->{ d } - $star->{ d } );
   }

  sub new {
    my ($class, $input) = @_;

    my ($a, $b, $c, $d) = split /,/, $input;
    my $self = {
      a => $a,
      b => $b,
      c => $c,
      d => $d,
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input25.txt';

my $constellations = [];

for my $line ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  my $star = Star->new( $line );
  my $found = -1;
  my $c = 0;
  while ($c < @{ $constellations }) {
    if ($star->in_constellation( $constellations->[$c] )) {
      if ($found >= 0) {
        # This star is in two constellations! Combine them into one
        push @{ $constellations->[$found] }, @{ $constellations->[$c] };
        splice( @{ $constellations }, $c, 1 );
        # Don't increment!
        $c--;
       }
      else {
        $found = $c;
       }
     }
    $c++;
   }

  if ($found == -1) {
    push @{ $constellations }, [ $star ];
   }
 }

print "There are ", scalar @{ $constellations }, " constellations.\n";

exit;
