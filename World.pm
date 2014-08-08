package World;

use strict;
use warnings;

use base qw(Object);
use Mob::Deer;
use Mob::Bird;
use Spawner::Tree;
use Spawner::Mountain;
use Place;
use Player;
use Item::Fish;
use Item::Feather;
use Item::Rock;
use Item::String;
use Item::Knife;
use Item::Rope;
use Item::Shovel;
use Item::Bread;
use Item::FishingPole;
use Item::Stick;
use Item::Twig;
use Item::Log;
use Item::Wheat;
use Item::Venison;

use Data::Dumper;

sub initialize {
    my $self = shift;
    my $file = 'startup';
    # my $file = shift;
    $self->{things} = {};

    open my $fh, '<', $file or die "Can't open $file: $!\n";
    while ( <$fh> ) {
        my $line = $_;
        # print "my line is: $line";
        my ($subject, $verb, @object) = split /\s+/, $line;
        die "Unknown line in startup $line" unless @object;

        # NOTE: all 'things' must declare their thingness FIRST in the startup file
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
                $it->item_add($self->{'things'}{$object[0]}) || die "Cannot populate room items: $line\n";
            }
            elsif ( $verb eq 'inhabits' ) {
                my $place = $self->{'things'}{$object[0]};
                $place->fixture_add($it) || die "Cannot populate room fixtures: $line\n";
            }
            elsif ( $verb eq 'has' ) {
                $it->inventory_add($self->{'things'}{$object[0]}) || die "Cannot populate inventory: $line\n";
            }
            elsif ( $verb eq 'goes' ) {
                $it->exit_add($object[0], $self->{'things'}{$object[2]}) || die "Cannot populate exits: $line\n";
            }
            else {
                die "Unknown line in startup $line";
            }
        }
    }
}

sub delete {
    my $self = shift;
    my $thing = shift;
    delete $self->{'things'}{$thing};
}

1;
