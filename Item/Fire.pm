package Item::Fire;

use strict;
use warnings;

use base qw(Item);

sub get_ingredients {
    my $self = shift;
    return ( 'rock', 'wheat' );
}

1;
