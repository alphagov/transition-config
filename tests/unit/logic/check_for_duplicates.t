use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'If host is Directgov and type is redirect, type of nginx block is location' );
is( $redirect, qq(location ~* ^/en/(.*/)?dg_201943\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx config is as expected' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'duplicate_entry_error',
	'Same old URL is a duplicate_entry_error' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/DG_201943',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'duplicate_entry_error',
	'Same DG number isa_ok a duplicate_entry_error' );


$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/pensioncredit',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'If host is Directgov and type is redirect, type of nginx block is location' );
is( $redirect, qq(location ~* ^/pensioncredit/?\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx config is as expected' );


$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/pensioncredit',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'duplicate_entry_error',
	'Duplicate without DG number is still duplicate_entry_error' );



done_testing();