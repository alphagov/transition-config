use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/ocrs' );
is( '301', $response_code, "ZenDesk #34055 example 1" );
is( 'https://www.gov.uk/operator-compliance-risk-score', $redirect_location, "redirect is to  https://www.gov.uk/operator-compliance-risk-score" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/bdotg/action/layer?r.l1=1081597476&r.l2=1082103262&r.l3=1085174504&r.s=tl&topicId=1085497596' );
is( '301', $response_code, "ZenDesk #34055 example 2" );
is( 'https://www.gov.uk/operator-compliance-risk-score', $redirect_location, "redirect is to  https://www.gov.uk/operator-compliance-risk-score" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/vosateststation' );
is( '301', $response_code, "ZenDesk #36074 example 1" );
is( 'https://www.gov.uk/find-your-nearest-vosa-test-station', $redirect_location, "redirect is to  https://www.gov.uk/find-your-nearest-vosa-test-station" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.gov.uk/vosateststation/' );
is( '301', $response_code, "ZenDesk #36074 example 2" );
is( 'https://www.gov.uk/find-your-nearest-vosa-test-station', $redirect_location, "https://www.gov.uk/find-your-nearest-vosa-test-station" );

done_testing();