package Character;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

sub is_character { return 1 }

sub get_health { return 1 }

sub can_go {
    my $self = shift;
    my $direction = shift;
    my $here = $self->where();
    my $coords = ($self->visible_containers($self))[-1];

    my $exits = $here->get_exits();
    return $exits->{$direction} ? 1 : 0;
}

sub move_to {
    my $self = shift;
    my $where = shift;
    my $here = $self->where();
    $here->remove_item($self);
    $where->add_item($self);
    return $self;
}

sub is_in {
    my $self = shift;
    my $place = shift;
    return $self->{'location'} eq $place;
}

# this is checking all items in the room and ALL their visible equipment (and theirs)
sub can_see {
    my $self = shift;
    my $thing = shift;
    my $here = $self->where();
    my $object = $self->has_on($thing) || $self->has_in($thing) || ($here->visible_containers($thing))[0];
    return $object;
}

1;
