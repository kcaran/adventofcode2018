#!/usr/bin/perl
#
# First guess: 3362, which was too low
#
use strict;
use warnings;

use Path::Tiny;

{ package Map;

  my %dirs = ( 'N' => [ -1, 0 ], 'E' => [ 0, 1 ], 'S' => [ 1, 0 ], 'W' => [ 0, -1 ] );

  sub traverse {
    my ($self, $curr) = @_;

    return unless @{ $self->{ path } };

    my $char = shift @{ $self->{ path } };
    
    if ($char eq '(') {
      push @{ $curr->{ children } }, Path->new( $curr );
      $curr = $curr->{ children }[0];
     }
    elsif ($char eq '|') {
      $curr = $curr->{ parent };
      push @{ $curr->{ children } }, Path->new( $curr );
      $curr = $curr->{ children }[-1];
     }
    elsif ($char eq ')') {
      $curr = $curr->{ parent };
     }
    else {
      $curr->{ str } .= $char;
      $self->{ map }{ "$curr->{ y },$curr->{ x }" }{ dirs } .= $char;
      $curr->{ count }++;
      $curr->{ y } += $dirs{ $char }->[0];
      $curr->{ x } += $dirs{ $char }->[1];
      if (!$self->{ map }{ "$curr->{ y },$curr->{ x }" }) {
        $self->{ map }{ "$curr->{ y },$curr->{ x }" } = { dirs => '', count => $curr->{ count } };
       }
     }

    return $self->traverse( $curr );
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
      regex => Path->new(),
      map => {},
      path => [],
     };
    bless $self, $class;

    my $data = Path::Tiny::path( $input_file )->slurp_utf8();
    $data =~ s/^\^//;
    $data =~ s/\$(.*)$//sm;
    $self->{ path } = [ split '', $data ];

    my $curr = $self->{ regex };
    $self->{ map }{ "0,0" } = { dirs => '', count => 0 };

    $self->traverse( $curr );

    return $self;
   }
    
};

{ package Path;

  sub new {
    my ($class, $parent) = @_;

    my $self = {
      str => '',
      parent => $parent,
      children => [],
      y => 0,
      x => 0,
      count => 0,
     };

    if ($parent) {
      $self->{ y } = $parent->{ y };
      $self->{ x } = $parent->{ x };
      $self->{ count } = $parent->{ count };
     }

    bless $self, $class;
    return $self;
   }
};

my $input_file = $ARGV[0] || 'input20.txt';

my $map = Map->new( $input_file );

my $max = 0;
for my $room (keys %{ $map->{ map } }) {
  $max = $map->{ map }{ $room }{ count } if ($max < $map->{ map }{ $room }{ count });
 }

print "The farthest room is $max doors away\n";
exit;
