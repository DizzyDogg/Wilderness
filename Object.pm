package Object;

use strict;
use warnings;

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
        my $self = shift;
        my $self2 = shift;
        return $self->name() eq $self2->name();
    },
    'eq' => sub {
        my $self = shift;
        my $self2 = shift;
        return $self->name() eq $self2->name();
    };

sub new {
    my $package = shift;
    my $self = {@_};
    $self->{'hidden'} = Container->new();
    $self->{'visible'} = Container->new();
    bless $self, $package;
    return $self;
}

sub name {
    my $self = shift;
    return $self->{'name'};
}

sub describe {
    my $self = shift;
    return "There does not appear to be anything special about it";
}

1;
