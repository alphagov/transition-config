my $test = AGO::Finalised->new();
$test->input_file("dist/ago_mappings_source.csv");
$test->output_file("dist/ago_all_tested.csv");
$test->output_error_file("dist/ago_errors.csv");
$test->output_redirects_file("dist/ago_redirects_chased.csv");
$test->run_tests();
exit;


package AGO::Finalised;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    
    my ( $passed, 
    	$response, 
    	$redirected_response, 
    	$chased_redirects ) = $self->test_closed_gones(@_);

    #i.e. it is not a 410
    if ( -1 == $passed ) { 
    	( $passed, 
    	$response, 
    	$redirected_response, 
    	$chased_redirects ) = $self->test_finalised_redirects(@_);
    }

    return ( $passed, 
    	$response, 
    	$redirected_response, 
    	$chased_redirects ); 
}

