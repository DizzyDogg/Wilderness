package Character;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

sub can_go {
    my $self = shift;
    my $direction = shift;
    my $here = $self->where();
    my $exits = $here->get_exits();
    return $exits->{$direction} ? 1: 0;
}

sub move_to {
    my $self = shift;
    my $where = shift;
    my $here = $self->where();
    $here->occupant_remove($self);
    $where->occupant_add($self);
    return $self->{'location'} = $where;
}

sub is_in {
    my $self = shift;
    my $place = shift;
    return $self->{'location'} eq $place;
}

sub equip {
    my $self = shift;
    my $item = shift;
    $self->inventory_remove($item);
    $self->equipment_add($item);
}

sub unequip {
    my $self = shift;
    my $item = shift;
    $self->equipment_remove($item);
    $self->inventory_add($item);
}

sub inventory_remove {
    my $self = shift;
    my $item = shift;
    $self->{'hidden'}->remove($item);
}

sub equipment_add {
    my $self = shift;
    my $item = shift;
    $self->{'visible'}->add($item);
}

sub equipment_remove {
    my $self = shift;
    my $item = shift;
    $self->{'visible'}->remove($item);
}

sub get_equipment{
    my $self = shift;
    my @items = $self->{'visible'}->get_all();
    return @items;
}

sub get_inventory{
    my $self = shift;
    my @items = $self->{'hidden'}->get_all();
    return @items;
}

sub get_all {
    my $self = shift;
    my @possessions = ( $self->get_equipment(), $self->get_inventory() );
    return @possessions;
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
1;
