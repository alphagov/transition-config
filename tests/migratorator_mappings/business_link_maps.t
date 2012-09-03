use strict;
use warnings;
use Test::More tests => 2;
use Mappings;

my %expected = (
	'www.businesslink.gov.uk' => {
		'redirect_map' => qq(~\\btopicId=1073858783\\b https://www.gov.uk/;\n~\\bitemId=5001241747\\b https://www.gov.uk/browse/business#/intellectual-property;\n~\\bitemId=1081930072\\b https://www.gov.uk/get-information-about-a-company;\n),
		'gone_map'     => qq(~\\btopicId=1073858811\\b 410;\n~\\bitemId=1075313260\\b 410;\n),
	}
);

my $mappings = Mappings->new( 'tests/integration/test_business_link.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
is_deeply( $configs, \%expected, 'expected config');
