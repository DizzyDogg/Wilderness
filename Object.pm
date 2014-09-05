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
        return $self->_name();
    },
    'eq' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->_name() if (ref $a && $a->can('_name'));
        $b = $b->_name() if (ref $b && $b->can('_name'));
        return $a eq $b;
    },
    'ne' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->_name() if (ref $a && $a->can('_name'));
        $b = $b->_name() if (ref $b && $b->can('_name'));
        return $a ne $b;
    },
    '==' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->_name() if (ref $a && $a->can('_name'));
        $b = $b->_name() if (ref $b && $b->can('_name'));
        return $a eq $b;
    },
    '!=' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->_name() if (ref $a && $a->can('_name'));
        $b = $b->_name() if (ref $b && $b->can('_name'));
        return $a ne $b;
    },
    # '==' => sub { return shift eq shift },
    # '!=' => sub { return ! shift eq shift },
    # 'ne' => sub { return ! shift eq shift },
    ;

sub _new {
    my $package = shift;
    my $self = {@_};
    my $name = lc((split '::', $package)[-1]);
    (my $path = $package) =~ s/::/\//;
    $path .= '.pm';
    require $path;
    $self->{'hidden'} = Container->_new();
    $self->{'visible'} = Container->_new();
    bless $self, $package;
    $self->_initialize();
    $self->{'name'} ||= $name;
    return $self;
}

sub _initialize { }

sub _is_item { return }
sub _is_character { return }
sub _is_fixture { return }
sub _is_player { return }
sub _is_place { return }
sub _is_biome { return }
sub _is_obstruction { return }

#find a way to check the 'required_action' instead of 'is_choppable'
sub _is_choppable { return }

sub _get_health { undef }

sub _name {
    my $self = shift;
    return $self->{'name'};
}

sub _required_sharpness { return 0 }
sub _required_weight { return 0 }
sub _sharpness { return 0 }
sub _weight { return 0 }

sub _has_requirements {
    my $self = shift;
    return $self->_required_sharpness()
        || $self->_required_weight()
        ;
}

sub _has_can_damage {
    my $self = shift;
    my $item = shift;
    my @equips = $self->_get_equipment();
    foreach my $equip (@equips) {
        return $equip if $equip->_can_damage($item);
    }
    warn "\tYou have nothing equipped strong enough to affect the $item\n";
    return;
}

sub _can_damage {
    my $self = shift;
    my $victim = shift;
    my $sharp = $self->_sharpness();
    my $weight = $self->_weight();
    my $req_sharp = $victim->_required_sharpness();
    my $req_weight = $victim->_required_weight();
    return $sharp >= $req_sharp && $weight >= $req_weight;
}

# Same as is_here, but skipping characters and their equipment.
sub _can_reach {
    my $self = shift;
    my $thing = shift;
    my $place = $self->_where();
    my @items = $place->_get_items();
    push @items, $self->_get_inventory(), $self->_get_equipment();
    foreach my $item (@items) {
        next if $item->_is_character();
        return $item if $item eq $thing;
        my @deep_items = $item->_get_deep_equipment();
        foreach my $deep_item (@deep_items) {
            return $deep_item if $deep_item eq $thing;
        }
    }
    return 0;
}

sub drop {
    my $self = shift;
    my $what = shift;
    my $here = $self->_where();
    return warn "\tYou don't have a $what\n" unless $self->_has($what);
    $self->_inventory_remove($what) || $self->_equipment_remove($what);
    $here->_add_item($what);
    print "\tYou place the $what gently on the ground\n" if $self->_is_player();
    return $self;
}

sub _has {
    my $self = shift;
    my $item = shift;
    return ( $self->_has_on($item) || $self->_has_in($item) ) ? 1 : 0;
}

sub _has_on {
    my $self = shift;
    my $item = shift;
    return $self->{'visible'}->_contains($item);
}

sub _has_in {
    my $self = shift;
    my $item = shift;
    return $self->{'hidden'}->_contains($item);
}

sub _where {
    my $self = shift;
    return $self->{'location'};
}

sub _desc {
    return 'There does not appear to be anything special about it';
}

sub _describe {
    my $self = shift;
    return join ("\n\t", $self->_desc(), $self->_get_sub_description());
}

sub _process {
    my $self = shift;
    return "Congratulations! You have just made a $self"
}

sub _get_ingredients { return }
sub _get_tools { return }

sub _get_sub_description {
    my $self = shift;
    my @items = $self->_get_equipment();
    my @lines;
    if ( @items ) {
        foreach my $item (@items) {
            push @lines, "\tThe $self has a $item";
            my @items_items = $item->_get_equipment();
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
    return warn "\tYou already have a $item equipped\n" if $self->_has_on($item);
    return warn "\tYou do not have a $item to equip\n" unless $self->_has_in($item);
    $self->_inventory_remove($item);
    $self->_equipment_add($item);
    print "\tYou take the $item out of your pack and place it in your hand\n";
    return 1;
}

sub unequip {
    my $self = shift;
    my $item = shift;
    return warn "\tWhat would you like to unequip?\n" unless $item;
    return warn "\tI do not know what a $item is\n" unless ref $item;
    return warn "\tYou do not have a $item equipped\n" unless $self->_has_on($item);
    $self->_equipment_remove($item);
    $self->_inventory_add($item);
    print "\tYou place the $item back in your pack\n";
    return 1;
}

sub _inventory_add {
    my $self = shift;
    my $item = shift;
    my $added = $self->{'hidden'}->_add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub _inventory_remove {
    my $self = shift;
    my $item = shift;
    my $removed;
    $removed = $self->{'hidden'}->_remove($item) if $self->{'hidden'};
    return $removed;
}

sub _get_inventory{
    my $self = shift;
    my @items = $self->{'hidden'}->_get_all();
    return @items;
}

sub _get_deep_inventory {
    my $self = shift;
    my @items = $self->_get_inventory();
    my @all_items;
    push @all_items, @items;
    foreach my $item (@items) {
        push @all_items, $item->_get_deep_inventory();
    }
    return @all_items;
}

sub _equipment_add {
    my $self = shift;
    my $item = shift;
    my $added = $self->{'visible'}->_add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub _equipment_remove {
    my $self = shift;
    my $item = shift;
    my $removed = $self->{'visible'}->_remove($item);
    return $removed;
}

sub _get_equipment{
    my $self = shift;
    my @items = $self->{'visible'}->_get_all();
    return @items;
}

sub _get_deep_equipment {
    my $self = shift;
    my @items = $self->_get_equipment();
    my @all_items;
    push @all_items, @items;
    foreach my $item (@items) {
        push @all_items, $item->_get_deep_equipment();
    }
    return @all_items;
}

sub _visible_containers {
    my $self = shift;
    my $find = shift;
    return $self if $find == $self;
    my @items = $self->_get_equipment();
    foreach my $item (@items) {
        my @deep_items = $item->_visible_containers($find);
        return (@deep_items, $self) if @deep_items;
    }
    return;
}

sub _has_on_ground {
    my $place = shift;
    my $item = shift;
    my @containers = $place->_visible_containers($item);
    return $containers[1] == $place;
}

sub _get_all {
    my $self = shift;
    my @possessions = ( $self->_get_equipment(), $self->_get_inventory() );
    return @possessions;
}

1;
