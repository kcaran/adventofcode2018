#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

my $guards = {};

{ package Guard;

  sub asleep {
    my $self = shift;
    my $min = shift;

    push @{ $self->{ asleep } }, [ $min, -1 ];

    return $self;
   }

  sub awake {
    my $self = shift;
    my $min = shift;

    # Complete sleeping
    $self->{ asleep }->[ -1 ][ 1 ] = $min;
    $self->{ mins_asleep } += $min - $self->{ asleep }->[ -1 ][ 0 ];

    return $self;
   }

  sub most_asleep {
    my $self = shift;

    my $min = -1;
    my $max_count = 0;
    my %count; 

    for my $nap (@{ $self->{ asleep } }) {
      for (my $i = $nap->[0]; $i < $nap->[1]; $i++) {
        $count{ $i }++;
        if ($count{ $i } > $max_count) {
          $min = $i;
          $max_count = $count{ $i };
         }
       }
     }

    return ($min, $max_count);
   }

  sub new {
    my $class = shift;
    my ($id, $start) = @_;

    my $self = {
      id => $id,
      start => int( $start ),
      asleep => [],
      mins_asleep => 0,
    };
   bless $self, $class;

   return $self;
  }
};

sub most_asleep {
  my $max = 0;
  my $guard_id_max = -1;

  for my $g (values %{ $guards }) {
    if ($g->{ mins_asleep } > $max) {
      $max = $g->{ mins_asleep };
      $guard_id_max = $g->{ id };
     }
   }

  return $guard_id_max;
 }
 
sub most_frequent {
  my $min_count_max = 0;
  my $min_max = 0;
  my $guard_id_max = -1;

  for my $g (values %{ $guards }) {
    my ($g_min, $g_count) = $g->most_asleep();

    if ($g_count > $min_count_max) {
      $min_max = $g_min;
      $min_count_max = $g_count;
      $guard_id_max = $g->{ id };
     }
   }

  return ($guard_id_max, $min_max);
 }
 
sub parse_input {
  my ($file) = @_;

  my @guard_input = sort ( path( $file )->lines_utf8( { chomp => 1 } ) );
  my $curr_guard;

  for my $input (@guard_input) {
    if ($input =~ /^\[1518-(\d{2})-(\d{2}) (23|00):(\d{2})\] Guard #(\d+) begins shift/) {
      my ($hour, $min, $id) = ($3, $4, $5);

      # Check if guard came on before midnight
      my $start_min = ($hour == 23) ? 0 : $min;
      $guards->{ $id } ||= Guard->new( $id, $min );
      $curr_guard = $guards->{ $id };
     }
    elsif ($input =~ /^\[1518-(\d{2})-(\d{2}) 00:(\d{2})\] falls asleep/) {
      $curr_guard->asleep( $3 );
     }
    elsif ($input =~ /^\[1518-(\d{2})-(\d{2}) 00:(\d{2})\] wakes up/) {
      $curr_guard->awake( $3 );
     }
    else {
      die "Unknown input: $input";
     }
   }

  return;
 }

my $input_file = $ARGV[0] || 'input04.txt';

parse_input( $input_file );

# Find guard with most asleep
my $max_guard = most_asleep();
my ($max_min, $cnt) = $guards->{ $max_guard }->most_asleep();
print "The Guard ID * minute most asleep is: ", $max_guard * $max_min, "\n";

# Find the guard with the most frequent minute
my ($freq_id, $freq_min) = most_frequent();

print "The Guard ID * minute most frequently asleep is: ", $freq_id * $freq_min, "\n";
