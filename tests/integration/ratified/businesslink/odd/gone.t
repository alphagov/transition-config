my $test = Businesslink::Ratified::Gone->new();
$test->input_file("dist/businesslink_mappings_source.csv");
$test->output_file("dist/businesslink_odd_gone_test_output.csv");
$test->output_error_file("dist/businesslink_odd_gone_errors.csv");
$test->run_tests();
exit;


package Businesslink::Ratified::Gone;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    state $count = 0;
    return -1 if $count++ % 2;
    
    $self->test_closed_gones(@_);
}
