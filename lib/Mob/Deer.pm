package Mob::Deer;

use strict;
use warnings;

use base qw(Mob);
use Item::Hide;
use Item::Venison;

sub desc { "The deer seems cute and kind ... but the sight of him makes you hungry" }

sub mass { return 60 }

1;
