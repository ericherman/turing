#!/usr/bin/perl

use strict;
use warnings;

use YAML qw( LoadFile );

use TuringMachine;

# a perl implementation of the "busy beaver" described at
# https://en.wikipedia.org/wiki/Turing_machine

# turn off output buffering
$| = 1;

# State table for 3 state, 2 symbol busy beaver
my $table = LoadFile("busy-beaver.yaml");

my $turing_machine = new TuringMachine( $table, 'a' );

$turing_machine->set_bfunc(
    sub {
        my $turing_machine = shift;
        print $turing_machine->peek(), "\n";
    }
);

$turing_machine->go();
$turing_machine->bfunc();

$turing_machine->for_each_tape_entry(
    sub {
        my ( $position, $contents ) = @_;

        printf( "%3d: %s\n", $position, $contents );
    }
);

