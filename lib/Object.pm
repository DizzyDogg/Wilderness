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
    $self->{'inventory'} = [];
    $self->{'visible'} = [];
    $self->{'composition'} = [];
    # "constitution" vs "composition"?
    bless $self, $package;
    $self->initialize();
    $self->{'name'} ||= $name;
    $self->{'durability'} ||= $self->durability();
    if ($self->{'attached'}) {
        $self->attach();
        delete $self->{'attached'};
    }
    $self->{'cut_points'} ||= $self->cut_points();
    return $self;
}

sub initialize { return }

sub is_item { return }
sub is_character { return }
sub is_fixture { return }
sub is_player { return }
sub is_place { return }
sub is_biome { return }
sub is_obstruction { return }
sub required_composition { return () }

sub is_attached {
    my $self = shift;
    my $points = $self->{'cut_points'};
    my $attached = ( defined $points && $points > 0 ) ? 1 : 0;
    return $attached;
}

sub is_alive {
    my $self = shift;
    my @comps = $self->composition_get() || ();
    my $alive = (@comps && $comps[0] eq 'health');
    return $alive;
}

#find a way to check the 'required_action' instead of 'is_choppable'
sub is_choppable { return }

sub get_health { return 0 }
sub durability { return 0 }

sub name {
    my $self = shift;
    return $self->{'name'};
}

sub required_sharpness { return 0 }
sub required_mass { return 0 }
sub sharpness { return 0 }
sub mass { return 0 }

sub has_requirements {
    my $self = shift;
    return $self->required_sharpness()
        || $self->required_mass()
        ;
}

sub cut_points {
    my $self = shift;
    my $points = shift;
    $self->{'cut_points'} = $points if defined $points;
    return $self->{'cut_points'};
}

sub get_damage_points {
    my $self = shift;
    my @weapon = shift;
    my $type = 'cut';
    my $amount = 10;
    # my $type2 = 'cut';
    # my $amount2 = 10;
    my $damage = {
        $type => $amount,
        # $type2 => $amount2,
    };
    return $damage;
}

sub apply_damage {
    my $self = shift;
    my $damage = shift;
    foreach my $type (keys $damage) {
        my $apply = "apply_${type}_damage";
        my @hit = $self->$apply($damage->{$type});
        # I actually need to get apply_cut_damage to return the thing that was cut off as well, or the thing that was cut partially off, or that got destroyed.
        print "\tYou cut partially through the $self\n" if $hit[1] eq 'cut';
        print "\tYou damaged the $self\n" if $hit[1] eq 'damaged';
        print "\tCannot apply $type damage\n" unless $hit[1];
    }
}

sub apply_cut_damage {
    my $self = shift;
    my $amount = shift;
    my $cut_points = $self->{'cut_points'};
    my $dur = $self->{'durability'};
    if ( $cut_points ) {
        $cut_points -= $amount;
        if ( $cut_points <= 0 ) {
            my $action = 'cut_off';
            $self->detach();
            $self->{'cut_points'} = 0;
            # $amount = -$cut_points;
            return ($self, $action);
        }
        else {
            $self->{'cut_points'} = $cut_points;
            my $action = 'cut';
            # $amount = 0;
            return ($self, $action);
        }
    }
    my ($first) = $self->composition_get();
    if ( $first ) {
        return $first->apply_cut_damage($amount);
    }

    $self->{'durability'} -= $amount;
    if ( $self->{'durability'} <= 0 ) {
        $self->destroy();
        my $action = 'destroyed';
        if ( $self->{'durability'} < 0 ) {
            # apply_cut_damage(top guy?) not sure how
        }
        return ($self, $action);
    }
    else {
        return 1;
    }
}

sub apply_bludgeon_damage {
    my $self = shift;
    my $amount = shift;
    return $amount unless $amount;
    my @items = $self->composition_get();
    if ( @items ) {
        foreach my $item ( @items ) {
            $item->apply_bludgeon_damage($amount);
        }
        return $amount;
    }
    else {
        my $half = ceil($amount / 2);
        if ( $self->{'durability'} > $half ) {
            $self->{'durability'} -= $half;
            $amount -= $half;
        }
        else {
            $amount -= $self->{'durability'};
            $self->{'durability'} = 0;
            $self->destroy();
        }
        return $amount;
    }
    return print "I made it to the end of bludgeon, what do I do here? I think I blew through the entire object.";
}

