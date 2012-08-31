#!/usr/bin/env perl

use strict;
use Text::CSV;
use Data::Dumper;

my $csv = Text::CSV->new({ binary => 1 });

my $fh = *STDIN;
my $titles = $csv->getline($fh);

while (my $row = $csv->getline($fh)) {

        #Title,Old Url, New Url, Status, Notes, Group, Name, Whole Tag
	my ($title, $old, $new, $status, $notes, $group, $name, $whole_tag) = @$row;

	print "$old,$new,$status\n";
}

$csv->eof or $csv->error_diag();