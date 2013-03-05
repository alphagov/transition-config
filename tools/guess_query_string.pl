#!/usr/bin/env perl

#
#  guess_mappings - attempt to find unique query string parameters in a set of mappings
#
use v5.10;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use URI;

require 'lib/c14n.pl';
require 'lib/lists.pl';

my $titles;

my $help;

GetOptions(
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

my %count = ();

while (<STDIN>) {
    chomp;

    unless ($titles) {
        $titles = $_;
        next;
    }

    my ($old, $new, $status) = split(/,/);

    my $uri = URI->new($old);

    my %query = $uri->query_form;
    foreach my $name (keys %query) {
        my $value = $query{$name};
        next unless ($value);

        my $key = "$name=$value";
        $count{$key}++;
    }
}

#
#  find the query string names which are most unique ..
#
my %uniques = ();
foreach my $key (keys %count) {
    if ($count{$key} < 3) {
        my ($name, $value) = split(/=/, $key, 1);
        $uniques{$name}++;
    }
}

foreach my $name (sort keys %uniques) {
    say $name
}

__END__

=head1 NAME

guess_mappings - attempt to find unique query string parameters in a set of mappings

=head1 SYNOPSIS

tools/guess_mappings.pl [options] < mappings

Options:

    -?, --help                  print usage

=cut
