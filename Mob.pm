package Mob;

use strict;
use warnings;

use base qw(Character);
use Module::Pluggable;
use Container;

sub hit_points { return 1 }

sub is_hostile { return 0 }

sub name {
    my $self = shift;
    my ($class, $name) = split /::/, ref($self);
    return lc $name;
}

1;
