use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1081930072&type=PIP',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'redirect_map',
	'If host is businesslink and type is redirect, type of nginx block is redirect_map'  );
is( $redirect, qq(~itemId=1081930072 https://www.gov.uk/get-information-about-a-company;\n),
    'Nginx config is as expected' );

my $businesslink_gone = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?&r.s=tl&r.l1=1073861197&r.lc=en&topicId=1073858975',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($businesslink_gone);
is( $gone_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $gone_type, 'gone_map',
	'If host is businesslink and type is gone, type of nginx block is gone_map'  );
is( $gone, qq(~topicId=1073858975 410;\n),
    'Nginx config is as expected' );


my $businesslink_redirect_awaiting_content = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858854',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'Awaiting-content',
};
my( $awaiting_content_host, $awaiting_content_type, $awaiting_content ) = $mappings->row_as_nginx_config($businesslink_redirect_awaiting_content);
is( $awaiting_content_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $awaiting_content_type, 'awaiting_content_map',
	"If status is 301 and whole tag 'status' is 'awaiting content', type of nginx block is awaiting_content_map"  );
is( $awaiting_content, qq(~topicId=1073858854 418;\n),
    'Nginx config is as expected' );

my $businesslink_redirect_awaiting_publication = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858860',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301,
	'Whole Tag'	=> 'Awaiting-publication',
};
my( $awaiting_publication_host, $awaiting_publication_type, $awaiting_publication ) = $mappings->row_as_nginx_config($businesslink_redirect_awaiting_publication);
is( $awaiting_publication_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $awaiting_publication_type, 'awaiting_content_map',
	"If status is 301 and whole tag 'status' is 'awaiting publication', type of nginx block is awaiting_content_map"  );
is( $awaiting_publication, qq(~topicId=1073858860 418;\n),
    'Nginx config is as expected' );


my $businesslink_no_new_url_open = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858858',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'Open',
};
my( $no_new_url_open_host, $no_new_url_open_type, $no_new_url_open_content ) = $mappings->row_as_nginx_config($businesslink_no_new_url_open);
is( $no_new_url_open_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $no_new_url_open_type, 'no_destination_error',
	"If status is 301, whole tag 'status' is Open, and there is no new url, this is a 'no destination' error."  );
is( $no_new_url_open_content, "http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858858\n",
    "The 'no destination' file will be populated with the URL." );

my $businesslink_no_new_url_closed = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858859',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'Closed',
};
my( $no_new_url_closed_host, $no_new_url_closed_type, $no_new_url_closed_content ) = $mappings->row_as_nginx_config($businesslink_no_new_url_closed);
is( $no_new_url_closed_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $no_new_url_closed_type, 'no_destination_error',
	"If status is 301, whole tag 'status' is Closed, and there is no new url, this is a 'no destination' error."  );
is( $no_new_url_closed_content, "http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858859\n",
    "The 'no destination' error file will be populated with the URL." );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );

my $businesslink_home_url = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/home?topicId=1073858854',
	'New Url'	=> 'https://www.gov.uk',
	'Status'	=> 301,
	'Whole Tag'	=> 'Closed',
};
my( $businesslink_home_host, $businesslink_home_type, $businesslink_home_content ) = $mappings->row_as_nginx_config($businesslink_home_url);
is( $businesslink_home_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_home_type, 'location',
	"If the URL has a query string, and the path is /bdotg/action/home then it is a location redirect."  );
is( $businesslink_home_content, "location = /bdotg/action/home { return 301 https://www.gov.uk; }\n",
    "The homepage redirects to the gov.uk homepage" );

$businesslink_home_url = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/home?topicId=1073858854',
	'New Url'	=> 'https://www.test.uk',
	'Status'	=> 301,
	'Whole Tag'	=> 'Closed',
};
( $businesslink_home_host, $businesslink_home_type, $businesslink_home_content ) = $mappings->row_as_nginx_config($businesslink_home_url);
is( $businesslink_home_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_home_type, 'location',
	"If the URL has a query string, and the path is /bdotg/action/home then it is a location redirect."  );
is( $businesslink_home_content, qq(location = /bdotg/action/home { return 301 https://www.test.uk; }\n),
    "The GOV.UK homepage is not hard-coded" );


my $businesslink_friendly_url = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/tattoopeircingelectrolysis',
	'New Url'	=> '',
	'Status'	=> 410,
	'Whole Tag'	=> 'Closed',
};
my( $businesslink_friendly_url_host, $businesslink_friendly_url_type, 
	$businesslink_friendly_url_content ) = $mappings->row_as_nginx_config($businesslink_friendly_url);
is( $businesslink_friendly_url_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_friendly_url_type, 'location',
	"If the location has no query string, it is a location block."  );
is( $businesslink_friendly_url_content, "location ~* ^/tattoopeircingelectrolysis\$ { return 410; }\n",
    "A friendly URL with a 410 creates a 410 location config line." );


$businesslink_friendly_url = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/yorkshire',
	'New Url'	=> 'https://www.gov.uk/yorkshire',
	'Status'	=> 301,
	'Whole Tag'	=> 'Closed',
};
( $businesslink_friendly_url_host, $businesslink_friendly_url_type, 
	$businesslink_friendly_url_content ) = $mappings->row_as_nginx_config($businesslink_friendly_url);
is( $businesslink_friendly_url_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_friendly_url_type, 'location',
	"If the location has no query string, it is a location block."  );
is( $businesslink_friendly_url_content, "location ~* ^/yorkshire\$ { return 301 https://www.gov.uk/yorkshire; }\n",
    "A friendly URL with a 301 creates a location redirect." );


my $businesslink_friendly_url_with_querystring = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/tattoopeircingelectrolysis?topicId=1073858865',
	'New Url'	=> 'http://www.gov.uk/testresult',
	'Status'	=> 301,
	'Whole Tag'	=> 'Closed',
};
my( $businesslink_friendly_host_with_querystring, $businesslink_friendly_type_with_querystring, 
	$businesslink_friendly_content_with_querystring ) = $mappings->row_as_nginx_config($businesslink_friendly_url_with_querystring);
is( $businesslink_friendly_host_with_querystring, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $businesslink_friendly_type_with_querystring, 'redirect_map',
	"If there is a query string, then it should to go a map, even if it looks like a friendly url"  );
is( $businesslink_friendly_content_with_querystring, "~topicId=1073858865 http://www.gov.uk/testresult;\n", 
	"A friendly URL does not contain a query string" );

done_testing();
