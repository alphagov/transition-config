use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $businesslink_gone = { 
    'Old Url'   => 'http://www.improve.businesslink.gov.uk/content/how-designing-demand-helped-us-rebrand-%E2%80%93-tastetech-ltd',
    'New Url'   => '',
    'Status'    => 410, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_gone);
is( $redirect_host, 'www.improve.businesslink.gov.uk', 
    'Host that config applies to is improve.businesslink' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/content/how-designing-demand-helped-us-rebrand-–-tastetech-ltd/?\$ { return 410; }\n),
    'Nginx config has original characters, not percent-encoded' );


$mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
my $businesslink_redirect = { 
    'Old Url'   => 'http://www.improve.businesslink.gov.uk/content/how-designing-demand-helped-us-rebrand-%E2%80%93-tastetech-ltd',
    'New Url'   => 'https://www.gov.uk/tastetech',
    'Status'    => 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
is( $redirect_host, 'www.improve.businesslink.gov.uk', 
    'Host that config applies to is improve.businesslink' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/content/how-designing-demand-helped-us-rebrand-–-tastetech-ltd/?\$ { return 301 https://www.gov.uk/tastetech; }\n),
    'Nginx config has original characters, not percent-encoded' );

$mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
my $directgov_gone = { 
    'Old Url'   => 'http://www.direct.gov.uk/content/how-designing-demand-helped-us-rebrand-%E2%80%93-tastetech-ltd',
    'New Url'   => '',
    'Status'    => 410, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_gone);
is( $redirect_host, 'www.direct.gov.uk', 
    'Host that config applies to is directgov' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/content/how-designing-demand-helped-us-rebrand-–-tastetech-ltd/?\$ { return 410; }\n),
    'Nginx config has original characters, not percent-encoded' );

$mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
my $directgov_redirect = { 
    'Old Url'   => 'http://www.direct.gov.uk/content/how-designing-demand-helped-us-rebrand-%E2%80%93-tastetech-ltd',
    'New Url'   => 'https://www.gov.uk/tastetech',
    'Status'    => 301, 
};
( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
    'Host that config applies to is directgov' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/content/how-designing-demand-helped-us-rebrand-–-tastetech-ltd/?\$ { return 301 https://www.gov.uk/tastetech; }\n),
    'Nginx config has original characters, not percent-encoded' );

done_testing();
