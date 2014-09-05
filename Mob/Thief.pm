package Mob::Thief;

use strict;
use warnings;

use base qw(Mob);

sub _is_hostile { return 1 }

sub _hit_points { return 4 }

1;
