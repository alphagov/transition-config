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

        my $url = $old;
        $url =~ s/\?*$//;
        $url =~ s/\/*$//;

	my $line = $_;
	$line =~ s/^[^,]*,//;
	$line = "$url,$line";

        if ($seen{$url}) {
		if ($new eq $seen{$url}->{new} && $status eq $seen{$url}->{status}) {
			say STDERR "ditching $url line $.";
			next;
		} else {
			if ($status eq $seen{$url}->{status}) {
				say STDERR "leaving duplicate $url [new url differs] line $.";
			} else {
				say STDERR "leaving duplicate $url [status differs] line $.";
			}
			say STDERR "> " . $line;
			say STDERR "> " . $seen{$url}->{line};
			say STDERR "";
		}
        }

	say "$line";

        $seen{$url} = {
		'new' => $new,
		'status' => $status,
		'line' => $line,
        };
    }
