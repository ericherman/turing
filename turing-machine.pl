#!/usr/bin/perl

use strict;
use warnings;

use YAML qw( LoadFile );

use TuringMachine;

# turn off output buffering
$| = 1;

my $file = "busy-beaver.yaml";
if ( scalar @ARGV ) {
    $file = $ARGV[0];
}

my $yaml = LoadFile($file);

my $table         = $yaml->{state_table};
my $initial_state = $yaml->{initial_state};
my $name          = $yaml->{name};
my $short_desc    = $yaml->{short_description};
my $long_desc     = $yaml->{long_description};

print "$name\n\n";
print "$short_desc\n\n";
print "$long_desc\n\n";

my $turing_machine = new TuringMachine( $table, $initial_state );

$turing_machine->set_bfunc(
    sub {
        my $turing_machine = shift;
        print $turing_machine->peek(), "\n";
    }
);

print "\nexecution:\n";
$turing_machine->go();
$turing_machine->bfunc();

print "\nfinal tape:\n";
$turing_machine->for_each_tape_entry(
    sub {
        my ( $position, $contents ) = @_;

        printf( "%3d: %s\n", $position, $contents );
    }
);

