use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

if ( 'preview' eq $ENV{'DEPLOY_TO'} ) {
    pass("Don't bother testing syndicated domains on preview.");
    done_testing();
    exit;
}

# aol
my ( $response_code, $redirect_location) = get_response ( 'http://aol.businesslink.gov.uk' );
is( '301', $response_code, "aol redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://aol.businesslink.gov.uk/portal/action/home?&domain=aol.businesslink.gov.uk' );
is( '301', $response_code, "actual aol homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://aol.businesslink.gov.uk/portal/action/layer?r.l1=1074404796&topicId=1074428566' );
is( '301', $response_code, "A sample aol page redirects" );
is ( 'https://www.gov.uk/business-finance-support-finder', $redirect_location, "to the appropriate GOV.UK page");

# msn
( $response_code, $redirect_location) = get_response ( 'http://msn.businesslink.gov.uk' );
is( '301', $response_code, "msn homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://msn.businesslink.gov.uk/portal/action/home?&domain=msn.businesslink.gov.uk' );
is( '301', $response_code, "actual msn homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://msn.businesslink.gov.uk/portal/action/layer?r.l1=1079717544&topicId=1087348476' );
is( '301', $response_code, "A sample msn page redirects" );
is ( 'https://www.gov.uk/economic-operator-registration-and-identification-eori-scheme', $redirect_location, "to the appropriate GOV.UK page");

# alliance & leicester
( $response_code, $redirect_location) = get_response ( 'http://alliance-leicestercommercialbank.businesslink.gov.uk' );
is( '301', $response_code, "A&L homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://alliance-leicestercommercialbank.businesslink.gov.uk/portal/action/home?&domain=alliance-leicestercommercialbank.businesslink.gov.uk' );
is( '301', $response_code, "actual A&L homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://alliance-leicestercommercialbank.businesslink.gov.uk/portal/action/layer?topicId=1086951342' );
is( '301', $response_code, "A sample msn page redirects" );
is ( 'https://www.gov.uk/renting-business-property-tenant-responsibilities', $redirect_location, "to the appropriate GOV.UK page");

# sage
( $response_code, $redirect_location) = get_response ( 'http://sagestartup.businesslink.gov.uk' );
is( '301', $response_code, "sage homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://sagestartup.businesslink.gov.uk/portal/action/home?&domain=sagestartup.businesslink.gov.uk' );
is( '301', $response_code, "actual sage homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://sagestartup.businesslink.gov.uk/portal/action/detail?itemId=1080898395&r.l1=1073858787&r.l2=1080898061&r.l3=1080898067&type=RESOURCES' );
is( '301', $response_code, "A sample sage page redirects" );
is ( 'https://www.gov.uk/paternity-leave-pay-employees', $redirect_location, "to the appropriate GOV.UK page");

( $response_code, $redirect_location) = get_response ( 'http://simplybusiness.businesslink.gov.uk' );
is( '301', $response_code, "simply business homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://simplybusiness.businesslink.gov.uk/portal/action/home?&domain=simplybusiness.businesslink.gov.uk' );
is( '301', $response_code, "actual simply business homepage redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

( $response_code, $redirect_location) = get_response ( 'http://simplybusiness.businesslink.gov.uk/portal/action/layer?r.l1=1073861225&r.s=m&topicId=1079068363' );
is( '301', $response_code, "A sample simply business page redirects" );
is ( 'https://www.gov.uk/browse/business/waste-environment', $redirect_location, "to the appropriate GOV.UK page");

( $response_code, $redirect_location) = get_response ( 'http://blackpoolunlimited.businesslink.gov.uk' );
is( '301', $response_code, "Blackpool Unlimited redirects" );
is ( 'https://www.gov.uk', $redirect_location, "to the GOV.UK homepage");

done_testing();