package Place;

use strict;
use warnings;

use base qw(Object);

sub is_place { return 1 }

# I need to figure out a way (in initialize?)
# to add exits between rooms that exist and rooms I am creating
sub initialize {
    my $self = shift;
    delete $self->{'hidden'};
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

sub get_exits {
    my $self = shift;
    my $coords = $self->where();
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
    $north0 = $north1 && $north1->is_obstruction() ? $north1 : $north2;
    $south0 = $south1 && $south1->is_obstruction() ? $south1 : $south2;
    $east0 = $east1 && $east1->is_obstruction() ? $east1 : $east2;
    $west0 = $west1 && $west1->is_obstruction() ? $west1 : $west2;

    my $exits = {
        north => [$north0, $north1, $north2],
        south => [$south0, $south1, $south2],
        east  => [$east0, $east1, $east2],
        west  => [$west0, $west1, $west2],
    };
    return $exits;
}

sub leads_to {
    my $self = shift;
    my $direction = shift;
    return $self->get_exits->{$direction}->[0];
}

1;
