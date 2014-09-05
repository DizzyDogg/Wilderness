package Biome::Desert;

use strict;
use warnings;

use base qw(Biome);
use Item::Rock;

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize();
    if ( rand() < .4 ) {
        my $rock = Item::Rock->_new();
        $self->_add_item($rock);
    }
    return $self;
}

1;
