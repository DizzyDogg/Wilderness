package Item::HandAxe;

use strict;
use warnings;

use base qw(Item);

sub get_ingredients { 'rock' }

sub process {
    return "You smash the rock against something hard a few times until finally\n"
        .  "\tyou manage to split the rock leaving behind a crude jagged edge.\n"
        .  "\tThis seems like it could cut something if you do it right.";
}

1;
