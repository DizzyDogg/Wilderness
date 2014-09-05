package Item;

use strict;
use warnings;

use base qw(Object);

sub _damage { return 1 }

sub _is_item { return 1 }

sub _prior_action {
    my $self = shift;
    my $do = $self->_required_action();
    return "\tFirst you must $do the $self\n";
}

1;
