#!/usr/bin/perl
#
use strict;
use warnings;

use Path::Tiny;

{ package Grid;

  my %carts = (
	'v' => '|',
	'^' => '|',
	'<' => '-',
	'>' => '-',
	);

  sub check_collisions {
    my ($self, $cart) = @_;

    for my $other (@{ $self->{ carts } }) {
      next if ($other->{ crashed });
      next if ($other == $cart);
      if ($other->{ x } == $cart->{ x } && $other->{ y } == $cart->{ y }) {
        $other->{ crashed } = 1;
        $self->{ num_crashed }++;
        $cart->{ crashed } = 1;
        $self->{ num_crashed }++;
        return "$cart->{ x },$cart->{ y }";
       }
     }

    return;
   }

  sub move_cart {
    my ($self, $cart) = @_;

    my $dir = $cart->{ dir };
    my $next_x = $cart->{ x };
    my $next_y = $cart->{ y };
 
    $next_x++ if ($dir eq '>');
    $next_x-- if ($dir eq '<');
    $next_y-- if ($dir eq '^');
    $next_y++ if ($dir eq 'v');

    my $next = $self->{ map }[$next_x][$next_y];
    if ($next eq '/') {
      $dir = $dir eq '^' ? '>'
           : $dir eq 'v' ? '<'
           : $dir eq '>' ? '^'
				         : 'v'
     }
    elsif ($next eq '\\') {
      $dir = $dir eq '^' ? '<'
           : $dir eq 'v' ? '>'
           : $dir eq '>' ? 'v'
				         : '^'
     }
    elsif ($next eq '+') {
      if ($cart->{ inter } == 0) {
        $dir = $dir eq '^' ? '<'
             : $dir eq 'v' ? '>'
             : $dir eq '>' ? '^'
				           : 'v'
       }
      elsif ($cart->{ inter } == 2) {
        $dir = $dir eq '^' ? '>'
             : $dir eq 'v' ? '<'
             : $dir eq '>' ? 'v'
				           : '^'
       }
      $cart->{ inter } = ($cart->{ inter } + 1) % 3;
     }

    $cart->{ x } = $next_x;
    $cart->{ y } = $next_y;
    $cart->{ dir } = $dir;
   }

  sub tick {
    my ($self) = @_;

    for my $cart (sort { $a->{ x } <=> $b->{ x } || $a->{ y } <=> $b->{ y } } @{ $self->{ carts } } ) {
      next if ($cart->{ crashed });
      $self->move_cart( $cart );
      my $collision = $self->check_collisions( $cart );
      if ($collision) {
        print "Collision at ($collision)\n";
       }
     }

    if ($self->{ num_crashed } >= @{ $self->{ carts } } - 1) {
      # Even number of carts - none would be left
      exit unless (@{ $self->{ carts } } % 2);
      for my $cart (@{ $self->{ carts } }) {
        return "The last cart is at ($cart->{ x },$cart->{ y })" if (!$cart->{ crashed });
       }
     }

    return;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     carts => [],
     num_crashed => 0,
    };

    my $y = 0;
    for my $row ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      my $x = 0;
      for my $col (split( '', $row )) {
        $self->{ map }[$x][$y] = $carts{ $col } || $col;
        if ($carts{ $col }) {
          push @{ $self->{ carts } }, Cart->new( $x, $y, $col );
         }
        $x++;
       }
      $y++;
     }

    bless $self, $class;
    return $self;
   }
}

{ package Cart;
  sub new {
    my ($class, $x, $y, $dir) = @_;

    my $self = {
     x => $x,
     y => $y,
     dir => $dir,
     inter => 0,
     crashed => 0,
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input13.txt';

my $grid = Grid->new( $input_file );

my $last_cart;
while (!($last_cart = $grid->tick())) {
 }

print "$last_cart\n";
exit;
