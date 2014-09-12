package Item::Log;

use strict;
use warnings;

use base qw(Item);
use Item::FireWood;

sub cut_points { return 50 }
sub required_composition { qw{firewood firewood} }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::FireWood->new() );
    $self->composition_add( Item::FireWood->new() );
    $self->composition_add( Item::FireWood->new() );
    $self->composition_add( Item::FireWood->new() );
    $self->composition_add( Item::FireWood->new() );
    return $self;
}

1;
