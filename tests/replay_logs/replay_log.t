my $test = ReplayLogs::ReplayLogs->new();
$test->input_file("dist/urls.csv");
$test->output_file("dist/replay_logs_test_output.csv");
$test->output_error_file("dist/logs_that_fail.csv");
$test->run_tests();
exit;


package ReplayLogs::ReplayLogs;
use base 'IntegrationTest';

use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    $self->is_valid_redirector_response(@_);
    
    # else fail and print out URL and actual status code
    
    # also, we want some numbers (come back to this)
}