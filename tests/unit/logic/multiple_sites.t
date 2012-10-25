use strict;
use warnings;
use Test::More tests => 2;
use Mappings;



my %expected = (
        'www.direct.gov.uk' => {
            'location' => qq(location ~* ^/16-19bursary\$ { return 301 https://www.gov.uk/1619-bursary-fund; }\n),
        },
        'www.businesslink.gov.uk' => {
            'redirect_map' => qq(~topicId=1073858783 https://www.gov.uk/;\n),
        },
    );


my $mappings = Mappings->new( 'tests/unit/test_data/multiple_sites.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
is_deeply( $configs, \%expected, 'expected config');
