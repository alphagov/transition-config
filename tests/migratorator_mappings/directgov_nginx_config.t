use strict;
use warnings;
use Test::More tests=>19;
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
	'If host is Directgov and type is redirect, type of nginx block is location' );
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


my $directgov_redirect_awaiting_content = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport/DG_174165',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:awaiting-content destination:content',
};
my( $awaiting_content_host, $awaiting_content_type, $awaiting_content ) = $mappings->row_as_nginx_config($directgov_redirect_awaiting_content);
ok( $awaiting_content_host eq 'www.direct.gov.uk', 
	'Host that config applies to is Directgov' );
ok( $awaiting_content_type eq 'location',
	'If host is Directgov and type is awaiting content, type of nginx block is location'  );
ok( $awaiting_content eq qq(location = /en/TravelAndTransport/Passports/Howtochangethenameonyourpassport/DG_174165 { return 418; }\n),
    'Nginx config is as expected' );



my $directgov_no_url_open = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport/DG_174165',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:open destination:content',
};
my( $no_new_url_open_host, $no_new_url_open_type, $no_new_url_open_content ) = $mappings->row_as_nginx_config($directgov_no_url_open);
ok( $no_new_url_open_host eq 'www.direct.gov.uk', 
	'Host that config applies to is Directgov' );
ok( $no_new_url_open_type eq 'unresolved',
	"If status is 301, whole tag 'status' is open, and there is no new url, this should be flagged as unresolved."  );
ok( $no_new_url_open_content eq "http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport/DG_174165\n",
    'The unresolved file will be populated with the URL.' );


my $directgov_no_url_closed = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport/DG_174165',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:closed destination:content',
};
my( $no_new_url_closed_host, $no_new_url_closed_type, $no_new_url_closed_content ) = $mappings->row_as_nginx_config($directgov_no_url_closed);
ok( $no_new_url_closed_host eq 'www.direct.gov.uk', 
	'Host that config applies to is Directgov' );
ok( $no_new_url_closed_type eq 'no_destination_error',
	"If status is 301, whole tag 'status' is closed, and there is no new url, this is a 'no destination' error."  );
ok( $no_new_url_closed_content eq "http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport/DG_174165\n",
    "The 'no destination' error file will be populated with the URL." );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );