use strict;
use warnings;
use Test::More;
use Mappings::Businesslink;




my $test_url     = '/bdotg/action/layer';
my $query_string = '=en&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
my $result_key   = Mappings::Businesslink::get_url_key( undef, $test_url, $query_string );
is( 'topicId=1081128739', $result_key, "If a URL has both a topic id and an item id then use the topic id if it is a 'layer' URL" );

$test_url     = '/bdotg/action/detail';
$query_string = '=en&itemId=1081129545&lang=en&topicId=1081129016&type=RESOURCES';
$result_key   = Mappings::Businesslink::get_url_key( undef, $test_url, $query_string );
is( 'itemId=1081129545', $result_key, "If a URL has both a topic id and an item id then use the item id if it is a 'detail' URL" );

$test_url     = '/bdotg/action/layer';
$query_string = '=en&detail&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
$result_key   = Mappings::Businesslink::get_url_key( undef, $test_url, $query_string );
is( 'topicId=1081128739', $result_key, "A 'layer' URL is determined by the start of the URL" );

$test_url     = '/bdotg/action/detail';
$query_string = '=en&layer&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
$result_key   = Mappings::Businesslink::get_url_key( undef, $test_url, $query_string );
is( 'itemId=1081128808', $result_key, "A 'detail' URL is determined by the start of the URL" );

$test_url     = '/bdotg/action/';
$query_string = '=en&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
$result_key   = Mappings::Businesslink::get_url_key( undef, $test_url, $query_string );
is( 'itemId=1081128808', $result_key, "If a URL has both a topic id and an item id and is not a 'layer' or 'detail' URL then use item id" );

$test_url     = '/bdotg/action/layer';
$query_string = 'topicId=1073858787';
$result_key   = Mappings::Businesslink::get_url_key( undef, $test_url, $query_string );
is( 'topicId=1073858787', $result_key, "If a URL has a topic id and no item Id then use the topic id" );

$test_url     = '/bdotg/action/detail';
$query_string = 'itemId=5002011861&type=ONEOFFPAGE';
$result_key   = Mappings::Businesslink::get_url_key( undef, $test_url, $query_string );
is( 'itemId=5002011861', $result_key, "If a URL has a item id and no topic id then use the item id" );

done_testing();
