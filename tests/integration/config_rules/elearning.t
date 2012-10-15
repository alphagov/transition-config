use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';



my $response_code;
my $redirect_location;

( $response_code, $redirect_location )
    = get_response( 'http://www.elearning.businesslink.gov.uk/startingup/0064' );
is( $response_code, 301, 'http://www.elearning.businesslink.gov.uk/startingup/0064' );
is( $redirect_location,
    'https://www.gov.uk/corporation-tax-rates',
    'redirect is to correct gov.uk URL'
);

foreach my $url ( '', '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    ( $response_code, $redirect_location )
        = get_response( "http://www.elearning.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://www.elearning.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/browse/business',
        'redirect is to correct gov.uk URL'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://elearning.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://elearning.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/browse/business',
        'redirect is to correct gov.uk URL'
    );
}

done_testing();
