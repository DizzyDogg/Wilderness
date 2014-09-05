package Item::Fire;

use strict;
use warnings;

use base qw(Item);

sub _desc { "You just stare at it mezmorized by the dancing flames" }

sub _get_ingredients { return qw(stick branch) }

sub _get_tools { return 'bow' }

sub _process {
    return "You wrap the stick within the cord of the bow and set the\n"
    . "\tbranch on the ground. Then you place one end of the stick against\n"
    . "\tthe branch and begin running the bow back and forth causing\n"
    . "\timmense friction between the stick and branch.\n"
    . "\tAfter a little blowing and great effort, the fire is lit.";
}

1;
