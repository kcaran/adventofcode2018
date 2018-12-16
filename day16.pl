#!/usr/bin/perl
#
#
use strict;
use warnings;

use Path::Tiny;

{ package Inst;

  my $test_opcodes = {
    'addr' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == $self->{ before }[$a] + $self->{ before}[$b];
       },
    'addi' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == $self->{ before }[$a] + $b;
       },
    'mulr' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == $self->{ before }[$a] * $self->{ before}[$b];
       },
    'muli' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == $self->{ before }[$a] * $b;
       },
    'banr' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] & $self->{ before}[$b]);
       },
    'bani' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] & $b);
       },
    'borr' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] | $self->{ before}[$b]);
       },
    'bori' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] | $b);
       },
    'setr' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == $self->{ before }[$a];
       },
    'seti' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == $a;
       },
    'gtir' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($a > $self->{ before }[$b] ? 1 : 0);
       },
    'gtri' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] > $b ? 1 : 0);
       },
    'gtrr' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] > $self->{ before }[$b] ? 1 : 0);
       },
    'eqir' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($a == $self->{ before }[$b] ? 1 : 0);
       },
    'eqri' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] == $b ? 1 : 0);
       },
    'eqrr' => sub { 
		my ($self, $opcode, $a, $b, $c) = @_;
        return $self->{ after }[$c] == ($self->{ before }[$a] == $self->{ before }[$b] ? 1 : 0);
       },
  };

  sub like_three {
    my ($self) = @_;

    my $like = 0;
    for my $op (keys %{ $test_opcodes }) {
      if (($test_opcodes->{ $op })->($self, @{ $self->{ code } })) {
        print "like $op\n";
        $like++;
       }
     }

    return $like >= 3;
   }

  sub new {
    my ($class, $before, $code, $after) = @_;
    my $self = {
      before => [ split( /,\s*/, $before ) ],
      code => [ split( /\s+/, $code ) ],
      after => [ split( /,\s*/, $after ) ],
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input16.txt';

my $data = Path::Tiny::path( $input_file )->slurp_utf8();
my $like_three = 0;
while ($data =~ /Before:\s*\[(.*?)\]\s+([0-9 ]*)\s+After:\s*\[(.*?)\]/smg) {
  my $inst = Inst->new( $1, $2, $3 );
  $like_three++ if ($inst->like_three());
 }

print "There are $like_three samples that behave like three or more opcodes\n";
