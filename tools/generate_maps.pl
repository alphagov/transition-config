#!/usr/bin/env perl

#
#  generate nginx maps from a mappings format CSV file
#
use v5.10;
use strict;
use warnings;
use lib './lib';

use Getopt::Long;
use Pod::Usage;
use Mappings;

my $help;

GetOptions(
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

my $filename = shift;
pod2usage(2) unless ($filename);

my $mappings = Mappings->new($filename);
die "generate_maps: unable to process $filename" unless defined $mappings;

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

__END__

=head1 NAME

generate_maps.pl - generate nginx maps from a mappings format CSV file

=head1 SYNOPSIS

tools/generate_maps.pl :: [options] filename

Options:

    -?, --help                      print usage

=cut
