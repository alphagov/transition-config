use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my $response_code;
my $redirect_location;

foreach my $url ( '/', '/blah', '/some/url', '/who?eric=bananaman' ) {
    ( $response_code, $redirect_location )
        = get_response( "https://edon.businesslink.gov.uk${url}" );
    is( $response_code, 301, "https://edon.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/advertise-job',
        'redirect from edon to advertise-job'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "https://jobwarehouse.businesslink.gov.uk${url}" );
    is( $response_code, 301, "https://jobwarehouse.businesslink.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/advertise-job',
        'redirect from jobwarehouse to advertise-job'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://www.jobseekers.direct.gov.uk${url}" );
    is( $response_code, 301, "http://www.jobseekers.direct.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/jobs-jobsearch',
        'redirect from jobseekers to jobs-jobsearch'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://jobseekers.direct.gov.uk${url}" );
    is( $response_code, 301, "http://jobseekers.direct.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/jobs-jobsearch',
        'redirect from jobseekers to jobs-jobsearch'
    );
    
    ( $response_code, $redirect_location )
        = get_response( "http://jobseeker.direct.gov.uk${url}" );
    is( $response_code, 301, "http://jobseeker.direct.gov.uk${url}" );
    is( $redirect_location,
        'https://www.gov.uk/jobs-jobsearch',
        'redirect from jobseekers to jobs-jobsearch'
    );
}

done_testing();
