#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

my $metadata_sum = 0;

{ package Tree;

  sub next_node {
    my ($self) = @_;
    my $num_children = shift @{ $self->{ input } };
    my $num_metadata = shift @{ $self->{ input } };

    my $node = Node->new( $num_children, $num_metadata );
    $self->{ root } = $node unless ($self->{ root });

    for (my $i = 0; $i < $num_children; $i++) {
      push( @{ $node->{ children } }, $self->next_node() );
     }
    for (my $i = 0; $i < $num_metadata; $i++) {
      my $metadata = shift @{ $self->{ input } };
      push( @{ $node->{ metadata } }, $metadata );
      $metadata_sum += $metadata; 
     }

    return $node; 
   }

  sub new {
    my $class = shift;
    my ($input_file) = @_;

    my $self = {
      nodes => {},
      input => [],
      root => '',
    };
   bless $self, $class;

   $self->{ input } = [ split( /\s+/, Path::Tiny::path( $input_file )->slurp_utf8() ) ];

   my $node = $self->next_node();


   return $self;
  }
};

{ package Node;

  sub value {
    my $self = shift;

    my $value = 0;

    for (my $i = 0; $i < $self->{ num_metadata }; $i++) {
      my $metadata = $self->{ metadata }[$i];
      if ($self->{ num_children } == 0) {
        $value += $metadata;
       }
      else {
        next unless ($metadata <= $self->{ num_children });
        $value += $self->{ children }[$metadata - 1]->value();
       } 
     }

    return $value;
   }

  sub new {
    my $class = shift;
    my ($num_children, $num_metadata) = @_;
    my $self = {
      num_children => $num_children,
      num_metadata => $num_metadata,
      children => [],
      metadata => [],
    };

   bless $self, $class;

   return $self;
  }
}

my $input_file = $ARGV[0] || 'input08.txt';

my $tree = Tree->new( $input_file );

print "The sum of metadata is $metadata_sum\n";

print "The value the root is ", $tree->{ root }->value(), "\n";

exit;
