my $test = Businesslink::Ratified::Redirects->new();
$test->input_file("dist/businesslink_mappings_source.csv");
$test->output_file("dist/businesslink_integration_test_failures.csv");
$test->run_tests();
exit;


package Businesslink::Ratified::Redirects;
use base 'IntegrationTest';

use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    $self->test_closed_redirects(@_);
}
