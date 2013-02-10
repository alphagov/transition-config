#!/usr/bin/env perl

#
#  tidy_mappings - canonicalise and remove duplicate redirector mappings
#
use v5.10;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

require 'lib/c14n.pl';

my $titles;
my %seen = ();
my $uniq = 0;
my $no_output;
my $help;

GetOptions(
    'no-output|n' => \$no_output,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

while (<STDIN>) {
    chomp;

    unless ($titles) {
        $titles = $_;
        next;
    }

    my ($old, $new, $status) = split(/,/);

    my $url = c14n_url($old);

    # line to be printed
    my $line = $_;
    $line =~ s/^[^,]*,//;
    $line = "$url,$line";

    my $key = $url;

    if ($seen{$url}) {
        if ($new eq $seen{$url}->{new} && $status eq $seen{$url}->{status}) {
            say STDERR "skipping $url line $.";
            next;
        } elsif ($status eq 410 && $seen{$url}->{status} eq "301") {
            say STDERR "skipping 410 $url for duplicate 301 line $.";
            next;
        } elsif ($status eq 301 && $seen{$url}->{status} eq "410") {
            say STDERR "replacing 410 $url with 301 line $.";
        } else {
            say STDERR "leaving $status $url duplicates differ line $.";
            $key = "#" . $uniq++;

            say STDERR "> " . $line;
            say STDERR "> " . $seen{$url}->{line};
            say STDERR "";
        }
    }

    $seen{$key} = {
        'new' => $new,
        'status' => $status,
        'line' => $line,
    };
}

#
#  print lines, sorted
#
unless ($no_output) {
    say $titles;
    open(OUT, "|sort");
    foreach my $url (keys %seen) {
         say OUT $seen{$url}->{line};
    }
    close(OUT);
}

__END__

=head1 NAME

tidy_mappings - canonicalise and remove duplicate redirector mappings

=head1 SYNOPSIS

tools/dedupe_mappings.pl [options] < mappings

Options:

    -n, --no-output     no output, just check
    -?, --help          print usage

=cut
