#!/usr/bin/env perl

#
#  tidy_mappings - canonicalise and remove duplicate redirector mappings
#
use v5.10;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use LWP::UserAgent;
use URI;

require 'lib/c14n.pl';

my $titles;
my %seen = ();
my $uniq = 0;
my $no_output;
my $use_actual;
my $allow_query_string;
my $trump;
my $help;

GetOptions(
    'no-output|n' => \$no_output,
    'use-actual|a' => \$use_actual,
    "allow-query-string|q"  => \$allow_query_string,
    "trump|t"  => \$trump,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

my $ua = LWP::UserAgent->new(max_redirect => 0);

while (<STDIN>) {
    chomp;

    unless ($titles) {
        $titles = $_;
        next;
    }

    my ($old, $new, $status) = split(/,/);

    my $url = c14n_url($old, $allow_query_string);

    # line to be printed
    my $line = $_;
    $line =~ s/^[^,]*,//;
    $line = "$url,$line";

    if ($trump) {
        $seen{$url} = { new => $new, status => $status, line => $line };
        next;
    }

    if (!$seen{$url}) {
        $seen{$url} = { new => $new, status => $status, line => $line };
        next;
    }

    if ($new eq $seen{$url}->{new} && $status eq $seen{$url}->{status}) {
        say STDERR "skipping $url line $.";
        next;
    }

    if ($status eq 410 && $seen{$url}->{status} eq "301") {
        say STDERR "skipping 410 $url for duplicate 301 line $.";
        next;
    }

    if ($status eq 301 && $seen{$url}->{status} eq "410") {
        say STDERR "replacing 410 $url with 301 line $.";
        $seen{$url} = { new => $new, status => $status, line => $line };
        next;
    }

    if ($use_actual) {
        my $request = HTTP::Request->new('GET', $old);
        my $response = $ua->request($request);
        my $actual_new = $response->header('location');
        my $actual_status = $response->code;

        if ($actual_status =~ /^(200|301|410)$/) {
            my @fields = split(/,/, $line);
            shift @fields; # Old Url
            shift @fields; # New Url
            shift @fields; # Status
            $line = "$url,$actual_new,$actual_status," . join(',', @fields);
            say STDERR "using actual $line line $.";
            $seen{$url} = { new => $new, status => $status, line => $line };
            next;
        }
    }

    say STDERR "leaving $status $url duplicates differ line $.";
    my $key = "#" . $uniq++;
    $seen{$key} = { new => $new, status => $status, line => $line };

    say STDERR "> " . $line;
    say STDERR "> " . $seen{$url}->{line};
    say STDERR "";
}

#
#  print lines, sorted
#
unless ($no_output) {
    say $titles;
    open(OUT, "|./tools/csort");
    foreach my $url (keys %seen) {
         say OUT $seen{$url}->{line};
    }
    close(OUT);
}

__END__

=head1 NAME

tidy_mappings - canonicalise and remove duplicate redirector mappings

=head1 SYNOPSIS

tools/tidy_mappings.pl [options] < mappings

Options:

    -n, --no-output             no output, just check
    -a, --use-actual            use the current, actual redirection to resolve conflicts
    -q, --allow-query-string    allow query-string in Old Urls
    -t, --trump                 later mappings overwrite earlier ones
    -?, --help                  print usage

=cut
