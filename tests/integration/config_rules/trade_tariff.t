use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

# should be handled by the redirector
my ( $response_code, $redirect_location) = get_response ( 'http://tariff.businesslink.gov.uk/tariff-bl/mainMenu' );
is( '301', $response_code, "Trade tariff homepage redirects" );
is( 'https://www.gov.uk/trade-tariff', $redirect_location, "redirect is to https://www.gov.uk/trade-tariff" );

( $response_code, $redirect_location) = get_response ( 'http://tariff.businesslink.gov.uk/tariff-bl/export/heading.html?export=false&simulationDate=09/10/12&id=3502000000&additionalCode1=&additionalCode2=&additionalCode3=&countryCode=' );
is( '301', $response_code, "A sample www.tariff.businesslink.gov.uk page redirects" );
is( 'https://www.gov.uk/trade-tariff', $redirect_location, "redirect is to https://www.gov.uk/trade-tariff" );

( $response_code, $redirect_location) = get_response ( 'http://tariff.businesslink.gov.uk/tariff-bl/export/sections.html?export=false' );
is( '301', $response_code, "Another sample www.tariff.businesslink.gov.uk page redirects" );
is( 'https://www.gov.uk/trade-tariff', $redirect_location, "redirect is to https://www.gov.uk/trade-tariff" );

( $response_code, $redirect_location) = get_response ( 'http://content.tariff.businesslink.gov.uk' );
is( '301', $response_code, "content.tariff.businesslink.gov.uk redirects" );
is( 'https://www.gov.uk/trade-tariff', $redirect_location, "redirect is to https://www.gov.uk/trade-tariff" );

done_testing();