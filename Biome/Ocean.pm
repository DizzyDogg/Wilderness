package Biome::Ocean;

use strict;
use warnings;

use base qw(Biome);
use Item::Fish;

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize();
    my $random = rand();
}

1;
