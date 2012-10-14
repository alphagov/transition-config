use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';



my $response_code;
my $redirect_location;

foreach my $url ( '', '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    ( $response_code, $redirect_location )
        = get_response( "http://improve.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://improve.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/browse/business',
        'redirect is to correct gov.uk URL'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://www.improve.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://www.improve.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/browse/business',
        'redirect is to correct gov.uk URL'
    );
}

done_testing();
