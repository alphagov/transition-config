use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

# contains /en but doesn't start with /en
my ( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/cy/Pensionsandretirementplanning/EndOfLife/WhatToDoAfterADeath/DG_10027878CY' );
is( '410', $response_code, "DG_10027878CY should be a 410" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/cy/Governmentcitizensandrights/Consumerrights/Protectyourselffromscams/DG_195967CY' );
is( '410', $response_code, "DG_195967CY should be a 410" );

# ending in htm/html
( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/prod_dg/groups/dg_digitalassets/@dg/@en/documents/digitalasset/dg_186295.html' );
is( '301', $response_code, "dg_186295 should be a 301" );
is( 'https://www.gov.uk/book-a-driving-theory-test', $redirect_location, "redirect is to https://www.gov.uk/book-a-driving-theory-test" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/groups/dg_digitalassets/@dg/@en/documents/digitalasset/dg_178842.htm' );
is( '410', $response_code, "dg_178842 should be a 410" );


done_testing();