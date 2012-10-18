use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

use constant BYPASS_REDIRECTOR => 1;


my $response_code;
my $redirect_location;

( $response_code, $redirect_location )
    = get_response( 'http://www.ukwelcomes.businesslink.gov.uk/bdotg/action/piplink?agency_id=875&service_id=16200010001&site=2000' );
is( $response_code, 301, 'http://www.ukwelcomes.businesslink.gov.uk/bdotg/action/piplink?agency_id=875&service_id=16200010001&site=2000' );
is( $redirect_location,
    'https://www.gov.uk/apply-for-a-licence/temporary-event-notice/cheshire-west-and-chester/apply-1',
    'redirect is to correct licence on gov.uk'
);

( $response_code, $redirect_location )
    = get_response( 'http://ukwelcomes.businesslink.gov.uk/bdotg/action/piplink?agency_id=875&service_id=16200010001&site=2000' );
is( $response_code, 301, 'http://ukwelcomes.businesslink.gov.uk/bdotg/action/piplink?agency_id=875&service_id=16200010001&site=2000' );
is( $redirect_location,
    'https://www.gov.uk/apply-for-a-licence/temporary-event-notice/cheshire-west-and-chester/apply-1',
    'redirect is to correct licence on gov.uk'
);

foreach my $url ( '', '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    ( $response_code, $redirect_location )
        = get_response( "http://ukwelcomes.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://ukwelcomes.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/uk-welcomes-business',
        'redirect is to correct gov.uk URL'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://www.ukwelcomes.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://www.ukwelcomes.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/uk-welcomes-business',
        'redirect is to correct gov.uk URL'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://upload.ukwelcomes.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://upload.ukwelcomes.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/uk-welcomes-business',
        'redirect is to correct gov.uk URL'
    );
}

done_testing();
