use v5.10;
use strict;
use warnings;

use HTTP::Request;
use LWP::UserAgent;
use URI;

my $host_type = $ENV{'DEPLOY_TO'} // 'preview';
my $ua = LWP::UserAgent->new( max_redirect => 0 );
my $redirector_host = "http://redirector.${host_type}.alphagov.co.uk";

sub get_response {
    my $test_url       = shift;
    my $not_redirector = shift // 0;

    my $test_uri = URI->new( $test_url );
    my $redirector_url = sprintf '%s%s',
    $redirector_host,
    $test_uri->path_query;
    
    my $request;
    if ( $not_redirector ) {
        $request = HTTP::Request->new( 'GET', $test_url );
    }
    else {
        $request = HTTP::Request->new( 'GET', $redirector_url );
        $request->header( 'Host', $test_uri->host );
    }

    my $response = $ua->request($request);
    my $response_code = $response->code;
    my $redirect_location = $response->header('location');

    ( $response_code, $redirect_location );
}

1;