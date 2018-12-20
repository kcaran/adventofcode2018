#!/usr/bin/perl
#
use strict;
use warnings;

use Path::Tiny;

{ package Regex;

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
      regex => Path->new(),
     };

    my $data = Path::Tiny::path( $input_file )->slurp_utf8();
    $data =~ s/^\^//;
    $data =~ s/\$(.*)$//sm;

    my $curr = $self->{ regex };
    for my $char (split '', $data) {
      if ($char eq '(') {
        push @{ $curr->{ children } }, Path->new( $curr );
        $curr = $curr->{ children }[0];
       }
      elsif ($char eq '|') {
        $curr = $curr->{ parent };
        push @{ $curr->{ children } }, Path->new( $curr );
        $curr = $curr->{ children }[-1];
       }
      elsif ($char eq ')') {
        $curr = $curr->{ parent };
       }
      else {
        $curr->{ str } .= $char;
       }
     }

    bless $self, $class;
    return $self;
   }
    
};

{ package Path;

  sub new {
    my ($class, $parent) = @_;

    my $self = {
      str => '',
      parent => $parent,
      children => [],
     };

    bless $self, $class;
    return $self;
   }
};

my $input_file = $ARGV[0] || 'input20.txt';

my $regex = Regex->new( $input_file );

exit;
