use strict;
use warnings; 
use Test::More;
use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;

my @rows;
my $csv = Text::CSV->new() 
    or die "Cannot use CSV: ".Text::CSV->error_diag();
my $ua = LWP::UserAgent->new( max_redirect => 0 );

open( my $fh, "<", "../../directgov.csv" ) 
	or die "directgov.csv: $!";
while ( my $row = $csv->getline( $fh ) ) {
    my $old_url = $row->[0];
    
    my $uri = URI->new($old_url);
    my $old_url_path = $uri->path;
    
    my $status_code = $row->[2];

    my $request = HTTP::Request->new( 'GET', "http://redirector.preview.alphagov.co.uk$old_url_path" );
    $request->header( 'Host', 'www.direct.gov.uk' );
    my $response = $ua->request($request);

    if ( $status_code eq 301 ) {
        my $new_url = $row->[1];
        my $redirected_url = $response->header("location");
        is( $redirected_url, $new_url, "$old_url redirects to $new_url" );
    }

    #if that works, add one for 410.
}

done_testing();