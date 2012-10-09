use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/subdomains/get_response.pl';


# Scotland
my ( $response_code, $redirect_location) = &get_response ( 'http://www.businesslink.gov.uk/bdotg/action/layer?r.l1=1081986989&r.s=tl&topicId=1087252345&site=202' );
is( '301', $response_code, "A sample site=202 page redirects" );
is( 'http://www.business.scotland.gov.uk/bdotg/action/layer?r.l1=1081986989&r.s=tl&topicId=1087252345&site=202', 
	$redirect_location, "redirect is the equivalent page on business.scotland" );

# Same one without site=202
( $response_code, $redirect_location) = &get_response ( 'http://www.businesslink.gov.uk/bdotg/action/layer?r.l1=1081986989&r.s=tl&topicId=1087252345' );
is( '301', $response_code, "The same page without =202 redirects" );
is( 'http://www.hmrc.gov.uk/agents/index.htm', 
	$redirect_location, "to the correct businesslink redirect" );

# Wales
( $response_code, $redirect_location) = &get_response ( 'http://www.businesslink.gov.uk/bdotg/action/layer?r.l1=1073858805&r.l2=1085541869&r.s=m&topicId=1073859188&site=230' );
is( '301', $response_code, "A sample site=230 redirects" );
is( 'http://business.wales.gov.uk/bdotg/action/layer?r.l1=1073858805&r.l2=1085541869&r.s=m&topicId=1073859188&site=230', 
	$redirect_location, "redirect is to the equivalent page on business.wales" );

# Same one without site=230
( $response_code, $redirect_location) = &get_response ( 'http://www.businesslink.gov.uk/bdotg/action/layer?r.l1=1073858805&r.l2=1085541869&r.s=m&topicId=1073859188' );
is( '301', $response_code, "The same page without site=230 redirects" );
is( 'https://www.gov.uk/vat-businesses', 
	$redirect_location, "to the correct businesslink redirect" );

# Northern Ireland
( $response_code, $redirect_location) = &get_response ( 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1073792345&r.l1=1073861225&r.l2=1073866217&r.l3=1074018703&r.s=sc&type=RESOURCES&site=191' );
is( '301', $response_code, "A sample site=191 redirects" );
is( 'http://www.nibusinessinfo.co.uk/bdotg/action/detail?itemId=1073792345&r.l1=1073861225&r.l2=1073866217&r.l3=1074018703&r.s=sc&type=RESOURCES&site=191', 
	$redirect_location, "redirect is the equivalent page on nibusinessinfo" );

# Same one without site=191
( $response_code, $redirect_location) = &get_response ( 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1073792345&r.l1=1073861225&r.l2=1073866217&r.l3=1074018703&r.s=sc&type=RESOURCES' );
is( '301', $response_code, "The same page without site=191 redirects" );
is( 'https://www.gov.uk/selling-your-business-your-responsibilities', 
	$redirect_location, "to the correct businesslink redirect" );


done_testing();