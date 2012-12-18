use v5.10;
use strict;
use warnings;

use LWP::UserAgent;
use Test::More;
use Text::CSV;
use URI;
require 'tests/integration/config_rules/get_response.pl';



my $input_file = 'data/directgov_subdomains.csv';
my $host_type  = $ENV{'DEPLOY_TO'} // 'preview';
my $ua         = LWP::UserAgent->new( max_redirect => 0 ),

my $csv = Text::CSV->new( { binary => 1 } ) 
    or die "Cannot use CSV: ".Text::CSV->error_diag();

open( my $fh, "<", $input_file ) 
    or die $input_file . ": $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );

ROW:
while ( my $row = $csv->getline_hr( $fh ) ) {
    my $old_url = sprintf 'http://%s/', $row->{'Subdomains'};
    my $action  = $row->{'Leave'};
    my $new_url = $row->{'redirect URL'};
    
    next ROW if $action =~ m{leave}i or $action =~ m{tbc}i;

    my $old_uri        = URI->new( $old_url );
    my $redirector_url = sprintf '%s%s',
                            "http://redirector.${host_type}.alphagov.co.uk",
                            $old_uri->path_query;
    my $request = HTTP::Request->new( 'GET', $redirector_url );
    $request->header( 'Host', $old_uri->host );
    my $response = $ua->request($request);
    my $location = $response->header('location') // '';
    
    if ( $action =~ m{gone}i ) {
        is(
            $response->code,
            410,
            "$old_url has gone"
        );
    }
    elsif ( $action =~ m{redirect}i ) {
        is(
            $response->code,
            301,
            "$old_url returns 301"
        );
        is(
            $location,
            $new_url,
            "$old_url redirects to $new_url",
        );
    }
    else {
        die "Unknown action: '$action' for $old_url";
    }
}

my ( $response_code, $redirect_location ) = get_response ( 'http://campaigns.direct.gov.uk/brand/toolkit/Toolkit_v3.4.1/Images/printlogo.gif' );
is( '200', $response_code, "asset on campaigns server is a 200" );

( $response_code, $redirect_location ) = get_response ( 'http://campaigns.direct.gov.uk/foo' );
is( '404', $response_code, "non-existent asset on campaigns server is a 404" );

done_testing();
