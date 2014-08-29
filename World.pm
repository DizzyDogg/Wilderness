package World;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

sub initialize {
    my $self = shift;
    $self->{'grid'}->{'0,0,0'} = 'new_world';
    my ($x, $y, $z) = (0, 0, 0);
    #populate 25 locations with forests
    foreach $x (-2 .. 2) {
        foreach $y (-2 .. 2) {
            my $even_coords = join ',', 2*$x, 2*$y, 2*$z;
            my $odd_coords = join ',', 2*$x-1, 2*$y-1, 2*$z;
            $self->{'grid'}->{$even_coords} = Object::new('Biome::Forest', location => $even_coords);
        }
    }
    return $self;
}

1;
