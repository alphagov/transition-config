my $test = ReplayLogs::ReplayLogs->new();
my $total_hits = 0;
my $failing_hits = 0;
$test->input_file("dist/urls.csv");
$test->output_file("dist/replay_logs_test_output.csv");
$test->output_error_file("dist/logs_that_fail.csv");
$test->run_tests();
open ( my $log_stats, ">", "dist/log_stats.txt" )
        or die "dist/log_stats.txt" . ": $!";
print $log_stats "Total hits: $total_hits\n";
print $log_stats "Failing hits: $failing_hits\n";
exit;


package ReplayLogs::ReplayLogs;
use base 'IntegrationTest';

use strict;
use warnings;
use Test::More;



sub test {
    my $self = shift;
    my $row = shift;

    my ($result, $response) = $self->is_valid_redirector_response($row);
    my $count = $row->{'Count'};
    $total_hits += $count;

    if (!$result) {
        $failing_hits += $count;
    }

    ($result, $response);
}


