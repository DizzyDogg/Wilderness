package Biome::Ocean;

use strict;
use warnings;

use base qw(Biome);
use Item::Fish;

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $random = rand();
}

1;
