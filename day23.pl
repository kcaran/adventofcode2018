#!/usr/bin/env perl
#
use strict;
use warnings;

use Data::Printer;
use Path::Tiny;

{ package Nanobot;

  sub dist {
    my ($self, $x, $y, $z) = @_;

    return (abs( $self->{ x } - $x ) + abs( $self->{ y } - $y ) + abs( $self->{ z } - $z ));
   }

  sub new {
    my ($class, $input) = @_;
    my ($x, $y, $z, $r) = ($input =~ /([0-9-]+)/g);
    my $self = { 
		x => $x,
		y => $y,
        z => $z,
        r => $r,
		};
    bless $self, $class;

    return $self;
  }
}

sub in_range {
  my ($bots, $idx) = @_;
  my ($x, $y, $z, $r) = @{ $bots->[$idx] }{ qw( x y z r ) };
  my $in = 0;

  for my $b (@{ $bots }) {
    $in++ if ($b->dist( $x, $y, $z ) <= $r);
   }

  return $in;
 }

my $input_file = $ARGV[0] || 'input23.txt';

my $bots = [];

my $strong_val = -1;
my $strong_idx = -1;

for (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  my $bot = Nanobot->new( $_ );
  if ($bot->{ r } > $strong_val) {
    $strong_val = $bot->{ r };
    $strong_idx = @{ $bots };
   }
  push @{ $bots }, $bot;
 }

print "The strongest is at $strong_idx\n";
print "There are ", in_range( $bots, $strong_idx ), " in range of the strongest.\n";
