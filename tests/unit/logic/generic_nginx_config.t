use strict;
use warnings;
use Test::More tests=>10;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $examplegov_redirect = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies.html',
	'New Url'	=> 'https://www.gov.uk/example/page',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($examplegov_redirect);
is( $redirect_host, 'www.example.gov.uk', 
	'Host that config applies to is example' );
is( $redirect_type, 'location',
	'it is a location block' );
is( $redirect, qq(location ~* ^/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies\\.html/?\$ { return 301 https://www.gov.uk/example/page; }\n),
    'Nginx config is as expected' );


my $examplegov_gone = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/Dl1/Directories.html',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($examplegov_gone);
is( $gone_host, 'www.example.gov.uk', 
	'Host that config applies to is examplegov' );
is( $gone_type, 'location',
	'it is a location block'  );
is( $gone, qq(location ~* ^/en/Dl1/Directories\\.html/?\$ { return 410; }\n),
    'Nginx config is as expected' );


my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );
