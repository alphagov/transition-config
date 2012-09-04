#!/usr/bin/env perl

use strict;
use warnings;
use Text::CSV;

my $csv = Text::CSV->new({ binary => 1 });

my $fh = *STDIN;
my $titles = $csv->getline($fh);
$csv->column_names(@$titles);

open my $formatting_errors,          '>>', 'dist/formatting_errors.txt';
open my $no_destination_errors,      '>>', 'dist/no_destination_errors.txt';
open my $looks_like_redirect_errors, '>>', 'dist/looks_like_redirect_errors.txt';


print "Old Url,New Url,Status\n";

while (my $row = $csv->getline_hr($fh)) {
    
    my $old    = $row->{'Old Url'};
    my $new    = $row->{'New Url'};
    my $status = $row->{'Status'};
    
    if ( ! length $old ) {
        print $formatting_errors "Entry without URL: '${old},${new},${status}'\n";
        next;
    }
    if ( ! length $status ) {
        print $formatting_errors "Entry without status: '${old},${new},${status}'\n";
        next;
    }
    
    if ( 301 == $status && ! length $new ) {
        print $no_destination_errors "Redirect without destination: '${old},${new},${status}'\n";
        next;
    }
    if ( 410 == $status && length $new ) {
        print $looks_like_redirect_errors "Gone but with destination: '${old},${new},${status}'\n";
        next;
    }
    
    print "${old},${new},${status}\n";
}

$csv->eof or $csv->error_diag();