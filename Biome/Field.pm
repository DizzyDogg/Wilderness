package Biome::Field;

use strict;
use warnings;

use base qw(Biome);
use Item::Wheat;

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize();
    if ( rand() < .4 ) {
        my $wheat = Item::Wheat->_new();
        $self->_add_item($wheat);
    }
}

1;
