my $test = Assets::BusinessLink->new();
$test->input_file("tests/integration/test_data/sample_assets.csv");
$test->output_file("dist/assets_test_output.csv");
$test->output_error_file("dist/asset_failures.csv");
$test->run_tests();
exit;


package Assets::BusinessLink;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;

    $self->is_ok_response(@_);
}