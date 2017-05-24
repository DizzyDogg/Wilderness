#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib);
use Test::More tests => 25;

use Carp;
local $SIG{'__DIE__'} = \&Carp::confess;
local $SIG{'__WARN__'} = \&Carp::cluck;

# my $lookies;
# local *STDOUT;
# open STDOUT, ">", \$lookies;

use_ok( 'Player' );
use_ok( 'Biome' );
use_ok( 'World' );
use_ok( 'Mob::Deer' );

my $world = World->new();
$world->{'grid'} = {};
is($world, 'world', 'Created the World');
my $biome = [0, 0, 0];
my $sbiome = "0,0,0";
my $b_room = $world->{'grid'}->{$sbiome} = Biome->new(location => $biome, world => $world);
is($b_room, 'biome', 'Created a generic Biome location');

my $player = Player->new(location => $world->{'grid'}->{$sbiome});
my $where_i_am = $player->where();
is(ref $where_i_am, ref $b_room, 'I started in the biome');

my $deer = Mob::Deer->new();
is($deer, 'deer', 'Created a Deer');
$b_room->visible_add($deer);
is(ref $deer->where(), ref $b_room, 'The deer is in the Biome');

ok( ! $player->can_see('meat'), 'I cannot see any Meat' );
my $return = $player->attack($deer);
ok($return, 'I attacked the deer');
$return = $player->attack($deer);
ok($return, 'I attacked the deer');
$return = $player->attack($deer);
ok($return, 'I attacked the deer');
ok( $player->can_see('meat'), 'I can now see Meat ... Killed th Deer' );

### put a tree here and 'attack' it too.


