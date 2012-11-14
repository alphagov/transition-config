#!/usr/bin/env perl

use strict;
use warnings;
use Mappings;

my $csv = shift;
die "Usage: create_mappings.pl <input_csv>"
    unless defined $csv;

my $mappings = Mappings->new( $csv );
die "$csv: not a valid CSV"
    unless defined $mappings;

my $configs = $mappings->entire_csv_as_nginx_config();

foreach my $host ( keys %$configs ) {
    foreach my $type ( keys %{ $configs->{$host} } ) {
        my $handle;
        
        if ( $type =~ m{error$} ) {
            open $handle, '>', "dist/${host}.${type}s.txt";
        }
        else {
            open $handle, '>', "dist/${host}.${type}.conf";
        }
        print $handle $configs->{$host}{$type};
    }
}
