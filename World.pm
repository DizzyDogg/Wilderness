package World;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

sub initialize {
    my $self = shift;
    $self->{'grid'}->{'0,0,0'} = 'new_world';
    my $z = 0;
    #populate 25 locations with forests
    foreach my $x (-2 .. 2) {
        foreach my $y (-2 .. 2) {
            my $even_coords = join ',', 2*$x, 2*$y, 2*$z;
            my $odd_coords = join ',', 2*$x-1, 2*$y-1, 2*$z;
            my $random = rand();
            $self->{'grid'}->{$even_coords} = Object::new(
                $self->pick_random_biome,
                location => $even_coords,
                world => $self,
            );
        }
    }
    return $self;
}

sub pick_random_biome {
    my $self = shift;
    my $random = rand();
    my $biome = 'Biome::';
    $biome .= $random < .2 ? 'Field' :
             $random < .4 ? 'Desert' :
             'Forest';
    return $biome;
}

1;
