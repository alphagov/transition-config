use strict;
use warnings;
use Test::More;
use IntegrationTest;


my $integration_test = IntegrationTest->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $integration_test, 'IntegrationTest' );

my $row = {
          'Status' => '410',
          'Old Url' => 'http://www.direct.gov.uk/en/Video/DG_WP195806',
          'New Url' => '',
        };

my $redirect_response = $integration_test->is_redirect_to_a_200_response($row);
is($redirect_response, -1, '410 is not redirect response');

$row = {
          'Status' => '301',
          'Old Url' => 'http://www.businesslink.gov.uk/mkt1_employment',
          'New Url' => 'https://www.gov.uk/browse/employing-people',
        };

my ($passed, $response, $redirected_response) = $integration_test->is_redirect_to_a_200_response($row);
is($passed, 1, '301 is a redirect response if it redirects to a 200');


done_testing();