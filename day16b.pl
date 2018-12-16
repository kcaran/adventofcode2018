#!/usr/bin/perl
#
#
use strict;
use warnings;

use Path::Tiny;

{ package Inst;

  my $test_opcodes = {
    'addr' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a] + $state->[$b];
       },
    'addi' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a] + $b;
       },
    'mulr' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a] * $state->[$b];
       },
    'muli' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a] * $b;
       },
    'banr' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] & $state->[$b]);
       },
    'bani' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] & $b);
       },
    'borr' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] | $state->[$b]);
       },
    'bori' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] | $b);
       },
    'setr' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a];
       },
    'seti' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $a;
       },
    'gtir' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($a > $state->[$b] ? 1 : 0);
       },
    'gtri' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] > $b ? 1 : 0);
       },
    'gtrr' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] > $state->[$b] ? 1 : 0);
       },
    'eqir' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($a == $state->[$b] ? 1 : 0);
       },
    'eqri' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] == $b ? 1 : 0);
       },
    'eqrr' => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] == $state->[$b] ? 1 : 0);
       },
  };

  sub like_three {
    my ($self) = @_;

    my $like = 0;
    for my $op (keys %{ $test_opcodes }) {
      my $val = $test_opcodes->{ $op }->($self->{ before }, @{ $self->{ code } });
      my $end_reg = $self->{ after }[ $self->{ code }[3] ];
      if ($end_reg == $val) {
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
      inst => [],
    };

    my @opcodes = keys %{ $test_opcodes };

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
