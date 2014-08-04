package Mob::Thief;

use strict;
use warnings;

use base qw(Mob);

sub is_hostile { return 1 }

sub hit_points { return 4 }

1;
