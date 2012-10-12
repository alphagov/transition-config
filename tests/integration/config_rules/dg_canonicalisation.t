use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/Environmentandgreenerliving/Greenertravel/Enjoyingthecountryside/DG_064868' );
is( '301', $response_code, "Full link redirects" );
is( 'https://www.gov.uk/find-your-local-park', $redirect_location, "redirect is to  https://www.gov.uk/find-your-local-park" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/Environmentandgreenerliving/Greenertravel/DG_064868' );
is( '301', $response_code, "Shorter link redirects" );
is( 'https://www.gov.uk/find-your-local-park', $redirect_location, "redirect is to  https://www.gov.uk/find-your-local-park" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/Environmentandgreenerliving/DG_064868' );
is( '301', $response_code, "Even shorter link redirects" );
is( 'https://www.gov.uk/find-your-local-park', $redirect_location, "redirect is to  https://www.gov.uk/find-your-local-park" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/DG_064868' );
is( '301', $response_code, "Shortest link redirects" );
is( 'https://www.gov.uk/find-your-local-park', $redirect_location, "redirect is to  https://www.gov.uk/find-your-local-park" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/AnyOldrubbish/DG_064868' );
is( '301', $response_code, "Link with any old rubbish redirects" );
is( 'https://www.gov.uk/find-your-local-park', $redirect_location, "redirect is to  https://www.gov.uk/find-your-local-park" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/really_anything/in_here/DG_064868' );
is( '301', $response_code, "Link with really anything in there redirects" );
is( 'https://www.gov.uk/find-your-local-park', $redirect_location, "redirect is to  https://www.gov.uk/find-your-local-park" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/Environmentandgreenerliving/Greenertravel/Enjoyingthecountryside/DG_064868' );
is( '404', $response_code, "Link without /en does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/Environmentandgreenerliving/Greenertravel/Enjoyingthecountryside/DG_064868.html' );
is( '404', $response_code, "Link that doesn't end in the DG number does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/cy/Environmentandgreenerliving/Greenertravel/Enjoyingthecountryside/DG_064868' );
is( '404', $response_code, "Link with /cy does not redirect" );


done_testing();
