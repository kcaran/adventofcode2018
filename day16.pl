#!/usr/bin/perl
#
#
use strict;
use warnings;

use Path::Tiny;

{ package Program;

  my $opcode_list = [
	{
     name => 'addr',
     opcode => -1,
     code => sub { 
       my ($state, $opcode, $a, $b, $c) = @_;
       return $state->[$a] + $state->[$b];
      },
    },
	{
     name => 'addi',
     opcode => -1,
     code => sub { 
       my ($state, $opcode, $a, $b, $c) = @_;
       return $state->[$a] + $b;
      },
    },
	{
     name => 'mulr',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a] * $state->[$b];
      },
    },
	{
     name => 'muli',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a] * $b;
      },
    },
	{
     name => 'banr',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] & $state->[$b]);
      },
    },
	{
     name => 'bani',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] & $b);
      },
    },
	{
     name => 'borr',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] | $state->[$b]);
      },
    },
	{
     name => 'bori',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] | $b);
      },
    },
	{
     name => 'setr',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $state->[$a];
      },
    },
	{
     name => 'seti',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return $a;
      },
    },
	{
     name => 'gtir',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($a > $state->[$b] ? 1 : 0);
      },
    },
	{
     name => 'gtri',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] > $b ? 1 : 0);
      },
    },
	{
     name => 'gtrr',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] > $state->[$b] ? 1 : 0);
      },
    },
	{
     name => 'eqir',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($a == $state->[$b] ? 1 : 0);
      },
    },
	{
     name => 'eqri',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] == $b ? 1 : 0);
      },
    },
	{
     name => 'eqrr',
     opcode => -1,
     code => sub { 
		my ($state, $opcode, $a, $b, $c) = @_;
        return ($state->[$a] == $state->[$b] ? 1 : 0);
      },
    },
  ];

  sub opcode {
    my ($self, $test) = @_;
    my $ret_val = -1;
    my $bit_string = sprintf "%016b", $test;
    if (scalar( grep { $_ == 1 } split( '', $bit_string ) ) == 1) {
      $ret_val = 15 - index( $bit_string, '1' );
     }

    return $ret_val;
   }

  sub teach {
    my ($self, $a, $b, $c) = @_;
    my $before = [ split( /,\s*/, $a ) ];
    my $code = [ split( /\s+/, $b ) ];
    my $after = [ split( /,\s*/, $c ) ];

    my $like = 0;
    for (my $op = 0; $op < @{ $opcode_list }; $op++) {
      my $val = $opcode_list->[$op]{ code }->($before, @{ $code });
      my $end_reg = $after->[ $code->[3] ];
      if ($end_reg == $val) {
        print "like $opcode_list->[ $op ]{ name }\n";
        $like |= 1 << $op;
       }
     }

    $self->{ opcodes }[$code->[0]] &= $like;

    # Check if we are down to a single opcode
    if ((my $opcode = $self->opcode( $self->{ opcodes }[$code->[0]] )) >= 0) {
      my $mask = 0xffff ^ (1 << $opcode);
      for (my $i = 0; $i < 16; $i++) {
        next if ($i == $code->[0]);
        $self->{ opcodes }[$i] &= $mask;
       }
     }

    return scalar( grep { $_ == 1 } split( '', sprintf "%b", $like ) ) >= 3;
   }

  sub execute {
    my ($self, $line) = @_;

    my $opcode = $opcode_list->[ $self->opcode( $self->{ opcodes }[ $line->[0] ] ) ];

    $self->{ reg }[$line->[3]] = $opcode->{ code }->( $self->{ reg }, @{ $line } );
   }

  sub new {
    my ($class, $before, $code, $after) = @_;
    my $self = {
      inst => [],
      opcodes => [],
      reg => [ 0, 0, 0, 0 ],
    };

    for (my $i = 0; $i < 16; $i++) {
      $self->{ opcodes }[$i] = 0xffff;
     }

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input16.txt';

my $data = Path::Tiny::path( $input_file )->slurp_utf8();
my $program = Program->new();
my $like_three = 0;
while ($data =~ /Before:\s*\[(.*?)\]\s+([0-9 ]*)\s+After:\s*\[(.*?)\]/smg) {
  $like_three++ if ($program->teach( $1, $2, $3 ));
 }

print "There are $like_three samples that behave like three or more opcodes\n";

my ($code) = $data =~ /((?:\d+ \d+ \d+ \d+\n)+)\Z/sm; 
my @program = split /\n/, $code;
for my $p (@program) {
  $program->execute( [ split /\s+/, $p ] );
 }

print "Register 0 is now $program->{ reg }[0]\n";

exit;
