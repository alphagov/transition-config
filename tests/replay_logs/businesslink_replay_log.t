use strict;
use warnings;
use POSIX qw(strftime);

my $test = ReplayLogs::ReplayLogs->new();
my $total_hits = 0;
my $failing_hits = 0;
$test->input_file("dist/businesslink-testable.csv");

my $timestamp = strftime '%Y-%m-%d-%H-%M', localtime;
$test->output_file("dist/businesslink-testable-output.${timestamp}.csv");
$test->output_error_file("dist/businesslink-testable-failures.${timestamp}.csv");
$test->run_tests();

open ( my $log_stats, ">", "dist/businesslink_log_stats.${timestamp}.txt" )
        or die "dist/log_stats.txt" . ": $!";
print $log_stats "Total hits: $total_hits\n";
print $log_stats "Failing hits: $failing_hits\n";
my $percentage_passing = (1 - ($failing_hits/$total_hits))*100;
$percentage_passing = sprintf "%.0f", $percentage_passing;
print $log_stats "${percentage_passing}% passing\n";
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


