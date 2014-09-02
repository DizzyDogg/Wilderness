package Player;

use strict;
use warnings;

use base qw(Character);
use Data::Dumper;
use Item::Knife;
use Item::Map;

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    my $knife = Item::Knife->new();
    $self->equipment_add($knife);
    my $map = Item::Map->new();
    $self->inventory_add($map);
    return $self;
}

sub quit {
    warn "\tI hope you enjoyed your stay in the Wilderness of Awesome !!!\n";
    exit }

sub is_player { return 1 }

sub str2obj {
    my $self = shift;
    my @args = @_;
    my @objs;
    foreach my $str (@args) {
        push @objs, $self->can_see($str) || $str;
    }
    return @objs;
}

sub give {
    my ($self, $item, $to, $receiver) = @_;
    return warn "\tGive what to whom?\n" unless $item;
    return warn "\tYou have no $item to give\n" unless $self->has($item);
    return warn "\tYou must unequip the $item before you can give it away\n" unless $self->has_in($item);
    return warn "\tGive $item to whom?\n" unless ref $receiver;
    # see if this warn spews on characters that do not exist anywhere
    return warn "\tSorry ... there is no $receiver here\n"
        unless ( $self->has($receiver) or ( $receiver->where() eq $self->where() ) );

    $self->{'hidden'}->remove($item);
    $receiver->{'hidden'}->add($item);
    print "\tYou say 'goodbye' as you part with the $item, holding back the tears\n";
    return $self;
}

sub go {
    my $self = shift;
    my $direction = shift;
    my $here = $self->where();
    return warn "\tGo where?\n" unless defined $direction;
    return warn "\tCan't go $direction from here\n"
        unless my $new_room = $here->leads_to($direction);
    $self->move_to($new_room);
    $self->look();
    return $self;
}

sub inventory {
    my $self = shift;
    my @args = @_;
    my @equipment = $self->get_equipment();
    my @inventory = $self->get_inventory();
    my @possessions = ( @equipment, @inventory );
    print "\tYou have ... nothing\n" unless @possessions;
    foreach my $item ( @inventory ) {
        # my $how_many = $possessions->{$item} == 1 ? 'a' : $possessions->{$item};
        # $item .= 's' if $how_many ne 'a';
        print "\tYou have a $item in your pack\n";
    }
    foreach my $item ( @equipment ) {
        # my $how_many = $possessions->{$item} == 1 ? 'a' : $possessions->{$item};
        # $item .= 's' if $how_many ne 'a';
        print "\tYou have a $item in your hand\n";
    }
    return $self;
}

sub chop {
    my $self = shift;
    my $item = shift;
    my $here = $self->where();
    my @containers = $self->visible_containers($item);
    return warn "\tYou cannot see any $item\n" unless $self->can_see($item);
    return warn "\tA $item is not something that can be chopped\n" unless $item->is_choppable();
    return warn "\tThe $item is not in a choppable state\n" if $item->is_item() && $here->has_on_ground($item);
    if ( $self->has_can_damage($item) ) {
        $containers[1]->drop($item);
        return warn "\tYou successfully chopped down the $item\n";
    }
    return warn "\tYou were unable to chop down the $item\n";
}

sub put {
    my $self = shift;
    my ($thing, $in_on, $receiver) = @_;
    return warn "\tPut what on or in what?\n" unless $thing;
    return warn "\tYou need to put $thing on or in something\n" unless $in_on;
    return warn "\tWhat would you like to put $thing $in_on?\n" unless $receiver;
    return warn "\tI do not know what a $thing is\n" unless ref $thing;
    return warn "\tYou can only put things 'on' or 'in' other things\n" unless ($in_on eq 'on' || $in_on eq 'in');
    return warn "\tYou cannot put $thing $in_on itself ... Silly Goose\n"
            .   "\tWhat does that even mean? What would that even look like?\n"
            .   "\tYou know what? No ... Just NO!\n" if $thing eq $receiver;
    return warn "\tI do not know what a $receiver is\n" unless ref $receiver;
    return warn "\tYou do not have a $thing to put $in_on that $receiver\n" unless $self->has($thing);
    return warn "\tYou cannot see a $receiver here\n" unless $self->can_see($receiver);
    my $lost = $self->equipment_remove($thing) || $self->inventory_remove($thing);
    if ( $lost ) {
        $receiver->inventory_add($thing) if $in_on eq 'in';
        $receiver->equipment_add($thing) if $in_on eq 'on';
    }
    print "\tYou carefully put the $thing $in_on the $receiver\n";
    return;
}

sub take {
    my $self = shift;
    my $what = shift;
    my $here = $self->where();
    my @baddies = grep { $_->is_character() } $here->get_items();
    return warn "\tThere's no $what here\n" unless ref $what;
    return warn "\tUmm ... What did you actually expect that to do?\n" if $what->is_player();
    foreach my $baddie (@baddies) {
        return warn "\tUmmm ... That is currently in someone's possession\n" if $baddie->has_on($what);
    }
    if ( $what->is_character() ) {
        print "\tSeriously? ... you really want that $what?\n";
        print "\tYou lonely? You want it as a pet or something?\n";
        print "\tProbably not the best idea\n";
        return;
    }
    return warn "\tThe $what is relatively permanent ... sorry\n" if $what->is_fixture();
    return warn "\tThe $what is not somewhere you can reach\n" unless $self->can_reach($what);
    my $cont = ($here->visible_containers($what))[1];
    if ( $cont && $cont != $here && $what->has_requirements() ) {
        return warn "\tYou are not capable of taking the $what in its current state.\n"
                  . $what->prior_action();
    }
    # return warn "\tYou already have the $what\n" unless
    if ( $cont ) {
        my $removed = $cont->equipment_remove($what) || $cont->remove_item($what);
        return warn "\t$what could not be removed\n" unless $removed;
        my $added = $self->inventory_add($what);
        return warn "\t$what could not be added to your inventory\n" unless $added;
        return warn "\tYou now have the $what\n";
    }
    my $mine = $self->has_on($what) || $self->has_in($what);
    return warn "\tAll the $what you can see is already in your possession\n" if $mine;
    return warn "\tTaking $what did not work\n";
}

