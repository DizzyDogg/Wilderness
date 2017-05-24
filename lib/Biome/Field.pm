package Biome::Field;

use strict;
use warnings;

use base qw(Biome);
use Item::Wheat;

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    if ( rand() < .4 ) {
        $self->visible_add(Item::Wheat->new());
    }
    $self->visible_add(Fixture::Bush->new(attached => 1));
}

1;
