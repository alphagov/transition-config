my $test = Other_Domains::BusinessLink->new();
$test->{'force_production_redirector'} = 1;
$test->input_file("tests/integration/test_data/sample_businesslink_other_domain_urls.csv");
$test->output_file("dist/sample_businesslink_other_domains_test_output.csv");
$test->output_error_file("dist/sample_businesslink_other_domains_failures.csv");
$test->run_tests();
exit;


package Other_Domains::BusinessLink;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;

    my ( $passed, $response, $test_response ) = $self->test_closed_redirects(@_);

    if ( -1 == $passed ) {
        ( $passed, $response, $test_response ) = $self->test_closed_gones(@_);
        if ( -1 == $passed ) {
            ( $passed, $response, $test_response ) = $self->is_ok_response(@_);
        }
    }

    return (
        $passed,
        $response,
        $test_response
    );
}