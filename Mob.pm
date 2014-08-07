package Mob;

use strict;
use warnings;

use base qw(Character);
use Module::Pluggable;
use Container;

sub hit_points { 1 }

sub is_hostile { 0 }

sub is_here { }

sub name {
    my $self = shift;
    my ($class, $name) = split /::/, ref($self);
    return lc $name;
}

1;
