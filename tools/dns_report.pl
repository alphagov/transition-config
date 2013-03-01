#!/usr/bin/perl

use strict;

my %status = (
    'aka.businesslink.gov.uk.edgekey.net.' => 'LIVE',
    'www.gov.uk.edgekey.net.' => 'LIVE',
    'redirector.www.gov.uk.edgekey.net.' => 'LIVE',
    'wildcard.ukwelcomes.businesslink.gov.uk.edgekey.net.' => 'LIVE',
    'aka.direct.gov.uk.edgekey.net.' => 'LIVE',
);

while (<>) {
    if ($_ =~ /CNAME/) {
        my ($host, $secs, $IN, $CNAME, $cname) = split;

        my $status = $status{$cname} // "-";

        my $old = $cname;
        my $new = "";

        printf "%-55s %8s  %-4s  %s\n", $host, ttl($secs), $status, $old, $new;
    }
}

sub ttl {
    my $secs = shift;
    return ($secs / 3600) . " hours" if ($secs > 3600);
    return              1 . " hour " if ($secs == 3600);
    return   ($secs / 60) . " mins " if ($secs > 60);
    return              1 . " min  " if ($secs == 60);
    return          $secs . " secs ";
}
