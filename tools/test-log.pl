#!/usr/bin/env perl

#
#  not integrated into the flow, but checks URLs in a CSV
#

use strict;

use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;
use Test::Simple;

my $redirector_host = "http://localhost";

my $ua = LWP::UserAgent->new( max_redirect => 0 ),

my $csv = Text::CSV->new( { binary => 1 } );
my $fh = *STDIN;
my $names = $csv->getline( $fh );
$csv->column_names( @$names );

while (my $row = $csv->getline_hr($fh)) {

	my ($url, $location, $status, $count, $meta) = (
		$row->{'Old Url'},
		$row->{'New Url'},
		$row->{'Status'},
		$row->{'Count'},
		$row->{'Whole Tag'},
	);

	my $uri = URI->new($url);

	my $request = HTTP::Request->new('GET', "http://localhost" . $uri->path_query);
	$request->header( 'Host', $uri->host );

	my $response = $ua->request($request);

	ok($response->code eq $status, "$url status E:[$status] R:[" . $response->code . "]");

	if ($location || $response->header('location')) {
		ok($response->header('location') eq $location, "$url location E:[$location] R:[" . $response->header('location') . "]");
	}
}
