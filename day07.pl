#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

my ($helpers, $time);

{ package Instructions;

  sub run {
    my $self = shift;
    my $order = '';
    my $sec = 0;
    my @helpers;
    my @step_ids = sort keys %{ $self->{ steps } };
    while (length( $order ) < @step_ids) {
      for (my $i = 0; $i < $helpers; $i++) {
        next if ($helpers[$i]);
        for my $id (@step_ids) {
          my $step = $self->{ steps }{ $id };
          next if ($step->{ running });
          next if ($step->{ completed });
          next if ($step->{ prev_steps });
          $helpers[$i] = $id;
          $step->{ running } = 1;
          last;
         }
       }

      for (my $i = 0; $i < $helpers; $i++) {
        if ($helpers[$i]) {
          my $step = $self->{ steps }{ $helpers[$i] };
          $step->{ time }--;
          if ($step->{ time } == 0) {
            $helpers[$i] = '';
            $self->run_step( $step->{ id } );
            $order .= $step->{ id };
           }
         }
       }
      $sec++;
     }

    return ($order, $sec);
   }

  sub run_step {
    my ($self, $step_id) = @_;

    for my $step (split( '', $self->{ steps }{ $step_id }{ next_steps } )) {
      $self->{ steps }{ $step }->clear_prev( $step_id );
     }

    $self->{ steps }{ $step_id }{ running } = 0;
    $self->{ steps }{ $step_id }{ completed } = 1;
   }

  sub new {
    my $class = shift;
    my ($input_file) = @_;

    my $self = {
      steps => {},
    };

   for my $inst ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } ) ) {
     my ($prev, $step) = $inst =~ /Step (\w) must be finished before step (\w)/;

     $self->{ steps }{ $step } ||= Step->new( $step );
     $self->{ steps }{ $prev } ||= Step->new( $prev );
     $self->{ steps }{ $step }->add_prev( $prev );
     $self->{ steps }{ $prev }->add_next( $step );
    }

   bless $self, $class;

   return $self;
  }
};

{ package Step;

  sub add_prev {
    my ($self, $prev_step) = @_;

    $self->{ prev_steps } .= $prev_step;
   }

  sub add_next {
    my ($self, $next_step) = @_;

    $self->{ next_steps } .= $next_step;
   }

  sub clear_prev {
    my ($self, $prev_step) = @_;

    $self->{ prev_steps } =~ s/$prev_step//;
   }

  sub new {
    my $class = shift;
    my ($id) = @_;
    my $self = {
      id => $id,
      prev_steps => '',
      next_steps => '',
      running => 0,
      completed => 0,
      time => $time + ord( $id ) - ord( 'A' ) + 1,
    };

   bless $self, $class;

   return $self;
  }
}

my $input_file = $ARGV[0] || 'input07.txt';
$helpers = $ARGV[1] || 1;
$time = $ARGV[2] || 0;

my $inst = Instructions->new( $input_file );

my ($order, $time_taken) = $inst->run();

print "The order of instructions should be: $order in $time_taken secs\n";
exit;
