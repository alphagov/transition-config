my $test = Directgov::Ratified::Redirects->new();
$test->input_file("dist/directgov_mappings_source.csv");
$test->output_file("dist/directgov_redirects_output.csv");
$test->output_error_file("dist/directgov_redirects_errors.csv");
$test->output_redirects_file("dist/directgov_redirects_chased.csv");
$test->run_tests();
exit;


package Directgov::Ratified::Redirects;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    $self->test_finalised_redirects(@_);
}
