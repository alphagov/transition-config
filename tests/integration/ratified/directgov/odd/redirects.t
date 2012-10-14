my $test = Directgov::Ratified::Redirects->new();
$test->input_file("dist/directgov_mappings_source.csv");
$test->{'output_has_no_header'} = 1;
$test->output_file("dist/directgov_odd_redirects_output.csv");
$test->output_error_file("dist/directgov_odd_redirects_errors.csv");
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
    
    state $count = 0;
    return -1 if $count++ % 2;
    
    $self->test_closed_redirects(@_);
}
