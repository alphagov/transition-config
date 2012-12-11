my $test = Businesslink::Bugs::Duplicates->new();
$test->input_file("tests/integration/test_data/mappings_failing_on_false_positive_duplicates.csv");
$test->{'output_has_no_header'} = 1;
$test->output_file("dist/false_positive_duplicates_output.csv");
$test->output_error_file("dist/false_positive_duplicates_errors.csv");
$test->run_tests();
exit;


package Businesslink::Bugs::Duplicates;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    $self->test_closed_redirects(@_);
}