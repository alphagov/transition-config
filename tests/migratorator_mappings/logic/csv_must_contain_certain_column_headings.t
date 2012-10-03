use strict;
use warnings;
use Test::More tests => 6;
use Mappings;

my $good_mappings = Mappings->new( 'tests/migratorator_mappings/first_line_good.csv' );
isa_ok( $good_mappings, 'Mappings' );

my $bad_mappings = Mappings->new( 'tests/migratorator_mappings/first_line_bad.csv' );
ok( ! defined $bad_mappings );

my $test_with_wrong_columns = {};
bless $test_with_wrong_columns, 'Mappings';
$test_with_wrong_columns->{'column_names'} = [ 'Test', 'wrong', 'column', 'names' ];
is( 0, $test_with_wrong_columns->has_mandatory_columns, 'If the CSV does not contain required column titles, the object will not instantiate.' );

my $test_with_only_correct_columns = {};
bless $test_with_only_correct_columns, 'Mappings';
$test_with_only_correct_columns->{'column_names'} = [ 'Old Url', 'New Url', 'Status'];
is( 1, $test_with_only_correct_columns->has_mandatory_columns, 'If the CSV contains the required column headings, the object can be instatiated.' );

my $test_including_correct_columns = {};
bless $test_including_correct_columns, 'Mappings';
$test_including_correct_columns->{'column_names'} = [ 'Some', 'Old Url', 'Other', 'New Url', 'Columns', 'Status'];
is( 1, $test_including_correct_columns->has_mandatory_columns, 'If the CSV contains the required column headings, other additional columns do not prevent instatiation of the object.' );

my $test_with_disordered_columns = {};
bless $test_with_disordered_columns, 'Mappings';
$test_with_disordered_columns->{'column_names'} = [ 'Status', 'Old Url', 'New Url'];
is( 1, $test_with_disordered_columns->has_mandatory_columns, 'If the CSV contains the required column headings, the order does not matter.' );
