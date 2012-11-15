use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $gone_url_with_brace = { 
    'Old Url'   => 'http://www.communities.gov.uk/documents/planningandbuilding/pdf/hedgeheight.pdf)',
    'New Url'   => '',
    'Status'    => 410,
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($gone_url_with_brace);
is( $redirect_host, 'www.communities.gov.uk', 
    'Host that config applies to is communities.gov' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/documents/planningandbuilding/pdf/hedgeheight\\.pdf\\\)/?\$ { return 410; }\n),
    'Nginx redirect has escaped close brace' );

done_testing();
