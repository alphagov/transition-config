my $test = Mod::Source->new('dist/mod_mappings_source.csv');
$test->run_tests();
exit;


package Mod::Source;
use base 'SourcesTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;
    $self->test_source_line(@_);
}
