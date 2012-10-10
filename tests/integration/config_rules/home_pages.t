use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/bdotg/action/home' );
is( '301', $response_code, "Businesslink homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to  https://www.gov.uk" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/' );
is( '301', $response_code, "Businesslink homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to  https://www.gov.uk" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/index.htm' );
is( '301', $response_code, "Directgov homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to  https://www.gov.uk" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/' );
is( '301', $response_code, "Directgov homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to  https://www.gov.uk" );


done_testing();

