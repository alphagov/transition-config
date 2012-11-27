use Test::More;

my $test = Businesslink::Ratified::Piplinks->new();
$test->input_file("dist/businesslink_piplink_redirects_source.csv");
$test->output_file("dist/businesslink_piplink_redirects_output.csv");
$test->output_error_file("dist/businesslink_piplink_redirects_errors.csv");
$test->run_tests();
exit;


package Businesslink::Ratified::Piplinks;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    $self->test_closed_redirects(@_);
}
