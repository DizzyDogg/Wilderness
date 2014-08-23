package Item::Branch;

use strict;
use warnings;

use base qw(Item);

sub required_action { 'chop' }
sub required_sharpness { 10 }
sub required_weight { 5 }

sub is_choppable { 1 }

1;
