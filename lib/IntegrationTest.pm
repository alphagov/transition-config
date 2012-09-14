package IntegrationTest;

use strict;
use warnings;
use Test::More;
use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;


sub new {
	my $class = shift;

	my $self = {};
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
	my $ua = LWP::UserAgent->new( max_redirect => 0 );

	open( my $fh, "<", $self->{'input_file'} ) 
	    or die $self->{'input_file'} . ": $!";

	my $names = $csv->getline( $fh );
	$csv->column_names( @$names );

	open ( my $output_log, ">", $self->{'output_file'} )
	    or die $self->{'output_file'} . ": $!";

	while ( my $row = $csv->getline_hr( $fh ) ) {
	    my $old_url = $row->{'Old Url'};
	    
	    my $uri = URI->new($old_url);
	    my $old_url_path = $uri->path_query;
	    
	    my $status_code = $row->{'Status'};

	    my $request = HTTP::Request->new( 'GET', "http://redirector.preview.alphagov.co.uk$old_url_path" );
	    $request->header( 'Host', $uri->host );
	    my $response = $ua->request($request);

	    
	    my( $return, $mapping_status, $new_url ) = $self->test($status_code, $response, $row);

	    if ( 0 == $return ) {
	        printf $output_log "%s,%s,%s,%s\n", $old_url, $new_url, $status_code, $mapping_status;
	    }
	}

	done_testing();
}

1;
