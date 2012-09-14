use strict;
use warnings;
use Test::More;
use Text::CSV;
use LWP::UserAgent;

#
#  de-dup using a hash
#
my %new_url = ();

# TBD: make filenames consistent
gather_new_urls('dist/directgov_all_mappings.csv');
gather_new_urls('dist/businesslink_mappings_source.csv');

#
#  check new urls
#
open ( my $output_log, ">", "dist/new_url_404s.csv" )
	or die "dist/new_url_404s.csv" . ": $!";

my $ua = LWP::UserAgent->new( max_redirect => 0 );

	foreach my $url (sort keys %new_url) {
		my $response = $ua->get($url);
		isnt ( $response->code, 404, "$url is not a 404")
			or print $output_log "$url\n";
	}

done_testing();

#
#  read CSV of mappings
#
sub gather_new_urls
{
	my ($path) = @_;

	my $csv = Text::CSV->new( { binary => 1 } ) 
	    or die "Cannot use CSV: ".Text::CSV->error_diag();

	open( my $fh, "<", $path )
	    or die "$path: $!";

	my $names = $csv->getline( $fh );
	$csv->column_names( @$names );

	while ( my $row = $csv->getline_hr( $fh ) ) {
		my $url = $row->{'New Url'};
		if ( defined $url ) {
			$new_url{$url}++;
		}
	}

	close ( $fh );
}
