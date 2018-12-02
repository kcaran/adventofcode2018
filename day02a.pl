#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Box_id;

  sub count_dupes {
    my ($self) = @_;

    for my $let (keys %{ $self->{ letter_cnt } }) {
      my $count = $self->{ letter_cnt }{ $let };
      $self->{ dupe_cnt }{ $count }++;
     }
   }

  sub count_letters {
    my ($self) = @_;

    for my $let (split( '', $self->{ id } )) {
      $self->{ letter_cnt }{ $let }++;
     }
   }

  sub num_dupes {
    my ($self, $num) = @_;

    return $self->{ dupe_cnt }{ $num } || 0;
   }

  sub new {
    my $class = shift;
    my $id = shift;
    my $self = {
      id => $id,
      letter_cnt => {},
      dupe_cnt => {},
    };
   bless $self, $class;

   $self->count_letters();
   $self->count_dupes();

   return $self;
  }
};

my $input_file = $ARGV[0] || 'input02.txt';

my @boxes = path( $input_file )->lines_utf8( { chomp => 1 } );

my ($has_two, $has_three) = (0, 0);
for my $box (@boxes) {
  my $box_id = Box_id->new( $box );
  $has_two++ if ($box_id->num_dupes( 2 ));
  $has_three++ if ($box_id->num_dupes( 3 ));
 }

print "The checksum is ", $has_two * $has_three, "\n";

