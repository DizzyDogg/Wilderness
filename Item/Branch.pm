package Item::Branch;

use strict;
use warnings;

use base qw(Item);
use Item::Stick;

sub required_action { return 'chop' }

sub cust_points { return 20 }
sub required_sharpness { return 10 }
sub required_mass { return 5 }

sub is_choppable { return 1 }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $stick1 = Item::Stick->new();
    my $stick2 = Item::Stick->new();
    my $stick3 = Item::Stick->new();
    $self->visible_add($stick1);
    $self->visible_add($stick2);
    $self->visible_add($stick3);
    return $self;
}

1;
