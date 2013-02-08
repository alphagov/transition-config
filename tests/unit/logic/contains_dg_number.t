use strict;
use warnings;
use Test::More;
use Mappings::Businesslink;


my $test_path     = '/en/DG_064868';
my $dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( $dg_number, 'dg_064868', "URL contains a DG number" );

$test_path     = '/en/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
isnt( $dg_number, 'DG_064868', "DG number is lower case" );

$test_path     = '/en/Environmentandgreenerliving/Greenertravel/Enjoyingthecountryside/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( $dg_number, 'dg_064868', "Long URL contains a DG number" );

$test_path     = '/en/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( $dg_number, 'dg_064868', "A DG number starts with DG_" );

$test_path     = '/en/dg_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( $dg_number, 'dg_064868', "A DG number can start with dg_" );

$test_path     = '/en/dg_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( $dg_number, 'dg_064868', "A DG number can start with Dg_" );

$test_path     = '/en/groups/dg_digitalassets/@dg/@en/documents/digitalasset/dg_178842.htm';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "URLs that do not end in the DG number are not canonicalised" );

$test_path     = '/en/D_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_path     = '/en/DG064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_path     = '/en/_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_path     = '/en/064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_path     = '/en/blahblahDG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "A DG number must be the whole segment" );

$test_path     = '/cy/DG_064868CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_path     = '/cy/DG_10027878CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_path     = '/cy/Governmentcitizensandrights/Consumerrights/Protectyourselffromscams/DG_195967CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_path     = '/cy/Pensionsandretirementplanning/EndOfLife/WhatToDoAfterADeath/DG_10027878CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_path     = '/cy/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_path     = '/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_path );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

done_testing();
