use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1082350122&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );

( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1082547325&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );

( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1083465352&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );

( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1083937170&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );


( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1084922903&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );


( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1085304104&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );


( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1086406503&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );

( $response_code, $redirect_location) = get_response ( 'https://online.businesslink.gov.uk/bdotg/action/crossSell?itemId=1097516983&type=CROSSSELL&site=1000' );
is( '301', $response_code, "should be a 301" );
is( 'https://www.gov.uk/transaction-finished', $redirect_location, "redirect is correct" );


done_testing();