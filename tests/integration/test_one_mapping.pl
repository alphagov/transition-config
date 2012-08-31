use strict;
use warnings; 
use HTTP::Request;
use LWP::UserAgent;
use URI;

my @rows;
my $ua = LWP::UserAgent->new( max_redirect => 0 );

my $old_url = shift;

my $uri = URI->new($old_url);
my $old_url_path = $uri->path;

my $request = HTTP::Request->new( 'GET', "http://redirector.preview.alphagov.co.uk$old_url_path" );
$request->header( 'Host', 'www.direct.gov.uk' );
my $response = $ua->request($request);

use Data::Dumper;
print Dumper $response;

