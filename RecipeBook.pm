package RecipeBook;

use strict;
use warnings;

# use base qw(Object);

use Data::Dumper;

sub _new {
    my $package = shift;
    my $self = {@_};
    bless $self, $package;
    $self->{'name'} = 'recipebook';
    return $self;
}

my $recipe;

my @dirs = ('Item', 'Fixture');
foreach my $dir (@dirs) {
    opendir(DIR, $dir) or die $!;
    while ( my $file = readdir(DIR) ) {
        next if ($file =~ m/^\./);
        my $path = "$dir\/$file";
        my $package = "$dir::$file";
        $package =~ s/\.pm//;
        (my $product = $file) =~ s/\.pm//;
        $product = lc($product);
        require $path;
        $recipe->{$product}->{'ingredients'} = [ $package->_get_ingredients() ] || [];
        $recipe->{$product}->{'tools'} = [ $package->_get_tools() ] || [];
        $recipe->{$product}->{'process'} = $package->_process() || '';
    }
}

sub _has_recipe {
    my $self = shift;
    my $product = shift;
    return $recipe->{"$product"};
}

sub _get_ingredients {
    my $self = shift;
    my $product = shift;
    return @{$recipe->{$product}->{'ingredients'}};
}

sub _get_tools {
    my $self = shift;
    my $product = shift;
    return @{$recipe->{$product}->{'tools'}};
}

sub _get_process {
    my $self = shift;
    my $product = shift;
    return $recipe->{$product}->{'process'};
}

1;
