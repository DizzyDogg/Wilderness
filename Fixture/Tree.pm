package Fixture::Tree;

use strict;
use warnings;

use base qw(Fixture);
use Item::Branch;

sub _desc {
    return "What a lovely tree, one of Nature's most precious creations.\n"
    ."\tIt seems like you could climb this tree, or use its wood to make things.";
}

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $branch = Item::Branch->new();
    $self->equipment_add($branch);
    return $self;
}

1;
