#!/usr/bin/perl
#
# First guess: 3362, which was too low
# Now I have 1323
# 
# I had to rely on this hint:
# https://www.reddit.com/r/adventofcode/comments/a8a704/solution_for_day_20_part_1/ecv67tz
#
# 2019: I realized that I have to do this in two parts: First build out the
# map and *then* find the paths to the rooms. Yes, that's what the instructions
# say but I thought I could combine the steps.
#
use strict;
use warnings;

use Path::Tiny;

{ package Map;

  my %dirs = ( 'N' => [ -1, 0 ], 'E' => [ 0, 1 ], 'S' => [ 1, 0 ], 'W' => [ 0, -1 ] );
  my %opp = ( 'N' => 'S', 'E' => 'W', 'S' => 'N', 'W' => 'E' );

  sub next_door {
    my ($self, $curr, $char, $pos) = @_;

    if (@{ $curr->{ children } }) {
      for my $child (@{ $curr->{ children } }) {
        $self->next_door( $child, $char, $pos );
       }
      return;
     }

    $curr->{ pos } = $pos;
    $curr->{ str } .= $char;

    # Note the door in the current room
    unless ($self->{ map }{ "$curr->{ y },$curr->{ x }" }{ dirs } =~ /$char/) {
      $self->{ map }{ "$curr->{ y },$curr->{ x }" }{ dirs } .= $char;
     }
    $curr->{ y } += $dirs{ $char }->[0];
    $curr->{ x } += $dirs{ $char }->[1];
    if (!$self->{ map }{ "$curr->{ y },$curr->{ x }" }) {
      $self->{ map }{ "$curr->{ y },$curr->{ x }" } = { dirs => '', count => 0 };
     }

    # Note the door in the new room
    unless ($self->{ map }{ "$curr->{ y },$curr->{ x }" }{ dirs } =~ /$opp{ $char }/) {
      $self->{ map }{ "$curr->{ y },$curr->{ x }" }{ dirs } .= $opp{ $char };
     }

    return;
   }

#
# "Now, only SSE(EE|N) remains. Because it is in the same parenthesized
# group as NEEE, it starts from the same room NEEE started in."
#
# There only needs to be a single set of children for each () - The
# branches aren't recursive!!
#
  sub parse {
    my ($self, $curr) = @_;

    while ($curr->{ pos } < @{ $self->{ path } }) {

      my $char = $self->{ path }->[ $curr->{ pos } ];
      $curr->{ pos }++;
      my $pos = $curr->{ pos };
    
      if ($char eq '(') {
        push @{ $curr->{ children } }, Path->new( $curr );
        $curr = $curr->{ children }[0];
       }
      elsif ($char eq '|') {
        $curr = $curr->{ parent };
        push @{ $curr->{ children } }, Path->new( $curr );
        $curr = $curr->{ children }[-1];
        $curr->{ pos } = $pos;
       }
      elsif ($char eq ')') {
        $curr = $curr->{ parent };
        $curr->{ children } = [];
        $curr->{ pos } = $pos;
       }
      else {
        $self->next_door( $curr, $char, $pos );
       }
     }

    return;
   }

  sub next_rooms {
    my ($self, $index, $count) = @_;

    my @next_rooms = ();
    my $room = $self->{ map }{ $index };
    my ($y, $x) = split ',', $index;
    for my $dir (split '', $room->{ dirs }) {
      my $next_y = $y + $dirs{ $dir }->[0];
      my $next_x = $x + $dirs{ $dir }->[1];
      my $next_room = "$next_y,$next_x";
      next if ($self->{ map }{ $next_room }{ count } || $next_room eq '0,0');
      $self->{ map }{ $next_room }{ count } = $count;
      push @next_rooms, $next_room;
     }

    return @next_rooms;
   }

  sub traverse {
    my ($self) = @_;

    my $rooms = [ "0,0" ];
    my $count = 0;
    while (@{ $rooms }) {
      my $next_rooms = [];
      $count++;
      for my $r (@{ $rooms }) {
        push @{ $next_rooms }, $self->next_rooms( $r, $count );
       }
      $rooms = $next_rooms;
     }
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

    $self->parse( $curr );

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
      pos => 0,
     };

    if ($parent) {
      $self->{ y } = $parent->{ y };
      $self->{ x } = $parent->{ x };
      $self->{ pos } = $parent->{ pos };
      $self->{ str } = $parent->{ str };
     }

    bless $self, $class;
    return $self;
   }
};

my $input_file = $ARGV[0] || 'input20.txt';

my $map = Map->new( $input_file );

$map->traverse();

my $max = 0;
for my $room (keys %{ $map->{ map } }) {
  $max = $map->{ map }{ $room }{ count } if ($max < $map->{ map }{ $room }{ count });
 }

print "The farthest room is $max doors away\n";

my $far_away = 0;
for my $room (keys %{ $map->{ map } }) {
  $far_away++ if ($map->{ map }{ $room }{ count } >= 1000);
 }

print "There are $far_away far away rooms\n";

exit;
