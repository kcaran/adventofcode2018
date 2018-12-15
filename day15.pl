#!/usr/bin/perl
#
use strict;
use warnings;

use Path::Tiny;

{ package Map;

  my @moves = ( [ -1, 0 ], [ 0, -1 ], [ 0, 1 ], [ 1, 0 ] );

  sub end_battle {
    my ($self, $type) = @_;

    my $unit_type = $type eq 'E' ? $self->{ elves } : $self->{ goblins };

    $self->print_map();

    my $score = 0;
    for my $unit (@{ $unit_type }) {
print "($unit->{ y }, $unit->{ x }) = $unit->{ hp }\n";
      $score += $unit->{ hp };
     }

    die "The score is $score * $self->{ num_rounds } = ", $score * $self->{ num_rounds }, "\n";
   }

  sub find_target {
    my ($self, $type, $y, $x) = @_;

    my $enemies = $type eq 'E' ? $self->{ elves } : $self->{ goblins };

    return grep { $_->{ y } == $y && $_->{ x } == $x } @{ $enemies };
   }

  sub kill_unit {
    my ($self, $unit) = @_;

    $self->{ map }[ $unit->{ y } ][ $unit->{ x } ] = '.';
   }

  sub unit_attack {
    my ($self, $unit) = @_;

    my $map = $self->{ map };
    my $enemy = $unit->{ type } eq 'E' ? 'G' : 'E';

    my @target_pos = map {
      my $y = $unit->{ y } + $_->[0];
      my $x = $unit->{ x } + $_->[1];
      $map->[$y][$x] eq $enemy ? [ $y, $x ] : ();
      } @moves;

    return unless (@target_pos);

    my @targets = sort { $a->{ hp } <=> $b->{ hp } } map { $self->find_target( $enemy, $_->[0], $_->[1] ) } @target_pos;
    $targets[0]->{ hp } -= $unit->{ attack };
print "($targets[0]->{ y }, $targets[0]->{ x }) : $targets[0]->{ hp }\n";
    if ($targets[0]->{ hp } <= 0) {
      $self->kill_unit( $targets[0] );
     }
   }

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
      next unless ($unit->{ hp } > 0);
      $self->move_unit( $unit );
      $self->unit_attack( $unit );
     }

    # Remove dead units
    $self->{ elves } = [ grep { $_->{ hp } > 0 } @{ $self->{ elves } } ];
    $self->end_battle( 'G' ) unless (@{ $self->{ elves } });
    $self->{ goblins } = [ grep { $_->{ hp } > 0 } @{ $self->{ goblins } } ];
    $self->end_battle( 'E' ) unless (@{ $self->{ goblins } });

    $self->{ num_rounds }++;

    return;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     elves => [],
     goblins => [],
     num_rounds => 0,
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
while (1) {
  print "Round $map->{ num_rounds }\n";
  $map->round();
  $map->print_map();
 }

exit;
