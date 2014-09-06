package Mob::Troll;

use strict;
use warnings;

use base qw(Mob);

sub is_hostile { 1 }

sub hit_points { 10 }

sub desc { 'It is huge and intimidating' }

1;
