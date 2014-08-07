package Place;

use strict;
use warnings;

use base qw(Object);

sub new {
    my $package = shift;
    my $self = {@_};
    $self->{'items'} = Container->new();
    $self->{'occupants'} = Container->new();
    $self->{'objects'} = Container->new();
    bless $self, $package;
    return $self;
}

sub object_add {
    my $self = shift;
    my $object = shift;
    my $added = $self->{'objects'}->add($object);
    $object->{'location'} = $self if $added;
    return $added;
}

sub object_remove {
    my $self = shift;
    my $object = shift;
    my $removed = $self->{'objects'}->remove($object);
    delete $object->{'location'} if $removed;
    return $removed;
}

sub item_add {
    my $self = shift;
    my $item = shift;
    my $added = $self->{'items'}->add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub item_remove {
    my $self = shift;
    my $item = shift;
    my $removed = $self->{'items'}->remove($item);
    delete $item->{'location'} if $removed;
    return $removed;
}

sub occupant_add {
    my $self = shift;
    my $occupant = shift;
    my $added = $self->{'occupants'}->add($occupant);
    $occupant->{'location'} = $self if $added;
    return $added;
}

sub occupant_remove {
    my $self = shift;
    my $occupant = shift;
    my $removed = $self->{'occupants'}->remove($occupant);
    delete $occupant->{'location'} if $removed;
    return $removed;
}

sub has {
    my $self = shift;
    my $item = shift;
    return $self->has_item($item)
        || $self->has_object($item)
        || $self->has_occupant($item);
}

sub has_item {
    my $self = shift;
    my $item = shift;
    return $self->{'items'}->contains($item);
}

sub has_object {
    my $self = shift;
    my $object = shift;
    return $self->{'objects'}->contains($object);
}

sub has_occupant {
    my $self = shift;
    my $occupant = shift;
    return $self->{'occupants'}->contains($occupant);
}

sub get_items {
    my $self = shift;
    return $self->{'items'}->get_all();
}

sub get_objects {
    my $self = shift;
    return $self->{'objects'}->get_all();
}

sub get_occupants {
    my $self = shift;
    return $self->{'occupants'}->get_all();
}

sub exit_add {
    my $self = shift;
    my $direction = shift;
    my $leads_to = shift;
    $self->{'exits'}{$direction} = $leads_to;
    return $self;
}

sub exit_remove {
    my $self = shift;
    my $direction = shift;
    delete $self->{'exits'}{$direction};
    return $self;
}

sub get_exits {
    my $self = shift;
    return $self->{'exits'};
}

sub leads_to {
    my $self = shift;
    my $direction = shift;
    return $self->{'exits'}{$direction};
}

1;
