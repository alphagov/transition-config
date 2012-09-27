use v5.10;
use strict;
use warnings; 
use HTTP::Request;
use LWP::UserAgent;
use URI;

my $url = shift;

my $uri  = URI->new($url);
my $path = $uri->path_query;
my $host = $uri->host;
my $ua   = LWP::UserAgent->new( max_redirect => 0 );

my $req_url = "http://redirector.production.alphagov.co.uk${path}";

my $request = HTTP::Request->new('GET', $req_url);
$request->header( 'Host', $host );

my $response = $ua->request($request);
my $redirect = $response->header('location');
my $code     = $response->code;


printf "%d %s\n", $code, $redirect // '';
if ( defined $redirect ) {
    my $redirect_request = HTTP::Request->new('GET', $redirect);
    my $redirect_response = $ua->request($redirect_request);
    
    $redirect = $redirect_response->header('location');
    $code     = $redirect_response->code;
    
    printf "%d %s\n", $code, $redirect // '';
}
