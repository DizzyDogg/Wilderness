package Character;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

sub can_go {
    my $self = shift;
    my $direction = shift;
    my $exits = $self->where()->available_exits();
    return $exits->{$direction};
}

sub inventory_add {
    my $self = shift;
    my $item = shift;
    $self->{'inventory'}{$item}++;
    return $self;
}

sub inventory_remove {
    my $self = shift;
    my $item = shift;
    $self->{'inventory'}{$item}--;
    delete $self->{'inventory'}{$item} unless $self->{'inventory'}{$item};
    return $self;
}

sub get_possessions {
    my $self = shift;
    return $self->{'inventory'};
}

sub has {
    my $self = shift;
    my $item = shift || '';
    return $self->{'inventory'}{$item};
}

sub move_to {
    my $self = shift;
    my $where = shift;
    my $here = $self->where();
    $here->occupant_remove($self);
    $where->occupant_add($self);
    return $self->{'location'} = $where;
}

sub where {
    my $self = shift;
    return $self->{'location'};
}

sub is_in {
    my $self = shift;
    my $place = shift;
    return $place->{'contents'}{$self};
}

1;
