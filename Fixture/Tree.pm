package Fixture::Tree;

use strict;
use warnings;

use base qw(Fixture);

my $desc = "What a lovely tree, one of Nature's most precious creations.\n"
            ."\tIt seems like you could climb this tree, or use its wood to make things.";

sub describe {
    my $self = shift;
    my $sub_desc = $self->get_sub_description();
    return join ("\n\t", $desc, $self->get_sub_description());
}

1;
