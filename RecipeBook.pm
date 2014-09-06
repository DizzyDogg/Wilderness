package RecipeBook;

use strict;
use warnings;

# use base qw(Object);

use Data::Dumper;

sub new {
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
        my $path = "$dir/$file";
        my $package = "$dir\::$file";
        $package =~ s/\.pm//;
        (my $product = $file) =~ s/\.pm//;
        $product = lc($product);
        require $path;
        $recipe->{$product}->{'package'} = $package || '';
        $recipe->{$product}->{'ingredients'} = [ $package->get_ingredients() ];
        $recipe->{$product}->{'tools'} = [ $package->get_tools() ];
        $recipe->{$product}->{'process'} = $package->process() || '';
    }
}

sub has_recipe {
    my $self = shift;
    my $product = shift;
    return $recipe->{"$product"} ? $recipe->{"$product"} : undef;
}

sub get_package {
    my $self = shift;
    my $product = shift;
    return $recipe->{$product}->{'package'};
}

sub get_ingredients {
    my $self = shift;
    my $product = shift;
    return @{$recipe->{$product}->{'ingredients'}};
}

sub get_tools {
    my $self = shift;
    my $product = shift;
    return @{$recipe->{$product}->{'tools'}};
}

sub get_process {
    my $self = shift;
    my $product = shift;
    return $recipe->{$product}->{'process'};
}

1;
