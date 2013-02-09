#!/usr/bin/env perl

#
#  filter obvious duplicates from CSV
#
#  usage:
#
#  $ tools/dedupe.pl < mappings.csv > output.csv
#
use v5.10;
use strict;
use warnings;

my $titles;
my %seen = ();
my $uniq = 0;

while (<STDIN>) {
    chomp;

    unless ($titles) {
        $titles = $_;
        next;
    }

    my ($old, $new, $status) = split(/,/);

    # c14n url
    my $url = $old;
    $url = lc($url);
    $url =~ s/\?*$//;
    $url =~ s/\/*$//;
    $url =~ s/\#*$//;

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
say $titles;
open(OUT, "|sort");
foreach my $url (keys %seen) {
     say OUT $seen{$url}->{line};
}
close(OUT);
