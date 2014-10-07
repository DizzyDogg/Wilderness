package History;

use strict;
use warnings;

sub new {
    my $class = shift;
    my @args = @_;
    my $self = bless {}, $class;

    $self->{'event'} = [];
    return $self;
}

sub add {
    my $self = shift;
    my $command = shift;
    my $time = time;

    push @{ $self->{'event'} }, {
            'command' => $command,
            'time' => $time,
        };

    # print out the commands:
#    foreach my $row (@{ $self->{'event'} }) {
#        print $row->{'command'}, "\n";
#    }
}

1;
