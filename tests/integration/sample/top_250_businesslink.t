my $test = Top_250::BusinessLink->new();
$test->input_file("tests/integration/test_data/top_250_businesslink_urls.csv");
$test->output_file("dist/top_250_businesslink_test_output.csv");
$test->output_error_file("dist/top_250_businesslink_failures.csv");
$test->run_tests();
exit;


package Top_250::BusinessLink;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    my ( $passed, $response, $test_response ) = $self->is_redirect_response(@_);
    
    if ( -1 == $passed ) {
    	( $passed, $response, $test_response ) = $self->is_gone_response(@_);
    	if ( -1 == $passed ) {
    		( $passed, $response, $test_response ) = $self->is_ok_response(@_);
    	}
    }

    return ( 
    	$passed, 
    	$response, 
    	$test_response 
    ); 
}