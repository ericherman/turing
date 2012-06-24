package TuringMachine;

use strict;
use warnings;

sub new {
    my $class = shift;
    my ( $table, $state, $blank_symbol, $tape ) = @_;
    my $self = {};
    bless $self, $class;

    $self->{table}          = $table;
    $self->{state}          = $state;
    $self->{blank}          = $blank_symbol;
    $self->{tape}           = $tape;           # tape_position => contents
    $self->{tape_position}  = 0;
    $self->{count}          = 0;
    $self->{scanned_symbol} = undef;

    $self->{tape}  //= {};
    $self->{blank} //= 0;

    return $self;
}

sub go {
    my $self = shift;

    while ( defined $self->{table}->{ $self->{state} } ) {
        $self->bfunc();

        $self->{count}++;
        $self->{tape}{ $self->{tape_position} } //= $self->{blank};
        $self->{scanned_symbol} = $self->{tape}{ $self->{tape_position} };

        my $t = $self->{table}{ $self->{state} }{ $self->{scanned_symbol} };

        $self->{tape}{ $self->{tape_position} } = $t->{write_symbol};
        $self->{tape_position} += $t->{move_tape};
        $self->{state} = $t->{next_state};

        $self->afunc();
    }
}

sub peek {
    my $self = shift;

    my @tape_positions_used = sort { $a <=> $b } keys %{ $self->{tape} };
    my $display_positions_used = join( ', ', @tape_positions_used );
    my $length = scalar @tape_positions_used;

    my $str = sprintf(
        "%2d  state: %s, length: %2d, position: %2d, written to: %s",
        $self->{count}, $self->{state}, $length, $self->{tape_position},
        $display_positions_used
    );

    return $str;
}

sub for_each_tape_entry {
    my ( $self, $func ) = @_;

    for my $position ( sort { $a <=> $b } keys %{ $self->{tape} } ) {
        my $contents = $self->{tape}{$position};
        $func->( $position, $contents );
    }
}

sub set_bfunc {
    my ( $self, $bfunc ) = @_;
    $self->{bfunc} = $bfunc;
}

sub bfunc {
    my $self = shift;

    if ( $self->{bfunc} ) {
        $self->{bfunc}->($self);
    }
}

sub set_afunc {
    my ( $self, $afunc ) = @_;
    $self->{afunc} = $afunc;
}

sub afunc {
    my $self = shift;

    if ( $self->{afunc} ) {
        $self->{afunc}->($self);
    }
}

1;

