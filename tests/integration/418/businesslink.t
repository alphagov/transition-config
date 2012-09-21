my $test = Businesslink::AwaitingContent->new();
$test->input_file("dist/businesslink_mappings_source.csv");
$test->output_file("dist/businesslink_418_test_failures.csv");
$test->run_tests();
exit;


package Businesslink::AwaitingContent;
use base 'IntegrationTest';

use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    my $status_code = shift;
    my $response = shift;
    my $row     = shift;

    my $mapping_status = lc $row->{'Whole Tag'};
    my $return = 1;
    my $new_url = '';

    if ( 301 == $status_code && defined $mapping_status && 'awaiting-content' eq $mapping_status ) {
        $return = is(  $response->code, 418, $row->{'Old Url'} . 'returns 418' );
    }

    return( $return, $mapping_status, $new_url );
}