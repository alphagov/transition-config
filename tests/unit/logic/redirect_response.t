use strict;
use warnings;
use Test::More;
use IntegrationTest;

my $integration_test = IntegrationTest->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $integration_test, 'IntegrationTest' );

# redirect to 200

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

# redirect to any non-failure response

$row = {
          'Status' => '301',
          'Old Url' => 'http://www.businesslink.gov.uk/mkt1_employment',
          'New Url' => 'https://www.gov.uk/browse/employing-people',
        };

($passed, $response, $redirected_response) = $integration_test->is_redirect_to_any_non_failure_response($row);
is($passed, 1, '301 is a redirect response if it redirects to a 200');


$row = {
          'Status' => '301',
          'Old Url' => 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1083400273&type=RESOURCES',
          'New Url' => 'http://www.bis.gov.uk/policies/business-law/competition',
        };

($passed, $response, $redirected_response) = $integration_test->is_redirect_to_any_non_failure_response($row);
is($passed, 1, '301 is a redirect response if it redirects to a 301');

$row = {
          'Status' => '301',
          'Old Url' => 'http://www.direct.gov.uk/journeyplanner',
          'New Url' => 'http://www.transportdirect.info/Web2/Home.aspx',
        };

($passed, $response, $redirected_response) = $integration_test->is_redirect_to_any_non_failure_response($row);
is($passed, 1, '301 is a redirect response if it redirects to a 302');

$row = {
          'Status' => '301',
          'Old Url' => 'http://www.businesslink.gov.uk/bdotg/action/emailafriend?itemId=1079305576&type=REGUPDATE',
          'New Url' => 'http://www.communities.gov.uk/housing/homeownership/homeinfopackquestions/',
        };

($passed, $response, $redirected_response) = $integration_test->is_redirect_to_any_non_failure_response($row);
is($passed, 1, '301 is a redirect response if it redirects to a 410');


# chase redirects

$row = {
          'Status' => '301',
          'Old Url' => 'http://www.direct.gov.uk/en/Governmentcitizensandrights/UKgovernment/PublicConsultations/DG_170463',
          'New Url' => 'https://www.gov.uk/government/consultations',
        };

($passed, $response, $redirected_response) = $integration_test->is_redirect_to_a_200_or_410_eventually($row);
is($passed, 1, '301 to redirect is a redirect response if it ends up at a 200');


done_testing();
