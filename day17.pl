#!/usr/bin/perl
#
use strict;
use warnings;

use Path::Tiny;

{ package Map;

  sub water_tiles {
    my ($self) = @_;

    return scalar grep { my ($y, $x) = split( ',', $_ ); my $tile = $self->{ map }[$y][$x] || ''; $tile eq '~' ? (1) : () } keys %{ $self->{ tiles } };
   }

  sub print_map {
    my ($self, $depth) = @_;

    my ($min_x, $max_x, $max_y) = (10000, 0, 0);
    for my $pos (keys %{ $self->{ tiles } }) {
      my ($y, $x) = split( ',', $pos );
      $min_x = $x - 1 if ($x <= $min_x);
      $max_x = $x + 1 if ($x >= $max_x);
      $max_y = $y + 1 if ($y >= $max_y);
     }
    for (my $y = (!$depth || $max_y < $depth) ? 0 : $max_y - $depth; $y <= $max_y; $y++) {
      for (my $x = $min_x; $x <= $max_x; $x++) {
        my $tile = $self->{ map }[$y][$x] || ($self->{ tiles }{ "$y,$x" } ? '|' : '.');
        print $tile;
       }
      print "\n";
     }

    print "bottom is $max_y\n\n";

    return;
   }

  sub bounds {
    my ($self, $y, $x) = @_;
    my $bounds = [ -1, -1 ];

    my $left = $x;
    while ($self->open( $y, $left - 1 ) && !$self->open( $y + 1, $left )) {
      $self->{ tiles }{ "$y,$left" } = 1;
      $left--;
     }
    $bounds->[0] = $left if (!$self->open( $y + 1, $left ));

    my $right = $x;
    while ($self->open( $y, $right + 1 ) && !$self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
      $right++;
     }
    $bounds->[1] = $right if (!$self->open( $y + 1, $right ));

    return $bounds if ($bounds->[0] >= 0 && $bounds->[1] >= 0);
   }

  sub overflow {
    my ($self, $y, $x) = @_;
    my $overflow = [];

    my $left = $x;
    while ($self->open( $y, $left ) && !$self->open( $y + 1, $left )) {
      $self->{ tiles }{ "$y,$left" } = 1;
      $left--;
     }
    if ($self->open( $y + 1, $left )) {
      $self->{ tiles }{ "$y,$left" } = 1;
#     print "overflow left at: ($y,$left)\n";
      push @{ $overflow }, [ $y, $left ] 
     }

    my $right = $x;
    while ($self->open( $y, $right ) && !$self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
      $right++;
     }
    if ($self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
#     print "overflow right at: ($y,$right)\n";
      push @{ $overflow }, [ $y, $right ] 
     }

    return $overflow;
   }

  sub open {
    my ($self, $y, $x) = @_;

    my $point = $self->{ map }[$y][$x] || '.';

    return ($point eq '.');
   }

  sub water {
    my ($self) = @_;

    my $possible = [ [ 0, 500 ] ];

    while (my $p = shift @{ $possible }) {
#   for my $p (@{ $possible }) {
#print "$p->[0]\n";
      next if ($p->[0] >= $self->{ max_y });

      while ($self->open( $p->[0] + 1, $p->[1] ) && $p->[0] < $self->{ max_y }) {
        $p->[0]++;
        # Don't count tiles above the minimum y!
        $self->{ tiles }{ $p->[0] . ",$p->[1]" } = 1 if ($p->[0] >= $self->{ min_y });
       }

      if (my $bounds = $self->bounds( $p->[0], $p->[1] )) {
        for (my $x = $bounds->[0]; $x <= $bounds->[1]; $x++) {
          $self->{ tiles }{ "$p->[0],$x" } = 1;
          $self->{ map }[$p->[0]][$x] = '~';
         }
       }
      else {
        # Don't count overflows more than once
        for my $a (@{ $self->overflow( $p->[0], $p->[1] ) }) {
          push @{ $possible }, $a unless (grep { $_->[0] == $a->[0] && $_->[1] == $a->[1] } @{ $possible });
         }
       }

      next;
     }
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     min_x => 10000,
     max_x => 0,
     min_y => 10000,
     max_y => 0,
     tiles => {},
    };

    for my $scan ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      my ($c1, $r1, $r2min, $r2max) = ($scan =~ /(\w)=(\d+), \w+=(\d+)\.\.(\d+)/);
      die unless ($c1 eq 'x' || $c1 eq 'y');

      if ($c1 eq 'x') {
        $self->{ min_x } = $r1 - 1 unless ($self->{ min_x } <= $r1 - 1);
        $self->{ max_x } = $r1 + 1 unless ($self->{ max_x } >= $r1 + 1);
        for (my $y = $r2min; $y <= $r2max; $y++) {
          $self->{ map }[$y][$r1] = '#';
         }
        $self->{ min_y } = $r2min  unless ($self->{ min_y } <= $r2min);
        $self->{ max_y } = $r2max  unless ($self->{ max_y } >= $r2max);
       }
      else {
        $self->{ min_y } = $r1  unless ($self->{ min_y } <= $r1);
        $self->{ max_y } = $r1 unless ($self->{ max_y } >= $r1);
        for (my $x = $r2min; $x <= $r2max; $x++) {
          $self->{ map }[$r1][$x] = '#';
         }
        $self->{ min_x } = $r2min - 1 unless ($self->{ min_x } <= $r2min - 1);
        $self->{ max_x } = $r2max + 1 unless ($self->{ max_x } >= $r2max + 1);
       }
     }

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input17.txt';
my $map = Map->new( $input_file );
my $tiles;

do {
  $tiles = scalar keys %{ $map->{ tiles } };
  $map->water();
# $map->print_map( 80 );
} while ($tiles < scalar keys %{ $map->{ tiles } });

$map->print_map();
print "There are $tiles tiles that can be reached by water\n\n";

print "There are ", $map->water_tiles(), " tiles at the end\n";

exit;
