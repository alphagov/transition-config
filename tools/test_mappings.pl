#!/usr/bin/env perl

#
#  test a redirector mappings format CSV file
#

use v5.10;
use strict;
use warnings;

use Text::CSV;
use Getopt::Long;
use Pod::Usage;
use HTTP::Request;
use LWP::UserAgent;
use URI;

require 'lib/assert.pl';
require 'lib/c14n.pl';

my $env = $ENV{'DEPLOY_TO'} // "dev";
my $host;
my $real;
my $timeout = 10;
my $skip_assets = 0;
my $no_follow = 0;
my $mappings = 0;
my $help;

GetOptions(
    'skip-assets|a' => \$skip_assets,
    'env|e=s' => \$env,
    'host|h=s' => \$host,
    'no-follow|n' => \$no_follow,
    'real|r' => \$real,
    'mappings|m' => \$mappings,
    'timeout|t=s' => \$timeout,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

$host //= "redirector.$env.alphagov.co.uk";

my $ua = LWP::UserAgent->new(max_redirect => 0, timeout => $timeout);
my $follow = LWP::UserAgent->new(max_redirect => 3, timeout => $timeout);

if ($mappings) {
    foreach my $mapping (@ARGV) {
        test_mapping('', split(',', $mapping));
    }
} else {
    foreach my $filename (@ARGV) {
        test_csv($filename);
    }
}

done_testing();
exit;

sub test_csv {
    my ($filename) = @_;
    my $csv = Text::CSV->new({ binary => 1 });

    open my $fh, "<$filename" or die "unable to open $filename";

    my $names = $csv->getline($fh);
    $csv->column_names(@$names);

    while (my $row = $csv->getline_hr($fh)) {

        my ($url, $location, $status) = (
            $row->{'Old Url'},
            $row->{'New Url'},
            $row->{'Status'},
        );

        test_mapping("$filename line $.", $url, $location, $status);
    }

    done_file();
    close($fh);
}

sub test_mapping {
    my ($context, $url, $location, $status) = @_;

    my $uri = URI->new($url);

    print "$url invalid uri $context\n" unless($uri);

    # direct or via redirector?
    my $get = $real ? $url : $uri->scheme . "://" . $host . $uri->path_query;

if (0) {
    # make request
    my $request = HTTP::Request->new('GET', $get);
    $request->header('Host', $uri->host);
    my $response = $ua->request($request);
    my $response_location = $response->header('location') // '';

    # skip assets?
    return if ($skip_assets && $status eq '200');

    # check response
    my $code = $response->code;
    my $message = $response->message;
    is($code, $status, "${url} unexpected status [$message] $context");

    if ($location || $response_location) {
        is($response_location, $location, "[$url] unexpected location $context");
    }

    # follow redirect
    unless ($no_follow) {
        if ($location && $response_location && $location eq $response->header('location')) {
            my $request = HTTP::Request->new('GET', $location);
            my $response = $follow->request($request);
            my $code = $response->code;
            my $message = $response->message;
            ok($code =~ /^(200|410)/, "followed redirect to [$location] which is [$code $message] $context");
        }
    }
    }
}

__END__

=head1 NAME

test_mappings - test redirector mappings

=head1 SYNOPSIS

tools/test_mappings.pl [options] [filename ...] | [mapping ...]

Options:

    -a, --skip-assets       ignore mappings which expect a 200 response
    -e, --environment env   override DEPLOY_TO environment dev|preview|production|...
    -h, --host hostname     specifiy redirector hostname
    -n, --no-follow         don't follow a redirect to check New Url
    -r, --real              test with real hostnames from mapping urls
    -t, --timeout secs      HTTP timeout in seconds
    -m, --mappings          treat args are a series of mapping lines
    -?, --help              print usage

=cut
