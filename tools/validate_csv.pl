#!/usr/bin/env perl

#
#  validate CSV file format
#
use Test::More;

foreach my $file (@ARGV) {
	my $test = ValidateCSV->new($file);
	$test->run_tests();
}

done_testing();
exit;


package ValidateCSV;
use base 'SourcesTest';

use v5.10;
use strict;
use warnings;
use Test::More;

sub test {
    my $self = shift;
    $self->test_source_line(@_);
}
