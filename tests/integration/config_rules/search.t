use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/AdvancedSearch/Searchresults/index.htm?fullText=' );
is( '301', $response_code, "Directgov search page redirects" );
is( 'https://www.gov.uk/search', $redirect_location, "redirect is to  https://www.gov.uk/search" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/bdotg/action/AdvancedSearch' );
is( '301', $response_code, "Businesslink advanced search page redirects" );
is( 'https://www.gov.uk/search', $redirect_location, "redirect is to  https://www.gov.uk/search" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/bdotg/action/searchAdvancedMode' );
is( '301', $response_code, "Businesslink advanced search results page redirects" );
is( 'https://www.gov.uk/search', $redirect_location, "redirect is to  https://www.gov.uk/search" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/bdotg/action/searchBasicMode' );
is( '301', $response_code, "Businesslink basic search results page redirects" );
is( 'https://www.gov.uk/search', $redirect_location, "redirect is to  https://www.gov.uk/search" );


done_testing();

