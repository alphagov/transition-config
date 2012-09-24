#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use Text::CSV;
use Net::Statsd;



my $businesslink_mappings
    = count_rows_in_csv('dist/businesslink_mappings_source.csv');
my $directgov_mappings
    = count_rows_in_csv('dist/directgov_all_mappings.csv');
my $total_mappings = $businesslink_mappings + $directgov_mappings;

say "--graph-number govuk.app.redirector.total.total=$total_mappings";
say "--graph-number govuk.app.redirector.total.directgov=$directgov_mappings";
say "--graph-number govuk.app.redirector.total.businesslink=$businesslink_mappings";

say STDERR "Businesslink total mappings $businesslink_mappings";
say STDERR "Directgov total mappings    $directgov_mappings";
say STDERR "TOTAL                       $total_mappings";

Net::Statsd::gauge(
    'govuk.app.redirector.total.businesslink',
    $businesslink_mappings
);
Net::Statsd::gauge(
    'govuk.app.redirector.total.directgov',
    $directgov_mappings
);
Net::Statsd::gauge(
    'govuk.app.redirector.total.total',
    $total_mappings
);
exit;



sub count_rows_in_csv {
    my $source = shift;
    
    my $csv = Text::CSV->new({ binary => 1 }) 
        or die "Cannot use CSV: " . Text::CSV->error_diag();
    
    open( my $fh, "<", $source ) 
        or die "${source}: $!";
    
    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );
    
    my $row_count = 0;
    while ( $csv->getline_hr( $fh ) ) {
        $row_count++;
    }
    
    return $row_count;
}
