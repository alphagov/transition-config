use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';



my $host_type = $ENV{'DEPLOY_TO'} // "dev";
my $response_code;
my $redirect_location;


if ( 'production' eq $host_type ) {
    ( $response_code, $redirect_location )
        = get_response( 'http://www.elearning.businesslink.gov.uk/startingup/0064' );
    is( $response_code, 301, 'http://elearning.businesslink.gov.uk/startingup/0064' );
    is( $redirect_location,
        'http://elearning.businesslink.gov.uk/startingup/0064',
        'redirect is to elearning without www'
    );
}

( $response_code, $redirect_location )
    = get_response( 'http://elearning.businesslink.gov.uk/startingup/0064' );
is( $response_code, 301, 'http://elearning.businesslink.gov.uk/startingup/0064' );
is( $redirect_location,
    'https://www.gov.uk/pay-corporation-tax',
    'redirect is to correct gov.uk URL'
);

foreach my $url ( '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    if ( 'production' eq $host_type ) {
        ( $response_code, $redirect_location )
            = get_response( "http://www.elearning.businesslink.gov.uk${url}" );
        is( $response_code, 301, "http://www.elearning.businesslink.gov.uk${url}" );
        is( $redirect_location,
            "http://elearning.businesslink.gov.uk${url}",
            'redirect is to elearning without www'
        );
    }
    
    ( $response_code, $redirect_location )
        = get_response( "http://elearning.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://elearning.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/browse/business',
        'redirect is to correct gov.uk URL'
    );
}

done_testing();
