#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib);
use Test::More tests => 17;

use Carp;
local $SIG{'__DIE__'} = \&Carp::confess;
local $SIG{'__WARN__'} = \&Carp::cluck;

my $lookies;
local *STDOUT;
open STDOUT, ">", \$lookies;

use_ok( 'Player' );
use_ok( 'Biome' );
use_ok( 'World' );
use_ok( 'Item::Rock' );

my $world = World->new();
$world->{'grid'} = {};
is($world, 'world', 'Created the World');
my $biome = [0, 0, 0];
my $sbiome = "0,0,0";
my $b_room = $world->{'grid'}->{$sbiome} = Biome->new(location => $biome, world => $world);
is($b_room, 'biome', 'Created a generic Biome location');

my $player = Player->new(location => $world->{'grid'}->{$sbiome});
my $where_i_am = $player->where();
is($where_i_am, 'biome', 'I started in the biome');

# Create the rock
my $rock = Item::Rock->new();
is($rock, 'rock', 'successfully created a rock');

# Place it in my inventory
ok($player->inventory_add($rock), 'Successfully placed rock in inventory');
is(ref $player->inventory_contains($rock), ref $rock,
    'I have the rock in my inventory');
isnt(ref $player->visible_contains($rock), ref $rock, 'and not in my equipment');

# Equip the rock
is($player->equip($rock), 1, 'Successfully equipped the rock');
is(ref $player->visible_contains($rock), ref $rock,
    'I have the rock in my equipment');
isnt(ref $player->inventory_contains($rock), ref $rock, 'and not in my inventory');

# Unequip it again
is($player->unequip($rock), 1, 'Successfully unequipped the rock');
is(ref $player->inventory_contains($rock), ref $rock,
    'I have the rock in my inventory');
isnt(ref $player->visible_contains($rock), ref $rock, 'and not in my equipment');
