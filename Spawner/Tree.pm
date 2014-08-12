package Spawner::Tree;

use strict;
use warnings;

use base qw(Spawner);

my $desc = "What a lovely tree, one of Nature's most precious creations.\n"
            ."\tIt seems like you could climb this tree, or use its wood to make things.";

sub describe {
    my $self = shift;
    my @items = $self->get_equipment();
    my @lines;
    if ( @items ) {
        foreach my $item (@items) {
            push @lines, "\tThe $self has a $item\n";
            my @items_items = $item->get_equipment();
            foreach my $items_item (@items_items) {
                push @lines, "\tThe $item has a $items_item\n";
            }
        }
    }
    my $description = join '', @lines;
    return $desc . "\n$description";
}

1;
