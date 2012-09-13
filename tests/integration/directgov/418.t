my $test = Directgov::AwaitingContent->new();
$test->input_file("dist/directgov_all_mappings.csv");
$test->output_file("dist/directgov_418_test_failures.csv");
$test->run_tests();
exit;


package Directgov::AwaitingContent;
use base 'IntegrationTest';

use strict;
use warnings;
use Test::More;


sub test {
    my $self        = shift;
    my $status_code = shift;
    my $response    = shift;
    my $row         = shift;
   
    my $mapping_status;
    if ( defined $row->{'Whole Tag'} && $row->{'Whole Tag'} =~ m{status:(\S+)} ) {
        $mapping_status = lc $1;
    }

    my $return = 0;

    if (  length $status_code && 301 == $status_code && defined $mapping_status && 'awaiting-content' eq $mapping_status ) {
        $return = is(  $response->code, 418, $row->{'Old Url'} . 'returns 418' );
    }

    return( $return, $mapping_status );
}