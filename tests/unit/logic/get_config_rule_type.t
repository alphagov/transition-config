use strict;
use warnings;
use Test::More;
use Mappings::Rules;


my $test_url_parts = {
    scheme => '',
    host   => '',
    path   => '',
    query  => '',
    frag   => '',
};

$test_url_parts->{host}     = 'www.businesslink.gov.uk';
$test_url_parts->{path}     = '/bdotg/action/layer';
$test_url_parts->{query}    = '=en&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
my $config_rule_type   = Mappings::Rules::get_config_rule_type( undef, $test_url_parts->{host}, $test_url_parts->{path}, $test_url_parts->{query} );
is( 'Mappings::Businesslink', $config_rule_type, 
	"If URL has query string and Businesslink host then is BL specific" );

$test_url_parts->{host}     = 'www.businesslink.gov.uk';
$test_url_parts->{path}     = '/bdotg/action/layer';
$test_url_parts->{query}    = undef;
$config_rule_type   = Mappings::Rules::get_config_rule_type( undef, $test_url_parts->{host}, $test_url_parts->{path}, $test_url_parts->{query} );
is( 'Mappings::LocationConfig', $config_rule_type, 
	"If URL has no query string and Businesslink host then is generic location" );

$test_url_parts->{host}     = 'www.direct.gov.uk';
$test_url_parts->{path}     = '/anything';
$test_url_parts->{query}    = 'something';
$config_rule_type   = Mappings::Rules::get_config_rule_type( undef, $test_url_parts->{host}, $test_url_parts->{path}, $test_url_parts->{query} );
is( 'Mappings::MapConfig', $config_rule_type, 
	"If URL has a query string and Directgov host then is generic map config" );

$test_url_parts->{host}     = 'www.direct.gov.uk';
$test_url_parts->{path}     = '/en/with/dg_1234';
$test_url_parts->{query}    = undef;
$config_rule_type   = Mappings::Rules::get_config_rule_type( undef, $test_url_parts->{host}, $test_url_parts->{path}, $test_url_parts->{query} );
is( 'Mappings::Directgov', $config_rule_type, 
	"If URL has no query string, Directgov host and DG number then is DG specific" );

$test_url_parts->{host}     = 'www.direct.gov.uk';
$test_url_parts->{path}     = '/anything/else';
$test_url_parts->{query}    = undef;
$config_rule_type   = Mappings::Rules::get_config_rule_type( undef, $test_url_parts->{host}, $test_url_parts->{path}, $test_url_parts->{query} );
is( 'Mappings::LocationConfig', $config_rule_type, 
	"If URL has no query string and Directgov host but no DG number then is location generic" );

$test_url_parts->{host}     = 'www.example.gov.uk';
$test_url_parts->{path}     = '/anything';
$test_url_parts->{query}    = 'something';
$config_rule_type   = Mappings::Rules::get_config_rule_type( undef, $test_url_parts->{host}, $test_url_parts->{path}, $test_url_parts->{query} );
is( 'Mappings::MapConfig', $config_rule_type, 
	"If URL has a query string and an unmentioned host then use map config generic" );

$test_url_parts->{host}     = 'www.example.gov.uk';
$test_url_parts->{path}     = '/anything';
$test_url_parts->{query}    = undef;
$config_rule_type   = Mappings::Rules::get_config_rule_type( undef, $test_url_parts->{host}, $test_url_parts->{path}, $test_url_parts->{query} );
is( 'Mappings::LocationConfig', $config_rule_type, 
	"If URL has no query string and unmentioned host then is location generic" );


done_testing();


