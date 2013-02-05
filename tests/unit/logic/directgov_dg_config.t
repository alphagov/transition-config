use strict;
use warnings;
use Test::More tests=>10;
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


my $directgov_gone = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/Dl1/Directories/DG_10011810',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($directgov_gone);
is( $gone_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $gone_type, 'location',
	'If host is Directgov and type is gone, type of nginx block is location'  );
is( $gone, qq(location ~* ^/en/(.*/)?dg_10011810\$ { return 410; }\n),
    'Nginx config is as expected' );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );