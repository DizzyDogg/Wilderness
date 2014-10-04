package Fixture::Tree;

use strict;
use warnings;

use base qw(Fixture);
use Item::Branch;
use Item::Log;

sub desc {
    return "What a lovely tree, one of Nature's most precious creations.\n"
    ."\tYou could use its wood to make things.";
}

# sub required_action { return 'chop' }

# sub required_sharpness { return 15 }
# sub required_mass { return 25 }

sub required_composition { return qw{log log} }

sub max_cut_points { return 50 }

sub attach {
    my $self = shift;
    my $max = $self->max_cut_points();
    return $self->cut_points($max);
}

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::Log->new(attached => 1) );
    $self->composition_add( Item::Log->new(attached => 1) );
    $self->composition_add( Item::Log->new(attached => 1) );
    $self->visible_add( Item::Branch->new(attached => 1) );
    return $self;
}

1;
