#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use Text::CSV;
use Net::Statsd;



my $output_csv     = shift;
my $base_namespace = 'govuk.app.redirector.ratified';

my $csv;
if ( defined $output_csv ) {
    open $csv, '>>', $output_csv
        or die $output_csv . ": $!";
}

graph_errors_in( 'dist/businesslink_redirects_test_output.csv', 'businesslink' );
graph_errors_in( 'dist/directgov_redirects_test_output.csv',    'directgov'    );
exit;


sub graph_errors_in {
    my $error_csv = shift;
    my $namespace = shift;
    
    my $csv = Text::CSV->new({ binary => 1 }) 
        or die "Cannot use CSV: " . Text::CSV->error_diag();
    
    open( my $fh, "<", $error_csv ) 
        or die "${error_csv}: $!";
    
    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );
    
    my %statuses;
    while ( my $row = $csv->getline_hr( $fh ) ) {
        my $actual_status = $row->{'New Url Status'};
        $statuses{$actual_status}++;
    }
    
    foreach my $status_code ( keys %statuses ) {
        next unless $status_code;
        
        my $graph_name = sprintf '%s.%s.redirects.returned_%s',
                            $base_namespace,
                            $namespace,
                            $status_code;
        
        say "$graph_name = $statuses{$status_code}";
        
        say $csv "$graph_name = $statuses{$status_code}"
            if defined $output_csv;
        
        Net::Statsd::gauge( $graph_name, $statuses{$status_code} );
    }
}
