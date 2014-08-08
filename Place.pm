package Place;

use strict;
use warnings;

use base qw(Object);

sub new {
    my $package = shift;
    my $self = {@_};
    $self->{'items'} = Container->new();
    $self->{'occupants'} = Container->new();
    $self->{'fixtures'} = Container->new();
    bless $self, $package;
    return $self;
}

sub fixture_add {
    my $self = shift;
    my $fixture = shift;
    my $added = $self->{'fixtures'}->add($fixture);
    $fixture->{'location'} = $self if $added;
    return $added;
}

sub fixture_remove {
    my $self = shift;
    my $fixture = shift;
    my $removed = $self->{'fixtures'}->remove($fixture);
    delete $fixture->{'location'} if $removed;
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
        || $self->has_fixture($item)
        || $self->has_occupant($item);
}

sub has_item {
    my $self = shift;
    my $item = shift;
    return $self->{'items'}->contains($item);
}

sub has_fixture {
    my $self = shift;
    my $fixture = shift;
    return $self->{'fixtures'}->contains($fixture);
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

sub get_fixtures {
    my $self = shift;
    return $self->{'fixtures'}->get_all();
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
