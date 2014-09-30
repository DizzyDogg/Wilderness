package Character;

use strict;
use warnings;

use base qw(Object);
use Health;
use Item::Bone;
use Item::Meat;
use Item::Hide;
use RecipeBook;

use Data::Dumper;

sub is_character { return 1 }
sub required_composition { return qw{health} }

sub initialize {
    my $self = shift;
    # create and add each individual meat and hide and bone, make carcass and define living animals
    $self->SUPER::initialize();
    $self->composition_add( Health->new(durability => $self->mass()) );
    $self->composition_add( Item::Meat->new(quantity => int($self->mass() / 10)) );
    $self->composition_add( Item::Hide->new(quantity => int($self->mass() / 15)) );
    $self->composition_add( Item::Bone->new(quantity => int($self->mass() / 20)) );
    return $self;
}

my $recipe_book = RecipeBook->new();

sub can_go {
    my $self = shift;
    my $direction = shift;
    my $here = $self->where();
    my $coords = ($self->visible_containers($self))[-1];

    my $exits = $here->get_exits();
    return $exits->{$direction} ? 1 : 0;
}

sub move_to {
    my $self = shift;
    my $where = shift;
    my $here = $self->where();
    $here->visible_remove($self);
    $where->add_item($self);
    return $self;
}

sub is_in {
    my $self = shift;
    my $place = shift;
    return $self->{'location'} eq $place;
}

# this is checking all items in the room and ALL their visible items (and theirs)
sub can_see {
    my $self = shift;
    my $thing = shift;
    my $here = $self->where();
    my $object = $self->has_in_visible($thing) || $self->has_in_inventory($thing) || ($here->visible_containers($thing))[0];
    return $object;
}

sub recipe {
    my $self = shift;
    my $product = shift;
    return warn "\tWhich recipe would you like to see?\n" unless $product;
    return warn "\tI don't know what a $product is\n" unless $recipe_book->has_recipe($product);
    my @ingredients = $recipe_book->get_ingredients("$product");
    my @tools = $recipe_book->get_tools("$product");
    return warn "\tA $product is not something you know how to make\n" unless @ingredients;
    my $recipe = "\tMaking a $product requires\n";
    foreach my $ingredient (@ingredients) {
        $recipe .= "\t\tA $ingredient\n";
    }
    $recipe .= "\t\tAs well as access to\n" if @tools;
    foreach my $tool (@tools) {
        $recipe .= "\t\tA $tool\n";
    }
    my $process = $recipe_book->get_process($product);
    $recipe .= "\t$process\n";
    return warn "$recipe";
}

sub make {
    my $self = shift;
    my $product = shift;
    return warn "\tI am sorry, you want to make what?\n" unless $product;
    return warn "\tI don't know what a $product is\n" unless defined $recipe_book->has_recipe($product);
    my $here = $self->where();
    my @ingredients = $recipe_book->get_ingredients("$product");
    my @tools = $recipe_book->get_tools("$product");
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
    my $made = $recipe_book->get_package($product)->new();
    $made->is_item() ? $self->inventory_add($made) : $here->add_item($made);
    foreach my $ingredient ( @ingredients ) {
        $self->give($ingredient, 'to', $made);
    }
    my $process = $recipe_book->get_process($product);
    return warn "\t$process\n";
}

1;
