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
    '==' => sub {
        my $a = shift;
        my $b = shift;
        return 0 unless ( ref $a && ref $b && $a->can('name') && $b->can('name') );
        return $a->name() eq $b->name();
    },
    'eq' => sub {
        my $a = shift;
        my $b = shift;
        return 0 unless ( ref $a && ref $b && $a->can('name') && $b->can('name') );
        return $a->name() eq $b->name();
    };

sub new {
    my $package = shift;
    my $self = {@_};
    $self->{'hidden'} = Container->new();
    $self->{'visible'} = Container->new();
    bless $self, $package;
    return $self;
}

sub get_health { undef }

sub name {
    my $self = shift;
    return $self->{'name'};
}

sub where {
    my $self = shift;
    return $self->{'location'};
}

my $default_description = 'There does not appear to be anything special about it';

sub describe {
    my $self = shift;
    return $default_description;
}

sub inventory_add {
    my $self = shift;
    my $item = shift;
    $self->{'hidden'}->add($item);
}

1;
