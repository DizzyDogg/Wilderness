package Spawner::Tree;

use strict;
use warnings;

use base qw(Spawner);

my $desc = "What a lovely tree, one of Nature's most precious creations.\n"
            ."\tIt seems like you could climb this tree, or use its wood to make things.";

sub describe {
    my $self = shift;
    return $desc;
}

1;
