#!/usr/bin/perl
#
# This was the hardest puzzle yet because of all of the specifications. I
# resorted to looking at reddit and found several (python) solutions that
# did not work with my input!
#
# I finally found one that did work and was able to detect my last error.
# I should have been looking not for the path to the enemy, but the path
# to the spot that put in enemy in *range*.
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
#print "($targets[0]->{ y }, $targets[0]->{ x }) : $targets[0]->{ hp }\n";
    if ($targets[0]->{ hp } <= 0) {
      $self->kill_unit( $targets[0] );
     }
   }

  #
  # My first attempt suffered from the bug explained in:
  # https://www.reddit.com/r/adventofcode/comments/a6chwa/2018_day_15_solutions/ebu7u0z
  # and tested using test15z.txt
  #
  # Also, I was checking the nearest *target*, but not the nearest *range*!
  #
  sub move_unit {
    my ($self, $unit) = @_;

    my $enemy = $unit->{ type } eq 'E' ? 'G' : 'E';
    my $map = $self->{ map };

    # Make sure there are still targets
    if ($enemy eq 'E') {
      $self->end_battle( 'G' ) unless (grep { $_->{ hp } > 0 } @{ $self->{ elves } });
     }
    else {
      $self->end_battle( 'E' ) unless (grep { $_->{ hp } > 0 } @{ $self->{ goblins } });
     }

    # Test if we are already in range
    return if (grep { $map->[$unit->{ y } + $_->[0]][$unit->{ x } + $_->[1]] eq $enemy } @moves);

    # First, we need to find the closest enemy
    my $possible = [ [ $unit->{ y }, $unit->{ x }, '' ] ];
    my %tested = ( "$unit->{ y },$unit->{ x }" => 1 );
    my @closest_range = ();
    while (!@closest_range && @{ $possible }) {
      my $next = [];
      for my $p (@{ $possible }) {
        # Check if there is a target in range
        for my $m (@moves) {
          if ($map->[$p->[0] + $m->[0]][$p->[1] + $m->[1]] eq $enemy) {
            push @closest_range, [$p->[0], $p->[1]];
           }
         }

        # Move
        for my $m (@moves) {
          my $y = $p->[0] + $m->[0];
          my $x = $p->[1] + $m->[1];
          next if $tested{ "$y,$x" };
          next if $map->[$y][$x] ne '.';
          $tested{ "$y,$x" } = 1;
          my $first = $p->[2] || [ $y, $x ];
          push @{ $next }, [ $y, $x, $first ];
         }
       }

      $possible = $next;
     }

    # Now, find the best way to move to that enemy
    return unless (@closest_range);
    @closest_range = sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @closest_range;
    my $closest = $closest_range[0];
    $possible = [ [ $unit->{ y }, $unit->{ x }, '' ] ];
    %tested = ( "$unit->{ y },$unit->{ x }" => 1 );
    for my $p (@{ $possible }) {
      # Move
      for my $m (@moves) {
        my $y = $p->[0] + $m->[0];
        my $x = $p->[1] + $m->[1];
        my $first = $p->[2] || [ $y, $x ];
        if ($y == $closest->[0] && $x == $closest->[1]) {
          # Done
          $map->[ $unit->{ y } ][ $unit->{ x } ] = '.';
          $unit->{ y } = $first->[0];
          $unit->{ x } = $first->[1];
          $map->[ $unit->{ y } ][ $unit->{ x } ] = $unit->{ type };
          return;
         }
        next if $tested{ "$y,$x" };
        next if $map->[$y][$x] ne '.';
        $tested{ "$y,$x" } = 1;
        push @{ $possible }, [ $y, $x, $first ];
       }
     }

    die "Error: unable to find path to target";
   }

  sub print_map {
    my ($self) = @_;

    print "$self->{ num_rounds }\n";
    for my $row (@{ $self->{ map } }) {
      print join( '', @{ $row } ), "\n";
     }

    return;
   }

  sub round {
    my ($self) = @_;

    # Remove dead units
    $self->{ elves } = [ grep { $_->{ hp } > 0 } @{ $self->{ elves } } ];
    $self->{ goblins } = [ grep { $_->{ hp } > 0 } @{ $self->{ goblins } } ];

    for my $unit (sort { $a->{ y } <=> $b->{ y } || $a->{ x } <=> $b->{ x } } (@{ $self->{ elves } }, @{ $self->{ goblins } })) {
      next unless ($unit->{ hp } > 0);
      $self->move_unit( $unit );
      $self->unit_attack( $unit );
     }

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
$map->print_map();
while (1) {
  $map->round();
  $map->print_map();
 }

exit;
