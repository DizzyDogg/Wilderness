package Biome::Forest;

use strict;
use warnings;

use base qw(Biome);
use Fixture::Tree;
use Mob::Deer;

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $random = rand();
    my $tree = Fixture::Tree->new(attached => 1);
        $self->add_item($tree);
    if ( $random < .6 ) {
        my $deer = Mob::Deer->new();
        $self->add_item($deer);
    }
}

1;
