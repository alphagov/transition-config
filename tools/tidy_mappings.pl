#!/usr/bin/env perl

#
#  tidy_mappings - canonicalise and remove duplicate redirector mappings
#
use v5.10;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use LWP::UserAgent;
use Text::CSV;
use URI;

require 'lib/c14n.pl';
require 'lib/lists.pl';

my $titles;
my %seen = ();
my %known = ();
my $uniq = 0;
my $no_output;
my $use_actual;
my $blacklist = "data/blacklist.txt";
my $ignore_blacklist;
my $sites = "data/sites.csv";
my $ignore_sites;
my $query_string;
my $trump;
my $help;

GetOptions(
    "blacklist|b=s"  => \$blacklist,
    "ignore-blacklist|B"  => \$ignore_blacklist,
    'no-output|n' => \$no_output,
    'use-actual|a' => \$use_actual,
    "query-string|q=s"  => \$query_string,
    "sites|s=s"  => \$sites,
    "ignore-sites|S"  => \$ignore_sites,
    "trump|t"  => \$trump,
    'help|?' => \$help,
) or pod2usage(1);

pod2usage(2) if ($help);

my %paths = load_blacklist($blacklist) unless ($ignore_blacklist);
load_sites($sites, \%known) unless ($ignore_sites);

my $ua = LWP::UserAgent->new(max_redirect => 0);

while (<STDIN>) {
    chomp;

    unless ($titles) {
        $titles = $_;
        next;
    }

    my ($old, $new, $status, $rest) = split(/,/, $_, 4);
    $rest //= "";

    $status = "410" if (uc($status) eq "TNA");
    $status ||= $new ? "301" : "410";

    $new = "" if ($status eq "410");

    my $url = c14n_url($old, $query_string);

    my $known = $known{c14n_url($new, '-')};
    if ($known) {
        say STDERR "swapping new [$new] with known [$known] line $.";
        $new = $known;
    }

    # line to be printed
    my @line = ( $url, $new, $status );
    push @line, $rest if ($rest);
    my $line = join(",", @line);

    my $old_path = $url;
    $old_path =~ s/^http:\/\/[^\/]*//;
    if ($paths{$old_path}) {
        say STDERR "skipping blacklisted path [$old_path] line $.";
        next;
    }

    if ($trump) {
        $seen{$url} = { new => $new, status => $status, line => $line };
        next;
    }

    if (!$seen{$url}) {
        $seen{$url} = { new => $new, status => $status, line => $line };
        next;
    }

    if ($new eq $seen{$url}->{new} && $status eq $seen{$url}->{status}) {
        say STDERR "skipping $url line $.";
        next;
    }

    if ($status eq 410 && $seen{$url}->{status} eq "301") {
        say STDERR "skipping 410 $url for duplicate 301 line $.";
        next;
    }

    if ($status eq 301 && $seen{$url}->{status} eq "410") {
        say STDERR "replacing 410 $url with 301 line $.";
        $seen{$url} = { new => $new, status => $status, line => $line };
        next;
    }

    if ($use_actual) {
        my $request = HTTP::Request->new('GET', $old);
        my $response = $ua->request($request);
        my $actual_new = $response->header('location');
        my $actual_status = $response->code;

        if ($actual_status =~ /^(200|301|410)$/) {
            my @fields = split(/,/, $line);
            shift @fields; # Old Url
            shift @fields; # New Url
            shift @fields; # Status
            $line = "$url,$actual_new,$actual_status," . join(',', @fields);
            say STDERR "using actual $line line $.";
            $seen{$url} = { new => $new, status => $status, line => $line };
            next;
        }
    }

    say STDERR "leaving $status $url duplicates differ line $.";
    my $key = "#" . $uniq++;
    $seen{$key} = { new => $new, status => $status, line => $line };

    say STDERR "> " . $line;
    say STDERR "> " . $seen{$url}->{line};
    say STDERR "";
}

#
#  print lines, sorted
#
unless ($no_output) {
    say $titles;
    open(OUT, "|./tools/csort");
    foreach my $url (keys %seen) {
         say OUT $seen{$url}->{line};
    }
    close(OUT);
}

#
#  load furls from sites.csv
#
sub load_sites {
    my $filename = shift;
    my $known = shift;
    my $csv = Text::CSV->new({ binary => 1 }) or die "Cannot use CSV: " . Text::CSV->error_diag();

    open(my $fh, "<", $filename) or die "$filename: $!";

    my $names = $csv->getline($fh);
    $csv->column_names(@$names);

    while (my $row = $csv->getline_hr($fh)) {
        my $host = $row->{'Host'};
        my $new = $row->{'New Url'};
        my $aliases = $row->{'Aliases'};

        # add hosts and aliases
        foreach my $host (split(/\s+/, $aliases), $host) {
            add_known($known, 'http://' . $host, $new);
        }

        # TBD: FURL should be a URL
        add_known($known, "https://www.gov.uk" . $row->{'FURL'}, $new);

    }
}

sub add_known {

    my ($known, $url, $new) = @_;
    $known->{c14n_url($url, "-")} = $new;
}

__END__

=head1 NAME

tidy_mappings - canonicalise and remove duplicate redirector mappings

=head1 SYNOPSIS

tools/tidy_mappings.pl [options] < mappings

Options:

    -a, --use-actual            use the current, actual redirection to resolve conflicts
    -b, --blacklist filename    constrain Old Url paths to those not in the given blacklist file
    -B, --ignore-blacklist      ignore the blacklist file
    -n, --no-output             no output, just check
    -q, --query-string p1,p2    significant query-string parameters in Old Urls
                                '*' allows any parameter, '-' leaves query-string as-is
    -s, --sites filename        expand FURLs from sites file
    -t, --trump                 later mappings overwrite earlier ones
    -?, --help                  print usage

=cut
