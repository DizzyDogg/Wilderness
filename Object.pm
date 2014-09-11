package Object;

use strict;
use warnings;

use Container;
use Data::Dumper;

use overload
    'bool' => sub {
        my $self = shift;
        return $self;
    },
    '""' => sub {
        my $self = shift;
        return $self->name();
    },
    'eq' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->name() if (ref $a && $a->can('name'));
        $b = $b->name() if (ref $b && $b->can('name'));
        return $a eq $b;
    },
    'ne' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->name() if (ref $a && $a->can('name'));
        $b = $b->name() if (ref $b && $b->can('name'));
        return $a ne $b;
    },
    '==' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->name() if (ref $a && $a->can('name'));
        $b = $b->name() if (ref $b && $b->can('name'));
        return $a eq $b;
    },
    '!=' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->name() if (ref $a && $a->can('name'));
        $b = $b->name() if (ref $b && $b->can('name'));
        return $a ne $b;
    },
    ;

sub new {
    my $package = shift;
    my $self = {@_};
    my $name = lc((split '::', $package)[-1]);
    (my $path = $package) =~ s/::/\//;
    $path .= '.pm';
    require $path;
    $self->{'inventory'} = Container->new();
    $self->{'visible'} = Container->new();
    $self->{'composition'} = Container->new();
    bless $self, $package;
    $self->initialize();
    $self->{'name'} ||= $name;
    return $self;
}

sub initialize { }

sub is_item { return }
sub is_character { return }
sub is_fixture { return }
sub is_player { return }
sub is_place { return }
sub is_biome { return }
sub is_obstruction { return }

#find a way to check the 'required_action' instead of 'is_choppable'
sub is_choppable { return }

sub get_health { undef }

sub name {
    my $self = shift;
    return $self->{'name'};
}

sub required_sharpness { return 0 }
sub required_weight { return 0 }
sub sharpness { return 0 }
sub weight { return 0 }

sub has_requirements {
    my $self = shift;
    return $self->required_sharpness()
        || $self->required_weight()
        ;
}

sub has_can_damage {
    my $self = shift;
    my $item = shift;
    my @equips = $self->get_visible();
    foreach my $equip (@equips) {
        return $equip if $equip->can_damage($item);
    }
    warn "\tYou have nothing equipped strong enough to affect the $item\n";
    return;
}

sub can_damage {
    my $self = shift;
    my $victim = shift;
    my $sharp = $self->sharpness();
    my $weight = $self->weight();
    my $req_sharp = $victim->required_sharpness();
    my $req_weight = $victim->required_weight();
    return $sharp >= $req_sharp && $weight >= $req_weight;
}

# Same as is_here, but skipping characters and their visible.
sub can_reach {
    my $self = shift;
    my $thing = shift;
    my $place = $self->where();
    my @items = $place->get_items();
    push @items, $self->get_inventory(), $self->get_visible();
    foreach my $item (@items) {
        next if $item->is_character();
        return $item if $item eq $thing;
        my @deep_items = $item->get_deep_visible();
        foreach my $deep_item (@deep_items) {
            return $deep_item if $deep_item eq $thing;
        }
    }
    return 0;
}

sub drop {
    my $self = shift;
    my $what = shift;
    my $here = $self->where();
    return warn "\tYou don't have a $what\n" unless $self->has($what);
    $self->inventory_remove($what) || $self->visible_remove($what);
    $here->add_item($what);
    print "\tYou place the $what gently on the ground\n" if $self->is_player();
    return $self;
}

sub has {
    my $self = shift;
    my $item = shift;
    return ( $self->has_in_visible($item) || $self->has_in_inventory($item) ) ? 1 : 0;
}

sub has_in_inventory {
    my $self = shift;
    my $item = shift;
    return $self->{'inventory'}->contains($item);
}

sub has_in_visible {
    my $self = shift;
    my $item = shift;
    return $self->{'visible'}->contains($item);
}

sub has_in_composition {
    my $self = shift;
    my $item = shift;
    return $self->{'composition'}->contains($item);
}

sub where {
    my $self = shift;
    return $self->{'location'};
}

sub desc {
    return 'There does not appear to be anything special about it';
}

sub describe {
    my $self = shift;
    return join ("\n\t", $self->desc(), $self->get_sub_description());
}

sub process {
    my $self = shift;
    return "Congratulations! You have just made a $self"
}

sub get_ingredients { return }
sub get_tools { return }

sub get_sub_description {
    my $self = shift;
    my @items = $self->get_visible();
    my @lines;
    if ( @items ) {
        foreach my $item (@items) {
            push @lines, "\tThe $self has a $item";
            my @items_items = $item->get_visible();
            foreach my $items_item (@items_items) {
                push @lines, "\tThe $item has a $items_item";
            }
        }
    }
    return @lines;
}

sub equip {
    my $self = shift;
    my $item = shift;
    return warn "\tWhat would you like to equip?\n" unless $item;
    return warn "\tI do not know what a $item is\n" unless ref $item;
    return warn "\tYou already have a $item equipped\n" if $self->has_in_visible($item);
    return warn "\tYou do not have a $item to equip\n" unless $self->has_in_inventory($item);
    $self->inventory_remove($item);
    $self->visible_add($item);
    print "\tYou take the $item out of your pack and place it in your hand\n";
    return 1;
}

sub unequip {
    my $self = shift;
    my $item = shift;
    return warn "\tWhat would you like to unequip?\n" unless $item;
    return warn "\tI do not know what a $item is\n" unless ref $item;
    return warn "\tYou do not have a $item equipped\n" unless $self->has_in_visible($item);
    $self->visible_remove($item);
    $self->inventory_add($item);
    print "\tYou place the $item back in your pack\n";
    return 1;
}

sub inventory_add { _add-> (@_, 'inventory') }
sub visible_add { _add->(@_, 'visible') }
sub composition_add { _add->(@_, 'composition') }

sub _add {
    my $self = shift;
    my $item = shift;
    my $container = shift;
    my $added = $self->{$container}->add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub inventory_remove { _remove-> (@_, 'inventory') }
sub visible_remove { _remove->(@_, 'visible') }
sub composition_remove { _remove->(@_, 'composition') }

sub _remove {
    my $self = shift;
    my $item = shift;
    my $container = shift;
    my $removed = $self->{$container}->remove($item);
    return $removed;
}

sub get_inventory { _get-> (@_, 'inventory') }
sub get_visible { _get->(@_, 'visible') }
sub get_composition { _get->(@_, 'composition') }

sub _get {
    my $self = shift;
    my $container = shift;
    my @items = $self->{$container}->get_all();
    return @items;
}

sub get_deep_visible {
    my $self = shift;
    my @items = $self->get_visible();
    my @all_items;
    push @all_items, @items;
    foreach my $item (@items) {
        push @all_items, $item->get_deep_visible();
    }
    return @all_items;
}

sub visible_containers {
    my $self = shift;
    my $find = shift;
    return $self if $find == $self;
    my @items = $self->get_visible();
    foreach my $item (@items) {
        my @deep_items = $item->visible_containers($find);
        return (@deep_items, $self) if @deep_items;
    }
    return;
}

sub has_on_ground {
    my $place = shift;
    my $item = shift;
    my @containers = $place->visible_containers($item);
    return $containers[1] == $place;
}

sub get_all {
    my $self = shift;
    my @possessions = ( $self->get_visible(), $self->get_inventory() );
    return @possessions;
}

1;
