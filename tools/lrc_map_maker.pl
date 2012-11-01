#!/usr/bin/env perl

use strict;
use Text::CSV;

my $input = shift or die "Usage: lrc_map_maker.pl <data/lrc_transactions_source.csv>\n";

my $csv = Text::CSV->new( { binary => 1 } ) 
    or die "Cannot use CSV: ".Text::CSV->error_diag();

open( my $fh, "<", $input )
    or die "$input: $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );

my %txnid;
my @tests;

while ( my $row = $csv->getline_hr( $fh ) ) {
    my $txnid = $row->{'TxnId'};
    my $url   = $row->{'New Url'};

    $url =~ s/&amp;/\&/g;
    $url =~ s/ /%20/g;

    $txnid{$txnid} = $url;

    push @tests, {
        old => 'http://lrc.businesslink.gov.uk/lrc/lrcOutbound?xgovs9k=${txnid}',
        new => $url,
        status => 301,
    };
}

foreach my $txnid ( sort { $b cmp $a } keys %txnid ) {
    print "~\\bxgovr3h=$txnid\\b $txnid{$txnid};\n";
}
