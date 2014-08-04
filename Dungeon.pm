package Dungeon;

use strict;
use warnings;

use base qw(Object);
use Mob::Troll;
use Mob::Thief;
use Mob::Bird;
use Place;
use Player;
use Item::Jewel;
use Item::Sword;
use Item::Lamp;
use Item::Knife;
use Item::Map;
use Item::Shovel;
use Item::Statue;

use Data::Dumper;

sub initialize {
    my $self = shift;
    my $file = 'dungeon';
    # my $file = shift;
    $self->{things} = {};

    open my $fh, '<', $file or die "Can't open $file: $!\n";
    while ( <$fh> ) {
        my $line = $_;
        # print "my line is: $line";
        my ($subject, $verb, @object) = split /\s+/, $line;
        die "Unknown line in dungeon: $line" unless @object;

        # NOTE: all 'things' must declare their thingness FIRST in the dungeon file
        # They may gain an inventory, location, etc. after that.
        if ( $verb eq 'is' && $object[0] ne 'in') {
            $self->{'things'}{$subject} = $object[0]->new(name => $subject);
            $self->{'things'}{$subject}{'name'} = $subject;
        }
        else {
            my $it = $self->{'things'}{$subject};
            if ( $verb eq 'is' && $object[0] eq 'in' ) {
                my $place = $self->{'things'}{$object[1]};
                $place->occupant_add($it);

            }
            elsif ( $verb eq 'contains' ) {
                # my $item = $self->{'things'}{$object[0]};
                # die Dumper $self;
                $it->item_add($object[0]) || die "Cannot populate room contents: $line\n";
            }
            elsif ( $verb eq 'has' ) {
                $it->inventory_add($object[0]) || die "Cannot populate inventory: $line\n";
            }
            elsif ( $verb eq 'goes' ) {
                $it->exit_add($object[0], $self->{'things'}{$object[2]}) || die "Cannot populate exits: $line\n";
            }
            else {
                die "Unknown line in dungeon: $line";
            }
        }
    }
}

1;
