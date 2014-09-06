package Mob;

use strict;
use warnings;

use base qw(Character);
use Module::Pluggable;
use Container;

sub hit_points { return 1 }

sub is_hostile { return 0 }

1;
