package Item::Branch;

use strict;
use warnings;

use base qw(Item);
use Item::Stick;

sub required_action { return 'chop' }

sub required_sharpness { return 10 }
sub required_weight { return 5 }

# sub is_choppable { return 1 }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $stick = Item::Stick->new();
    $self->visible_add($stick);
    $self->visible_add($stick);
    $self->visible_add($stick);
    return $self;
}

1;
