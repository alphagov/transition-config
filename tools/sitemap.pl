#!/usr/bin/env perl
#
#  generate a sitemap.xml
#
use strict;
use Text::CSV;
use URI;

my $input = shift or die "Usage: sitemap.pl <dist/mappings_source.csv>   > sitemap.xml";

# whitelist of hostnames
my %host = ();
foreach my $host (@ARGV) {
    $host{$host} = 1;
}

my $csv = Text::CSV->new( { binary => 1 } ) 
    or die "Cannot use CSV: ".Text::CSV->error_diag();

open( my $fh, "<", $input )
    or die "$input: $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );

my %url;

while ( my $row = $csv->getline_hr( $fh ) ) {

    my $url = $row->{'Old Url'};
    my $status = $row->{'Status'};

    next unless ($status =~ /^[23]/);

    my $uri = URI->new($url);

    next unless ($host{$uri->host});

    # XML encode ampersands
    $url =~ s/&/\&amp;/g;

    # rip off trailing query character
    $url =~ s/\?$//;

    $url{$url} = $url;
}

print '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
print '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n";

foreach my $url ( sort { $b cmp $a } keys %url ) {
	print "    <url><loc>$url{$url}</loc></url>\n";
}

print "</urlset>\n";

exit 0;