use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

use constant BYPASS_REDIRECTOR => 1;


my $response_code;
my $redirect_location;

foreach my $url ( '', '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    ( $response_code, $redirect_location )
        = get_response( "http://events.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://events.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/business-training-and-networking-events-near-you',
        'redirect is to correct gov.uk URL'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://www.events.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://www.events.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/business-training-and-networking-events-near-you',
        'redirect is to correct gov.uk URL'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://admin.events.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://admin.events.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.business-events.org.uk',
        'redirect is to www.business-events.org.uk'
    );
}

# events.nibusinessinfo.co.uk does not hit the redirector
( $response_code, $redirect_location )
    = get_response( 'http://events.nibusinessinfo.co.uk', BYPASS_REDIRECTOR );
is( $response_code, 301, 'http://events.nibusinessinfo.co.uk' );
is( $redirect_location,
    'http://www.events.nibusinessinfo.co.uk/',
    'redirect is to www.events.nibusinessinfo.co.uk'
);
( $response_code, $redirect_location )
    = get_response( 'http://www.events.nibusinessinfo.co.uk', BYPASS_REDIRECTOR );
is( $response_code, 200, 'http://www.events.nibusinessinfo.co.uk' );
is( $redirect_location,
    undef,
    'www.events.nibusinessinfo.co.uk is not a redirect'
);

done_testing();
