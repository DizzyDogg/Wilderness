package Item::Log;

use strict;
use warnings;

use base qw(Item);
use Item::FireWood;

sub max_cut_points { return 50 }
sub required_composition { qw{firewood firewood} }

sub attach {
    my $self = shift;
    my $max = $self->max_cut_points();
    return $self->cut_points($max);
}

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::FireWood->new(attached => 1) );
    $self->composition_add( Item::FireWood->new(attached => 1) );
    $self->composition_add( Item::FireWood->new(attached => 1) );
    $self->composition_add( Item::FireWood->new(attached => 1) );
    $self->composition_add( Item::FireWood->new(attached => 1) );
    return $self;
}

1;
