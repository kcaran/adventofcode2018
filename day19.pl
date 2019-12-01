#!/usr/bin/perl
#
#
use strict;
use warnings;

use Path::Tiny;

my $part = $ARGV[0] || 0;
my $debug = 1;

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

    my $zero = -1;

    my $reg = $self->{ regs };
    while ((my $line = $reg->[ $self->{ inst } ]) < @{ $self->{ code } }) {
      $self->execute( $self->{ code }[$line] );
      $self->{ regs }[$self->{ inst }]++;
      if ($self->{ regs }[0] != $zero) {
print "[ ", join( ',', map { sprintf "%10d", $_ } @{ $self->{ regs } } ), " ]\n" if ($debug);
$zero = $self->{ regs }[0];
       }
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

my $input_file = $ARGV[0] || 'input19.txt';

my $program = Program->new( $input_file );

$program->run();

print join( ' ', @{ $program->{ regs } } ), "\n";

exit;
