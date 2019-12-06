#!/usr/bin/perl
#
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

my ($immunity, $infection) = ( [], [] );

my $debug = 0;

{ package Army;

  sub attack {
    my ($self) = @_;

    return unless ($self->{ units } > 0);
    return unless ($self->{ target });
    return unless ($self->{ target }{ units } > 0);

    my $damage = $self->damage_done( $self->{ target } );
    my $kills = int( $damage / $self->{ target }{ hp } );

    $self->{ target }{ units } -= $kills;

    return;
   }

  sub damage_done {
    my ($self, $e) = @_;

    my $damage = $self->power();

    if ($debug) {
      if ($e->{ traits } =~ /immune to([^;]+?)$self->{ type }/) {
        print "Immune to $self->{ type }: $e->{ traits }\n";
       }
      if ($e->{ traits } =~ /weak to([^;]+?)$self->{ type }/) {
        print "Weak to $self->{ type }: $e->{ traits }\n";
       }
     }

    return 0 if ($e->{ traits } =~ /immune to([^;]+?)$self->{ type }/);
    return $damage * 2 if ($e->{ traits } =~ /weak to([^;]+?)$self->{ type }/);

    return $damage;
   }

  sub choose_attack {
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
    $self->{ target } = $target;

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
      traits => $3 || '',
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
    $unit->choose_attack( $enemy );
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
  for my $attacker (sort { $b->{ init } <=> $a->{ init } } @units) {
    $attacker->attack();
   }

  # Finally, clean up the wiped out units
  $immunity = [ map { $_->{ units } > 0 ? $_ : () } @{ $immunity } ];
  $infection = [ map { $_->{ units } > 0 ? $_ : () } @{ $infection } ];
 }

# Only one army will have any units left
my $num_units = 0;
for my $army ( @{ $immunity }, @{ $infection } ) {
  $num_units += $army->{ units };
 }

print "The number of units left is $num_units\n";

exit;
