package Item::Pole;

use strict;
use warnings;

use base qw(Item);
use Item::Stick;

sub desc {
    return "You admire the long smooth piece of wood\n"
        .  "\tYou could use it as a handle in crafting tools or weapons.";
}

sub get_consumables { return qw(branch) }
sub get_tools { return qw(handaxe) } # something sharp

sub required_composition { return qw{stick stick} }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->composition_add( Item::Stick->new() );
    $self->composition_add( Item::Stick->new() );
    $self->composition_add( Item::Stick->new() );
    return $self;
}

1;
