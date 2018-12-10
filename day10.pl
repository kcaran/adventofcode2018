#!/usr/bin/perl
#
# day10.pl - Wait for stars to stop coalescing and start expanding again.
# Then print out the prior seconds' graph.
#
use strict;
use warnings;

use Path::Tiny;

my $metadata_sum = 0;

{ package Grid;

  sub check_bounds {
    my ($self) = @_;
    my @old_bounds = @{ $self->{ bounds } };

    # Use the first points coordinates for bounds
    my $pt = $self->{ points }[0]{ coord };
    $self->{ bounds } = [ $pt->[0], $pt->[0], $pt->[1], $pt->[1] ];

    for (my $i = 1; $i < @{ $self->{ points } }; $i++) {
      my $pt = $self->{ points }[$i]{ coord };

      $self->{ bounds }[0] = $pt->[0] if ($self->{ bounds }[0] > $pt->[0]);
      $self->{ bounds }[1] = $pt->[0] if ($self->{ bounds }[1] < $pt->[0]);
      $self->{ bounds }[2] = $pt->[1] if ($self->{ bounds }[2] > $pt->[1]);
      $self->{ bounds }[3] = $pt->[1] if ($self->{ bounds }[3] < $pt->[1]);
     }

    return ($self->{ bounds }[0] < $old_bounds[0]
			|| $self->{ bounds }[1] > $old_bounds[1]
			|| $self->{ bounds }[2] < $old_bounds[2]
			|| $self->{ bounds }[3] > $old_bounds[3]);
   }

  sub display {
    my ($self) = @_; 

    my $grid = [];
    my ($min_x, $max_x, $min_y, $max_y) = @{ $self->{ bounds } };
    for (my $y = $min_y; $y <= $max_y; $y++) {
      for (my $x = $min_x; $x <= $max_x; $x++) {
        $grid->[$y - $min_y][$x - $min_x] = '.';
       }
     }

    for (my $i = 0; $i < @{ $self->{ points } }; $i++) {
      my $pt = $self->{ points }[$i]{ coord };
      $grid->[$pt->[1] - $min_y][$pt->[0] - $min_x] = '#';
     }

    print "\nAfter $self->{ time } seconds:\n";
    for my $row (@{ $grid }) {
      print join( '', @{ $row } ), "\n";
     }
   }
 
  sub next_sec {
    my ($self) = @_;

    for (my $i = 0; $i < @{ $self->{ points } }; $i++) {
      $self->{ points }[$i]->move();
     }

    if ($self->check_bounds()) {
      for (my $i = 0; $i < @{ $self->{ points } }; $i++) {
        $self->{ points }[$i]->move_back();
       }

      $self->check_bounds();
      $self->display();
      return 1;
     }

    $self->{ time }++;

    return;
   }

  sub new {
    my $class = shift;
    my ($input_file) = @_;

    my $self = {
      time => 0,
      points => [],
      bounds => [ 0, 0, 0, 0 ],
    };
   bless $self, $class;

   for my $input ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } ) ) {
     $input =~ /<\s*(-?\d+),\s*(-?\d+)>.*<\s*(-?\d+),\s*(-?\d+)>/ or die "Illegal input: $input";

     my $point = Point->new( $1, $2, $3, $4 );
     push @{ $self->{ points } }, $point;
    }

   $self->check_bounds();

   return $self;
  }
};

{ package Point;

  sub move_back {
    my $self = shift;

    $self->{ coord }[0] -= $self->{ vel }[0];
    $self->{ coord }[1] -= $self->{ vel }[1];

    return $self->{ coord };
   }

  sub move {
    my $self = shift;

    $self->{ coord }[0] += $self->{ vel }[0];
    $self->{ coord }[1] += $self->{ vel }[1];

    return $self->{ coord };
   }

  sub new {
    my $class = shift;
    my ($x, $y, $x_vel, $y_vel) = @_;
    my $self = {
      coord => [ $x, $y ],
      vel => [ $x_vel, $y_vel ],
    };

   bless $self, $class;

   return $self;
  }
}

my $input_file = $ARGV[0] || 'input10.txt';

my $grid = Grid->new( $input_file );

while (!$grid->next_sec()) {}
  
exit;
