package Item::Meat;

use strict;
use warnings;

use base qw(Item);

sub durability { return 5 }
# shift->{'quantity'} * 5 }

1;
