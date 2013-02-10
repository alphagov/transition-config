#!/usr/bin/env perl

#
#  test a redirector mappings format CSV file
#
# TBD: follow and check redirect
# TBD: create csv files for reports
# TBD: check 410 content for archive and suggested links

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

my $env = $ENV{'DEPLOY_TO'} // "preview";
my $host = "http://redirector.$env.alphagov.co.uk";
my $skip_assets = 0;
my $mappings = 0;
my $help;

GetOptions(
    'skip-assets|a' => \$skip_assets,
    'mapping|m' => \$mappings,,
    'help|?' => \$help,
) or pod2usage(1);

my $ua = LWP::UserAgent->new(max_redirect => 0);

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
    close($fh);
}

sub test_mapping {
    my ($context, $url, $location, $status) = @_;

    my $uri = URI->new($url);

    my $request = HTTP::Request->new('GET', $host . $uri->path_query);
    $request->header('Host', $uri->host);

    my $response = $ua->request($request);

    return if ($skip_assets && $status eq '200');

    is($response->code, $status, "${url} status $context");

    if ($location || $response->header('location')) {
        is($response->header('location'), $location, "[$url] location $context");
    }
}

__END__

=head1 NAME

test_mappings - test redirector mappings

=head1 SYNOPSIS

prove tools/test_mappings.pl :: [options] [filename ...] | [mapping ...]

Options:

    -a, --skip-assets       ignore mappings which expect a 200 response
    -m, --mappings          treat args are a series of mapping lines
    -?, --help              print usage

=cut
