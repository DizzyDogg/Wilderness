#!/usr/bin/perl

use strict;
use warnings;

my (%inventory, %room_contents, %location, %exit);

while (<>) {
    my $line = shift;
    $line = /^(\S+)\s+(\S+)\s+(.*)$/
        || die "Unknown line in dungeon: $line";
    my ($first, $second, $last) = ($1, $2, $3);

    if ( $second =~ /contains/ ) {
        ++( $room_contents{$first}{$last} ) || die "Cannot populate room contents: $first $second $last";
    }
    elsif ( $second =~ /^has$/ ) {
       ++( $inventory{$first}{$last} ) || die "Cannot populate inventory: $first $second $last";
    }
    elsif ( $second =~ /is/ ) {
        $last =~ /in\s+(.+)/
            || die "Cannot parse location: $first $second $last";
        $location{$first} = $1;
    }
    elsif ( $second =~ /(?:north|south|east|west|up|down)/ ) {
        $last =~ /^goes\s+to\s+(.+)$/
            || die "Cannot parse direction: $first $second $last";
        $exit{$first}{$second} = $1;
    }
    else {
        die "Unknown line in dungeon: $first $second $last";
    }
}

my %verb = ( give => \&give, drop => \&drop,
             take => \&take, kill => &kill('kill'), slay => &kill('slay'),
             look => \&look, have => \&inventory, go => \&go,
             quit => sub { exit },
);

# Minimum definition of the game to make demonstration work

# my %inventory     = ( me => { jewel => 1 }, troll => { diamond => 1 } );
# my %room_contents = ( cave => { sword => 1 } );
# my %location      = ( me => 'cave', troll => 'cave', thief => 'attic' );

for ( prompt(); $_ = <STDIN>; prompt() ) {
    chomp;
    next unless /(\S+)(?:\s+(.+))?/;
    $verb{$1} or warn "\tI don't know how to $1\n" and next;
    $verb{$1}->($2);
}

sub prompt { print "Command: " }

sub give {
    my $command = shift;
    $command =~ /(\S+)\s+to\s+(\S+)/ or return warn "\tGive what to whom?\n";
    delete $inventory{me}{$1} or return warn "\tYou don't have a $1 to give\n";
    $inventory{$2}{$1}++;
    print "\tGiven\n";
}

sub go {
    my $where = shift;
    return warn "\tGo where?\n" unless $where;
    return warn "\tCan't go $where from here\n" unless $exit{$location{'me'}}{$where};
    $location{'me'} = $exit{$location{'me'}}{$where};
}

sub drop {
    my $what = shift;
    delete $inventory{me}{$what} or return warn "\tYou don't have a $what\n";
    my $here = $location{me};
    $room_contents{$here}{$what}++;
    print "\tDropped\n";
}

sub take {
    my $what = shift;
    my $here = $location{me};
    delete $room_contents{$here}{$what} or return warn "\tThere's no $what here\n";
    $inventory{me}{$what}++;
    print "\tTaken\n";
}

sub inventory {
    for my $have ( keys %{ $inventory{me} } ) {
        print "\tYou have a $have\n";
    }
}

sub look {
    my $here = $location{me};
    print "\tYou are in the $here\n";
    for my $around ( keys %{ $room_contents{$here} } ) {
        print "\tThere is a $around on the ground\n";
    }
    for my $actor ( keys %location ) {
        next if $actor eq 'me';
        print "\tThere is a $actor here\n" if $location{$actor} eq $here;
    }
    my @exits = keys %{$exit{$here}};
    print ("\tThere are exits leading " . join(', ', @exits) . "\n") if @exits;
}

sub kill {
    my $word = shift;
    return sub {
        my $command = shift;
        $command =~ /(\S+)\s+with\s+(\S+)/ or return warn "\t\u${word} who with what?\n";
        $inventory{me}{$2} or return warn "\tYou don't have a $2\n";
        my $here = $location{me};
        my $its_at = $location{$1} or return warn "\tNo $1 to $word\n";
        $its_at eq $here or return warn "\tThe $1 isn't here\n";
        delete $location{$1};
        my $had_ref = delete $inventory{$1};
        $room_contents{$here}{$_}++ for keys %$had_ref;
        print "\u${word}ed!\n";
    }
}

__END__
i do not like writing 'me' everywhere
I need to create a player object and somehow use that

i might want to create a room object, and make a bunch of them with different names.
