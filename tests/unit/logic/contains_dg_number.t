use strict;
use warnings;
use Test::More;
use Mappings::Businesslink;


my $test_url_parts = {
    scheme => '',
    host   => '',
    path   => '',
    query  => '',
    frag   => '',
};


$test_url_parts->{path}     = '/en/DG_064868';
my $dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( $dg_number, 'dg_064868', "URL contains a DG number" );

$test_url_parts->{path}     = '/en/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
isnt( $dg_number, 'DG_064868', "DG number is lower case" );

$test_url_parts->{path}     = '/en/Environmentandgreenerliving/Greenertravel/Enjoyingthecountryside/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( $dg_number, 'dg_064868', "Long URL contains a DG number" );

$test_url_parts->{path}     = '/en/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( $dg_number, 'dg_064868', "A DG number starts with DG_" );

$test_url_parts->{path}     = '/en/dg_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( $dg_number, 'dg_064868', "A DG number can start with dg_" );

$test_url_parts->{path}     = '/en/dg_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( $dg_number, 'dg_064868', "A DG number can start with Dg_" );

$test_url_parts->{path}     = '/en/groups/dg_digitalassets/@dg/@en/documents/digitalasset/dg_178842.htm';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "URLs that do not end in the DG number are not canonicalised" );

$test_url_parts->{path}     = '/en/D_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_url_parts->{path}     = '/en/DG064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_url_parts->{path}     = '/en/_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_url_parts->{path}     = '/en/064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "A DG number must start with some form of DG_ " );

$test_url_parts->{path}     = '/en/blahblahDG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "A DG number must be the whole segment" );

$test_url_parts->{path}     = '/cy/DG_064868CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_url_parts->{path}     = '/cy/DG_10027878CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_url_parts->{path}     = '/cy/Governmentcitizensandrights/Consumerrights/Protectyourselffromscams/DG_195967CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_url_parts->{path}     = '/cy/Pensionsandretirementplanning/EndOfLife/WhatToDoAfterADeath/DG_10027878CY';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_url_parts->{path}     = '/cy/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

$test_url_parts->{path}     = '/DG_064868';
$dg_number   = Mappings::Directgov::dg_number( undef, $test_url_parts );
is( undef, $dg_number, "URLs without /en/ are not canonicalised using DG numbers" );

done_testing();
