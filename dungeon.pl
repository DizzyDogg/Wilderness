#!/usr/bin/perl

use strict;
use warnings;

use Dungeon;
use Data::Dumper;
use Player;

my $dungeon = Dungeon->new(name => 'Awesome');
$dungeon->initialize();

my $player = $dungeon->{'things'}{'me'};

my %alternates = (
    have    => 'inventory',
    grab    => 'take',
    get     => 'take',
    pickup  => 'take',
    retrieve => 'take',
);

print "\n\nWelcome to the Dungeon of Awesome.\n";
print "Do you have what it takes to survive?\n\n";

$player->look($dungeon);

while ( my ($verb, @arguments) = prompt() ) {
    if ( my $m = $player->can($alternates{$verb} || $verb) ) {
        my @args = string2obj(@arguments);
        $player->$m($dungeon, @args);
    }
    else {
        warn "\tYou do not know how to $verb\n";
    }
}

# Modify prompt to not return until it gets an input
sub prompt {
    print "\nWhat would you like to do? ";
    my $command = <STDIN>;
    chomp $command;
    $command =~ s/\bthe\b//;
    $command =~ s/\ba\b//;
    $command =~ s/\bat\b//;
    return split /\s+/, $command;
}

sub string2obj {
    my @strings = @_;
    my @objects;
    foreach my $string ( @strings ) {
        push @objects, $dungeon->{'things'}{$string} || $string;
    }
    return @objects;
}
