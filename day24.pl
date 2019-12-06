#!/usr/bin/perl
#
# Note: With a boost of 20, both sides are immune to the others' attacks!
# No one wins!
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

    return 0 unless ($self->{ units } > 0);
    return 0 unless ($self->{ target });
    return 0 unless ($self->{ target }{ units } > 0);

    my $damage = $self->damage_done( $self->{ target } );
    my $kills = int( $damage / $self->{ target }{ hp } );

    $self->{ target }{ units } -= $kills;

    return $kills;
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

  # The easiest way to create a clone of this army is to create a new one
  # from the original input
  sub clone {
    my ($self, $boost) = @_;
    my $clone = Army->new( $self->{ input } );
    $clone->{ attack } += $boost if ($boost);
    return $clone;
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
      input => $input,
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

sub battle {
  my ($immunity, $infection, $boost) = @_;

  # Make copies of the original armies before battling
  my @imm = map { $_->clone( $boost ) } @{ $immunity };
  my @inf = map { $_->clone() } @{ $infection };

  # Battle
  while (@imm && @inf) {
    my @units = ( @imm, @inf );
    init( @units );
    target_select( \@imm, \@inf );
    target_select( \@inf, \@imm );
    my $damage = 0;
    for my $attacker (sort { $b->{ init } <=> $a->{ init } } @units) {
      $damage += $attacker->attack();
     }

    # Finally, clean up the wiped out units
    @imm = map { $_->{ units } > 0 ? $_ : () } @imm;
    @inf = map { $_->{ units } > 0 ? $_ : () } @inf;

    # Make sure battle hasn't come to a standstill
    return -1 if (!$damage);
   }

  # Only one army will have any units left
  my $num_units = 0;
  for my $army ( @imm, @inf ) {
    $num_units += $army->{ units };
   }
  my $immunity_wins = @imm ? 1 : 0;

  return ($immunity_wins, $num_units);
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
  push @{ $group }, Army->new( $line );
 }

# Battle
my $boost = 0;
my $immunity_wins = 0;
my $num_units;

while ($immunity_wins <= 0) {
  ($immunity_wins, $num_units) = battle( $immunity, $infection, $boost );
  if ($immunity_wins < 0) {
    print "No winner with a boost of $boost.\n";
   }
  else {
    my $winner = ($immunity_wins ? 'Immunity' : 'Infection');
    print "$winner wins with a boost of $boost. The number of units left is $num_units\n";
   }
  $boost++;
 }

exit;
