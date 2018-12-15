#!/usr/bin/perl
#
use strict;
use warnings;

use Path::Tiny;

{ package Map;

  my @moves = ( [ -1, 0 ], [ 0, -1 ], [ 0, 1 ], [ 1, 0 ] );
  sub move_unit {
    my ($self, $unit) = @_;

    my $enemy = $unit->{ type } eq 'E' ? 'G' : 'E';
    my $map = $self->{ map };
    my $possible = [ [ $unit->{ y }, $unit->{ x }, '' ] ];
    my %tested = ( "$unit->{ y },$unit->{ x }" => 1 );
    for my $p (@{ $possible }) {
      # Check if there is a target in range
      if (grep { $map->[$p->[0] + $_->[0]][$p->[1] + $_->[1]] eq $enemy } @moves) {
       # Done
       if ($p->[2]) {
         $map->[ $unit->{ y } ][ $unit->{ x } ] = '.';
         $unit->{ y } = $p->[2][0];
         $unit->{ x } = $p->[2][1];
         $map->[ $unit->{ y } ][ $unit->{ x } ] = $unit->{ type };
        }
       return;
      }

      # Move
      for my $m (@moves) {
        my $y = $p->[0] + $m->[0];
        my $x = $p->[1] + $m->[1];
        next if $tested{ "$y,$x" };
        next if $map->[$y][$x] ne '.';
        $tested{ "$y,$x" } = 1;
        my $first = $p->[2] || [ $y, $x ];
        push @{ $possible }, [ $y, $x, $first ];
       }
     }

    return;
   }

  sub print_map {
    my ($self) = @_;
    for my $row (@{ $self->{ map } }) {
      print join( '', @{ $row } ), "\n";
     }

    return;
   }

  sub round {
    my ($self) = @_;

    for my $unit (sort { $a->{ y } <=> $b->{ y } || $a->{ x } <=> $b->{ x } } (@{ $self->{ elves } }, @{ $self->{ goblins } })) {
      $self->move_unit( $unit );
     }

    return;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     elves => [],
     goblins => [],
    };

    my $y = 0;
    for my $row ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      my $x = 0;
      for my $col (split( '', $row )) {
        $self->{ map }[$y][$x] = $col;
        if ($col eq 'E') {
          push @{ $self->{ elves } }, Unit->new( $col, $x, $y );
         }
        if ($col eq 'G') {
          push @{ $self->{ goblins } }, Unit->new( $col, $x, $y );
         }
        $x++;
       }
      $y++;
     }

    bless $self, $class;
    return $self;
   }
}

{ package Unit;
  sub new {
    my ($class, $type, $x, $y) = @_;

    my $self = {
     type => $type,
     x => $x,
     y => $y,
     hp => 200,
     attack => 3,
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input15.txt';

my $map = Map->new( $input_file );
for (my $i = 0; $i < 3; $i++) {
  print "Round $i\n";
  $map->round();
  $map->print_map();
 }

exit;
