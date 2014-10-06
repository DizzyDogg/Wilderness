package Player;

use strict;
use warnings;

use base qw(Character);
use Data::Dumper;
use Item::Knife;
use Item::Map;

sub is_player { return 1 }

sub mass { return 75 }

sub initialize {
    my $self = shift;
    $self->SUPER::initialize();
    $self->visible_add( Item::Knife->new() );
    $self->inventory_add( Item::Map->new() );
    return $self;
}

sub str2obj {
    my $self = shift;
    my @args = @_;
    my @objs;
    foreach my $str (@args) {
        push @objs, $self->can_see($str) || $str;
    }
    return @objs;
}

my %verbs = (
    attack  => 'attack',
    build   => 'make',
    chop    => 'chop',
    craft   => 'make',
    create  => 'make',
    die     => 'die',
    equip   => 'equip',
    examine => 'examine',
    exit    => 'go',
    get     => 'take',
    give    => 'give',
    go      => 'go',
    grab    => 'take',
    have    => 'inventory',
    help    => 'help',
    inventory => 'inventory',
    kill    => 'kill',
    look    => 'look',
    make    => 'make',
    move    => 'go',
    pickup  => 'take',
    place   => 'put',
    put     => 'put',
    recipe  => 'recipe',
    retrieve => 'take',
    say     => 'say',
    slay    => 'slay',
    speak   => 'say',
    take    => 'take',
    talk    => 'say',
    travel  => 'go',
    unequip => 'unequip',
    quit    => 'quit',
    walk    => 'go',
);

sub get_verb {
    my $self = shift;
    my $verb = shift;
    my $command = $verbs{$verb};
    return $command;
}

sub help {
    print "\nHere is a list of ALL the commands this prompt will recognize\n";
    my @commands = sort keys %verbs;
    while (@commands) {
        my @cmds = splice @commands, 0, 7;
        my $line = join "\t", @cmds;
        print "\t$line\n";
    }
}

sub quit {
    print "\tQuitters NEVER win, and winners NEVER quit...\n",
        "\tBut, if you never quit AND never win ... then you are just a loser.\n",
        "\tYou LOSE! I hope you have better luck in the REAL World.\n";
    exit }

sub give {
    my ($self, $item, $to, $receiver) = @_;
    return print "\tGive what to whom?\n" unless $item;
    ($item) = $self->str2obj($item) unless ref $item;
    return print "\tI do not know what a $item is\n" unless ref $item;
    return print "\tYou have no $item to give\n" unless $self->has($item);
    return print "\tGive $item to whom?\n" unless ref $receiver;
    # see if this print spews on characters that do not exist anywhere
    return print "\tSorry ... there is no $receiver here\n"
        unless ( $self->has($receiver) or ( $receiver->where() eq $self->where() ) );

    $self->inventory_remove($item);
    $receiver->inventory_add($item);
    print "\tYou say 'goodbye' as you part with the $item, holding back the tears\n";
    return $self;
}

sub go {
    my $self = shift;
    my $direction = shift;
    my $here = $self->where();
    return print "\tGo where?\n" unless defined $direction;
    my $new_room = $here->leads_to($direction);
    return print "\tCan't go $direction from here\n"
        unless $new_room;
    return print "\tYou can't go through the $new_room\n" if $new_room->is_obstruction();
    $self->move_to($new_room);
    $self->look();
    return $self;
}

