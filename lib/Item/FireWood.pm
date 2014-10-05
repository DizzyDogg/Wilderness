package Item::FireWood;

use strict;
use warnings;

use base qw(Item);
use Item::Kindling;

sub max_cut_points { return 20 }
sub required_composition { qw{kindling kindling} }

sub attach {
    my $self = shift;
    my $max = $self->max_cut_points();
    return $self->cut_points($max);
}

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::Kindling->new(attached => 1) );
    $self->composition_add( Item::Kindling->new(attached => 1) );
    $self->composition_add( Item::Kindling->new(attached => 1) );
    $self->composition_add( Item::Kindling->new(attached => 1) );
    $self->composition_add( Item::Kindling->new(attached => 1) );
    return $self;
}

1;
