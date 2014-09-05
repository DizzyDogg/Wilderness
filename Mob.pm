package Mob;

use strict;
use warnings;

use base qw(Character);
use Module::Pluggable;
use Container;

sub _hit_points { return 1 }

sub _is_hostile { return 0 }

1;
