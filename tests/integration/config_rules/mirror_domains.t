use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my ( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.co.uk' );
is( '301', $response_code, "www.businesslink.co.uk homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.co.uk/bdotg/action/layer?r.s=tl&topicId=1086951342' );
is( '301', $response_code, "A sample www.businesslink.co.uk page redirects" );
is( 'https://www.gov.uk/renting-business-property-tenant-responsibilities', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.org' );
is( '301', $response_code, "www.businesslink.org homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://www.businesslink.org/bdotg/action/detail?itemId=1076795317&r.l1=1073858790&r.l2=1084705429&r.l3=1087443481&r.l4=1076795303&r.s=m&type=RESOURCES' );
is( '301', $response_code, "A sample www.businesslink.org page redirects" );
is( 'https://www.gov.uk/business-finance-explained', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );

( $response_code, $redirect_location) = get_response ( 'http://business.gov.uk' );
is( '301', $response_code, "business.gov.uk homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://business.gov.uk/bdotg/action/layer?r.l1=1081597476&r.s=tl&topicId=1082103262' );
is( '301', $response_code, "A sample business.gov.uk page redirects" );
is( 'https://www.gov.uk/browse/driving', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );

( $response_code, $redirect_location) = get_response ( 'http://businesslink.co.uk' );
is( '301', $response_code, "businesslink.co.uk homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://businesslink.co.uk/bdotg/action/detail?itemId=1084193360&r.l1=1073858787&r.l2=1084607697&r.l3=1084188521&r.s=sc&type=RESOURCES' );
is( '301', $response_code, "A sample businesslink.co.uk page redirects" );
is( 'https://www.gov.uk/employers-checks-job-applicants', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );

( $response_code, $redirect_location) = get_response ( 'http://businesslink.org' );
is( '301', $response_code, "businesslink.org homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://businesslink.org/bdotg/action/layer?r.l1=1081986989&r.s=tl&topicId=1087252345' );
is( '301', $response_code, "A sample businesslink.org page redirects" );
is( 'http://www.hmrc.gov.uk/agents/index.htm', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );

( $response_code, $redirect_location) = get_response ( 'http://www.business.gov.uk' );
is( '301', $response_code, "www.business.gov.uk homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://www.business.gov.uk/bdotg/action/detail?itemId=1087011081&type=RESOURCES' );
is( '301', $response_code, "A sample www.business.gov.uk page redirects" );
is( 'https://www.gov.uk/preventing-air-pollution', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );

( $response_code, $redirect_location) = get_response ( 'http://businesslink.gov.uk' );
is( '301', $response_code, "businesslink.gov.uk homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://businesslink.gov.uk/bdotg/action/detail?itemId=1087011081&type=RESOURCES' );
is( '301', $response_code, "A sample businesslink.gov.uk page redirects" );
is( 'https://www.gov.uk/preventing-air-pollution', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );

( $response_code, $redirect_location) = get_response ( 'http://online.businesslink.gov.uk' );
is( '301', $response_code, "online.businesslink.gov.uk homepage redirects" );
is( 'https://www.gov.uk', $redirect_location, "redirect is to https://www.gov.uk/" );

( $response_code, $redirect_location) = get_response ( 'http://online.businesslink.gov.uk/bdotg/action/detail?itemId=1084193360&r.l1=1073858787&r.l2=1084607697&r.l3=1084188521&r.s=sc&type=RESOURCES' );
is( '301', $response_code, "A sample online.businesslink.gov.uk page redirects" );
is( 'https://www.gov.uk/employers-checks-job-applicants', $redirect_location, "redirect is to the equivalent businesslink redirect on GOV.UK" );


done_testing();