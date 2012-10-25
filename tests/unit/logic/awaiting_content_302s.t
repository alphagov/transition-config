use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

# businesslink maps
my $businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/?topicId=12345678',
	'New Url'	=> '',
	'Status'	=> 302,
	'Whole Tag' => 'closed',
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'awaiting_content_map',
	'A 302 with no new URL is added to the awaiting content map'  );
is( $redirect, qq(~topicId=12345678 https://www.gov.uk/browse/business/maritime;\n),
    'Redirect is to the GOV.UK maritime browse page' );

$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/?topicId=01234567',
	'New Url'	=> 'https://www.gov.uk/place',
	'Status'	=> 302,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'awaiting_content_map',
	'A 302 with a new URL is added to the awaiting content map'  );
is( $redirect, qq(~topicId=01234567 https://www.gov.uk/browse/business/maritime;\n),
    'Redirect is to the GOV.UK maritime browse page' );

$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/?topicId=00123456',
	'New Url'	=> 'https://www.gov.uk/another-place',
	'Status'	=> 301,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'redirect_map',
	'A 301 with a new URL is added to the redirect content map'  );
is( $redirect, qq(~topicId=00123456 https://www.gov.uk/another-place;\n),
    'Redirect is as expected' );

$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/?topicId=0002345',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'no_destination_error',
	'A 301 with no new URL is added no destination error map'  );
is( $redirect, qq(http://www.businesslink.gov.uk/bdotg/action/?topicId=0002345\n),
    'Redirect is as expected' );


# businesslink locations
$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/friendlyurl',
	'New Url'	=> '',
	'Status'	=> 302,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'location',
	'A friendly URL 302 with no new URL is added to the location block'  );
is( $redirect, qq(location ~* ^/friendlyurl\$ { return 302 https://www.gov.uk; }\n),
    'Redirect is to the GOV.UK homepage' );

$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/anotherfriendlyurl',
	'New Url'	=> 'https://www.gov.uk/place',
	'Status'	=> 302,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'location',
	'A friendly URL 302 with a new URL is added to the location block'  );
is( $redirect, qq(location ~* ^/anotherfriendlyurl\$ { return 302 https://www.gov.uk; }\n),
    'Redirect is to the GOV.UK homepage' );

$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/validurl',
	'New Url'	=> 'https://www.gov.uk/validplace',
	'Status'	=> 301,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'location',
	'A friendly URL 301 with a new URL is added to the location map'  );
is( $redirect, qq(location ~* ^/validurl\$ { return 301 https://www.gov.uk/validplace; }\n),
    'Redirect is as expected' );

$businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/invalidurl',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
is( $redirect_type, 'no_destination_error',
	'A friendly URL 301 with no new URL is added no destination error map'  );
is( $redirect, qq(http://www.businesslink.gov.uk/invalidurl\n),
    'Redirect is as expected' );


# directgov locations

$mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/reallyfriendlyurl',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag' => 'status:awaiting-content',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'A friendly URL 301 with no new URL and a tag of awaiting content is added to the location block'  );
is( $redirect, qq(location ~* ^/reallyfriendlyurl\$ { return 302 https://www.gov.uk; }\n),
    'Redirect is to the GOV.UK homepage' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/anotherfriendlyurl',
	'New Url'	=> 'https://www.gov.uk/place',
	'Status'	=> 301,
	'Whole Tag' => 'status:awaiting-content',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'A friendly URL 301 with a new URL and a status of awaiting content is added to the location block'	 );
is( $redirect, qq(location ~* ^/anotherfriendlyurl\$ { return 302 https://www.gov.uk; }\n),
	'Redirect is to the GOV.UK homepage' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/validurl',
	'New Url'	=> 'https://www.gov.uk/validredirect',
	'Status'	=> 301,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'A friendly URL 301 with a new URL and a status of closed is added to the location map'	 );
is( $redirect, qq(location ~* ^/validurl\$ { return 301 https://www.gov.uk/validredirect; }\n),
	'Redirect is as expected' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/reallybrokenurl',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag' => 'closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'no_destination_error',
	'A friendly URL 301 with no new URL and a tag of closed is added to the no destination error map'  );
is( $redirect, qq(http://www.direct.gov.uk/reallybrokenurl\n),
    'Redirect is as expected' );


# directgov dg_canonicalisation

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/DG_1234',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag' => 'status:awaiting-content',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'A friendly URL 301 with no new URL and a tag of awaiting content is added to the location block'  );
is( $redirect, qq(location ~* ^/en/(.*/)?dg_1234\$ { return 302 https://www.gov.uk; }\n),
    'Redirect is to the GOV.UK homepage' );


$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/DG_0123',
	'New Url'	=> 'https://www.gov.uk/location',
	'Status'	=> 301,
	'Whole Tag' => 'status:awaiting-content',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'A friendly URL 301 with a new URL and a status of awaiting content is added to the location block'  );
is( $redirect, qq(location ~* ^/en/(.*/)?dg_0123\$ { return 302 https://www.gov.uk; }\n),
    'Redirect is to the GOV.UK homepage' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/DG_0010',
	'New Url'	=> 'https://www.gov.uk/validredirect',
	'Status'	=> 301,
	'Whole Tag' => 'status:closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'A friendly URL 301 with a new URL and a status of closed is added to the location map'  );
is( $redirect, qq(location ~* ^/en/(.*/)?dg_0010\$ { return 301 https://www.gov.uk/validredirect; }\n),
    'Redirect is as expected' );

$directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/DG_0012',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag' => 'status:closed',
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'no_destination_error',
	'A friendly URL 301 with no new URL and a tag of closed is added to the no destination error map'  );
is( $redirect, qq(http://www.direct.gov.uk/en/DG_0012\n),
    'Redirect is as expected' );


done_testing();
