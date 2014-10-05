package Item::Branch;

use strict;
use warnings;

use base qw(Item);
use Item::Stick;

sub required_action { return 'chop' }

sub max_cut_points { return 20 }
sub required_sharpness { return 10 }
sub required_mass { return 5 }

sub attach {
    my $self = shift;
    my $max = $self->max_cut_points();
    return $self->cut_points($max);
}

sub is_choppable { return 1 }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->visible_add( Item::Stick->new(attached => 1) );
    $self->visible_add( Item::Stick->new(attached => 1) );
    $self->visible_add( Item::Stick->new(attached => 1) );
    return $self;
}

1;
