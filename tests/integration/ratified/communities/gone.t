my $test = Communities::Ratified::Gone->new();
$test->input_file("dist/communities_mappings_source.csv");
$test->output_file("dist/communities_gone_output.csv");
$test->output_error_file("dist/communities_gone_errors.csv");
$test->run_tests();
exit;


package Communities::Ratified::Gone;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    $self->test_closed_gones(@_);
}
