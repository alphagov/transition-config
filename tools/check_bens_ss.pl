#! /usr/bin/env perl

#
#  help improve consistency of Ben's Spreadsheet
#

use strict;
use warnings;

use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;

#
#  curl Ben's spreadsheet
#
system('curl "https://docs.google.com/spreadsheet/pub?key=0AprXhKI73WmwdHMwaW1aZVphOUJ1a3dTTGhJSFV5dGc&single=true&gid=0&output=csv" > bens.csv');

#
#  list of urls
#
my %urls = ();

#
#  process Ben's spreadsheet
#
my $column = 0;
open( my $fh, "<", "bens.csv" ) or die "bens.csv: $!";
my $csv = Text::CSV->new( { 'binary' => 1 } ) or die "Cannot use CSV: ".Text::CSV->error_diag();
while ( my $row = $csv->getline( $fh ) ) {

    next unless($column++);

    # BL_TITLE,Old Url,ITEM_ID,TOPIC_ID,New Url,GOVUK_TITLE,GOVUK_SECTION,Status,Whole tag,SUGGESTED_URLS,NOTES

    my ($old_url, $new_url, $status_code) = ($row->[1], $row->[4], $row->[7]);

    if ($new_url) {
	if ($new_url !~ /^http/) {
		print STDERR "invalid new_url: $new_url\n"
	} else {
		$urls{$new_url} = $column;
	}
    }
}

#
#  check new urls
#
my $ua = LWP::UserAgent->new( max_redirect => 0 );

foreach my $url (sort keys %urls) {

    next unless ($url =~ /^https:\/\/www.gov.uk/);

    my $request = HTTP::Request->new( 'GET', $url );
    my $response = $ua->request($request);

    my $ok = ($response->code == 200) ? ' ' : '*';

    print STDERR $response->code . "$ok $url\n";
}

exit 0;
