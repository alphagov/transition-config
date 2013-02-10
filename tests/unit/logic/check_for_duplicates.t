use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $mapping = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'If host is Directgov and type is redirect, type of nginx block is location' );
is( $redirect, qq(location ~* ^/en/(.*/)?dg_201943\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx config is as expected' );

$mapping = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'duplicate_entry_error',
	'Same old URL is a duplicate_entry_error' );

$mapping = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/DG_201943',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'duplicate_entry_error',
	'Same DG number isa_ok a duplicate_entry_error' );


$mapping = { 
	'Old Url'	=> 'http://www.direct.gov.uk/pensioncredit',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'If host is Directgov and type is redirect, type of nginx block is location' );
is( $redirect, qq(location ~* ^/pensioncredit/?\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx config is as expected' );


$mapping = { 
	'Old Url'	=> 'http://www.direct.gov.uk/pensioncredit',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'duplicate_entry_error',
	'Duplicate without DG number is still duplicate_entry_error' );

$mapping = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/tax',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'location',
	'Type is location' );
is( $redirect, qq(location ~* ^/tax/?\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx config is as expected' );

# $mapping = { 
# 	'Old Url'	=> 'http://www.businesslink.gov.uk/tax/',
# 	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
# 	'Status'	=> 301, 
# };
# ( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
# is( $redirect_host, 'www.businesslink.gov.uk', 
# 	'Host that config applies to is businesslink' );
# is( $redirect_type, 'duplicate_entry_error',
# 	'Trailing slash counts as duplicate_entry_error' );

$mapping = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail?itemid=1073789114&type=RESOURCES',
	'New Url'	=> 'https://www.gov.uk/running-a-limited-company/directors-responsibilities',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'redirect_map',
	'Type is redirect_map' );
is( $redirect, qq(~*itemid=1073789114 https://www.gov.uk/running-a-limited-company/directors-responsibilities;\n),
    'Nginx config is as expected' );


$mapping = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail/blah?type=RESOURCES&itemid=1073789114',
	'New Url'	=> 'https://www.gov.uk/running-a-limited-company/directors-responsibilities',
	'Status'	=> 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($mapping);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'duplicate_entry_error',
	'duplicate itemid for Businesslink is duplicate' );



done_testing();
