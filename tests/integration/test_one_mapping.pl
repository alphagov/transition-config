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

my $req_url = "http://redirector.preview.alphagov.co.uk${path}";

my $request = HTTP::Request->new('GET', $req_url);
$request->header( 'Host', $host );

my $response = $ua->request($request);

print $response->code;
print ' ' . $response->header('location')
    if defined $response->header('location');
print "\n";
