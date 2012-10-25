use strict;
use warnings;
use Test::More tests => 7;
use Mappings;



my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );


my $missing_old_url = { 
    'Old Url' => '',
    'New Url' => 'https://www.gov.uk/working-tax-credit/overview',
    'Status'  => 301, 
};
my( $missing_url_host, $missing_url_type, $missing_url_output ) = $mappings->row_as_nginx_config($missing_old_url);
is( $missing_url_host, 'no_host', 
    'No host as the Old Url is missing' );
is( $missing_url_type, 'no_source_url',
    'No host gives a type of no_source_url' );
is( $missing_url_output, qq(https://www.gov.uk/working-tax-credit/overview\n),
    'Returns new_url in case that is helpful for debugging' );


my $missing_status = { 
    'Old Url' => 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1081930072&type=PIP',
    'New Url' => 'https://www.gov.uk/working-tax-credit/overview',
    'Status'  => '', 
};
my( $missing_status_host, $missing_status_type, $missing_status_output ) = $mappings->row_as_nginx_config($missing_status);
is( $missing_status_host, 'www.businesslink.gov.uk', 
    'Host is Businesslink' );
is( $missing_status_type, 'no_status',
    'No status gives a type of no_status' );
is( $missing_status_output, qq(http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1081930072&type=PIP\n),
    'Returns old_url in case that is helpful for debugging' );
