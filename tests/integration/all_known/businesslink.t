my $test = Businesslink::AllKnown->new();
$test->input_file("dist/businesslink_mappings_source.csv");
$test->output_file("dist/businesslink_all_known_mappings_output.csv");
$test->output_error_file("dist/businesslink_all_known_mappings_that_fail.csv");
$test->run_tests();
exit;


package Businesslink::AllKnown;
use base 'IntegrationTest';

use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    my $row     = shift;

    my $response = $self->get_response($row);
    
    my $correct_response_code = ( 410 == $response->code || 301 == $response->code );
    my $passed = is(  1, $correct_response_code, $row->{'Old Url'} . ' returns either a 410 or a 301' );

    return(
        $passed,
        $response,
        undef
    );
}

done_testing();