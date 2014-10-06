#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib);
use Test::More tests => 8;

use Carp;
local $SIG{'__DIE__'} = \&Carp::confess;
local $SIG{'__WARN__'} = \&Carp::cluck;

my $lookies;
local *STDOUT;
open STDOUT, ">", \$lookies;

use_ok( 'Player' );
use_ok( 'Biome::Desert' );
use_ok( 'Biome::Field' );
use_ok( 'World' );

my $world = World->new();
$world->{'grid'} = {};
my $desert = [0, 0, 0];
my $sdesert = "0,0,0";
my $d_room = $world->{'grid'}->{$sdesert} = Biome::Desert->new(location => $desert, world => $world);
is($d_room, 'desert', 'Created a Desert location');

my $field = [0, 2, 0];
my $sfield = "0,2,0";
my $f_room = $world->{'grid'}->{$sfield} = Biome::Field->new(location => $field, world => $world);
is($f_room, 'field', 'Created a Field location');

my $player = Player->new(location => $world->{'grid'}->{$sdesert});
my $where_i_am = $player->where();
is($where_i_am, 'desert', 'I started in the desert');

# see if I can go north once
$player->go('north');
my $where_i_am_now = $player->where();
is($where_i_am_now, 'field', 'I moved to the field');
