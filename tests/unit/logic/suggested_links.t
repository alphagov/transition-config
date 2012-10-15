use strict;
use warnings;
use Test::More tests => 2;
use Mappings;



my %expected = (
        'www.direct.gov.uk' => {

            'location' => qq(location ~* ^/16-19bursary\$ { return 410; }\nlocation ~* ^/en/(.*/)?dg_10034785\$ { return 410; }\n),
            'location_suggested_links' => qq(\$location_suggested_links['/16-19bursary'] = "<a href='http://www.dwp.gov.uk'>Department for &lt;b&gt;''Work and Pensions''&lt;/b&gt;</a>";\n),
        },
        'www.businesslink.gov.uk' => {
            'gone_map' => qq(~topicId=1073858783 410;\n),
            'suggested_links_map' => qq(\$query_suggested_links['topicId=1073858783'] = "<a href='http://www.hmrc.gov.uk'>HMRC</a>";\n),
        },
    );


my $mappings = Mappings->new( 'tests/unit/suggested_links.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
is_deeply( $configs, \%expected, 'expected config');
