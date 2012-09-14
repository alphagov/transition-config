my $test = Businesslink::Ratified->new();
$test->input_file("dist/businesslink_mappings_source.csv");
$test->output_file("dist/businesslink_integration_test_failures.csv");
$test->run_tests();
exit;


package Businesslink::Ratified;
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
    my $return = 0;
    my $new_url = '';

    if ( 'closed' eq $mapping_status ) {
        if ( 410 == $status_code ) {
            $return = is(  $response->code, 410, $row->{'Old Url'} . ' returns 410' )
        }        

        if ( 301 == $status_code ) {
            $new_url = $row->{'New Url'};
            my $redirected_url = $response->header("location");
            $return = is( $redirected_url, $new_url, $row->{'Old Url'} . " redirects to $new_url" );
        }
    }

    return( $return, $mapping_status, $new_url );
}

