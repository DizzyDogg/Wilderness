package Place;

use strict;
use warnings;

use base qw(Object);

sub _is_place { return 1 }

# I need to figure out a way (in initialize?)
# to add exits between rooms that exist and rooms I am creating
sub _initialize {
    my $self = shift;
    delete $self->{'hidden'};
    return $self;
}

sub _add_item {
    my $self = shift;
    my $item = shift;
    my $added = $self->{'visible'}->_add($item);
    $item->{'location'} = $self if $added;
    return $added;
}

sub _remove_item {
    my $self = shift;
    my $item = shift;
    my $removed = $self->{'visible'}->_remove($item);
    return $removed;
}

sub _has {
    my $self = shift;
    my $item = shift;
    return $self->{'visible'}->_contains($item);
}

sub _get_items {
    my $self = shift;
    return $self->{'visible'}->_get_all();
}

sub _get_exits {
    my $self = shift;
    my $coords = $self->_where();
    my ($x, $y, $z) = split ',', $coords;
    my $north1 = $self->{'world'}->{'grid'}->{join ',', $x, $y+1, $z};
    my $south1 = $self->{'world'}->{'grid'}->{join ',', $x, $y-1, $z};
    my $east1 = $self->{'world'}->{'grid'}->{join ',', $x+1, $y, $z};
    my $west1 = $self->{'world'}->{'grid'}->{join ',', $x-1, $y, $z};
    my $north2 = $self->{'world'}->{'grid'}->{join ',', $x, $y+2, $z};
    my $south2 = $self->{'world'}->{'grid'}->{join ',', $x, $y-2, $z};
    my $east2 = $self->{'world'}->{'grid'}->{join ',', $x+2, $y, $z};
    my $west2 = $self->{'world'}->{'grid'}->{join ',', $x-2, $y, $z};
    my ($north0, $south0, $east0, $west0);
    $north0 = $north1 && $north1->_is_obstruction() ? $north1 : $north2;
    $south0 = $south1 && $south1->_is_obstruction() ? $south1 : $south2;
    $east0 = $east1 && $east1->_is_obstruction() ? $east1 : $east2;
    $west0 = $west1 && $west1->_is_obstruction() ? $west1 : $west2;

    my $exits = {
        north => [$north0, $north1, $north2],
        south => [$south0, $south1, $south2],
        east  => [$east0, $east1, $east2],
        west  => [$west0, $west1, $west2],
    };
    return $exits;
}

sub _leads_to {
    my $self = shift;
    my $direction = shift;
    return $self->_get_exits->{$direction}->[0];
}

1;
