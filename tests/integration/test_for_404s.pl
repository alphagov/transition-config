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

while ( my $row = $csv->getline_hr( $fh ) ) {
	my $old_url = $row->{'Old Url'};
	my $response = $ua->get($old_url);

	isnt ( $response->code, 404, "$old_url is not a 404");
}