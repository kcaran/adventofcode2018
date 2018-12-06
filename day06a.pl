#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Grid;

  sub is_closest {
    my ($self, $point, $x, $y) = @_;

    if ($self->{ closest }{ "$x, $y" }) {
      return ($self->{ closest }{ "$x, $y" } == $point->{ id });
     }

    my $dist = $point->distance( $x, $y );
    for my $test (@{ $self->{ points } }) {
      next if ($test->{ id } == $point->{ id });
      return 0 if ($test->distance( $x, $y ) <= $dist);
     }

   $self->{ closest }{ "$x, $y" } = $point->{ id };
   return 1;
  }

  sub find_area {
    my ($self, $point) = @_;

    my $area = 0;

    # Find boundaries of area
    my $min_x = $point->{ x };
    while ($self->is_closest( $point, $min_x - 1, $point->{ y } )) {
      $min_x--;
     }

    my $max_x = $point->{ x };
    while ($self->is_closest( $point, $max_x + 1, $point->{ y } )) {
      $max_x++;
     }

    my $min_y = $point->{ y };
    while ($self->is_closest( $point, $point->{ x }, $min_y - 1 )) {
      $min_y--;
     }

    my $max_y = $point->{ y };
    while ($self->is_closest( $point, $point->{ x }, $max_y + 1 )) {
      $max_y++;
     }

    for (my $x = $min_x; $x <= $max_x; $x++) {
      for (my $y = $min_y; $y <= $max_y; $y++) {
        $area++ if ($self->is_closest( $point, $x, $y ));
       }
     }

    return $area;
   }

  sub largest_area {
    my $self = shift;
    my $largest = 0;
    for my $point (@{ $self->{ points } }) {
      next if ($point->{ inf } < 0);
      my $area = $self->find_area( $point );
      $largest = $area if ($area > $largest);
     }

    return $largest;
   }

  sub test_infinite_min_x {
    my $self = shift;

    POINT: for my $point (@{ $self->{ points } }) {
      # Don't bother if already infinite
      next if ($point->{ inf } < 0);
      for my $test (@{ $self->{ points } }) {
        next if ($test->{ id } == $point->{ id });
        my $x = $self->{ min_x };
        next POINT if ($test->distance( $x, $point->{ y } ) <= $point->distance( $x, $point->{ y } ));
       }
 
      # Use negative numbers to determine the direction
      $point->{ inf } = -1;
     }

    return;
   }

  sub test_infinite_max_x {
    my $self = shift;

    POINT: for my $point (@{ $self->{ points } }) {
      # Don't bother if already infinite
      next if ($point->{ inf } < 0);
      for my $test (@{ $self->{ points } }) {
        next if ($test->{ id } == $point->{ id });
        my $x = $self->{ max_x };
        next POINT if ($test->distance( $x, $point->{ y } ) <= $point->distance( $x, $point->{ y } ));
       }
 
      # Use negative numbers to determine the direction
      $point->{ inf } = -2;
     }

    return;
   }
 
  sub test_infinite_min_y {
    my $self = shift;

    POINT: for my $point (@{ $self->{ points } }) {
      # Don't bother if already infinite
      next if ($point->{ inf } < 0);
      for my $test (@{ $self->{ points } }) {
        next if ($test->{ id } == $point->{ id });
        my $y = $self->{ min_x };
        next POINT if ($test->distance( $point->{ x }, $y ) <= $point->distance( $point->{ x }, $y ));
       }
 
      # Use negative numbers to determine the direction
      $point->{ inf } = -3;
     }

    return;
   }

  sub test_infinite_max_y {
    my $self = shift;

    POINT: for my $point (@{ $self->{ points } }) {
      # Don't bother if already infinite
      next if ($point->{ inf } < 0);
      for my $test (@{ $self->{ points } }) {
        next if ($test->{ id } == $point->{ id });
        my $y = $self->{ max_y };
        next POINT if ($test->distance( $point->{ x }, $y ) <= $point->distance( $point->{ x }, $y ));
       }
 
      # Use negative numbers to determine the direction
      $point->{ inf } = -4;
     }

    return;
   }
 
  sub new {
    my $class = shift;
    my ($input_file) = @_;

    my $self = {
      min_x => 0,
      min_y => 0,
      max_x => 0,
      max_y => 0,
      points => [],
      closest => {},
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

my $grid = Grid->new( $input_file );
$grid->test_infinite_min_x();
$grid->test_infinite_max_x();
$grid->test_infinite_min_y();
$grid->test_infinite_max_y();

print "The largest area is ", $grid->largest_area(), "\n";
exit;
