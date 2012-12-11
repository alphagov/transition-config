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
        = get_response( "http://www.improve.businesslink.gov.uk/content/protecting-your-business" );
    is( $response_code, 301, "http://www.improve.businesslink.gov.uk/content/protecting-your-business" );
    is( $redirect_location,
        'http://improve.businesslink.gov.uk/content/protecting-your-business',
        'redirect is to improve without www'
    );
}

( $response_code, $redirect_location )
    = get_response( "http://improve.businesslink.gov.uk/content/protecting-your-business" );
is( $response_code, 301, "http://improve.businesslink.gov.uk/content/protecting-your-business" );
is( $redirect_location,
    'https://www.gov.uk/intellectual-property-an-overview',
    'redirect is to correct gov.uk URL'
);

if ( 'production' eq $host_type ) {
    ( $response_code, $redirect_location )
        = get_response( "http://www.improve.businesslink.gov.uk/bl_tools/export_node_xml" );
    is( $response_code, 301, "http://www.improve.businesslink.gov.uk/bl_tools/export_node_xml" );
    is( $redirect_location,
        "http://improve.businesslink.gov.uk/bl_tools/export_node_xml",
        'redirect is to improve without www'
    );
}

( $response_code, $redirect_location )
    = get_response( "http://improve.businesslink.gov.uk/bl_tools/export_node_xml" );
is( $response_code, 200, "http://improve.businesslink.gov.uk/bl_tools/export_node_xml" );

foreach my $url ( '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    if ( 'production' eq $host_type ) {
        ( $response_code, $redirect_location )
            = get_response( "http://www.improve.businesslink.gov.uk${url}" );
        is( $response_code, 301, "http://www.improve.businesslink.gov.uk${url}" );
        is( $redirect_location,
            "http://improve.businesslink.gov.uk${url}",
            'redirect is to improve without www'
        );
    }
    
    ( $response_code, $redirect_location )
        = get_response( "http://improve.businesslink.gov.uk${url}" );
    is( $response_code, 301, "http://improve.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/growing-your-business',
        'redirect is to correct gov.uk URL'
    );
}

done_testing();
