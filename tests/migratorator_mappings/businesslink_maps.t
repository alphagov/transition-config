use strict;
use warnings;
use Test::More tests => 2;
use Mappings;

my %expected = (
	'www.businesslink.gov.uk' => {
		'redirect_map' => qq(~topicId=1073858783 https://www.gov.uk;\n~detail.*itemId=5001241747 https://www.gov.uk/browse/business#/intellectual-property;\n~detail.*itemId=1081930072 https://www.gov.uk/get-information-about-a-company;\n),
		'gone_map'     => qq(~layer.*topicId=1073858811 410;\n~detail.*itemId=1075313260 410;\n),
	}
);

my $mappings = Mappings->new( 'tests/migratorator_mappings/test_business_link.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
is_deeply( $configs, \%expected, 'expected config');
