use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

# aol
my ( $response_code, $redirect_location) = get_response ( 'http://aol.businesslink.gov.uk' );
is( '200', $response_code, "aol homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://aol.businesslink.gov.uk/portal/action/home?&domain=aol.businesslink.gov.uk' );
is( '200', $response_code, "actual aol homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://aol.businesslink.gov.uk/portal/action/layer?r.l1=1074404796&topicId=1074428566' );
is( '200', $response_code, "A sample aol page does not redirect" );

# msn
( $response_code, $redirect_location) = get_response ( 'http://msn.businesslink.gov.uk' );
is( '200', $response_code, "msn homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://msn.businesslink.gov.uk/portal/action/home?&domain=msn.businesslink.gov.uk' );
is( '200', $response_code, "actual msn homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://msn.businesslink.gov.uk/portal/action/layer?r.l1=1079717544&topicId=1087348476' );
is( '200', $response_code, "A sample msn page does not redirect" );

# alliance & leicester
( $response_code, $redirect_location) = get_response ( 'http://alliance-leicestercommercialbank.businesslink.gov.uk' );
is( '200', $response_code, "A&L homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://alliance-leicestercommercialbank.businesslink.gov.uk/portal/action/home?&domain=alliance-leicestercommercialbank.businesslink.gov.uk' );
is( '200', $response_code, "actual A&L homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://alliance-leicestercommercialbank.businesslink.gov.uk/portal/action/layer?topicId=1086951342' );
is( '200', $response_code, "A sample msn page does not redirect" );

# sage
( $response_code, $redirect_location) = get_response ( 'http://sagestartup.businesslink.gov.uk' );
is( '200', $response_code, "sage homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://sagestartup.businesslink.gov.uk/portal/action/home?&domain=sagestartup.businesslink.gov.uk' );
is( '200', $response_code, "actual sage homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://sagestartup.businesslink.gov.uk/portal/action/detail?itemId=1080898395&r.l1=1073858787&r.l2=1080898061&r.l3=1080898067&type=RESOURCES' );
is( '200', $response_code, "A sample sage page does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://simplybusiness.businesslink.gov.uk' );
is( '200', $response_code, "simply business homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://simplybusiness.businesslink.gov.uk/portal/action/home?&domain=simplybusiness.businesslink.gov.uk' );
is( '200', $response_code, "actual simply business homepage does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://simplybusiness.businesslink.gov.uk/portal/action/layer?r.l1=1073861225&r.s=m&topicId=1079068363' );
is( '200', $response_code, "A sample sage page does not redirect" );

( $response_code, $redirect_location) = get_response ( 'http://blackpoolunlimited.businesslink.gov.uk' );
is( '200', $response_code, "Blackpool Unlimited does not redirect" );

done_testing();