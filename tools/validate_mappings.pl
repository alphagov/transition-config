#!/usr/bin/env perl

#
#  validate a redirector mappings format CSV file
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

require 'lib/c14n.pl';
require 'lib/lists.pl';

my $skip_canonical;
my $allow_duplicates;
my $allow_query_string;
my $allow_https;
my $disallow_embedded_urls;
my $blacklist = "data/blacklist.txt";
my $whitelist = "data/whitelist.txt";
my $ignore_blacklist;
my $ignore_whitelist;
my $host = "";
my %seen = ();
my $help;

GetOptions(
    "blacklist|b=s"  => \$blacklist,
    "ignore-blacklist|B"  => \$ignore_blacklist,
    "skip-canonical|c"  => \$skip_canonical,
    "allow-duplicates|d"  => \$allow_duplicates,
    "allow-query-string|q"  => \$allow_query_string,
    "allow-https|t"  => \$allow_https,
    "disallow-embedded-urls|u"  => \$disallow_embedded_urls,
    "host|h=s"  => \$host,
    "whitelist|w=s"  => \$whitelist,
    "ignore-whitelist|W"  => \$ignore_whitelist,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

my %hosts = load_whitelist($whitelist) unless ($ignore_whitelist);
my %paths = load_blacklist($blacklist) unless ($ignore_blacklist);

foreach my $filename (@ARGV) {
    %seen = ();
    check_unquoted($filename);
    test_file($filename);
}

done_testing();

exit;

sub test_file {
    my $filename = shift;
    my $csv = Text::CSV->new({ binary => 1 }) or die "Cannot use CSV: " . Text::CSV->error_diag();

    open(my $fh, "<", $filename) or die "$filename: $!";

    my $names = $csv->getline($fh);
    $csv->column_names(@$names);

    my $line = join(",", @$names);
    ok($line =~ /^Old Url,New Url,Status(,?$|,)/, "incorrect column names [$line]");

    while (my $row = $csv->getline_hr($fh)) {
        test_row("$filename line $.", $row);
    }
}

sub test_row {
    my ($context, $row)  = @_;

    my $old_url = $row->{'Old Url'} // '';
    my $new_url = $row->{'New Url'} // '';
    my $status = $row->{'Status'} // '';

    my $old_uri = check_url($context, 'Old Url', $old_url);

    my $c14n = c14n_url($old_url, $allow_query_string);

    unless ($skip_canonical) {
        is($old_url, $c14n, "Old Url [$old_url] is not canonical [$c14n] $context");
    }

    unless ($allow_query_string) {
        ok(!$old_uri->query, "Old Url [$old_url] query string not allowed $context");
    }

    if ($disallow_embedded_urls) {
        ok($old_url !~ /^http[^\?]*http/, "Old Url [$old_url] contains another Url $context");
    }

    my $scheme = $old_uri->scheme;

    my $s = ($allow_https) ? "s?": "";
    ok($scheme =~ m{^http$s$}, "Old Url [$old_url] scheme [$scheme] must be [http] $context");

    my $old_path = $old_uri->path;
    ok(!$paths{$old_path}, "Old Url [$old_url] path [$old_path] is blacklisted $context");

    ok($old_url =~ m{^https?://$host}, "Old Url [$old_url] host not [$host] $context");

    unless ($allow_duplicates) {
        ok(!defined($seen{$c14n}), "Old Url [$old_url] $context is a duplicate of line " . ($seen{$c14n} // ""));
        $seen{$c14n} = $.;
    }

    if ($status =~ /^301|418$/) {
        my $new_uri = check_url($context, "$status New Url", $new_url);
        if ($new_uri) {
            my $new_host = $new_uri->host;
            ok($hosts{$new_host}, "New Url [$new_url] host [$new_host] not whitelist $context");
        }
    } elsif ( "410" eq $status) {
        ok($new_url eq '', "unexpected New Url [$new_url] for 410 $context");
    } elsif ( "200" eq $status) {
        ok($new_url eq '', "unexpected New Url [$new_url] for 200 $context");
    } else {
       fail("invalid Status [$status] for Old Url [$old_url] line $.");
    }
}

sub check_url {
    my ($context, $name, $url) = @_;

    # | is valid in our Urls
    $url =~ s/\|/%7C/g;

    ok($url =~ m{^https?://}, "$name [$url] should be a full URI $context");

    my $uri = URI->new($url);
    is($uri, $url, "$name '$url' should be a valid URI $context");

    return $uri;
}

sub check_unquoted {
    my $filename = shift;
    open(FILE, "< $filename") or die "unable to open whitelist $filename";
    my $contents = do { local $/; <FILE> };
    ok($contents !~ /["']/, "file [$filename] contains quotes");
}

__END__

=head1 NAME

validate_mappings - validate a redirector mappings format CSV file

=head1 SYNOPSIS

prove tools/validate_mappings.pl :: [options] [file ...]

Options:

    -b, --blacklist filename        constrain Old Url paths to those not given the blacklist file
    -B, --ignore-blacklist          ignore the blacklist file
    -c, --skip-canonical            don't check for canonical Old Urls
    -d, --allow-duplicates          allow duplicate Old Urls
    -h, --host host                 constrain Old Urls to host
    -t, --allow-https               allow https in Old Urls
    -q, --allow-query-string        allow query-string in Old Urls
    -u, --disallow-embedded-urls    disallow Urls in Old Urls
    -w, --whitelist filename        constrain New Urls to those in given whitelist file
    -W, --ignore-whitelist          ignore the whitelist file
    -?, --help                      print usage

=cut
