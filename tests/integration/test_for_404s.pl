use strict;
use warnings;
use Test::More;
use Text::CSV;
use LWP::UserAgent;


my $csv = Text::CSV->new( { binary => 1 } ) 
    or die "Cannot use CSV: ".Text::CSV->error_diag();
my $ua = LWP::UserAgent->new( max_redirect => 0 );

open( my $fh, "<", "dist/directgov_all_mappings.csv" ) 
    or die "dist/directgov_all_mappings.csv: $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );


open ( my $output_log, ">", "dist/directgov_404s.csv" )
	or die "dist/directgov_404s.csv" . ": $!";


while ( my $row = $csv->getline_hr( $fh ) ) {
	my $url = $row->{'New Url'};

	if ( defined $url ) {
		my $response = $ua->get($url);
		isnt ( $response->code, 404, "$url is not a 404")
			or print $output_log "$url\n";
	}
}
done_testing();