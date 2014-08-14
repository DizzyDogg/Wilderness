package Place;

use strict;
use warnings;

use base qw(Object);

sub new {
    my $package = shift;
    my $self = {@_};
    $self->{'visible'} = Container->new();
    bless $self, $package;
    return $self;
}

sub add_item {
    my $self = shift;
    my $item = shift;
    my $added = $self->{'visible'}->add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub remove_item {
    my $self = shift;
    my $item = shift;
    my $removed = $self->{'visible'}->remove($item);
    delete $item->{'location'} if $removed;
    return $removed;
}

sub has {
    my $self = shift;
    my $item = shift;
    return $self->{'visible'}->contains($item);
}

sub get_items {
    my $self = shift;
    return $self->{'visible'}->get_all();
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
