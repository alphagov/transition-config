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
 use File::Path qw(mkpath);
use Mappings;

my $dir = "dist/maps";
my $help;

GetOptions(
    'dir|d=s' => \$dir,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

my $file = shift or pod2usage(2);
;
my $mappings = Mappings->new($file);
die "generate_maps: unable to process $file" unless defined $mappings;

my $configs = $mappings->entire_csv_as_nginx_config();

$configs->{'location'} = '' unless($configs->{'location'});

foreach my $type (keys %$configs) {

    # guess suffix from the config name
    my $suffix;
    if ($type =~ m{error$}) {
        $suffix = ".txt" 
    } elsif ($type =~ /archive|suggested/) {
        $suffix = ".php" 
    } else {
        $suffix = ".conf";
    }

    my $path = "$dir/$type$suffix";

    say STDERR "creating $path";

    my $handle;
    open $handle, '>', "$path" or die "unable to open $path: $!";
    print $handle $configs->{$type};
    close $handle;
}

__END__

=head1 NAME

generate_maps.pl - generate nginx maps from a mappings format CSV file

=head1 SYNOPSIS

tools/generate_maps.pl :: [options] file

Options:

    -d, --directory                 directory to create maps
    -?, --help                      print usage

=cut
