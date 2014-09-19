package Item::FireWood;

use strict;
use warnings;

use base qw(Item);
use Item::Kindling;

sub cut_points { return 20 }
sub required_composition { qw{kindling kindling} }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::Kindling->new() );
    $self->composition_add( Item::Kindling->new() );
    $self->composition_add( Item::Kindling->new() );
    $self->composition_add( Item::Kindling->new() );
    $self->composition_add( Item::Kindling->new() );
    return $self;
}

1;
