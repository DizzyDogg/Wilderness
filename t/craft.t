#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib);
use Test::More tests => 10;

use Carp;
local $SIG{'__DIE__'} = \&Carp::confess;
local $SIG{'__WARN__'} = \&Carp::cluck;

my $lookies;
local *STDOUT;
open STDOUT, ">", \$lookies;

use_ok( 'Player' );
use_ok( 'Biome::Desert' );
use_ok( 'World' );
use_ok( 'Item::Rock' );

my $world = World->new();
$world->{'grid'} = {};
my $desert = [0, 0, 0];
my $sdesert = "0,0,0";
my $d_room = $world->{'grid'}->{$sdesert} = Biome::Desert->new(location => $desert, world => $world);
is($d_room, 'desert', 'Created a Desert location');

my $player = Player->new(location => $world->{'grid'}->{$sdesert});
my $where_i_am = $player->where();
is($where_i_am, 'desert', 'I started in the desert');

my $rock = Item::Rock->new();
is(ref $rock, 'Item::Rock', 'Created a Rock');

$player->inventory_add( $rock );
is($player->inventory_contains($rock), 'rock', 'Placed rock in my inventory');

$player->make('handaxe');
is($player->inventory_contains('handaxe'), 'handaxe', 'Created a handaxe');

isnt($player->inventory_contains($rock), 'rock', 'I no longer have the Rock');
