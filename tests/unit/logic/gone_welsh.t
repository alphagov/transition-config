use strict;
use warnings;
use Test::More tests => 2;
use Mappings;



my %expected = (
        'www.direct.gov.uk' => {
            'location' => qq(location = /cy/Parents/Yourchildshealthandsafety/WorriedAbout/DG_10026210CY { return 301 https://www.gov.uk/cymraeg; }\nlocation = /en/Nl1/Newsroom/DG_187286 { return 410; }\n),
        },
    );


my $mappings = Mappings->new( 'tests/unit/gone_welsh.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
is_deeply( $configs, \%expected, 'expected config');
