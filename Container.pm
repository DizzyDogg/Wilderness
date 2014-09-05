package Container;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

# Containers are now officially ARRAY refs, not HASH refs.

sub _new {
    my $package = shift;
    my $self = [@_];
    bless $self, $package;
    return $self;
}

sub _add {
    my $self = shift;
    my $item = shift;
    return push @$self, $item;
}

sub _remove {
    my $self = shift;
    my $item = shift;
    foreach my $i ( 0 .. scalar(@$self)-1 ) {
        return my ($a) = splice(@$self, $i, 1) if $self->[$i] == $item;
    }
    return;
}

sub _get_all {
    my $self = shift;
    return @$self;
}

sub _contains {
    my $self = shift;
    my $item = shift;
    foreach my $object ( @$self ) {
        return $object if $object eq $item;
    }
    return 0;
}

1;
