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
    foreach my $x (-8 .. 8) {
        foreach my $y (-8 .. 8) {
            # my $even_coords = join ',', 2*$x, 2*$y, 2*$z;
            # my $odd_coords = join ',', 2*$x-1, 2*$y-1, 2*$z;

            my $location = $x%2 + $y%2;
            my $biome;
            if ( abs $x > 6 || abs $y > 6 ) {
                $biome = 'Obstruction::Ocean';
            }
            elsif ( abs $x == 6 || abs $y == 6 ) {
                $biome = 'Biome::Beach';
            }
            else {
                $biome = $location == 0 ? $self->pick_random_biome() : next;
            }
            my $coords = join ',', $x, $y, $z;
            $self->{'grid'}->{$coords} = Object::new(
                $biome,
                location => $coords,
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
             $random < .5 ? 'Desert' :
             'Forest';
    return $biome;
}

1;
