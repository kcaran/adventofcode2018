#!/usr/bin/perl
#
#
use strict;
use warnings;

use Path::Tiny;

#
# Note: For part a at line 28, register 0 has to match register 3:
#
# 28 eqrr 3 0 4
#
# Using the debug print statements, I determined the output of register 3
# the first time line 28 was reached.
#
my $part = defined( $ARGV[1] ) || 7216956;
my $debug = 1;

my %halt_vals;

{ package Program;

  my $opcodes = {
    'addr' => sub { 
		my ($self, $a, $b, $c) = @_;
        return $self->{ regs }[$a] + $self->{ regs }[$b];
       },
    'addi' => sub { 
		my ($self, $a, $b, $c) = @_;
        return $self->{ regs }[$a] + $b;
       },
    'mulr' => sub { 
		my ($self, $a, $b, $c) = @_;
        return $self->{ regs }[$a] * $self->{ regs }[$b];
       },
    'muli' => sub { 
		my ($self, $a, $b, $c) = @_;
        return $self->{ regs }[$a] * $b;
       },
    'banr' => sub { 
		my ($self, $a, $b, $c) = @_;
        return int( $self->{ regs }[$a] ) & int( $self->{ regs }[$b] );
       },
    'bani' => sub { 
		my ($self, $a, $b, $c) = @_;
        return int( $self->{ regs }[$a] ) & $b;
       },
    'borr' => sub { 
		my ($self, $a, $b, $c) = @_;
        return int( $self->{ regs }[$a] ) | int( $self->{ regs }[$b] );
       },
    'bori' => sub { 
		my ($self, $a, $b, $c) = @_;
        return int( $self->{ regs }[$a] ) | $b;
       },
    'setr' => sub { 
		my ($self, $a, $b, $c) = @_;
        return $self->{ regs }[$a];
       },
    'seti' => sub { 
		my ($self, $a, $b, $c) = @_;
        return $a;
       },
    'gtir' => sub { 
		my ($self, $a, $b, $c) = @_;
        return ($a > $self->{ regs }[$b] ? 1 : 0);
       },
    'gtri' => sub { 
		my ($self, $a, $b, $c) = @_;
        return ($self->{ regs }[$a] > $b ? 1 : 0);
       },
    'gtrr' => sub { 
		my ($self, $a, $b, $c) = @_;
        return ($self->{ regs }[$a] > $self->{ regs }[$b] ? 1 : 0);
       },
    'eqir' => sub { 
		my ($self, $a, $b, $c) = @_;
        return ($a == $self->{ regs }[$b] ? 1 : 0);
       },
    'eqri' => sub { 
		my ($self, $a, $b, $c) = @_;
        return ($self->{ regs }[$a] == $b ? 1 : 0);
       },
    'eqrr' => sub { 
		my ($self, $a, $b, $c) = @_;
        return ($self->{ regs }[$a] == $self->{ regs }[$b] ? 1 : 0);
       },
  };

  sub execute {
    my ($self, $code) = @_;

    my ($opcode, $a, $b, $c) = split( /\s+/, $code );

    $self->{ regs }[$c] = $opcodes->{ $opcode }->( $self, $a, $b );
   }

  sub run {
    my ($self) = @_;

    my $reg = $self->{ regs };
    while ((my $line = $reg->[ $self->{ inst } ]) < @{ $self->{ code } }) {
      print "[ ", join( ',', map { sprintf "%10x", $_ } @{ $self->{ regs } } ), " ]\n" if ($debug == 1 && $line == 28);
      print "[ ", join( ',', map { sprintf "%10x", $_ } @{ $self->{ regs } } ), " ]\n" if ($debug > 1);
      if ($line == 28) {
        my $halt = $self->{ regs }[3];
        die "A match was found. Use the previous value of register 4.\n" if ($halt_vals{ $halt });                                                              
        $halt_vals{ $halt } = 1;
       }

      $self->execute( $self->{ code }[$line] );

      # Short-circuit the loop!
      if (1 && $line == 17) {
        $self->{ regs }[4] = ($self->{ regs }[2] / 256) - 1;
       }

      $self->{ regs }[$self->{ inst }]++;
     }

    return;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
      code => [],
      regs => [ $part, 0, 0, 0, 0, 0 ],
      inst => 0,
    };

    my $data = Path::Tiny::path( $input_file )->slurp_utf8();
    ($self->{ inst }) = $data =~ /\#ip (\d+)/sm;
    while ($data =~ /(\w+ \d+ \d+ \d+)\n/smg) {
      push @{ $self->{ code } }, $1;
     }
      
    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input21.txt';

my $program = Program->new( $input_file );

$program->run();

print join( ' ', @{ $program->{ regs } } ), "\n";

exit;
