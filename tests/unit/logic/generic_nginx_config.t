use strict;
use warnings;
use Test::More tests=>19;
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


my $examplegov_redirect_awaiting_content = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport.html',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:examplegov source:mapping-exercise status:awaiting-content destination:content',
};
my( $awaiting_content_host, $awaiting_content_type, $awaiting_content ) = $mappings->row_as_nginx_config($examplegov_redirect_awaiting_content);
is( $awaiting_content_host, 'www.example.gov.uk', 
	'Host that config applies to is examplegov' );
is( $awaiting_content_type, 'location',
	'it is a location block'  );
is( $awaiting_content, qq(location ~* ^/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport\\.html/?\$ { return 302 https://www.gov.uk; }\n),
    'Nginx config is as expected' );



my $examplegov_no_url_open = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassporttest.html',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:open destination:content',
};
my( $no_new_url_open_host, $no_new_url_open_type, $no_new_url_open_content ) = $mappings->row_as_nginx_config($examplegov_no_url_open);
is( $no_new_url_open_host, 'www.example.gov.uk', 
	'Host that config applies to is examplegov' );
is( $no_new_url_open_type, 'unresolved',
	"If status is 301, whole tag 'status' is open, and there is no new url, this should be flagged as unresolved."  );
is( $no_new_url_open_content, "http://www.example.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassporttest.html\n",
    'The unresolved file will be populated with the URL.' );


my $examplegov_no_url_closed = { 
	'Old Url'	=> 'http://www.example.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourdrivinglicence.html',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:closed destination:content',
};
my( $no_new_url_closed_host, $no_new_url_closed_type, $no_new_url_closed_content ) = $mappings->row_as_nginx_config($examplegov_no_url_closed);
is( $no_new_url_closed_host, 'www.example.gov.uk', 
	'Host that config applies to is examplegov' );
is( $no_new_url_closed_type, 'no_destination_error',
	"If status is 301, whole tag 'status' is closed, and there is no new url, this is a 'no destination' error."  );
is( $no_new_url_closed_content, "http://www.example.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourdrivinglicence.html\n",
    "The 'no destination' error file will be populated with the URL." );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );
