#!/usr/bin/env perl

#
#  filter obvious duplicates from CSV
#
use v5.10;
use strict;
use warnings;

my %seen = ();

    while (<STDIN>) {
        chomp;
        my ($old, $new, $status) = split(/,/);

	my $line = $_;

        my $url = $old;
        $url =~ s/\?*$//;
        $url =~ s/\/*$//;

        if ($seen{$url}) {
		if ($new eq $seen{$url}->{new} && $status eq $seen{$url}->{status}) {
			say STDERR "ditching $url line $.";
			next;
		} else {
			say STDERR "leaving $url line $.";

			# print canonical url, so sortable
			$line =~ s/^[^,]*,//;
			$line = "$url,$line";
		}
        }

	say "$line";

        $seen{$url} = {
		'new' => $new,
		'status' => $status,
        };
    }
