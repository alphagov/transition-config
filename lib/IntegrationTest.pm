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
	say $output_log "Old Url,New Url,Status,Whole Tag,Test Result,"
	                . "Actual Status,Actual New Url";

	while ( my $row = $csv->getline_hr( $fh ) ) {
	    my( $passed, $response_status, $location_header ) = $self->test($row);
	    
	    if ( $passed != -1 ) {
	        say $output_log 
	            join ',',
	                $row->{'Old Url'},
                    $row->{'New Url'},
                    $row->{'Status'},
                    $row->{'Whole Tag'},
                    $passed,
                    $response_status,
                    $location_header;
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
        
        my $passed = is(
                $response->header('location'),
                $new_url,
                "$old_url redirects to $new_url"
            );
        
        return(
            $passed,
            $response->code,
            $response->header('location')
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
            $response->code,
            $response->header('location') // ''
        );
    }
    
    return -1;
}

1;