sub inventory {
    my $self = shift;
    my @args = @_;
    my @visible = $self->visible_get();
    my @inventory = $self->inventory_get();
    my @possessions = ( @visible, @inventory );
    print "\tYou have ... nothing\n" unless @possessions;
    foreach my $item ( @inventory ) {
        # my $how_many = $possessions->{$item} == 1 ? 'a' : $possessions->{$item};
        # $item .= 's' if $how_many ne 'a';
        print "\tYou have a $item in your pack\n";
    }
    foreach my $item ( @visible ) {
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
    my @containers = $here->visible_containers($item);
    return print "\tYou cannot see any $item\n" unless $self->can_see($item);
    return print "\tA $item is not something that can be chopped\n" unless $item->is_choppable();
    return print "\tThe $item is not in a choppable state\n" if $item->is_item() && $here->has_on_ground($item);
    if ( $self->has_can_damage($item) ) {
        $containers[1]->drop($item);
        return print "\tYou successfully chopped down the $item\n";
    }
    return print "\tYou were unable to chop down the $item\n";
}

sub put {
    my $self = shift;
    my ($thing, $in_on, $receiver) = @_;
    return print "\tPut what on or in what?\n" unless $thing;
    return print "\tYou need to put $thing on or in something\n" unless $in_on;
    return print "\tWhat would you like to put $thing $in_on?\n" unless $receiver;
    return print "\tI do not know what a $thing is\n" unless ref $thing;
    return print "\tYou can only put things 'on' or 'in' other things\n" unless ($in_on eq 'on' || $in_on eq 'in');
    return print "\tYou cannot put $thing $in_on itself ... Silly Goose\n"
            .   "\tWhat does that even mean? What would that even look like?\n"
            .   "\tYou know what? No ... Just NO!\n" if $thing eq $receiver;
    return print "\tI do not know what a $receiver is\n" unless ref $receiver;
    return print "\tYou do not have a $thing to put $in_on that $receiver\n" unless $self->has($thing);
    return print "\tYou cannot see a $receiver here\n" unless $self->can_see($receiver);
    my $lost = $self->visible_remove($thing) || $self->inventory_remove($thing);
    if ( $lost ) {
        $receiver->inventory_add($thing) if $in_on eq 'in';
        $receiver->visible_add($thing) if $in_on eq 'on';
    }
    print "\tYou carefully put the $thing $in_on the $receiver\n";
    return;
}

sub take {
    my $self = shift;
    my $what = shift;
    my $here = $self->where();
    my @baddies = grep { $_->is_character() } $here->get_items();
    return print "\tThere's no $what here\n" unless ref $what;
    return print "\tUmm ... What did you actually expect that to do?\n" if $what->is_player();
    foreach my $baddie (@baddies) {
        return print "\tUmmm ... That is currently in someone's possession\n" if $baddie->has_in_visible($what);
    }
    if ( $what->is_character() ) {
        print "\tSeriously? ... you really want that $what?\n";
        print "\tYou lonely? You want it as a pet or something?\n";
        print "\tProbably not the best idea\n";
        return;
    }
    return print "\tThe $what is relatively permanent ... sorry\n" if $what->is_fixture();
    return print "\tThe $what is not somewhere you can reach\n" unless $self->can_reach($what);
    my $cont = $what->has_me();
    if ( $cont && $cont != $here && $what->has_requirements() ) {
        return print "\tYou are not capable of taking the $what in its current state.\n"
                  . $what->prior_action();
    }
    # return print "\tYou already have the $what\n" unless
    if ( $cont ) {
        my $removed = $cont->visible_remove($what);
        return print "\t$what could not be removed\n" unless $removed;
        my $added = $self->inventory_add($what);
        return print "\t$what could not be added to your inventory\n" unless $added;
        return print "\tYou now have the $what\n";
    }
    my $mine = $self->has_in_visible($what) || $self->has_in_inventory($what);
    return print "\tAll the $what you can see is already in your possession\n" if $mine;
    return print "\tTaking $what did not work\n";
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
            if ( $item->is_character() ) {
                if ( $item->is_alive() ) {
                    print "\tA $item notices your presence\n";
                }
                else {
                    print "\tYou see a $item lying on the ground\n";
                }
            }
            elsif ( $item->is_attached() ) {
                print "\tThere is a $item here\n";
            }
            else {
                print "\tYou see a $item lying on the ground\n";
            }
        }
        my $exits = $here->get_exits() if $here->is_place();
        print "\n";
        foreach my $exit (sort keys %$exits) {
            print ("\t\tTo the $exit, you see a $exits->{$exit}[0]\n") if $exits->{$exit}[0];
        }
    }
    return $self;
}

sub examine {
    my $self = shift;
    my $thing = shift;
    return print "\tWhat would you like to examine?\n" unless $thing;
    my $here = $self->where();
    if ( $thing =~ /up|down|north|south|east|west/ ) {
        my $room = $here->leads_to($thing);
        return print "\tYou see nothing of interest $thing\n" unless $room;
        print "\tWhen you look $thing, you see the $room\n" if $room;
        return;
    }
    return print "\tI have no idea what a $thing is\n" unless ref $thing;
    return print "\tYou cannot see a $thing\n" unless $self->can_see($thing);
    my $description = $thing->describe();
    return print "\t$description\n";
}

sub say {
    my $self = shift;
    print "\tYou mutter for a bit ... and realize you are talking to youself\n"
        . "\tYou decide that you can indeed still talk\n"
        . "\tBut, you shake your head and refocus your efforts on surviving\n";
    return $self;
}

sub attack {
    my $self = shift;
    my $victim = shift;
    return print "\tAttack what?\n" unless ref $victim;
    my @equipped = $self->visible_get();
    return print "\tYou should really equip something before attempting this\n" unless @equipped;
    foreach my $weapon (@equipped) {
        print "\tYou swing your $weapon at the $victim\n";
        my $damage = $self->get_damage_points($weapon);
        $victim->apply_damage($damage);
        # print something about current health of $victim
    }
}

sub kill { shift->_kill(kill => @_) }

sub slay { shift->_kill(slay => @_) }

sub _kill {
    my $self = shift;
    my $word = shift;
    my ($baddie, $with, $item) = (@_);
    my $here = $self->where();
    return print "\t\u${word} who with what?\n" unless ref $baddie;
    return print "\t\uWhat will you kill the $baddie with?\n" unless ref $item;
    return print "\tYou don't have a $item\n" unless $self->has($item);
    return print "\tYou must equip your $item before you may use it\n" unless $self->has_in_visible($item);
    return print "\tThe $baddie is not something that can be killed\n" unless $baddie->is_alive();
    return print "\tThere is no $baddie here\n" unless $baddie->where() eq $here;
    return print "\tWhy would you kill the poor innocent $baddie?\n"
              . "\tIt hasn't done anything to anyone\n" unless $baddie->is_character();
    return print "\tUh ... I am pretty sure suicide is illegal\n"
              . "\tand generally considered bad for your health\n" if $baddie == $self;

    # now we add its inventory to the room's inventory
    print "\u\tYou ${word}ed the $baddie\n";
    print "\tYou watch as the $baddie blinks out of existence\n";
    my @loot = $baddie->destroy();
    print "\t\tYou notice it has left:\n" if @loot;
    foreach my $item ( @loot ) {
        $here->add_item($item);
        print "\t\tA $item\n";
    }
    return $self;
}

sub die { print "\tUmmm ... No! That is the OPPOSITE of the point of this game\n" }

1;
