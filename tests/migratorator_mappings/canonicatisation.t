use strict;
use warnings;
use Test::More;
use Mappings;


my $test_url = '/bdotg/action/layer?=en&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
my $result_key = Mappings::get_url_key( undef, $test_url );
is( 'topicId=1081128739', $result_key, "If a URL has both a topic id and an item id then use the topic id if it is a 'layer' URL" );

$test_url = '/bdotg/action/detail?&itemId=1081129545&lang=en&topicId=1081129016&type=RESOURCES';
$result_key = Mappings::get_url_key( undef, $test_url );
is( 'itemId=1081129545', $result_key, "If a URL has both a topic id and an item id then use the item id if it is a 'detail' URL" );

$test_url = '/bdotg/action/layer?=en&detail&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
$result_key = Mappings::get_url_key( undef, $test_url );
is( 'topicId=1081128739', $result_key, "A 'layer' URL is determined by the start of the URL" );

$test_url = '/bdotg/action/detail?=en&layer&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
$result_key = Mappings::get_url_key( undef, $test_url );
is( 'itemId=1081128808', $result_key, "A 'detail' URL is determined by the start of the URL" );

$test_url = '/bdotg/action/=en&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES';
$result_key = Mappings::get_url_key( undef, $test_url );
is( 'itemId=1081128808', $result_key, "If a URL has both a topic id and an item id and is not a 'layer' or 'detail' URL then use item id" );

$test_url = '/bdotg/action/layer?topicId=1073858787';
$result_key = Mappings::get_url_key( undef, $test_url );
is( 'topicId=1073858787', $result_key, "If a URL has a topic id and no item Id then use the topic id" );

$test_url = '/bdotg/action/detail?itemId=5002011861&type=ONEOFFPAGE';
$result_key = Mappings::get_url_key( undef, $test_url );
is( 'itemId=5002011861', $result_key, "If a URL has a item id and no topic id then use the item id" );





done_testing();