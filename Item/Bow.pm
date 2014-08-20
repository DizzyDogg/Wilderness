package Item::Bow;

use strict;
use warnings;

use base qw(Item);

sub _desc {
    return "This crude bow could probably manage to shoot an arrow.\n"
    . "Although, I am not sure how accurate it will be";
}

sub get_ingredients { 'stick', 'cord' }

sub process {
    return "You fasten each end of the cord to each end of the stick.\n";
}

1;