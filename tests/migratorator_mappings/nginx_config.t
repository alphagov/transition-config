use strict;
use warnings;
use Test::More tests => 13;
use Mappings;


my $mappings = Mappings->new( 'tests/migratorator_mappings/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
ok( $redirect_host eq 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
ok( $redirect_type eq 'location',
	'If host is Directgov and type is redirect, type of nginx block is location'  );
ok( $redirect eq qq(location = /en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943 { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx config is as expected' );


my $directgov_gone = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/Dl1/Directories/DG_10011810',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($directgov_gone);
ok( $gone_host eq 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
ok( $gone_type eq 'location',
	'If host is Directgov and type is gone, type of nginx block is location'  );
ok( $gone eq qq(location = /en/Dl1/Directories/DG_10011810 { return 410; }\n),
    'Nginx config is as expected' );


my $directgov_redirect_without_url = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/Nl1/Newsroom/DG_200994',
	'New Url'	=> '',
	'Status'	=> 301, 
};
my( $redirect_without_url_host, $redirect_without_url_type, $redirect_without_url  ) = $mappings->row_as_nginx_config($directgov_redirect_without_url);
ok( $redirect_without_url_host eq 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
ok( $redirect_without_url_type eq 'location',
    'invalid type is location'  );
use constant INVALID_NGINX  => qq(# invalid entry: status='301' old='http://www.direct.gov.uk/en/Nl1/Newsroom/DG_200994' new=''\n);
ok( INVALID_NGINX  eq $redirect_without_url, 
	'invalid nginx is produced' );


my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );
