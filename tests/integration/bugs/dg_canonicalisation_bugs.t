use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/cy/Pensionsandretirementplanning/EndOfLife/WhatToDoAfterADeath/DG_10027878CY' );
is( '410', $response_code, "DG_10027878CY should be a 410" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/cy/Governmentcitizensandrights/Consumerrights/Protectyourselffromscams/DG_195967CY' );
is( '410', $response_code, "DG_195967CY should be a 410" );

done_testing();