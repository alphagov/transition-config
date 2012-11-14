use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

if ( 'production' eq $ENV{'DEPLOY_TO'} ) {
    pass("Don't bother testing communities on production before it goes live.");
    done_testing();
    exit;
}

my $response_code;
my $redirect_location;

foreach my $url ( '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    ( $response_code, $redirect_location )
        = get_response( "http://www.dclg.gov.uk${url}" );
    is( $response_code, 301, "http://www.dclg.gov.uk${url}" );
    is( $redirect_location,
        "http://www.communities.gov.uk",
        'redirect is to www.communities'
    );
}

( $response_code, $redirect_location )
    = get_response( "http://www.communities.gov.uk/" );
is( $response_code, 301, "Communities homepage redirects" );
is( $redirect_location,
    'https://www.gov.uk/government/organisations/department-for-communities-and-local-government',
    'Communities homepage redirects'
);

( $response_code, $redirect_location )
    = get_response( "http://www.communities.gov.uk/corporate/" );
is( $response_code, 301, "Communities corporate homepage redirects" );
is( $redirect_location,
    'https://www.gov.uk/government/organisations/department-for-communities-and-local-government',
    'Communities homepage redirects'
);

done_testing();
