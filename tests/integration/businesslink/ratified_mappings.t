my $test = Businesslink::Ratified->new();
$test->input_file("dist/businesslink_mappings_source.csv");
$test->output_file("dist/businesslink_all_known_mappings_that_fail.csv");
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
    
    my $mapping_status;
    my $return = 0;

    if ( 410 == $status_code ) {
        $return = is(  $response->code, 410, $row->{'Old Url'} . ' returns 410' )
    }        

    if ( 301 == $status_code ) {
        $mapping_status = lc $row->{'Whole Tag'};
        if ( 'awaiting-content' eq $mapping_status ) {
            $return = is(  $response->code, 418, $row->{'Old Url'} . ' returns 418' );
        }
        else {
            my $new_url = $row->{'New Url'};
            my $redirected_url = $response->header("location");
            $return = is( $redirected_url, $new_url, $row->{'Old Url'} . " redirects to $new_url" );
        }
    }

    return( $return, $mapping_status );
}

