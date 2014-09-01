package Biome::Field;

use strict;
use warnings;

use base qw(Biome);
use Item::Wheat;

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    if ( rand() < .4 ) {
        my $wheat = Item::Wheat->new();
        $self->add_item($wheat);
    }
}

1;
