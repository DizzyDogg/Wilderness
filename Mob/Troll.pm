package Mob::Troll;

use strict;
use warnings;

use base qw(Mob);

sub is_hostile { 1 }

sub hit_points { 10 }

my $desc = 'It is huge and intimidating';

sub describe {
    my $self = shift;
    return $desc;
}

1;
