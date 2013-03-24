#!/usr/bin/env perl

#
#  generate nginx locations from a validated redirector mappings format CSV file
#
use v5.10;
use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

my $host = "";
my $help;

GetOptions(
    "host|h=s"  => \$host,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

while (<>) {
    next unless (/^http:\/\/$host/);

    chomp;
    my ($old, $new, $status) = split(",");

    # chop Old Url into a path
    my $path = location($old);

    my $space = $new ? " " : "";

    print "location ~* ^$path/?\$ { return $status$space$new; }\n";
}

exit;

sub location {
    my $path = shift;
    $path =~ s{http://[^/]*}{};

    # changing %-encoding back into real characters
    # possibly not needed ..
    #$path =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;

    $path =~ s{\(}{\\(}g;
    $path =~ s{\)}{\\)}g;
    $path =~ s{\.}{\\.}g;
    $path =~ s{\*}{\\*}g;
    $path =~ s{ }{\\ }g;
    $path =~ s{\t}{\\\t}g;
    $path =~ s{;}{\\;}g;

    return $path;
}


__END__

=head1 NAME

generate_locations - generate nginx locations from a validated redirector mappings format CSV file

=head1 SYNOPSIS

tools/generate_locations.pl :: [options]

Options:

    -h, --host host             only use Old Urls for the host
    -?, --help                  print usage

=cut
