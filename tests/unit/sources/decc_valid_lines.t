my $test = Decc::Source->new('dist/decc_mappings_source.csv');
$test->run_tests();
exit;


package Decc::Source;
use base 'SourcesTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    $self->test_source_line(@_);
}

