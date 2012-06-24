#!/usr/bin/perl

use strict;
use warnings;

use YAML qw( LoadFile );
use Getopt::Long;
use Pod::Usage;

use TuringMachine;

# turn off output buffering
$| = 1;

my $verbose;
my $help;
GetOptions( "help" => \$help, "verbose" => \$verbose );

my $file;
if ( scalar @ARGV ) {
    $file = $ARGV[0];
}

if ( $help or not $file ) {
    pod2usage(1);
}

my $yaml = LoadFile($file);

my $table         = $yaml->{state_table};
my $initial_state = $yaml->{initial_state};
my $name          = $yaml->{name};
my $short_desc    = $yaml->{short_description};
my $long_desc     = $yaml->{long_description};
my $blank         = $yaml->{empty_symbol};

my $tape = {};
my $tapefile;
if ( 1 < scalar @ARGV ) {
    $tapefile = $ARGV[1];
    if ($tapefile) {
        open( my $FILE, '<', $tapefile );
        my @lines = <$FILE>;
        close($FILE);
        my $pos = 0;
        foreach my $line (@lines) {
            chomp $line;
            $tape->{ $pos++ } = $line;
        }
    }
}

my $turing_machine = new TuringMachine( $table, $initial_state, $blank, $tape );

print "$name\n\n";
print "$short_desc\n\n";
if ($verbose) {
    print "$long_desc\n\n";
}

if ($verbose) {
    $turing_machine->set_bfunc(
        sub {
            my $turing_machine = shift;
            print $turing_machine->peek(), "\n";
        }
    );
}

if ($verbose) {
    print "\nexecution:\n";
}
$turing_machine->go();

print "\nfinal state:\noperations: ", $turing_machine->peek(), "\n";

print "\nfinal tape:\n";
$turing_machine->for_each_tape_entry(
    sub {
        my ( $position, $contents ) = @_;

        printf( "%3d: %s\n", $position, $contents );
    }
);

__END__

=head1 NAME

turing-machine.pl - reads turing descriptions in YAML format

=head1 SYNOPSIS

turing-machien.pl [options] yamlfilename [tapefile]

    Options:
        -help        brief help message
        -verbose     full printout of execution steps

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-verbose>

prints more stuff.

=back

=head1 DESCRIPTION

B<This program> will read the given input YAML file and execute the
table. If a tapefile is not profived, it will assume a blank, infinite
strip.

=cut
