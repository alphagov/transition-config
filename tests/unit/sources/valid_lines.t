use v5.10;
use strict;
use warnings;

use Test::More;
use Text::CSV;

my $csv = Text::CSV->new({ binary => 1 }) 
        or die "Cannot use CSV: " . Text::CSV->error_diag();
    
open( my $fh, "<", "dist/businesslink_mappings_source.csv" ) 
        or die "dist/businesslink_mappings_source.csv: $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );

while ( my $row = $csv->getline_hr( $fh ) ) {
	ok( $row->{'Old Url'} ne "#REF!", "should not contain #REF!");
}

done_testing();