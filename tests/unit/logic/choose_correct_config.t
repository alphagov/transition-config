use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies.html',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'Directgov is always location' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en?blah&blah',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'redirect_map',
	'Directgov is no longer always location, query string or no' );

my $businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1081930072&type=PIP',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'redirect_map',
	'If host is businesslink and url has query string, type of nginx block is redirect_map'  );

$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'location',
	'If host is businesslink and there is no query string, it is assumed to be a FURL'  );

my $unspecified_redirect = { 
	'Old Url'	=> 'http://www.example.gov.uk/bdotg/action/detail?itemId=101181930072&type=PIP',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($unspecified_redirect);
is( $redirect_host, 'www.example.gov.uk', 
	'Host that config applies to is example' );
is( $redirect_type, 'redirect_map',
	'If host is unspecified and url has query string, type of nginx block is map'  );

$unspecified_redirect = { 
	'Old Url'	=> 'http://www.example.gov.uk/bdotg/action/detail1',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($unspecified_redirect);
is( $redirect_host, 'www.example.gov.uk', 
	'Host that config applies to is example' );
is( $redirect_type, 'location',
	'If host is unspecified and url has no query string, type of nginx block is assumed to be location (for now)'  );


done_testing();