package Item::Stick;

use strict;
use warnings;

use base qw(Item);

sub durability { return 10 }

sub max_cut_points { return 10 }

sub attach {
    my $self = shift;
    my $max = $self->max_cut_points();
    return $self->cut_points($max);
}

1;
