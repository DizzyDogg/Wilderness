package World;

use strict;
use warnings;

use base qw(Object);
use Fixture::Mountain;
use Fixture::Tree;
use Item::Branch;
use Item::Bow;
use Item::Bread;
use Item::Cord;
use Item::Fillet;
use Item::Fire;
use Item::Fish;
use Item::FishingPole;
use Item::Feather;
use Item::HandAxe;
use Item::Hide;
use Item::Knife;
use Item::Log;
use Item::Map;
use Item::Rock;
use Item::Rope;
use Item::Shovel;
use Item::Stick;
use Item::String;
use Item::Twig;
use Item::Venison;
use Item::Wheat;
use Mob::Bird;
use Mob::Deer;
use Place;
use Player;

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
                $place->add_item($it);

            }
            elsif ( $verb eq 'has' ) {
                my $add = ($object[1] || '') eq 'equipped' ? 'equipment_add' : 'inventory_add';
                $it->$add($self->{'things'}{$object[0]}) || die "Cannot add item: $line\n";
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
