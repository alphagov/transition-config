#!/usr/bin/env perl

#
#  validate redirector sites CSV file
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
use Date::Parse;
use HTML::Entities;

my %seen_site;
my %seen_host;
my $help;

GetOptions(
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

foreach my $filename (@ARGV) {
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
    ok($line =~ /^Site,Host,Redirection Date,TNA Timestamp,Title,FURL,Aliases,Options,New Url(,?$|,)/, "incorrect column names [$line]");

    while (my $row = $csv->getline_hr($fh)) {
        my $site = $row->{'Site'} // '';
        test_row("[$site] $filename line $.", $row);
    }
}

sub test_row {
    my ($context, $row)  = @_;

    my $site = $row->{'Site'} // '';
    ok($site =~ /^[A-z0-9_]+$/, "invalid site name");
    ok(!$seen_site{$site}, "duplicate site [$site] $context");
    $seen_site{$site} = $context;

    my $title = $row->{'Title'} // '';
    is($title, c14n_html($title), "title incorrectly HTML encoded");

    my $host = $row->{'Host'} // '';
    check_host($context, "host", split(/\s+/, $host));

    my $redirection_date = $row->{'Redirection Date'} // '';
    ok($redirection_date =~ /\d{1,2}(st|rd|th) \w{3,8} 20\d\d$/, "invalid redirection date format [$redirection_date] $context");
    ok(str2time($redirection_date), "invalid redirection date [$redirection_date] $context");

    my $tna_timestamp = $row->{'TNA Timestamp'} // '';
    ok($tna_timestamp =~ /[0-9]{14}/, "invalid TNA timestamp format [$tna_timestamp] $context");
    my $tna_time = sprintf "%s%s-%s-%sT%s:%s:%s UTC", $tna_timestamp =~ m/(..)/g, ('00') x 7;
    ok(str2time($tna_time), "invalid TNA timestamp time [$tna_timestamp] [$tna_time] $context");

    my $furl = $row->{'FURL'} // '';
    ok($furl =~ /^\/[a-z0-9-]+$/, "invalid furl [$furl] $context") if ($furl);

    $furl = "https://www.gov.uk$furl";
    check_new_url($context, 'FURL', $furl);

    my $aliases = $row->{'Aliases'} // '';
    check_host($context, "aliases", split(/\s+/, $aliases)) if ($aliases);

    my $options = $row->{'Options'} // '';

    my $new_url = $row->{'New Url'} // '';
    check_new_url($context, 'New Url', $new_url);
}

sub check_new_url {
    my ($context, $name, $url) = @_;

    ok($url =~ m{^https://}, "$name '$url' should be a https URI $context");

    my $uri = URI->new($url);
    is($uri, $url, "$name '$url' should be a valid URI $context");

    return $uri;
}

sub check_unquoted {
    my $filename = shift;
    open(FILE, "< $filename") or die "unable to open whitelist $filename";
    my $contents = do { local $/; <FILE> };
    ok($contents !~ /["']/, "file [$filename] contains quotes");
    ok($contents !~ /\t/, "file [$filename] contains tab characters");
}

sub check_host {
    my $context = shift;
    my $name = shift;
    foreach my $host (@_) {
        # actually more restrictive than RFC 1035
        ok(!$seen_host{$host}, "duplicate host [$host] $context");
        ok($host =~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,3}$/, "invalid $name [$host] $context");
        $seen_host{$host} = $name;
    }
}

sub c14n_html {
    return encode_entities(decode_entities(shift, "&<>'\","));
}

__END__

=head1 NAME

validate_sites - validate redirector sites CSV file

=head1 SYNOPSIS

prove tools/validate_sites.pl :: [options] [file ...]

Options:

    -?, --help                      print usage

=cut
