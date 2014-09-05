package Item::Branch;

use strict;
use warnings;

use base qw(Item);
use Item::Stick;

sub _required_action { return 'chop' }
sub _required_sharpness { return 10 }
sub _required_weight { return 5 }

sub _is_choppable { return 1 }

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize();
    my $stick = Item::Stick->_new();
    $self->_equipment_add($stick);
    $self->_equipment_add($stick);
    $self->_equipment_add($stick);
    return $self;
}

1;
