#!/usr/bin/env perl

use strict;
use Text::CSV;
use Data::Dumper;

my $csv = Text::CSV->new({ binary => 1 });

my $fh = *STDIN;
my $titles = $csv->getline($fh);
my $line = 1;

while (my $row = $csv->getline($fh)) {
    $line++;
    
        #Title,Old Url, New Url, Status, Notes, Group, Name, Whole Tag
    my ($title, $old, $new, $status, $notes, $group, $name, $whole_tag) = @$row;
    
    if ( ! length $old ) {
        print STDERR "Entry without URL at line ${line}\n";
        next;
    }
    
    if ( 301 == $status ) {
        if ( ! length $new ) {
            print STDERR "${old} has no redirect destination at line ${line}\n";
            next;
        }
    }
    
    print "${old},${new},${status}\n";
}

$csv->eof or $csv->error_diag();