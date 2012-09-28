#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use Text::CSV;
use Net::Statsd;



my $base_namespace = 'govuk.app.redirector.ratified';

graph_open_sources_in( 'dist/businesslink_mappings_source.csv', 'businesslink' );
graph_open_sources_in( 'dist/directgov_all_mappings.csv',       'directgov'    );
exit;


sub graph_open_sources_in {
    my $source_csv = shift;
    my $namespace  = shift;
    
    my $csv = Text::CSV->new({ binary => 1 }) 
        or die "Cannot use CSV: " . Text::CSV->error_diag();
    
    open( my $fh, "<", $source_csv ) 
        or die "${source_csv}: $!";
    
    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );
    
    my %page_state;
    
    while ( my $row = $csv->getline_hr( $fh ) ) {
        my $tag = lc $row->{'Whole Tag'};
        next if $tag =~ m{closed};
        
        $page_state{'total'}++;
        
        if ( $tag =~ m{awaiting-content} ) {
            $page_state{'awaitingcontent'}++;
        }
        elsif ( $tag =~ m{open} ) {
            $page_state{'open'}++;
        }
        elsif ( $tag =~ m{reviewed:no} ) {
            $page_state{'unreviewed'}++;
        }
        elsif ( $tag =~ m{devolved} ) {
            $page_state{'unreviewed'}++;
        }
        
        next if $tag =~ m{awaiting-content};
        next if $tag =~ m{open};
        next if $tag =~ m{reviewed:no};
        next if $tag =~ m{devolved};
        
        say STDERR "Unknown state: '${tag}'";
        use Data::Dumper::Concise;
        print Dumper \$row;
    }
    
    foreach my $state ( keys %page_state ) {
        my $graph_name = sprintf '%s.%s.unclosed.%s',
                            $base_namespace,
                            $namespace,
                            $state;
        
        say "$graph_name = $page_state{$state}";
        Net::Statsd::gauge( $graph_name, $page_state{$state} );
    }
}
