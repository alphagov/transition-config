use strict;
use warnings; 
use Test::More;
use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;

my @rows;
my $csv = Text::CSV->new( { binary => 1 } ) 
    or die "Cannot use CSV: ".Text::CSV->error_diag();
my $ua = LWP::UserAgent->new( max_redirect => 0 );



open( my $fh, "<", "dist/businesslink_mappings_source.csv" ) 
	or die "dist/businesslink_mappings_source.csv: $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );

open ( my $output_log, ">", "dist/integration_test_failures.csv")
    or die "dist/integration_test_failures.csv: $!";

while ( my $row = $csv->getline_hr( $fh ) ) {
    my $old_url = $row->{'Old Url'};
    
    my $uri = URI->new($old_url);
    my $old_url_path = $uri->path_query;
    
    my $status_code = $row->{'Status'};

    my $request = HTTP::Request->new( 'GET', "http://redirector.preview.alphagov.co.uk$old_url_path" );
    $request->header( 'Host', 'www.businesslink.gov.uk' );
    my $response = $ua->request($request);

    my $return;
    my $mapping_status;
    my $new_url;


    if ( 410 == $status_code ) {
        $return = is(  $response->code, 410, "$old_url returns 410" )
    }        

    if ( 301 == $status_code ) {
        $mapping_status = lc $row->{'Whole Tag'};
        if ( 'awaiting-content' eq $mapping_status || 'awaiting-publication' eq $mapping_status ) {
            $return = is(  $response->code, 418, "$old_url returns 418" );
        }
        else {
            $new_url = $row->{'New Url'};
            my $redirected_url = $response->header("location");
            $return = is( $redirected_url, $new_url, "$old_url redirects to $new_url" );
        } 
    }

    if ( 0 == $return ) {
        printf $output_log "%s,%s,%s,%s\n", $old_url, $new_url, $status_code, $mapping_status;
    }

}

done_testing();
