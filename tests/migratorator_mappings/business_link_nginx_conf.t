use strict;
use warnings;
use Test::More tests=>19;
use Mappings;


my $mappings = Mappings->new( 'tests/migratorator_mappings/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1081930072&type=PIP',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
ok( $redirect_host eq 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
ok( $redirect_type eq 'redirect_map',
	'If host is businesslink and type is redirect, type of nginx block is redirect_map'  );
ok( $redirect eq qq(~itemId=1081930072 https://www.gov.uk/get-information-about-a-company;\n),
    'Nginx config is as expected' );

my $businesslink_gone = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?&r.s=tl&r.l1=1073861197&r.lc=en&topicId=1073858975',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($businesslink_gone);
ok( $gone_host eq 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
ok( $gone_type eq 'gone_map',
	'If host is businesslink and type is gone, type of nginx block is gone_map'  );
ok( $gone eq qq(~topicId=1073858975 410;\n),
    'Nginx config is as expected' );


my $businesslink_redirect_awaiting_content = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858854',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'Awaiting-content',
};
my( $awaiting_content_host, $awaiting_content_type, $awaiting_content ) = $mappings->row_as_nginx_config($businesslink_redirect_awaiting_content);
ok( $awaiting_content_host eq 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
ok( $awaiting_content_type eq 'gone_map',
	'If host is businesslink and type is awaiting content, type of nginx block is awaiting_content_map'  );
ok( $awaiting_content eq qq(~topicId=1073858854 418;\n),
    'Nginx config is as expected' );


my $businesslink_no_new_url_open = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858854',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'Open',
};
my( $no_new_url_open_host, $no_new_url_open_type, $no_new_url_open_content ) = $mappings->row_as_nginx_config($businesslink_no_new_url_open);
ok( $no_new_url_open_host eq 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
ok( $no_new_url_open_type eq 'unresolved',
	"If status is 301, whole tag 'status' is Open, and there is no new url, this should be flagged as unresolved."  );
ok( $no_new_url_open_content eq "http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858854\n",
    'The unresolved file will be populated with the URL.' );

my $businesslink_no_new_url_closed = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858854',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'Closed',
};
my( $no_new_url_closed_host, $no_new_url_closed_type, $no_new_url_closed_content ) = $mappings->row_as_nginx_config($businesslink_no_new_url_closed);
ok( $no_new_url_closed_host eq 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
ok( $no_new_url_closed_type eq 'no_destination_error',
	"If status is 301, whole tag 'status' is Closed, and there is no new url, this is a 'no destination' error."  );
ok( $no_new_url_closed_content eq "http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073858854\n",
    "The 'no destination' error file will be populated with the URL." );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );