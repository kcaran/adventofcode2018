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

  sub print_map {
    my ($self) = @_;

    for my $row (@{ $self->{ map } }) {
      print join( '', @{ $row } ), "\n";
     }

    print "\n";

    return;
   }

  sub adjacent {
    my ($self, $y, $x) = @_;

    my $min_y = ($y > 0) ? $y - 1 : $y;
    my $min_x = ($x > 0) ? $x - 1 : $x;
    my $max_y = ($y < $self->{ size } - 1) ? $y + 1 : $y;
    my $max_x = ($x < $self->{ size } - 1) ? $x + 1 : $x;

    my $adj_str = '';
    for (my $adj_y = $min_y; $adj_y <= $max_y; $adj_y++) {
      for (my $adj_x = $min_x; $adj_x <= $max_x; $adj_x++) {
        next if ($adj_y == $y && $adj_x == $x);
        $adj_str .= $self->{ map }[$adj_y][$adj_x];
       }
     }

    return $adj_str;
   }

  sub new_state {
    my ($self, $y, $x) = @_;

    my $state = $self->{ map }[$y][$x];
    my $adjacent = $self->adjacent( $y, $x );

    my $new_state;

    if ($state eq '.') {
      $new_state = ($adjacent =~ tr/|// >= 3) ? '|' : '.';
     }
    elsif ($state eq '|') {
      $new_state = ($adjacent =~ tr/#// >= 3) ? '#' : '|';
     }
    else {
      $new_state = (($adjacent =~ tr/#// > 0) && ($adjacent =~ tr/|// > 0)) ? '#' : '.';
     }

    return $new_state;
   }
 
  sub tick {
    my ($self) = @_;
    my $new_map = [];

    for (my $y = 0; $y < $self->{ size }; $y++) {
      for (my $x = 0; $x < $self->{ size }; $x++) {
        $new_map->[$y][$x] = $self->new_state( $y, $x );
       }
     }

    $self->{ map } = $new_map;

    return;
   }

  sub total_resources {
    my ($self) = @_;
    my $trees = 0;
    my $yards = 0;
    for (my $y = 0; $y < $self->{ size }; $y++) {
      for (my $x = 0; $x < $self->{ size }; $x++) {
        $trees++ if ($self->{ map }[$y][$x] eq '|');
        $yards++ if ($self->{ map }[$y][$x] eq '#');
       }
     }

    my $resources = $trees * $yards;

    for (my $i = @{ $self->{ resources } } - 1; $i >= 0; $i--) {
      if ($resources == $self->{ resources }[$i]) {
        # Check if this is really a cycle
        my $cycle_cnt = @{ $self->{ resources } } - $i;
        my $cycle = 1;
        for (my $j = 1; $j < $cycle_cnt; $j++) {
          $cycle &&= ($self->{ resources }[-$j] == $self->{ resources }[-($j+$cycle_cnt)]);
         }
        if ($cycle) {
          $self->{ cycle } = $i; 
          last;
         }
       }
     }

    push @{ $self->{ resources } }, $resources unless ($self->{ cycle });

    return $resources;
   }

  sub compute_resources {
    my ($self, $count) = @_;

    my $width = @{ $self->{ resources } } - $self->{ cycle };

    my $idx = ($count - $self->{ cycle } - 1) % $width;

    return $self->{ resources }[ $self->{ cycle } + $idx ];
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     size => 0,
     cycle => 0,
     resources => [],
    };

    my $y = 0;
    for my $row ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      my $x = 0;
      for my $col (split( '', $row )) {
        $self->{ map }[$y][$x] = $col;
        $x++;
       }
      $y++;
     }

    $self->{ size } = $y;

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input18.txt';

my $map = Map->new( $input_file );

$map->print_map();

my $i = 0;
while ($i < 2000 && !$map->{ cycle }) {
  $map->tick();
$i++;
  my $resources = $map->total_resources();
print "$i: $resources\n";
 }

print "The total resource value is ", $map->compute_resources( 1000000000 ), "\n";

exit;
