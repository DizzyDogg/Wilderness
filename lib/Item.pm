package Item;

use strict;
use warnings;

use base qw(Object);

sub damage { return 1 }

sub is_item { return 1 }

sub prior_action {
    my $self = shift;
    my $do = $self->required_action();
    return "\tFirst you must $do the $self\n";
}

1;
