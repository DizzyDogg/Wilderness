package Player;

use strict;
use warnings;

use base qw(Character);

sub name {
    my $self = shift;
    my $name = ref($self);
    return lc $name;
}

sub quit { exit }

sub give {
    my ($self, $dungeon, $item, $to, $receiver) = @_;
    return warn "\tGive what to whom?\n" unless $item;
    return warn "\tYou have no $item to give\n" unless $self->has($item);
    return warn "\tGive $item to whom?\n" unless defined $receiver;
    # see if this warn spews on characters that do not exist anywhere
    return warn "\tSorry ... there is no $receiver here\n"
        unless $receiver->where() eq $self->where();

    $self->inventory_remove($item);
    $receiver->inventory_add($item);
    print "\t$self gave the $item to the $receiver\n";
}

sub go {
    my $self = shift;
    my $dungeon = shift;
    my $direction = shift;
    my $here = $self->where();
    return warn "\tGo where?\n"
        unless defined $direction;
    return warn "\tCan't go $direction from here\n"
        unless my $new_room = $self->can_go($direction);
    $self->move_to($new_room);
    $self->look($dungeon);
    return $self;
}

sub inventory {
    my $self = shift;
    my $dungeon = shift;
    my @args = @_;
    my $possessions = $self->get_possessions();
    print "\tYou have ... nothing\n" unless keys %$possessions;
    for my $item ( keys %$possessions ) {
        my $how_many = $possessions->{$item} == 1 ? 'a' : $possessions->{$item};
        $item .= 's' if $how_many ne 'a';
        print "\tYou have $how_many $item\n";
    }
}

sub drop {
    my $self = shift;
    my $dungeon = shift;
    my $what = shift;
    my $here = $self->where();
    return warn "\tYou don't have a $what\n" unless $self->has($what);
    $self->inventory_remove($what);
    $here->item_add($what);
    print "\tYou place the $what gently on the ground\n";
}

sub take {
    my $self = shift;
    my $dungeon = shift;
    my $what = shift;
    my $here = $self->where();
    if ( $here->is_occupied_by($what) ) {
        print "\tSeriously? ... you really want that $what?\n";
        print "\tYou lonely? You want it as a pet or something?\n";
        print "\tProbably not the best idea\n";
        return;
    }
    return warn "\tThere's no $what here\n" unless $here->contains($what);
    $here->item_remove($what);
    $self->inventory_add($what);
    print "\tYou now have the $what\n";
}

sub look {
    my $self = shift;
    my $dungeon = shift;
    my @args = @_;
    my $here = $self->where();

    if (@args) {
        $self->examine($dungeon, @args);
    }
    else {
        print "\tYou are in the $here\n";

        my $items = $here->get_contents();
        foreach my $item ( keys %$items ) {
            my $how_many = $items->{$item} == 1 ? 'a' : $items->{$item};
            $item .= 's' if $how_many ne 'a';
            print "\tYou see $how_many $item on the ground\n";
        }

        my $chars = $here->get_occupants();
        my @not_me = grep { "$_" ne "$self" } keys %$chars;
        print "\tThere is a $_ here\n" foreach @not_me;

        my $exits = $here->available_exits();
        print ("\tThere are exits leading " . join(', ', keys %$exits) . "\n") if $exits;
    }
}

sub examine {
    my $self = shift;
    my $dungeon = shift;
    my $thing = shift;
    my $here = $self->where();
    my $room = $self->can_go($thing);
    return warn "\t$thing leads to the $room\n" if $room;
    return warn "\tYou cannot see a $thing\n" unless ( $self->has($thing) || $here->contains($thing) || $here->is_occupied_by($thing) );
    my $description = $thing->describe();
    return warn "\t$description\n";
}

sub kill { shift->_kill(kill => @_) }

sub slay { shift->_kill(slay => @_) }

sub _kill {
    my $self = shift;
    my $word = shift;
    my $dungeon = shift;
    my ($baddie, $with, $item) = (@_, '', '');
    my $here = $self->where();
    return warn "\t\u${word} who with what?\n" unless $baddie;
    return warn "\t\uWhat will you kill the $baddie with?\n" unless $item;
    return warn "\tYou don't have a $item\n" unless $self->has($item);
    return warn "\tThere is no $baddie here\n" unless $baddie->where() eq $here;

    # now we add its inventory to the room's inventory
    my $loot = $baddie->get_possessions();
    foreach my $item ( keys %$loot ) {
        $here->item_add($item);
        $baddie->inventory_remove($item);
        print "\u\tYou ${word}ed the $baddie\n";
    }
    # and eliminate it
    $here->occupant_remove($baddie);
}

1;
