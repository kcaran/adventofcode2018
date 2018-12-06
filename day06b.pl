#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Grid;

  sub sum_dist {
    my ($self, $x, $y) = @_;

    if ($self->{ sum_dist }{ "$x, $y" }) {
      return ($self->{ sum_dist }{ "$x, $y" } < $self->{ max_dist });
     }

    my $dist = 0;
    for my $test (@{ $self->{ points } }) {
      last if ($dist >= $self->{ max_dist });
      $dist += $test->distance( $x, $y );
     }

   $self->{ sum_dist }{ "$x, $y" } = $dist;

   return ($dist < $self->{ max_dist });
  }

  sub safe_area {
    my ($self, $point) = @_;

    my $area = 0;

    # Find boundaries of area
    my $mid_x = int( ($self->{ max_x } - $self->{ min_x })/2 );
    my $mid_y = int( ($self->{ max_y } - $self->{ min_y })/2 );

    my $min_x = $mid_x;
    while ($self->sum_dist( $min_x - 1, $mid_y )) {
      $min_x--;
     }

    my $max_x = $mid_x;
    while ($self->sum_dist( $max_x + 1, $mid_y )) {
      $max_x++;
     }

    my $min_y = $mid_y;
    while ($self->sum_dist( $mid_x, $min_y - 1 )) {
      $min_y--;
     }

    my $max_y = $mid_y;
    while ($self->sum_dist( $mid_x, $max_y + 1 )) {
      $max_y++;
     }

    for (my $x = $min_x; $x <= $max_x; $x++) {
      for (my $y = $min_y; $y <= $max_y; $y++) {
        $area++ if ($self->sum_dist( $x, $y ));
       }
     }

    return $area;
   }

  sub new {
    my $class = shift;
    my ($input_file, $distance) = @_;

    my $self = {
      min_x => 0,
      min_y => 0,
      max_x => 0,
      max_y => 0,
      points => [],
      sum_dist => {},
      max_dist => $distance,
    };

   my $num_points = 0;
   for my $point ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } ) ) {
     my ($x, $y) = $point =~ /\s*(\d+),\s*(\d+)/;
     $self->{ min_x } = $x if ($x < $self->{ min_x });
     $self->{ max_x } = $x if ($x > $self->{ max_x });
     $self->{ min_y } = $y if ($y < $self->{ min_y });
     $self->{ max_y } = $y if ($y > $self->{ max_y });

     $num_points++;
     push @{ $self->{ points } }, Point->new( $num_points, $x, $y );
    }

   bless $self, $class;

   return $self;
  }
};

{ package Point;

  sub distance {
    my $self = shift;
    my ($x, $y) = @_;

    return (abs( $self->{ x } - $x ) + abs( $self->{ y } - $y ));
   }

  sub new {
    my $class = shift;
    my ($id, $x, $y) = @_;
    my $self = {
      id => $id,
      x => $x,
      y => $y,
      inf => 0,
    };
   bless $self, $class;

   return $self;
  }
}

my $input_file = $ARGV[0] || 'input06.txt';
my $max_dist = $ARGV[1] || 10000;

my $grid = Grid->new( $input_file, $max_dist );

print "The safe area is ", $grid->safe_area(), "\n";
exit;