# I am not ready to actually implement this yet
sub apply_fire_damage {
    my $self = shift;
    my $amount = shift;
    my @items = $self->composition_get();
    if ( @items ) {
        foreach my $item (@items) {
            $item->apply_fire_damage($amount);
        }
    }
    else {
        $self->{'durability'} -= $amount;
        if ( $self->{'durability'} <= 0 ) {
            # destroy $self
        }
    }
}

sub has_can_damage {
    my $self = shift;
    my $item = shift;
    my @equips = $self->visible_get();
    foreach my $equip (@equips) {
        return $equip if $equip->can_damage($item);
    }
    print "\tYou have nothing equipped strong enough to affect the $item\n";
    return;
}

sub can_damage {
    my $self = shift;
    my $victim = shift;
    my $sharp = $self->sharpness();
    my $mass = $self->mass();
    my $req_sharp = $victim->required_sharpness();
    my $req_mass = $victim->required_mass();
    return $sharp >= $req_sharp && $mass >= $req_mass;
}

# Same as is_here, but skipping characters and their visible.
sub can_reach {
    my $self = shift;
    my $thing = shift;
    my $place = $self->where();
    my @items = $place->get_items();
    push @items, $self->inventory_get(), $self->visible_get();
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

# takes an item from your inventory or equipment and places it on the ground
sub drop {
    my $self = shift;
    my $what = shift;
    my $here = $self->where();
    return print "\tYou don't have a $what\n" unless $self->has($what);
    $self->inventory_remove($what) || $self->visible_remove($what);
    $here->add_item($what);
    print "\tYou place the $what gently on the ground\n" if $self->is_player();
    return $self;
}


# takes an item from container (compositionally) and places it on the ground
sub detach {
    my $self = shift;
    my $container = $self->has_me();
    my $here = $self->where();
    if ( $container->has_in_composition($self) ) {
        $container->composition_remove($self);
    }
    elsif ( $container->has_in_visible($self) ) {
        $container->visible_remove($self);
    }
    else {
        return print "\tThere is no $self to detach\n";
    }
    $here->add_item($self);
    print "\tThe $self falls to the ground\n";
    return $self;
}

sub composition_check {
    my $self = shift;
    my $comp = {};
    my $req_comp = {};
    $comp->{ $_ }++ foreach $self->composition_get();
    $req_comp->{ $_ }++ foreach $self->required_composition();
    my $sufficient = 1;
    foreach my $item (keys %$comp) {
        do { $sufficient = 0; last; } if $comp->{$item} < $req_comp->{$item};
    }
    $self->destroy() unless $sufficient;
    return $sufficient;
}

sub has {
    my $self = shift;
    my $item = shift;
    return ( $self->has_in_visible($item) || $self->has_in_inventory($item) ) ? 1 : 0;
}

sub has_in_inventory {
    my $self = shift;
    my $item = shift;
    return $self->inventory_contains($item);
}

sub has_in_visible {
    my $self = shift;
    my $item = shift;
    return $self->visible_contains($item);
}

sub has_in_composition {
    my $self = shift;
    my $item = shift;
    return $self->composition_contains($item);
}

# the thing that contains me
sub has_me {
    my $self = shift;
    my @containers = $self->get_container_chain();
    return $containers[1];
}

# the room that contains me
sub where {
    my $self = shift;
    my @containers = $self->get_container_chain();
    foreach my $container (@containers) {
        return $container if $container->is_place();
    }
    return;
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
sub get_consumables { return }
sub get_tools { return }

sub get_sub_description {
    my $self = shift;
    my @items = $self->visible_get();
    my @lines;
    if ( @items ) {
        foreach my $item (@items) {
            push @lines, "\tThe $self has a $item";
            my @items_items = $item->visible_get();
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
    return print "\tWhat would you like to equip?\n" unless $item;
    return print "\tI do not know what a $item is\n" unless ref $item;
    return print "\tYou already have a $item equipped\n" if $self->has_in_visible($item);
    return print "\tYou do not have a $item to equip\n" unless $self->has_in_inventory($item);
    my @equipped = $self->visible_get();
    return print "\tSorry, you only have two hands and they are both full\n" if @equipped >= 2;
    $self->inventory_remove($item);
    $self->visible_add($item);
    print "\tYou take the $item out of your pack and place it in your hand\n";
    return 1;
}

sub unequip {
    my $self = shift;
    my $item = shift;
    return print "\tWhat would you like to unequip?\n" unless $item;
    return print "\tI do not know what a $item is\n" unless ref $item;
    return print "\tYou do not have a $item equipped\n" unless $self->has_in_visible($item);
    $self->visible_remove($item);
    $self->inventory_add($item);
    print "\tYou place the $item back in your pack\n";
    return 1;
}

sub inventory_add { _add(@_, 'inventory') }
sub visible_add { _add(@_, 'visible') }
sub composition_add { _add(@_, 'composition') }

sub _add {
    my $self = shift;
    my $item = shift;
    my $container = shift;
    my $added = push @{$self->{$container}}, $item;
    $item->{'location'} = $self if $added;
    return $added;
}

sub inventory_remove { _remove(@_, 'inventory') }
sub visible_remove { _remove(@_, 'visible') }
sub composition_remove {
    my ($self, $item) = @_;
    $self->_remove($item, 'composition');
    $self->composition_check();
}

sub _remove {
    my $self = shift;
    my $item = shift;
    my $container = shift;
    my $removed;
    # foreach (@{$self->{$container}}) {
    #     print "$_\n";
    # }
    foreach my $i ( 0 .. scalar(@{$self->{$container}})-1 ) {
        if ( $self->{$container}->[$i] == $item ) {
            ($removed) = splice(@{$self->{$container}}, $i, 1);
            if ( $removed ) {
                delete $item->{'location'};
                last;
            }
        }
    }
    return $removed;
}

sub inventory_contains { shift->_contains(shift, 'inventory') }
sub visible_contains { shift->_contains(shift, 'visible') }
sub composition_contains { shift->_contains(shift, 'composition') }

sub _contains {
    my $self = shift;
    my $item = shift;
    my $container = shift;
    foreach my $object ( @{$self->{$container}} ) {
        return $object if $object eq $item;
    }
    return 0;
}

sub inventory_get { shift->_get('inventory') }
sub visible_get { shift->_get('visible') }
sub composition_get { shift->_get('composition') }

sub _get {
    my $self = shift;
    my $container = shift;
    my @items = @{$self->{$container}};
    return @items;
}

sub get_deep_visible {
    my $self = shift;
    my @items = $self->visible_get();
    my @all_items;
    push @all_items, @items;
    foreach my $item (@items) {
        push @all_items, $item->get_deep_visible();
    }
    return @all_items;
}

# return a drill down list of containers starting from $self
# and ending with the item (biggest to smallest)
sub visible_containers {
    my $self = shift;
    my $find = shift;
    return $self if $find == $self;
    my @items = $self->visible_get();
    foreach my $item (@items) {
        my @deep_items = $item->visible_containers($find);
        return (@deep_items, $self) if @deep_items;
    }
    return;
}

# return a list of containers starting from $self and ending with the item
# (smallest to biggest)
sub get_container_chain {
    my $self = shift;
    my $container = $self->{'location'};
    if ( ref $container ne 'ARRAY' ) {
        my @chain = $container->get_container_chain();
        return ($self, @chain);
    }
    return ($self, $container);
}

sub has_on_ground {
    my $place = shift;
    my $item = shift;
    my @containers = $place->visible_containers($item);
    return $containers[1] == $place;
}

sub get_all {
    my $self = shift;
    my @possessions = ( $self->visible_get(), $self->inventory_get(), $self->composition_get() );
    return @possessions;
}

sub destroy {
    my $self = shift;
    my @items = $self->get_all();
    my $room = $self->where();
    print "\tThe $self falls apart\n";
    foreach my $item (@items) {
        $room->visible_add($item);
        delete $item->{'cut_points'} if $item->{'cut_points'};
        print "\t\tIts $item falls to the ground\n";
    }
    $self->{'location'}->visible_remove($self);
    undef $self;
    return @items;
}

1;
