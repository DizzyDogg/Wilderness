package Mob::Troll;

use strict;
use warnings;

use base qw(Mob);

sub _is_hostile { 1 }

sub _hit_points { 10 }

sub _desc { 'It is huge and intimidating' }

1;
