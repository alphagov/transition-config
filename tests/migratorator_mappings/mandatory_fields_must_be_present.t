use strict;
use warnings;
use Test::More tests => 2;
use Mappings;

my $good_mappings = Mappings->new( 'tests/migratorator_mappings/first_line_good.csv' );
isa_ok( $good_mappings, 'Mappings' );

my $bad_mappings = Mappings->new( 'tests/migratorator_mappings/first_line_bad.csv' );
ok( ! defined $bad_mappings );
