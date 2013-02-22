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

my $dir = "dist";
my $help;

GetOptions(
    'dir|d=s' => \$dir,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

my ($site) = @ARGV;
pod2usage(2) unless ($site);

my $file = "data/mappings/$site.csv";

my $mappings = Mappings->new($file);
die "generate_maps: unable to process $file" unless defined $mappings;

my $configs = $mappings->entire_csv_as_nginx_config();

my @hosts = keys %{$configs};
die "multiple hostnames in $file\n" if (@hosts > 1);

my %types = @hosts ? %{$configs->{$hosts[0]}} : ();
$types{'location'} = '' unless($types{'location'});

foreach my $type (keys %types) {

    my $suffix = ($type =~ m{error$}) ? "s.txt" : ".conf";
    my $path = "$dir/${site}.${type}${suffix}";

    say STDERR "creating $path";

    my $handle;
    open $handle, '>', "$path";
    print $handle $types{$type};
    close $handle;
}

__END__

=head1 NAME

generate_maps.pl - generate nginx maps from a mappings format CSV file

=head1 SYNOPSIS

tools/generate_maps.pl :: [options] site [file]

Options:

    -d, --directory                 directory to create maps
    -?, --help                      print usage

=cut
