#!/usr/bin/env perl

use strict;
use Text::CSV;
use Data::Dumper;

my $csv = Text::CSV->new({ binary => 1 });

my $fh = *STDIN;
my $titles = $csv->getline($fh);

while (my $row = $csv->getline($fh)) {

        #Title,Old Url, item id, topic id, New Url, new title, section, Status, suggested URLs, Notes
	my ($title, $old, $item_id, $topic_id, $new, $new_title, $section, $status, $suggested_urls, $notes) = @$row;

	print "$old,$new,$status\n";
}

$csv->eof or $csv->error_diag();
