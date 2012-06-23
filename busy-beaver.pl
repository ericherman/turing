#!/usr/bin/perl

use strict;
use warnings;

# a perl implementation of the "busy beaver" described at
# https://en.wikipedia.org/wiki/Turing_machine

# turn off output buffering
$| = 1;

# State table for 3 state, 2 symbol busy beaver
my $table = {
    a => {
        0 => {
            write_symbol => 1,
            move_tape    => 1,
            next_state   => 'b',
        },
        1 => {
            write_symbol => 1,
            move_tape    => -1,
            next_state   => 'c',
        },
    },
    b => {
        0 => {
            write_symbol => 1,
            move_tape    => -1,
            next_state   => 'a',
        },
        1 => {
            write_symbol => 1,
            move_tape    => 1,
            next_state   => 'b',
        },
    },
    c => {
        0 => {
            write_symbol => 1,
            move_tape    => -1,
            next_state   => 'b',
        },
        1 => {
            write_symbol => 1,
            move_tape    => -1,
            next_state   => 'halt',
        },
    },
};

my $tape          = {};    # tape_position => contents
my $tape_position = 0;
my $state         = 'a';
my $scanned_symbol;

my $count = 0;
while ( $state ne 'halt' ) {
    my @positions = sort { $a <=> $b } keys %$tape;
    my $display = join( ', ', @positions );
    my $length = scalar @positions;
    printf( "%2d  state: %s, length: %2d, position: %2d, written to: %s\n",
        $count, $state, $length, $tape_position, $display );

    $count++;
    $tape->{$tape_position} //= 0;

    $scanned_symbol = $tape->{$tape_position};
    $tape->{$tape_position} =
      $table->{$state}->{$scanned_symbol}->{write_symbol};
    $tape_position += $table->{$state}->{$scanned_symbol}->{move_tape};
    $state = $table->{$state}->{$scanned_symbol}->{next_state};
}

