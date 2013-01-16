use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';

my $response_code;
my $redirect_location;

my $url = '/';
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
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseekers.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseekers.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseeker.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseeker.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

$url = '/blah';
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
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseekers.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseekers.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseeker.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseeker.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

$url = '/some/url';
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
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseekers.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseekers.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseeker.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseeker.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

$url = '/who?eric=bananaman';
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
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseekers.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseekers.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);

( $response_code, $redirect_location )
    = get_response( "http://jobseeker.direct.gov.uk${url}" );
is( $response_code, 301, "http://jobseeker.direct.gov.uk${url}" );
is( $redirect_location,
    'https://www.gov.uk/jobsearch',
    'redirect from jobseekers to jobsearch'
);


done_testing();
