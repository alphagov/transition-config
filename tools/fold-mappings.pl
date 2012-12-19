#!/usr/bin/env perl

#
#  hack to fold mappings so we don't redirect to a redirect
#

use strict;

use Text::CSV;
use URI;

my %urls;

#
#  read mappings CSV ..
#
my $csv = Text::CSV->new({ binary => 1 });

my $names = $csv->getline(*STDIN);
$csv->column_names(@$names);

while (my $row = $csv->getline_hr(*STDIN)) {
	$urls{$row->{'Old Url'}} = $row;
}

#
#  write folded mappings ..
#
$csv->combine($names);
print $csv->string() . "\n";

foreach my $url (sort keys %urls) {
	my $row = $urls{$url};

	$row->{'New Url'} = $urls{$row->{'New Url'}}->{'New Url'} // $row->{'New Url'};

	$csv->combine(map { $row->{$_} } @$names);
	print $csv->string() . "\n";
}

exit 0;
