#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib);
use Test::More tests => 6;

use Carp;
local $SIG{'__DIE__'} = \&Carp::confess;
local $SIG{'__WARN__'} = \&Carp::cluck;

use_ok( 'Player' );
use_ok( 'Biome::Desert' );
use_ok( 'Biome::Field' );
use_ok( 'World' );

my $world = World->new();
$world->{'grid'} = {};
my $desert = [0, 0, 0];
my $sdesert = "0,0,0";
$world->{'grid'}->{$sdesert} = Biome::Desert->new(location => $desert, world => $world);
my $field = [0, 2, 0];
my $sfield = "0,2,0";
$world->{'grid'}->{$sfield} = Biome::Field->new(location => $field, world => $world);
my $player = Player->new(location => $world->{'grid'}->{$sdesert});

# see if I can go north once
my $where_i_am = $player->where();
$player->go('north');
my $where_i_am_now = $player->where();

is($where_i_am, 'desert', 'I started in the desert');
is($where_i_am_now, 'field', 'I moved to the field');
