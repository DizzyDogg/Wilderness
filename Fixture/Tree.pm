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
# sub required_weight { return 25 }

sub cut_points { return 50 }

sub required_composition { return qw{log} }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::Log->new() );
    $self->composition_add( Item::Log->new() );
    $self->composition_add( Item::Log->new() );
    $self->visible_add( Item::Branch->new() );
    return $self;
}

1;
