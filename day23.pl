#!/usr/bin/env perl
#
use strict;
use warnings;

use Data::Printer;
use Path::Tiny;

{ package Nanobot;

  sub in_range {
    my ($self, $box) = @_;

    my $dist = 0;

    if ($self->{ x } > $box->{ x } + $box->{ side } - 1) {
      $dist += $self->{ x } - ($box->{ x } + $box->{ side } - 1);
     }
    elsif ($self->{ x } < $box->{ x } - $box->{ side } - 1) {
      $dist += $box->{ x } - $box->{ side } - $self->{ x };
     }

    if ($self->{ y } > $box->{ y } + $box->{ side } - 1) {
      $dist += $self->{ y } - ($box->{ y } + $box->{ side } - 1);
     }
    elsif ($self->{ y } < $box->{ y } - $box->{ side } - 1) {
      $dist += $box->{ y } - $box->{ side } - $self->{ y };
     }

    if ($self->{ z } > $box->{ z } + $box->{ side } - 1) {
      $dist += $self->{ z } - ($box->{ z } + $box->{ side } - 1);
     }
    elsif ($self->{ z } < $box->{ z } - $box->{ side } - 1) {
      $dist += $box->{ z } - $box->{ side } - $self->{ z };
     }

    return ($dist <= $self->{ r });
   }

  sub dist {
    my ($self, $x, $y, $z) = @_;

    return (abs( $self->{ x } - $x ) + abs( $self->{ y } - $y ) + abs( $self->{ z } - $z ));
   }

  sub new {
    my ($class, $input) = @_;
    my ($x, $y, $z, $r) = ($input =~ /([0-9-]+)/g);
    my $self = { 
		x => $x,
		y => $y,
        z => $z,
        r => $r,
		};
    bless $self, $class;

    return $self;
  }
}

{ package BoundingBox;

  sub dist {
    my ($self, $x, $y, $z) = @_;

    return (abs( $self->{ x } - $x ) + abs( $self->{ y } - $y ) + abs( $self->{ z } - $z ));
   }

  sub in_range {
    my ($self, $bots) = @_;

    return $self->{ in_range } if (defined $self->{ in_range });
    my $count = 0;
    for my $b (@{ $bots }) {
      $count++ if ($b->in_range( $self ));
     }

    $self->{ in_range } = $count;
    return $count;
   }

  sub split {
    my ($self, $bots) = @_;

    my @new_boxes = ();
    my $side = $self->{ side } / 2;
    my ($x, $y, $z) = @{ $self }{ qw( x y z ) };

    push @new_boxes, BoundingBox->new( $side, $x - $side, $y - $side, $z - $side );
    push @new_boxes, BoundingBox->new( $side, $x - $side, $y - $side, $z + $side );
    push @new_boxes, BoundingBox->new( $side, $x - $side, $y + $side, $z - $side );
    push @new_boxes, BoundingBox->new( $side, $x - $side, $y + $side, $z + $side );
    push @new_boxes, BoundingBox->new( $side, $x + $side, $y - $side, $z - $side );
    push @new_boxes, BoundingBox->new( $side, $x + $side, $y - $side, $z + $side );
    push @new_boxes, BoundingBox->new( $side, $x + $side, $y + $side, $z - $side );
    push @new_boxes, BoundingBox->new( $side, $x + $side, $y + $side, $z + $side );

    return @new_boxes;
   }

  sub new {
    my ($class, $side, $x, $y, $z) = @_;

    my $self = {
		x => $x || 0,
		y => $y || 0,
		z => $z || 0,
        side => $side,
		};

    bless $self, $class;
   }
}

sub in_range {
  my ($bots, $idx) = @_;
  my ($x, $y, $z, $r) = @{ $bots->[$idx] }{ qw( x y z r ) };
  my $in = 0;

  for my $b (@{ $bots }) {
    $in++ if ($b->dist( $x, $y, $z ) <= $r);
   }

  return $in;
 }

my $input_file = $ARGV[0] || 'input23.txt';

my $bots = [];

my $strong_val = -1;
my $strong_idx = -1;

my ($min_x, $min_y, $min_z) = (0, 0, 0);

for (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  my $bot = Nanobot->new( $_ );
  if ($bot->{ r } > $strong_val) {
    $strong_val = $bot->{ r };
    $strong_idx = @{ $bots };
   }
  $min_x = $bot->{ x } if ($bot->{ x } < $min_x);
  $min_y = $bot->{ y } if ($bot->{ y } < $min_y);
  $min_z = $bot->{ z } if ($bot->{ z } < $min_z);

  push @{ $bots }, $bot;
 }

print "The strongest is at $strong_idx\n";
print "There are ", in_range( $bots, $strong_idx ), " in range of the strongest.\n";

# Make sure the bounding box covers all of the bots
my $side = (1 << 28);
my $boxes = [ BoundingBox->new( $side, $min_x + $side, $min_y + $side, $min_z + $side ) ];

my $best_box;
while (1) {
  #
  # Choosing the 'best' box with the most bots in range, split it into eight
  # equal parts and see if one of those is still the best. Keep splitting
  # until the best is a single point (side == 1)
  #
  $boxes = [ sort { $b->in_range( $bots ) <=> $a->in_range( $bots ) || $a->dist( 0, 0, 0 ) <=> $b->dist( 0, 0, 0 ) || $a->{ side } <=> $b->{ side } } @{ $boxes } ];
  $best_box = shift @{ $boxes };
print $best_box->in_range( $bots ), " in range for ($best_box->{ x }, $best_box->{ y }, $best_box->{ z }) side $best_box->{ side }\n";
  last if ($best_box->{ side } == 1);
  push @{ $boxes }, $best_box->split( $bots );
 }

print "The distance is: ", $best_box->dist( 0, 0, 0 ), "\n";

exit;
