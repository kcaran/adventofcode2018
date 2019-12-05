#!/usr/bin/perl
#
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

my ($immunity, $infection) = ( [], [] );

{ package Army;

  sub damage_done {
    my ($self, $e) = @_;

    my $damage = $self->power();

    if ($e->{ traits } =~ /immune to([^;]+?)$self->{ type }/) {
      print "Debug: Immune to $self->{ type }: $e->{ traits }\n";
     }
    if ($e->{ traits } =~ /weak to([^;]+?)$self->{ type }/) {
      print "Debug: Weak to $self->{ type }: $e->{ traits }\n";
     }

    return 0 if ($e->{ traits } =~ /immune to([^;]+?)$self->{ type }/);
    return $damage * 2 if ($e->{ traits } =~ /weak to([^;]+?)$self->{ type }/);

    return $damage;
   }

  sub will_attack {
    my ($self, $enemy) = @_;

    my $max = 0;
    my $target;
    for my $e (@{ $enemy }) {
      next if ($e->{ is_target });
      my $dmg = $self->damage_done( $e );
      if ($max < $dmg) {
        $max = $dmg;
        $target = $e;
       }
      elsif ($dmg == $max && $max > 0) {
        if ($e->power() > $target->power()) {
          $target = $e;
         }
       }
     }
    $target->{ is_target } = $self if ($target);

    return; 
   }

  sub power {
    my ($self) = @_;

    return $self->{ units } * $self->{ attack };
   }

  sub new {
    my ($class, $input) = @_;

    $input =~ /^(\d+) units each with (\d+) hit points (\([^)]+\))?\s*with an attack that does (\d+) (\S+) damage at initiative (\d+)$/ || die "Illegal input";
    my $self = {
      units => $1,
      hp => $2,
      traits => $3,
      attack => $4,
      type => $5,
      init => $6,
      is_target => '',
      target => '',
    };

    bless $self, $class;
    return $self;
   }
}

sub init {
  my (@units) = @_;

  for my $u (@units) {
    $u->{ is_target } = '';
    $u->{ target } = '';
   }
 }

sub power_sort {
  return $b->power() <=> $a->power()
    || $b->{ init } <=> $a->{ init };
 }

sub target_select {
  my ($group, $enemy) = @_;

  for my $unit (sort power_sort @{ $group }) {
    $unit->will_attack( $enemy );
   }

  return;
 }

my $input_file = $ARGV[0] || 'input24.txt';

# Initialization
my $group = $immunity;
for my $line ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  next unless $line;
  if ($line =~ /^Immune System/) {
    $group = $immunity;
    next;
   }
  if ($line =~ /^Infection/) {
    $group = $infection;
    next;
   }
  push @{ $group }, Army->new( $line, $group );
 }

# Battle
while (@{ $immunity } && @{ $infection }) {
  my @units = ( @{ $immunity }, @{ $infection } );
  init( @units );
  target_select( $immunity, $infection );
  target_select( $infection, $immunity );
exit;
 }

exit;
