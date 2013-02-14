use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $examplegov_redirect_location = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies.html',
	'New Url'	=> 'https://www.gov.uk/example/page',
	'Status'	=> 301, 
};
my( $host, $type, $config ) = $mappings->row_as_nginx_config($examplegov_redirect_location);
is( $host, 'www.example.gov.uk', 
	'Host that config applies to is example' );
is( $type, 'location',
	'it is a location block' );
is( $config, qq(location ~* ^/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies\\.html/?\$ { return 301 https://www.gov.uk/example/page; }\n),
    'Nginx config is as expected' );


my $examplegov_gone_location = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/Dl1/Directories.html',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $type, $config ) = $mappings->row_as_nginx_config($examplegov_gone_location);
is( $host, 'www.example.gov.uk', 
	'Host that config applies to is examplegov' );
is( $type, 'location',
	'it is a location block'  );
is( $config, qq(location ~* ^/en/Dl1/Directories\\.html/?\$ { return 410; }\n),
    'Nginx config is as expected' );

my $examplegov_418_location = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/Directories.html',
	'New Url'	=> 'https://www.gov.uk/example/page',
	'Status'	=> 418, 
};
( $host, $type, $config ) = $mappings->row_as_nginx_config($examplegov_418_location);
is( $host, 'www.example.gov.uk', 
	'Host that config applies to is examplegov' );
is( $type, 'location',
	'it is a location block'  );
is( $config, qq(location ~* ^/en/Directories\\.html/?\$ { return 418; }\n),
    'Nginx config is as expected' );



my $examplegov_redirect_map = { 
	'Old Url'	=> 'http://www.example.gov.uk?TaxCredits/Gettingstarted/whoqualifies.html',
	'New Url'	=> 'https://www.gov.uk/example/page',
	'Status'	=> 301, 
};
( $host, $type, $config ) = $mappings->row_as_nginx_config($examplegov_redirect_map);
is( $host, 'www.example.gov.uk', 
	'Host that config applies to is example' );
is( $type, 'redirect_map',
	'it is a redirect map' );
is( $config, qq(~*TaxCredits/Gettingstarted/whoqualifies.html https://www.gov.uk/example/page;\n),
    'Nginx config is as expected' );


my $examplegov_gone_map = { 
	'Old Url'	=> 'http://www.example.gov.uk?TaxCredits/whoqualifies.html',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $type, $config ) = $mappings->row_as_nginx_config($examplegov_gone_map);
is( $host, 'www.example.gov.uk', 
	'Host that config applies to is example' );
is( $type, 'gone_map',
	'it is a gone map' );
is( $config, qq(~*TaxCredits/whoqualifies.html 410;\n),
    'Nginx config is as expected' );


my $examplegov_418_map = { 
	'Old Url'	=> 'http://www.example.gov.uk?TaxCredits/test/whoqualifies.html',
	'New Url'	=> 'https://www.gov.uk/example/page',
	'Status'	=> 418, 
};
( $host, $type, $config ) = $mappings->row_as_nginx_config($examplegov_418_map);
is( $host, 'www.example.gov.uk', 
	'Host that config applies to is example' );
is( $type, 'awaiting_content_map',
	'it is an awaiting content map' );
is( $config, qq(~*TaxCredits/test/whoqualifies.html 418;\n),
    'Nginx config is as expected' );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );

done_testing();
