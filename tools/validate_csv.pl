#!/usr/bin/env perl

#
#  validate CSV file format
#
use v5.10;
use strict;
use warnings;

use Test::More;
use Text::CSV;
use Getopt::Long;
use Pod::Usage;
use HTTP::Request;
use LWP::UserAgent;
use URI;

my $canonical;
my $duplicates;
my $https;
my $help;
my %hosts = ();
my %seen = ();

GetOptions(
    "canonical|c"  => \$canonical,
    "duplicates|d"  => \$duplicates,
    "https|h"  => \$https,
    'help|?' => \$help,
) or pod2usage(1);

my $filename = shift // "";
my $domain = shift // "";
my $whitelist = shift // "data/whitelist.txt";

pod2usage(2) if ($help);

load_whitelist($whitelist);

check_unquoted($filename);

test_file($filename);

done_testing();

exit;

sub test_file {
    my $filename = shift;
    my $csv = Text::CSV->new({ binary => 1 }) or die "Cannot use CSV: " . Text::CSV->error_diag();

    open(my $fh, "<", $filename) or die "$filename: $!";

    my $names = $csv->getline($fh);
    $csv->column_names(@$names);

    while (my $row = $csv->getline_hr($fh)) {
        ok(!$csv->is_quoted(1), "value quoted $.");
        test_row($row);
    }
}

sub test_row {
    my $row  = shift;

    my $old_url = $row->{'Old Url'} // '';
    my $new_url = $row->{'New Url'} // '';
    my $status = $row->{'Status'} // '';

    my $old_uri = check_url('Old Url', $old_url);

    my $scheme = $old_uri->scheme;


    my $s = ($https) ? "s?" : "";
    ok($scheme =~ m{^http$s$}, "Old Url [$old_url] scheme [$scheme] must be [http] line $.");

    ok($old_url =~ m{^https?://$domain}, "Old Url [$old_url] domain not [$domain] line $.");

    my $c14n = c14n_url($old_url);

    if ($canonical) {
        is($old_url, $c14n, "Old Url [$old_url] is not canonical [$c14n] line $.");
    }

    if ($duplicates) {
        ok(!defined($seen{$c14n}), "Old Url [$old_url] line $. is a duplicate of line " . ($seen{$c14n} // ""));
        $seen{$c14n} = $.;
    }

    if ( "301" eq $status) {
        my $new_uri = check_url('New Url', $new_url);
        my $host = $new_uri->host;
        ok($hosts{$host}, "New Url [$new_url] host [$host] not whiltelist line $.");
    } elsif ( "410" eq $status) {
        ok($new_url eq '', "unexpected New Url [$new_url] for 410 line $.");
    } elsif ( "200" eq $status) {
        ok($new_url eq '', "unexpected New Url [$new_url] for 200 line $.");
    } else {
       fail("invalid Status [$status] for Old Url [$old_url] line $.");
    }
}

sub check_url {
    my ($name, $url) = @_;

    $url =~ s/\|/%7C/g;

    ok($url =~ m{^https?://}, "$name '$url' should be a full URI line $.");

    ok($url !~ m{,}, "bare comma in $name $url line $.");

    my $uri = URI->new($url);
    is($uri, $url, "$name '$url' should be a valid URI line $.");

    return $uri;
}

sub c14n_url {
    my ($url) = @_;
    $url = lc($url);
    $url =~ s/\?*$//;
    $url =~ s/\/*$//;
    $url =~ s/\#*$//;
    return $url;
}

sub load_whitelist {
    my $filename = shift;
    local *FILE;
    open(FILE, "< $filename") or die "unable to open whitelist $filename";
    while (<FILE>) {
        chomp;
        $_ =~ s/\s*\#.*$//;
        $hosts{$_} = 1 if ($_);
    }
}

sub check_unquoted {
    my $filename = shift;
    open(FILE, "< $filename") or die "unable to open whitelist $filename";
    my $contents = do { local $/; <FILE> };
    ok($contents !~ /["']/, "file [$filename] contains quotes");
}

__END__

=head1 NAME

validate_csv - validate a redirector mappings style CSV file

=head1 SYNOPSIS

prove tools/validate_csv.pl [options] [file ...]

Options:

    -c, --canonical   check for canonical Old Urls
    -d, --duplicates  check for duplicate Old Urls
    -h, --https       allow Old Urls to be https
    -?, --help        print usage

=cut