sub look {
    my $self = shift;
    my @args = @_;
    my $here = $self->where();

    if (@args) {
        $self->examine(@args);
    }
    else {
        print "\tYou are in the $here\n";

        my @items = $here->get_items();
        foreach my $item ( @items ) {
            next if $item eq $self;
            # my $how_many = $items->{$item} == 1 ? 'a' : $items->{$item};
            # $item .= 's' if $how_many ne 'a';
            print "\tYou see a $item lying on the ground\n" if $item->is_item();
            print "\tThere is a $item here\n" if $item->is_fixture();
            print "\tA $item notices your presence\n" if $item->is_character();
        }
        my $exits = $here->get_exits();
        print "\n";
        foreach my $exit (sort keys $exits) {
            print ("\t\tTo the $exit, you see a $exits->{$exit}[0]\n") if $exits->{$exit}[0];
        }
    }
    return $self;
}

sub examine {
    my $self = shift;
    my $thing = shift;
    my $here = $self->where();
    if ( $thing =~ /up|down|north|south|east|west/ ) {
        my $room = $here->leads_to($thing);
        return warn "\tYou see nothing of interest $thing\n" unless $room;
        print "\tWhen you look $thing, you see the $room\n" if $room;
        return;
    }
    return warn "\tI have no idea what a $thing is\n" unless ref $thing;
    return warn "\tYou cannot see a $thing\n" unless $self->can_see($thing);
    my $description = $thing->describe();
    return warn "\t$description\n";
}

sub say {
    my $self = shift;
    print "\tYou mutter for a bit ... and realize you are talking to youself\n"
          ."\tYou decide that you can indeed still talk\n"
          ."\tBut, you shake your head and refocus your efforts on surviving\n";
    return $self;
}

sub recipe {
    my $self = shift;
    my $product = shift;
    return warn "\tWhich recipe would you like to see?\n" unless $product;
    return warn "\tI don't know what a $product is\n" unless ref $product;
    my @ingredients = $product->get_ingredients();
    my @tools = $product->get_tools();
    return warn "\tA $product is not something you know how to make\n" unless @ingredients;
    my $recipe = "\tMaking a $product requires\n";
    foreach my $ingredient (@ingredients) {
        $recipe .= "\t\tA $ingredient\n";
    }
    $recipe .= "\t\tAs well as access to\n" if @tools;
    foreach my $tool (@tools) {
        $recipe .= "\t\tA $tool\n";
    }
    return warn "$recipe";
}

sub make {
    my $self = shift;
    my $product = shift;
    my $here = $self->where();
    my @ingredients = $product->get_ingredients();
    my @tools = $product->get_tools();
    return warn "\tI don't know what a $product is\n" unless ref $product;
    return warn "\tA $product is not something you know how to make\n" unless @ingredients;
    my @lack;
    foreach my $ingredient (@ingredients) {
        push @lack, $ingredient unless $self->has($ingredient);
    }
    foreach my $tool (@tools) {
        push @lack, $tool unless $self->can_reach($tool);
    }
    my $lack_string = join "\n\t\tA ", @lack;
    if ( @lack ) {
        return warn "\tTo make a $product, you still need\n" . "\t\tA $lack_string\n";
    }
    $product->is_item() ? $self->inventory_add($product) : $here->add_item($product);
    foreach my $ingredient ( @ingredients ) {
        $self->give($ingredient, 'to', $product);
    }
    my $process = $product->process();
    return warn "\t$process\n";
}

sub kill { shift->_kill(kill => @_) }

sub slay { shift->_kill(slay => @_) }

sub _kill {
    my $self = shift;
    my $word = shift;
    my ($baddie, $with, $item) = (@_);
    my $here = $self->where();
    return warn "\t\u${word} who with what?\n" unless ref $baddie;
    return warn "\t\uWhat will you kill the $baddie with?\n" unless ref $item;
    return warn "\tYou don't have a $item\n" unless $self->has($item);
    return warn "\tYou must equip your $item before you may use it\n" unless $self->has_on($item);
    return warn "\tThe $baddie is not something that can be killed\n" unless $baddie->get_health();
    return warn "\tThere is no $baddie here\n" unless $baddie->where() eq $here;
    return warn "\tWhy would you kill the poor innocent $baddie?\n"
                . "\tIt hasn't done anything to anyone\n" unless $baddie->is_character();
    return warn "\tUh ... I am pretty sure suicide is illegal\n"
                . "\tand generally considered bad for your health\n" if $baddie == $self;

    # now we add its inventory to the room's inventory
    print "\u\tYou ${word}ed the $baddie\n";
    print "\tYou watch as the $baddie blinks out of existence\n";
    my @loot = $baddie->get_all();
    print "\t\tYou notice it has left:\n" if @loot;
    foreach my $item ( @loot ) {
        $here->add_item($item);
        warn "\t\tA $item\n";
    }
    # and eliminate it
    $here->remove_item($baddie);
    # delete $baddie; Do I just leave it around with no location?
    return $self;
}

sub die { warn "\tUmmm ... No! That is the OPPOSITE of the point of this game\n" }

1;
