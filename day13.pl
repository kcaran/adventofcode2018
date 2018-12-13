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
      next if ($other == $cart);
      if ($other->{ x } == $cart->{ x } && $other->{ y } == $cart->{ y }) {
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
      $self->move_cart( $cart );
      my $collision = $self->check_collisions( $cart );
      return $collision if ($collision);
     }

    return;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     carts => [],
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
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input13.txt';

my $grid = Grid->new( $input_file );

my $collision;
while (!($collision = $grid->tick())) {
 }

print "The first collision is at $collision\n";
exit;
