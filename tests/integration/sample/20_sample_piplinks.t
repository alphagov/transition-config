my $test = Top_250::BusinessLink->new();
$test->{'force_production_redirector'} = 1;
$test->input_file("tests/integration/test_data/sample_piplink_urls.csv");
$test->output_file("dist/piplinks_test_output.csv");
$test->output_error_file("dist/piplink_failures.csv");
$test->run_tests();
exit;


package Top_250::BusinessLink;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;

    $self->is_redirect_response(@_);
}