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


# devolved admin trade-tariffs should not be handled by the redirector.
# NI
( $response_code, $redirect_location) = get_response ( 'http://tariff.nibusinessinfo.co.uk/tariff-bl/mainMenu' );
is( '500', $response_code, "The NI trade tariff homepage should not be handled by the redirector" );

( $response_code, $redirect_location) = get_response ( 'http://tariff.nibusinessinfo.co.uk/tariff-bl/export/sections.html?export=true' );
is( '500', $response_code, "A sample NI trade tariff page should not be handled by the redirector" );

# Scotland
( $response_code, $redirect_location) = get_response ( 'http://tariff.business.scotland.gov.uk/tariff-bl/mainMenu' );
is( '500', $response_code, "The Scotland trade tariff homepage should not be handled by the redirector" );

( $response_code, $redirect_location) = get_response ( 'http://tariff.business.scotland.gov.uk/tariff-bl/export/section.html?export=true&from=list&id=04&simulationDate=09/10/12' );
is( '500', $response_code, "A sample Scotland trade tariff page should not be handled by the redirector" );

# Wales
( $response_code, $redirect_location) = get_response ( 'http://tariff.business.wales.gov.uk/tariff-bl/mainMenu' );
is( '500', $response_code, "The Wales trade tariff homepage should not be handled by the redirector" );

( $response_code, $redirect_location) = get_response ( 'http://tariff.business.wales.gov.uk/tariff-bl/export/heading.html?export=false&simulationDate=11/10/12&id=2309105100&additionalCode1=&additionalCode2=&additionalCode3=&countryCode=' );
is( '500', $response_code, "A sample Wales trade tariff page should not be handled by the redirector" );


done_testing();