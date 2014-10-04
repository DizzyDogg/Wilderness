package World;

use strict;
use warnings;

use base qw(Object);

use Data::Dumper;

sub initialize {
    my $self = shift;
    my $z = 0;
    foreach my $x (-8 .. 8) {
        foreach my $y (-8 .. 8) {
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
            my $coords = [$x, $y, $z];
            my $scoords = "$x,$y,$z";
            $self->{'grid'}->{$scoords} = Object::new(
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
