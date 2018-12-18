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
    my ($self, $reached) = @_;

    for (my $y = 0; $y <= $self->{ max_y }; $y++) {
      for (my $x = $self->{ min_x }; $x <= $self->{ max_x }; $x++) {
        my $tile = $self->{ map }[$y][$x] || ($self->{ tiles }{ "$y,$x" } ? '|' : '.');
        print $tile;
       }
      print "\n";
     }

    print "\n";

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
      push @{ $overflow }, [ $y, $left ] 
     }

    my $right = $x;
    while ($self->open( $y, $right ) && !$self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
      $right++;
     }
    if ($self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
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

    for my $p (@{ $possible }) {
#print "$p->[0]\n";
      return if ($p->[0] >= $self->{ max_y });

      while ($self->open( $p->[0] + 1, $p->[1] ) && $p->[0] < $self->{ max_y }) {
        $p->[0]++;
        $self->{ tiles }{ $p->[0] . ",$p->[1]" } = 1;
       }

      if (my $bounds = $self->bounds( $p->[0], $p->[1] )) {
        for (my $x = $bounds->[0]; $x <= $bounds->[1]; $x++) {
          $self->{ tiles }{ "$p->[0],$x" } = 1;
          $self->{ map }[$p->[0]][$x] = '~';
         }
       }
      else {
        push @{ $possible }, @{ $self->overflow( $p->[0], $p->[1] ) };
       }
     }
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     min_x => 10000,
     max_x => 0,
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
        $self->{ max_y } = $r2max  unless ($self->{ max_y } >= $r2max);
       }
      else {
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
# $map->print_map();
} while ($tiles < scalar keys %{ $map->{ tiles } });

print "There are $tiles tiles that can be reached by water\n";

exit;
