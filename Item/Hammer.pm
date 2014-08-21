package Item::Hammer;

use strict;
use warnings;

use base qw(Item);

sub _desc {
    return "This hammer is beautiful and it brings tears to your eyes\n"
    . "\t\t(especially, when you drop it on your foot).\n"
    . "\tIt can be used for building and for destroying. Use with care.";
}

sub get_ingredients { qw(rock stick) }

sub get_tools {  }

sub process {
    return "You place the rock on one end of the stick and they magically stick together.";
}

1;
