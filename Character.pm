package Character;

use strict;
use warnings;

use base qw(Object);
use RecipeBook;

use Data::Dumper;

sub _is_character { return 1 }

sub _get_health { return 1 }

my $recipe_book = RecipeBook->_new();

sub _can_go {
    my $self = shift;
    my $direction = shift;
    my $here = $self->_where();
    my $coords = ($self->_visible_containers($self))[-1];

    my $exits = $here->_get_exits();
    return $exits->{$direction} ? 1 : 0;
}

sub _move_to {
    my $self = shift;
    my $where = shift;
    my $here = $self->_where();
    $here->_remove_item($self);
    $where->_add_item($self);
    return $self;
}

sub _is_in {
    my $self = shift;
    my $place = shift;
    return $self->{'location'} eq $place;
}

# this is checking all items in the room and ALL their visible equipment (and theirs)
sub _can_see {
    my $self = shift;
    my $thing = shift;
    my $here = $self->_where();
    my $object = $self->_has_on($thing) || $self->_has_in($thing) || ($here->_visible_containers($thing))[0];
    return $object;
}

sub recipe {
    my $self = shift;
    my $product = shift;
    return warn "\tWhich recipe would you like to see?\n" unless $product;
    return warn "\tI don't know what a $product is\n" unless $recipe_book->_has_recipe($product);
    my @ingredients = $recipe_book->_get_ingredients("$product");
    my @tools = $recipe_book->_get_tools("$product");
    return warn "\tA $product is not something you know how to make\n" unless @ingredients;
    my $recipe = "\tMaking a $product requires\n";
    foreach my $ingredient (@ingredients) {
        $recipe .= "\t\tA $ingredient\n";
    }
    $recipe .= "\t\tAs well as access to\n" if @tools;
    foreach my $tool (@tools) {
        $recipe .= "\t\tA $tool\n";
    }
    my $process = $recipe_book->_get_process($product);
    $recipe .= "\t$process\n";
    return warn "$recipe";
}

sub make {
    my $self = shift;
    my $product = shift;
    return warn "\tI am sorry, you want to make what?\n" unless $product;
    return warn "\tI don't know what a $product is\n" unless defined $recipe_book->_has_recipe($product);
    my $here = $self->_where();
    my @ingredients = $recipe_book->_get_ingredients("$product");
    my @tools = $recipe_book->_get_tools("$product");
    return warn "\tA $product is not something you know how to make\n" unless @ingredients;
    my @lack;
    foreach my $ingredient (@ingredients) {
        push @lack, $ingredient unless $self->_has($ingredient);
    }
    foreach my $tool (@tools) {
        push @lack, $tool unless $self->_can_reach($tool);
    }
    my $lack_string = join "\n\t\tA ", @lack;
    if ( @lack ) {
        return warn "\tTo make a $product, you still need\n" . "\t\tA $lack_string\n";
    }
    my $made = $recipe_book->_get_package($product)->_new();
    $made->_is_item() ? $self->_inventory_add($made) : $here->_add_item($made);
    foreach my $ingredient ( @ingredients ) {
        $self->give($ingredient, 'to', $made);
    }
    my $process = $recipe_book->_get_process($product);
    return warn "\t$process\n";
}

1;
