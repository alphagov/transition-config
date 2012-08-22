use strict;
use warnings;
use Test::More tests => 4;
use Mappings;

use constant NGINX_CONFIG => qq(location = /16-19bursary { return 301 https://www.gov.uk/1619-bursary-fund; }\n);
use constant DOMAINS_LIST => qw( www.direct.gov.uk www.businesslink.gov.uk );

my $mappings = Mappings->new( 'tests/multiple_sites.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
ok( $configs->{'www.direct.gov.uk'} eq NGINX_CONFIG, 'directgov config exists' );
ok( $configs->{'www.businesslink.gov.uk'} eq NGINX_CONFIG, 'businesslink config exists' );
is( keys %$configs, DOMAINS_LIST, 'only two domains found' );
