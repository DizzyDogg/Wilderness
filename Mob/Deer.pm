package Mob::Deer;

use strict;
use warnings;

use base qw(Mob);
use Item::Hide;
use Item::Venison;

sub _desc { "The deer seems cute and kind ... but the sight of him makes you hungry" }

sub _initialize {
    my $self = shift;
    my $hide = Item::Hide->_new();
    $self->_inventory_add($hide);
    my $venison = Item::Venison->_new();
    $self->_inventory_add($venison);
}

1;
