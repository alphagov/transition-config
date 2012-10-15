use v5.10;
use strict;
use warnings;

use Text::CSV;



my $THRESHOLD = 0.9;

my $csv = Text::CSV->new({ binary => 1 }) 
    or die "Cannot use CSV: " . Text::CSV->error_diag();

open( my $fh, "<", 'dist/integration_results.csv' ) 
    or die "dist/integration_results.csv: $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );

my $total_tests_run    = 0;
my $total_tests_passed = 0;

while ( my $row = $csv->getline_hr( $fh ) ) {
    $total_tests_run = $row->{'count'}
        if $row->{'graph'} eq 'govuk.app.redirector.total.total';
    $total_tests_passed = $row->{'count'}
        if $row->{'graph'} eq 'govuk.app.redirector.ratified.passed';
}

# return an error code if not enough tests pass
exit( ($total_tests_passed / $total_tests_run) < $THRESHOLD );
