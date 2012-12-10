use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my $response_code;
my $redirect_location;

( $response_code, $redirect_location ) = get_response( "http://www.dclg.gov.uk/" );
is( $response_code, 301, "ends in /" );
is( $redirect_location,
        "http://www.communities.gov.uk",
        'redirect is to www.communities'
    );

( $response_code, $redirect_location ) = get_response( "http://www.dclg.gov.uk/blah" );
is( $response_code, 301, "ends in /blah" );
is( $redirect_location,
        "http://www.communities.gov.uk",
        'redirect is to www.communities'
    );

( $response_code, $redirect_location ) = get_response( "http://www.dclg.gov.uk/some/url" );
is( $response_code, 301, "ends in /some/url" );
is( $redirect_location,
        "http://www.communities.gov.uk",
        'redirect is to www.communities'
    );

( $response_code, $redirect_location ) = get_response( "http://www.dclg.gov.uk/who?eric=bananaman" );
is( $response_code, 301, "ends in /who?eric=bananaman" );
is( $redirect_location,
        "http://www.communities.gov.uk",
        'redirect is to www.communities'
    );

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
