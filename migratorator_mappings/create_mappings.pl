#!/usr/bin/env perl

use strict;
use warnings;
use Mappings;

my $csv = shift;
die "Usage: create_mappings.pl <input_csv>"
    unless defined $csv;

my $mappings = Mappings->new( $csv );
die "Not a valid CSV"
    unless defined $mappings;

my $configs = $mappings->entire_csv_as_nginx_config();
foreach my $host ( keys %$configs ) {
    open my $handle, '>', "$host.conf";
    print $handle $configs->{$host};
}
