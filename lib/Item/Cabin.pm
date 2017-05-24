package Item::Cabin;

use strict;
use warnings;

use base qw(Item);

sub desc {
    return "What a magnificent structure. It looks so warm and cozy\n"
        .  "\tFor some reason it reminds you of Hansel and Gretel\n"
}

# components added into the creation of this item
sub get_ingredients {
    my @items = split ' ', 'log ' x 30;
    push @items, split ' ', 'mud ' x 6;
    return @items;
}

sub process {
    return "This is quite an undertaking which takes much in resources\n"
        .  "\tYou place the logs one on top of the other filling in\n"
        .  "\tbetween them with mud to hold them and prevent a draft";
}

1;
