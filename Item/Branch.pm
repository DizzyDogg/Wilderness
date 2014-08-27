package Item::Branch;

use strict;
use warnings;

use base qw(Item);
use Item::Stick;

sub required_action { 'chop' }
sub required_sharpness { 10 }
sub required_weight { 5 }

sub is_choppable { 1 }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $stick = Item::Stick->new();
    $self->equipment_add($stick);
    $self->equipment_add($stick);
    $self->equipment_add($stick);
}

1;
