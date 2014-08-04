package Place;

use strict;
use warnings;

use base qw(Object);

sub item_add {
    my $self = shift;
    my $item = shift;
    return ++$self->{'contents'}{$item};
}

sub item_remove {
    my $self = shift;
    my $item = shift;
    $self->{'contents'}{$item}--;
    delete $self->{'contents'}{$item} unless $self->{'contents'}{$item};
    return $self;
}

sub contains {
    my $self = shift;
    my $item = shift;
    return $self->{'contents'}{$item};
}

sub get_contents {
    my $self = shift;
    return $self->{'contents'};
}

sub exit_add {
    my $self = shift;
    my $direction = shift;
    my $leads_to = shift;
    $self->{'exits'}{$direction} = $leads_to;
    return $self;
}

sub available_exits {
    my $self = shift;
    return $self->{'exits'};
}

sub enter {
    my $self = shift;
    my $who = shift;
    return ++$self->{'occupants'}{$who};
}

sub occupant_add {
    my $self = shift;
    my $occupant = shift;
    $self->{'occupants'}{"$occupant"} = $occupant;
    $occupant->{'location'} = $self;
}

sub occupant_remove {
    my $self = shift;
    my $occupant = shift;
    delete $self->{'occupants'}{"$occupant"};
    delete $occupant->{'location'};
}

sub is_occupied_by {
    my $self = shift;
    my $mob = shift;
    return $self->{'occupants'}{$mob};
}

sub get_occupants {
    my $self = shift;
    return $self->{'occupants'};
}

1;
