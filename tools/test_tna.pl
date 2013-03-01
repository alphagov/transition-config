#!/usr/bin/env perl

#
#  check Old Urls are in The National Archives
#  usage: < data/mappings/domain.csv
#

use v5.10;
use strict;
use warnings;

use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;

my $csv = Text::CSV->new({ binary => 1 }) or die "Cannot use CSV: ".Text::CSV->error_diag();
open(my $fh, "<-") or die "$!";

print "Old Url,New Url,Status,TNA\n";

my $names = $csv->getline($fh);
$csv->column_names(@$names);

while ( my $row = $csv->getline_hr( $fh ) ) {

	my $old_url = $row->{'Old Url'};
	my $new_url = $row->{'New Url'};
	my $status = $row->{'Status'};

	# fetch Old Url from The National Archives
	my $tna_url = "http://webarchive.nationalarchives.gov.uk/*/${old_url}";

	my $request = HTTP::Request->new('GET', $tna_url);
	my $ua = LWP::UserAgent->new(max_redirect => 0);
	my $response = $ua->request($request);
	my $tna_status = $response->code;

	print "$old_url,$new_url,$status,$tna_status\n";
}
