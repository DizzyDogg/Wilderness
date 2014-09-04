package Biome;

use strict;
use warnings;

use base qw(Place);

sub is_biome { return 1 }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    delete $self->{'hidden'};
    return $self;
}

1;
