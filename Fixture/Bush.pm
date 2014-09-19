package Fixture::Bush;

use strict;
use warnings;

use base qw(Fixture);

sub desc {
    return "This is a bush, the berries could be tasty... or DEATH";
    }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $berry = Item::Berry->new();
    $self->visible_add($berry);
    $self->visible_add($berry);
    $self->visible_add($berry);
    $self->visible_add($berry);
    $self->visible_add($berry);
    return $self;
}
1;
