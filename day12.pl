#!/usr/bin/perl
#
use strict;
use warnings;

use Path::Tiny;

{ package Pots;

  sub sum_pots {
    my ($self) = @_;
    
    my $count = 0;

    for (my $i = 0; $i < length( $self->{ pots } ); $i++) {
      if (substr( $self->{ pots }, $i, 1 ) eq '#') {
        $count += $i + $self->{ left };
       }
     }

    return $count;
   }

  sub next_gen {
    my ($self) = @_;

    # Check the pots two to the left and right
    my $pots = "....$self->{ pots }....";
    $self->{ left } -= 2;
    my $next_pots = '';
    for (my $i = 0; $i < length( $pots ) - 5; $i++) {
      $next_pots .= $self->{ spread }{ substr( $pots, $i, 5 ) } || '.';
     }

    # Trim excess pots
    $next_pots =~ s/^(\.+)//;
    $self->{ left } += length( $1 );
    $next_pots =~ s/\.$//;

    # If the pots are the same, get the offset for each additional
    if ($self->{ pots } eq $next_pots) {
      $self->{ add_count } = $self->sum_pots() - $self->{ sum_pots };
      return 1;
     }

    $self->{ num_gens }++;
    $self->{ pots } = $next_pots;
    $self->{ sum_pots } = $self->sum_pots();

    return;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     pots => '',
     spread => {},
     left => 0,
     num_gens => 0,
     sum_pots => 0,
     add_count => 0,
    };

    for my $input ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      next unless $input;
      if ($input =~ /^initial state: (.*)$/) {
        $self->{ pots } = $1;
       }
      elsif ($input =~ /^([.#]{5}) => (.)$/) {
        $self->{ spread }{ $1 } = $2;
       }
      else {
        die "Invalid input: $input";
       }
     }

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input12.txt';

my $pots = Pots->new( $input_file );

if (0) {
for (my $i = 0; $i < 20; $i++) {
   $pots->next_gen();
 }
print "The sum of pots with plants is ", $pots->sum_pots(), "\n";
exit;
}

while (!$pots->next_gen()) {
  print "$pots->{ num_gens }: The sum of pots with plants is ", $pots->sum_pots(), "\n";
 }

my $num_gens = 50000000000;

my $sum = $pots->{ sum_pots } + ($num_gens - $pots->{ num_gens }) * $pots->{ add_count };
print "The sum of pots with plants is $sum\n";

