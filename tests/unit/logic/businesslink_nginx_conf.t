use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail?itemid=1081930072&type=PIP',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'redirect_map',
	'If host is businesslink and type is redirect, type of nginx block is redirect_map'  );
is( $redirect, qq(~*itemid=1081930072 https://www.gov.uk/get-information-about-a-company;\n),
    'Nginx config is as expected' );

my $businesslink_gone = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?&r.s=tl&r.l1=1073861197&r.lc=en&topicid=1073858975',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($businesslink_gone);
is( $gone_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $gone_type, 'gone_map',
	'If host is businesslink and type is gone, type of nginx block is gone_map'  );
is( $gone, qq(~*topicid=1073858975 410;\n),
    'Nginx config is as expected' );

my $businesslink_no_map_key = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?&r.s=tl&r.l1=1073861197&r.lc=en&tcid=1073858975',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $no_key_host, $no_key_type, $no_map_key ) = $mappings->row_as_nginx_config($businesslink_no_map_key);
is( $no_key_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $no_key_type, 'no_map_key_error',
	'If map key cannot be found type of nginx block is gone_map'  );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );


my $businesslink_friendly_url = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/tattoopeircingelectrolysis',
	'New Url'	=> '',
	'Status'	=> 410,
};
my( $businesslink_friendly_url_host, $businesslink_friendly_url_type, 
	$businesslink_friendly_url_content ) = $mappings->row_as_nginx_config($businesslink_friendly_url);
is( $businesslink_friendly_url_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_friendly_url_type, 'location',
	"If the location has no query string, it is a location block."  );
is( $businesslink_friendly_url_content, "location ~* ^/tattoopeircingelectrolysis/?\$ { return 410; }\n",
    "A friendly URL with a 410 creates a 410 location config line." );


$businesslink_friendly_url = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/yorkshire',
	'New Url'	=> 'https://www.gov.uk/yorkshire',
	'Status'	=> 301,
};
( $businesslink_friendly_url_host, $businesslink_friendly_url_type, 
	$businesslink_friendly_url_content ) = $mappings->row_as_nginx_config($businesslink_friendly_url);
is( $businesslink_friendly_url_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_friendly_url_type, 'location',
	"If the location has no query string, it is a location block."  );
is( $businesslink_friendly_url_content, "location ~* ^/yorkshire/?\$ { return 301 https://www.gov.uk/yorkshire; }\n",
    "A friendly URL with a 301 creates a location redirect." );


my $businesslink_friendly_url_with_querystring = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/tattoopeircingelectrolysis?topicid=1073858865',
	'New Url'	=> 'http://www.gov.uk/testresult',
	'Status'	=> 301,
};
my( $businesslink_friendly_host_with_querystring, $businesslink_friendly_type_with_querystring, 
	$businesslink_friendly_content_with_querystring ) = $mappings->row_as_nginx_config($businesslink_friendly_url_with_querystring);
is( $businesslink_friendly_host_with_querystring, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_friendly_type_with_querystring, 'redirect_map',
	"If there is a query string, then it should to go a map, even if it looks like a friendly url"  );
is( $businesslink_friendly_content_with_querystring, "~*topicid=1073858865 http://www.gov.uk/testresult;\n", 
	"A friendly URL does not contain a query string" );

my $businesslink_friendly_url_with_empty_querystring = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/tattoos?',
	'New Url'	=> 'https://www.gov.uk/testresult',
	'Status'	=> 301,
};
my( $host, $type, $line ) = $mappings->row_as_nginx_config($businesslink_friendly_url_with_empty_querystring);
is( $host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $type, 'location',
	"If there is a query string and it is empty then it is location"  );
is( $line, "location ~* ^/tattoos/?\$ { return 301 https://www.gov.uk/testresult; }\n", 
	"A friendly URL does not contain a query string" );

my $businesslink_page_redirect = {
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/staticpage?page=Accessibility',
	'New Url'	=> 'https://www.gov.uk/support/accessibility',
	'Status'	=> 301,
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_page_redirect);
is( $redirect_host, 'www.businesslink.gov.uk',
	'Host that config applies to is businesslink' );
is( $redirect_type, 'redirect_map',
	'If host is businesslink and type is redirect, type of nginx block is redirect_map'  );
is( $redirect, qq(~*page=Accessibility https://www.gov.uk/support/accessibility;\n),
    'Nginx config is as expected' );

done_testing();
