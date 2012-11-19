my $test = Businesslink::Ratified::Redirects->new();
$test->input_file("dist/businesslink_mappings_source.csv");
$test->{'output_has_no_header'} = 1;
$test->output_file("dist/businesslink_even_redirects_output.csv");
$test->output_error_file("dist/businesslink_even_redirects_errors.csv");
$test->run_tests();
exit;


package Businesslink::Ratified::Redirects;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    $self->test_closed_redirects(@_);
}
