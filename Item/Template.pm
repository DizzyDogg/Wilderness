package Item::Template;

use strict;
use warnings;

use base qw(Item);

sub _desc {
    return "Descripton of what this item is.\n"
        .  "\tThis description is what the player sees\n"
        .  "\twhen they 'look' at it";
}

# components added into the creation of this item
sub get_ingredients { return qw(item1 item2 item3) }

# tools requipred (not consumed) in the crafting of this item
sub get_tools { return qw(tool1 tool2) }

# requirements to free up this item so it can be obtained
# sub required_sharpness { 10 }
# sub required_weight { 5 }

# abilities of this item
# sub sharpness { 10 }
# sub weight { 5 }

# # Populate the object with anything it contains
# sub initialize {
#     my $self = shift;
#     $self->SUPER::initialize();
#     my $sub_item = Item::SubItem->new();
#     $self->equipment_add($sub_item);
#     return $self;
# }

sub process {
    return "Description of how this item can be crafted.\n"
        .  "\tThis will display when a player 'crafts' this item\n";
}

1;
