#!/usr/bin/env perl

#
#  not integrated into the flow, but checks URLs in a CSV
#

use strict;

use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;
use Test::More;

my $host_type = $ENV{'DEPLOY_TO'} // "dev";
my $redirector_host = "http://localhost";

$redirector_host = 'http://redirector.preview.alphagov.co.uk'
    if $host_type eq 'preview';
$redirector_host = 'http://redirector.production.alphagov.co.uk'
    if $host_type eq 'production';

my $ua = LWP::UserAgent->new( max_redirect => 0 ),

my $csv = Text::CSV->new( { binary => 1 } );
open my $fh, '<-';
my $names = $csv->getline( $fh );
$csv->column_names( @$names );

while (my $row = $csv->getline_hr($fh)) {

	my ($url, $location, $status, $md5) = (
		$row->{'Old Url'},
		$row->{'New Url'},
		$row->{'Status'},
		$row->{'md5'},
	);

	my $uri = URI->new($url);

	my $request;
	
	$request = HTTP::Request->new('GET', $redirector_host . $uri->path_query);
	$request->header( 'Host', $uri->host );

	my $response = $ua->request($request);

	is( $response->code, $status, "${url} should return $status" );

	if ($location || $response->header('location')) {
		is( $response->header('location'), $location, "$url should redirect to $location");
	}
}

done_testing();
