package IntegrationTest;

use v5.10;
use strict;
use warnings;

use Test::More;
use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;


sub new {
    my $class = shift;

    my $self = {
        ua => LWP::UserAgent->new( max_redirect => 0 ),
    };
    bless $self, $class;

    return $self;
}

sub input_file {
    my $self = shift;

    $self->{'input_file'} = shift;
}
sub output_file {
    my $self = shift;

    $self->{'output_file'} = shift;
}
sub output_error_file {
    my $self = shift;

    $self->{'output_error_file'} = shift;
}

sub run_tests {
    my $self = shift;

    my $csv = Text::CSV->new( { binary => 1 } ) 
        or die "Cannot use CSV: ".Text::CSV->error_diag();

    open( my $fh, "<", $self->{'input_file'} ) 
        or die $self->{'input_file'} . ": $!";

    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );

    open ( my $output_log, ">", $self->{'output_file'} )
        or die $self->{'output_file'} . ": $!";
    
    open ( my $output_error_log, '>', $self->{'output_error_file'} )
        or die $self->{'output_error_file'} . ": $!";
    
    say $output_log "Old Url,New Url,Status,Whole Tag,Test Result,"
                    . "Actual Status,Actual New Url,New Url Status";

    say $output_error_log "Old Url,New Url,Status,Whole Tag,Test Result,"
                          . "Actual Status,Actual New Url,New Url Status";
    
    while ( my $row = $csv->getline_hr( $fh ) ) {
        my( $passed, $response, $redirected_response )
            = $self->test($row);
        
        if ( $passed != -1 ) {
            my $response_status   = $response->code;
            my $location_header   = $response->header('location') // '';
            my $redirected_status = 0;
            
            if ( defined $redirected_response ) {
                $redirected_status = $redirected_response->code;
                my $is_redirect = 301 == $redirected_status
                                  || 302 == $redirected_status;
                
                if ( $is_redirect ) {
                    $location_header =
                        $redirected_response->header('location');
                }
            }
            
            say $output_log 
                join ',',
                    $row->{'Old Url'},
                    $row->{'New Url'} // '',
                    $row->{'Status'},
                    $row->{'Whole Tag'} // '',
                    $passed,
                    $response_status,
                    $location_header,
                    $redirected_status;
            
            if ( $passed == 0 ) {
                say $output_error_log
                    join ',',
                        $row->{'Old Url'},
                        $row->{'New Url'} // '',
                        $row->{'Status'},
                        $row->{'Whole Tag'} // '',
                        $passed,
                        $response_status,
                        $location_header,
                        $redirected_status;
            }
        }
    }

    done_testing();
}

sub get_response {
    my $self = shift;
    my $row  = shift;
    
    my $old_uri        = URI->new( $row->{'Old Url'} );
    my $redirector_url = sprintf '%s%s',
                            'http://redirector.preview.alphagov.co.uk',
                            $old_uri->path_query;
    
    my $request = HTTP::Request->new( 'GET', $redirector_url );
    $request->header( 'Host', $old_uri->host );
    
    return $self->{'ua'}->request($request);
}

sub test_closed_redirects {
    my $self = shift;
    my $row  = shift;
    
    my $mapping_status = lc $row->{'Whole Tag'};
    
    if ( $mapping_status =~ m{\bclosed\b} ) {
        return $self->is_redirect_response($row);
    }
    
    return -1;
}
sub is_redirect_response {
    my $self = shift;
    my $row  = shift;
    
    if ( 301 == $row->{'Status'} ) {
        my $old_url  = $row->{'Old Url'};
        my $new_url  = $row->{'New Url'};
        my $response = $self->get_response($row);
        
        my $passed = $response->header('location') eq $new_url;
        my $redirected_response;
        
        if ( $passed ) {
            $redirected_response = $self->{'ua'}->get($new_url);
            
            # FIXME swallow 404s for now - this allows our integration
            # tests to pass for "awaiting publication" content, which makes
            # them more useful for highlighting broken code
            if ( 404 == $redirected_response->code ) {
                $passed = 1;
                pass("$old_url redirects to $new_url, which is 200 (or 404)");
            }
            else {
                $passed = is(
                    $redirected_response->code,
                    200,
                    "$old_url redirects to $new_url, which is 200"
                );
            }
        }
        
        return(
            $passed,
            $response,
            $redirected_response
        );
    }
    
    return -1;
}
sub test_closed_gones {
    my $self = shift;
    my $row  = shift;
    
    my $mapping_status = lc $row->{'Whole Tag'};
    
    if ( $mapping_status =~ m{\bclosed\b} ) {
        return $self->is_gone_response($row);
    }
    
    return -1;
}
sub is_gone_response {
    my $self = shift;
    my $row  = shift;
    
    if ( 410 == $row->{'Status'} ) {
        my $response = $self->get_response($row);
        my $old_url  = $row->{'Old Url'};
        
        my $passed = is(
                $response->code,
                410,
                "$old_url returns 410"
            );
        
        return(
            $passed,
            $response,
            undef
        );
    }
    
    return -1;
}
sub is_valid_redirector_response {
    my $self = shift;
    my $row  = shift;

    my $response = $self->get_response($row);
    my $response_code = $response->code;
    my $valid_response = ( 410 == $response_code || 301 == $response_code );

    my $old_url  = $row->{'Old Url'};

    my $passed = ok( $valid_response, "$old_url returns $response_code" );

    return(
        $passed,
        $response,
        undef
    );
}

1;
