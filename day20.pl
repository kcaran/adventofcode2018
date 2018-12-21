#!/usr/bin/perl
#
use strict;
use warnings;

use Path::Tiny;

{ package Regex;

  my %doors = ( 'N' => 0, 'E' => '1', 'S' => '2', 'W' => '3' );
  my %dirs = ( 'N' => [ -1, 0 ], 'E' => [ 0, 1 ], 'S' => [ 1, 0 ], 'W' => [ 0, -1 ] );
  sub new {
    my ($class, $input_file) = @_;
    my $self = {
      regex => Path->new(),
      map => {},
     };

    my $data = Path::Tiny::path( $input_file )->slurp_utf8();
    $data =~ s/^\^//;
    $data =~ s/\$(.*)$//sm;

    my $curr = $self->{ regex };
    $self->{ map }{ "0,0" } = { dirs =>[ 0, 0, 0, 0 ], count => 0 };

    for my $char (split '', $data) {
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
        $self->{ map }{ "$curr->{ y },$curr->{ x }" }{ dirs }[ $doors{ $char } ] = 1;
        $curr->{ count }++;
        $curr->{ y } += $dirs{ $char }->[0];
        $curr->{ x } += $dirs{ $char }->[1];
        if (!$self->{ map }{ "$curr->{ y },$curr->{ x }" }) {
          $self->{ map }{ "$curr->{ y },$curr->{ x }" } = { dirs =>[ 0, 0, 0, 0 ], count => $curr->{ count } };
         }
       }
     }

    bless $self, $class;
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
      dirs => [ 0, 0, 0, 0 ],
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

my $regex = Regex->new( $input_file );

my $max = 0;
for my $room (keys %{ $regex->{ map } }) {
  $max = $regex->{ map }{ $room }{ count } if ($max < $regex->{ map }{ $room }{ count });
 }

print "The farthest room is $max doors away\n";
exit;
