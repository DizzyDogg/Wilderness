package Fixture::Bush;

use strict;
use warnings;

use base qw(Fixture);
use Item::Stick;
use Item::Berry;

sub desc {
    return "This is a bush, the berries could be tasty... or DEATH";
}

sub required_composition { qw{stick stick stick} }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::Stick->new() );
    $self->composition_add( Item::Stick->new() );
    $self->composition_add( Item::Stick->new() );
    $self->visible_add( Item::Berry->new() );
    $self->visible_add( Item::Berry->new() );
    $self->visible_add( Item::Berry->new() );
    $self->visible_add( Item::Berry->new() );
    $self->visible_add( Item::Berry->new() );
    return $self;
}

1;
