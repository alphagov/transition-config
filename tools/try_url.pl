#!/usr/bin/env perl

#
#  curl urls against the redirector
#

use v5.10;
use strict;
use warnings; 

use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use HTTP::Request;
use LWP::UserAgent;
use URI;

my $env = $ENV{'DEPLOY_TO'} // "dev";
my $host;
my $curl_cmd;
my $real;
my $verbose;
my $help;

GetOptions(
    'curl-cmd|c' => \$curl_cmd,
    'env|e=s' => \$env,
    'host|h=s' => \$host,
    'real|r' => \$real,
    'verbose|v' => \$verbose,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

$host //= "redirector.$env.alphagov.co.uk";

my $ua = LWP::UserAgent->new(max_redirect => 0);

foreach my $url (@ARGV) {
    try_url($url);
}

sub try_url {
    my $url = shift;

    my $uri = URI->new($url);

    # direct or via redirector?
    my $get = $real ? $url : $uri->scheme . "://" . $host . $uri->path_query;

    my $flags = $verbose ? "-v" : "";
    my $cmd =  "curl $flags -H 'host: " . $uri->host . "' '$get'";
    say "+ $cmd";

    if ($curl_cmd) {
        exec($cmd);
    } else {
        # make request
        my $request = HTTP::Request->new('GET', $get);
        $request->header('Host', $uri->host);
        my $response = $ua->request($request);
        my $code = $response->code;
        my $location = $response->header('location') // '';

        say "$code $location";
        print Dumper $response if $verbose;
    }
}

__END__

=head1 NAME

try_url.pl - try out a url directly against the redirector

=head1 SYNOPSIS

tools/try_url.pl [options] [url ...]

Options:

    -c, --curl              use real curl command
    -e, --environment env   override DEPLOY_TO environment dev|preview|production|...
    -h, --host hostname     specifiy redirector hostname
    -r, --real              test with real hostnames
    -v, --verbose           dump response
    -?, --help              print usage

=cut
