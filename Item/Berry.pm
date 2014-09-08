package Item::Berry;

use strict;
use warnings;

use base qw(Item);

sub desc {
    return "Descripton of what this item is.\n"
        .  "\tThis description is what the player sees\n"
        .  "\twhen they 'look' at it";
}



1;
