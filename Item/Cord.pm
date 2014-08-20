package Item::Cord;

use strict;
use warnings;

use base qw(Item);

sub get_ingredients { 'hide' }

sub get_tools { 'handaxe' }

sub process {
    return "You take the handaxe and carefully cut the hide into strips\n"
    . "\tAfterwards, you fasten the strips together, forming a crude cord";
}

1;
