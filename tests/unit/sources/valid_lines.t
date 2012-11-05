use v5.10;
use strict;
use warnings;

use Test::More;
use Text::CSV;
use URI;


test_file('dist/businesslink_mappings_source.csv');
test_file('dist/businesslink_piplink_redirects_source.csv');
test_file('dist/directgov_mappings_source.csv');
done_testing();



sub test_file {
    my $filename = shift;
    
    my $csv = Text::CSV->new({ binary => 1 }) 
            or die "Cannot use CSV: " . Text::CSV->error_diag();

    open( my $fh, "<", $filename )
            or die "$filename: $!";

    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );

    while ( my $row = $csv->getline_hr( $fh ) ) {
        test_row($row);
    }
}
sub test_row {
    my $row = shift;
    
    my $old_url = $row->{'Old Url'};
    ok( $old_url ne '#REF!',        "$old_url should not be '#REF!'" );
    ok( $old_url =~ m{^https?://},  "$old_url should be a full URL"  );
    
    # strip leading/trailing whitespace before comparing
    $old_url =~ s{^\s*(.*?)\s*$}{$1};
    my $old_uri = URI->new($old_url);
    is( $old_uri, $old_url, "$old_url should be a valid URL" );

    my $new_url = $row->{'New Url'};
    ok( $new_url !~ m{^http://www.gov.uk}, "$old_url points to $new_url - should point to HTTPS" );
    
    if ( "301" eq $row->{'Status'} && $new_url ne '' ) {
        # strip leading/trailing whitespace before comparing
        $new_url =~ s{^\s*(.*?)\s*$}{$1};
        my $new_uri = URI->new($new_url);
        
        ok( $new_url =~ m{^https?://}, "$new_url (from $old_url) should be a full URL"  );
        is( $new_uri, $new_url,        "$new_url (from $old_url) should be a valid URL" );
    }
}
