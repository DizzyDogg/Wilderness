package Mob::Deer;

use strict;
use warnings;

use base qw(Mob);

my $desc = "The deer seems cute and kind ... but the sight of him makes you hungry";

sub describe {
    my $self = shift;
    return $desc;
}

1;
