package Container;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

# Containers are now officially ARRAY refs, not HASH refs.

sub new {
    my $package = shift;
    my $self = [@_];
    bless $self, $package;
    return $self;
}

sub add {
    my $self = shift;
    my $item = shift;
    return push @$self, $item;
}

sub remove {
    my $self = shift;
    my $item = shift;
    foreach my $i ( 0 .. scalar(@$self)-1 ) {
        return my ($a) = splice(@$self, $i, 1) if $self->[$i] == $item;
    }
    return warn "\tThere is no $item to remove\n";
}

sub get_all {
    my $self = shift;
    return @$self;
}

sub contains {
    my $self = shift;
    my $item = shift;
    foreach my $object ( @$self ) {
        return 1 if $object eq $item;
    }
    return 0;
}

1;
