package Biome::Forest;

use strict;
use warnings;

use base qw(Biome);
use Fixture::Tree;
use Mob::Deer;

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize();
    my $random = rand();
    my $tree = Fixture::Tree->_new();
        $self->_add_item($tree);
    if ( $random < .6 ) {
        my $deer = Mob::Deer->_new();
        $self->_add_item($deer);
    }
}

1;
