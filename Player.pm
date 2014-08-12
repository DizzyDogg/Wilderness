package Player;

use strict;
use warnings;

use base qw(Character);
use Data::Dumper;

sub name {
    my $self = shift;
    my $name = ref($self);
    return lc $name;
}

sub quit {
    warn "\tI hope you enjoyed your stay in the Wilderness of Awesome !!!\n";
    exit }

sub give {
    my ($self, $world, $item, $to, $receiver) = @_;
    return warn "\tGive what to whom?\n" unless $item;
    return warn "\tYou have no $item to give\n" unless $self->has($item);
    return warn "\tYou must unequip the $item before you can give it away\n" unless $self->has_in($item);
    return warn "\tGive $item to whom?\n" unless ref $receiver;
    # see if this warn spews on characters that do not exist anywhere
    return warn "\tSorry ... there is no $receiver here\n"
        unless $receiver->where() eq $self->where();

    $self->{'hidden'}->remove($item);
    $receiver->{'hidden'}->add($item);
    print "\t$self gave the $item to the $receiver\n";
}

sub go {
    my $self = shift;
    my $world = shift;
    my $direction = shift;
    my $here = $self->where();
    return warn "\tGo where?\n"
        unless defined $direction;
    return warn "\tCan't go $direction from here\n"
        unless my $new_room = $here->leads_to($direction);
    $self->move_to($new_room);
    $self->look($world);
    return $self;
}

sub inventory {
    my $self = shift;
    my $world = shift;
    my @args = @_;
    my @equipment = $self->get_equipment();
    my @inventory = $self->get_inventory();
    my @possessions = ( @equipment, @inventory );
    print "\tYou have ... nothing\n" unless @possessions;
    foreach my $item ( @inventory ) {
        # my $how_many = $possessions->{$item} == 1 ? 'a' : $possessions->{$item};
        # $item .= 's' if $how_many ne 'a';
        print "\tYou have a $item\n";
    }
    foreach my $item ( @equipment ) {
        # my $how_many = $possessions->{$item} == 1 ? 'a' : $possessions->{$item};
        # $item .= 's' if $how_many ne 'a';
        print "\tYou have a $item equipped\n";
    }
}

sub drop {
    my $self = shift;
    my $world = shift;
    my $what = shift;
    my $here = $self->where();
    return warn "\tYou don't have a $what\n" unless $self->has($what);
    $self->{'hidden'}->remove($what);
    $here->item_add($what);
    print "\tYou place the $what gently on the ground\n";
}

sub take {
    my $self = shift;
    my $world = shift;
    my $what = shift;
    my $here = $self->where();
    return warn "\tI don't know what a $what is\n" unless ref $what;
    if ( $here->has_occupant($what) ) {
        print "\tSeriously? ... you really want that $what?\n";
        print "\tYou lonely? You want it as a pet or something?\n";
        print "\tProbably not the best idea\n";
        return;
    }
    if ( $here->has_fixture($what) ) {
        return warn "\tThe $what is relatively permanent ... sorry\n";
    }
    return warn "\tThere's no $what here\n" unless $here->has_item($what);
    $here->item_remove($what);
    $self->inventory_add($what);
    print "\tYou now have the $what\n";
}

sub look {
    my $self = shift;
    my $world = shift;
    my @args = @_;
    my $here = $self->where();

    if (@args) {
        $self->examine($world, @args);
    }
    else {
        print "\tYou are in the $here\n";

        my @items = $here->get_items();
        foreach my $item ( @items ) {
            # my $how_many = $items->{$item} == 1 ? 'a' : $items->{$item};
            # $item .= 's' if $how_many ne 'a';
            print "\tYou see a $item lying on the ground\n";
        }
        my @fixtures = $here->get_fixtures();
        foreach my $fixture ( @fixtures) {
            print "\tThere is a $fixture here\n";
        }

        my @chars = $here->get_occupants();
        my @not_me = grep { "$_" ne "$self" } @chars;
        print "\tA $_ notices your presence\n" foreach @not_me;

        my $exits = $here->get_exits();
        print ("\tThere are exits leading " . join(', ', keys %$exits) . "\n") if $exits;
    }
}

sub examine {
    my $self = shift;
    my $world = shift;
    my $thing = shift;
    my $here = $self->where();
    if ( $thing =~ /up|down|north|south|east|west/ ) {
        my $room = $here->leads_to($thing);
        return warn "\tYou see nothing of interest $thing\n" unless $room;
        print "\tWhen you look $thing, you see the $room\n" if $room;
        return;
    }
    return warn "\tI have no idea what a $thing is\n" unless ref $thing;
    return warn "\tYou cannot see a $thing\n" unless ( $self->has($thing) || $here->has($thing) );
    my $description = $thing->describe();
    return warn "\t$description\n";
}

sub say {
    my $self = shift;
    print "\tYou mutter for a bit ... and realize you are talking to youself\n"
          ."\tYou decide that you can indeed still talk\n"
          ."\tBut, you shake your head and refocus your efforts on surviving\n";
}

sub kill { shift->_kill(kill => @_) }

sub slay { shift->_kill(slay => @_) }

sub _kill {
    my $self = shift;
    my $word = shift;
    my $world = shift;
    my ($baddie, $with, $item) = (@_);
    my $here = $self->where();
    return warn "\t\u${word} who with what?\n" unless ref $baddie;
    return warn "\t\uWhat will you kill the $baddie with?\n" unless ref $item;
    return warn "\tYou don't have a $item\n" unless $self->has($item);
    return warn "\t$baddie is not something that can be killed\n" unless $baddie->get_health();
    return warn "\tThere is no $baddie here\n" unless $baddie->where() eq $here;
    return warn "\tWhy would you kill the poor innocent $baddie?\n"
                . "\tIt hasn't done anything to anyone\n" unless $here->has_occupant($baddie);
    return warn "\tUh ... I am pretty sure suicide is illegal\n"
                . "\tand generally considered bad for your health\n" if $baddie == $self;

    # now we add its inventory to the room's inventory
    my @loot = $baddie->get_all();
    foreach my $item ( @loot ) {
        $here->item_add($item);
    }
    # and eliminate it
    $here->occupant_remove($baddie);
    $world->delete($baddie);
    print "\u\tYou ${word}ed the $baddie\n";
}

1;
