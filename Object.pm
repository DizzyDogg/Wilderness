package Object;

use strict;
use warnings;

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
    '==' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->name() if (ref $a && $a->can('name'));
        $b = $b->name() if (ref $b && $b->can('name'));
        return $a eq $b;
    },
    'eq' => sub {
        my $a = shift;
        my $b = shift;
        $a = $a->name() if (ref $a && $a->can('name'));
        $b = $b->name() if (ref $b && $b->can('name'));
        return $a eq $b;
    };

sub new {
    my $package = shift;
    my $self = {@_};
    my $name = lc((split '::', $package)[-1]);
    (my $path = $package) =~ s/::/\//;
    require "$path.pm";
    $self->{'hidden'} = Container->new();
    $self->{'visible'} = Container->new();
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

#find a way to check the 'required_action' instead of 'is_choppable'
sub is_choppable { return }

sub get_health { undef }

sub name {
    my $self = shift;
    return $self->{'name'};
}

sub required_sharpness { 0 }
sub required_weight { 0 }
sub sharpness { 0 }
sub weight { 0 }

sub has_requirements {
    my $self = shift;
    return $self->required_sharpness()
        || $self->required_weight()
        ;
}

sub has_can_damage {
    my $self = shift;
    my $item = shift;
    my @equips = $self->get_equipment();
    foreach my $equip (@equips) {
        return 1 if $equip->can_damage($item);
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

# Same as is_here, but skipping characters and their equipment.
sub can_reach {
    my $self = shift;
    my $thing = shift;
    my $place = $self->where();
    my @items = $place->get_items();
    push @items, $self->get_inventory(), $self->get_equipment();
    foreach my $item (@items) {
        next if $item->is_character();
        return $item if $item eq $thing;
        my @deep_items = $item->get_deep_equipment();
        foreach my $deep_item (@deep_items) {
            return $deep_item if $deep_item eq $thing;
        }
    }
    return 0;
}

sub drop {
    my $self = shift;
    my $world = shift;
    my $what = shift;
    my $here = $self->where();
    return warn "\tYou don't have a $what\n" unless $self->has($what);
    $self->inventory_remove($what) || $self->equipment_remove($what);
    $here->add_item($what);
    print "\tYou place the $what gently on the ground\n" if $self->is_player();
}

sub has {
    my $self = shift;
    my $item = shift;
    return ( $self->has_on($item) || $self->has_in($item) ) ? 1 : 0;
}

sub has_on {
    my $self = shift;
    my $item = shift;
    return $self->{'visible'}->contains($item);
}

sub has_in {
    my $self = shift;
    my $item = shift;
    return $self->{'hidden'}->contains($item);
}

sub where {
    my $self = shift;
    return $self->{'location'};
}

sub _desc {
    return 'There does not appear to be anything special about it';
}

sub describe {
    my $self = shift;
    return join ("\n\t", $self->_desc(), $self->get_sub_description());
}

sub process {
    my $self = shift;
    return "Congratulations! You have just made a $self"
}

sub get_ingredients { return }
sub get_tools { return }

sub get_sub_description {
    my $self = shift;
    my @items = $self->get_equipment();
    my @lines;
    if ( @items ) {
        foreach my $item (@items) {
            push @lines, "\tThe $self has a $item";
            my @items_items = $item->get_equipment();
            foreach my $items_item (@items_items) {
                push @lines, "\tThe $item has a $items_item";
            }
        }
    }
    return @lines;
}

sub equip {
    my $self = shift;
    my $world = shift;
    my $item = shift;
    return warn "\tWhat would you like to equip?\n" unless $item;
    return warn "\tI do not know what a $item is\n" unless ref $item;
    return warn "\tYou already have a $item equipped\n" if $self->has_on($item);
    return warn "\tYou do not have a $item to equip\n" unless $self->has_in($item);
    $self->inventory_remove($item);
    $self->equipment_add($item);
    print "\tYou take the $item out of your pack and place it in your hand\n";
    return 1;
}

sub unequip {
    my $self = shift;
    my $world = shift;
    my $item = shift;
    return warn "\tWhat would you like to unequip?\n" unless $item;
    return warn "\tI do not know what a $item is\n" unless ref $item;
    return warn "\tYou do not have a $item equipped\n" unless $self->has_on($item);
    $self->equipment_remove($item);
    $self->inventory_add($item);
    print "\tYou place the $item back in your pack\n";
    return 1;
}

sub inventory_add {
    my $self = shift;
    my $item = shift;
    my $added = $self->{'hidden'}->add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub inventory_remove {
    my $self = shift;
    my $item = shift;
    my $removed = $self->{'hidden'}->remove($item) if $self->{'hidden'};
    return $removed;
}

sub get_inventory{
    my $self = shift;
    my @items = $self->{'hidden'}->get_all();
    return @items;
}

sub get_deep_inventory {
    my $self = shift;
    my @items = $self->get_inventory();
    my @all_items;
    push @all_items, @items;
    foreach my $item (@items) {
        push @all_items, $item->get_deep_inventory();
    }
    return @all_items;
}

sub equipment_add {
    my $self = shift;
    my $item = shift;
    my $added = $self->{'visible'}->add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub equipment_remove {
    my $self = shift;
    my $item = shift;
    my $removed = $self->{'visible'}->remove($item);
    return $removed;
}

sub get_equipment{
    my $self = shift;
    my @items = $self->{'visible'}->get_all();
    return @items;
}

sub get_deep_equipment {
    my $self = shift;
    my @items = $self->get_equipment();
    my @all_items;
    push @all_items, @items;
    foreach my $item (@items) {
        push @all_items, $item->get_deep_equipment();
    }
    return @all_items;
}

sub visible_containers {
    my $self = shift;
    my $find = shift;
    my $place = $self->where();
    return $self if $find == $self;
    my @items = $self->get_equipment();
    foreach my $item (@items) {
        my @deep_items = $item->visible_containers();
        return (@deep_items, $self) if @deep_items;
    }
    return 0;
}

sub has_on_ground {
    my $place = shift;
    my $item = shift;
    my @containers = $place->visible_containers($item);
    return $containers[1] == $place;
}

sub get_all {
    my $self = shift;
    my @possessions = ( $self->get_equipment(), $self->get_inventory() );
    return @possessions;
}

1;
