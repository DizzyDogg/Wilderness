package Mob::Deer;

use strict;
use warnings;

use base qw(Mob);
use Item::Hide;
use Item::Venison;

sub desc { "The deer seems cute and kind ... but the sight of him makes you hungry" }

sub weight { return 60 }

sub initialize {
    my $self = shift;
    my $hide = Item::Hide->new();
    $self->composition_add($hide);
    my $venison = Item::Venison->new();
    $self->composition_add($venison);
}

1;
