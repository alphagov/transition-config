use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/Employment/Employees/Timeoffandholidays/DG_073741' );
is( '301', $response_code, "Case 1 redirects" );
is( 'https://www.gov.uk/bank-holidays', $redirect_location, "redirect is to  https://www.gov.uk/bank-holidays" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/Employment/Employees/Timeoffandholidays/dg_073741' );
is( '301', $response_code, "Case 2 redirects" );
is( 'https://www.gov.uk/bank-holidays', $redirect_location, "redirect is to  https://www.gov.uk/bank-holidays" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/employment/Employees/Timeoffandholidays/dg_073741' );
is( '301', $response_code, "Case 3 redirects" );
is( 'https://www.gov.uk/bank-holidays', $redirect_location, "redirect is to  https://www.gov.uk/bank-holidays" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/en/employment/employees/timeoffandholidays/dg_073741' );
is( '301', $response_code, "Case 4 redirects" );
is( 'https://www.gov.uk/bank-holidays', $redirect_location, "redirect is to  https://www.gov.uk/bank-holidays" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/16-19bursary' );
is( '301', $response_code, "Case 4 redirects" );
is( 'https://www.gov.uk/1619-bursary-fund', $redirect_location, "friendly URL redirects" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/somethinghere16-19bursary' );
is( '404', $response_code, "the string being matched must be at the start" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/16-19bursarysomethinghere' );
is( '404', $response_code, "the string being matched must be at the end" );

( $response_code, $redirect_location) = get_response ( 'http://www.direct.gov.uk/blahblah16-19bursarysomethinghere' );
is( '404', $response_code, "the string being matched must be the whole string" );

done_testing();

