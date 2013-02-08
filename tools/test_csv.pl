#!/usr/bin/env perl

#
#  command to test a single CSV file
#  - currently a Perl test, so has the rather strange usage:
#
#  $ prove tools/test_csv.pl :: data/mappings/file.csv ...
#
#  TBD: 
#  - refactor into a conventional unix command with switches
#  - make error messages human readable
#  - output files in sensible place
#

use v5.10;
use strict;
use warnings;

use Test::More;

#
#  test the mappings cited in CSV files
#
foreach my $file (@ARGV) {

	my $name = $file;
	$name =~ s/^.*\/([\w\.]*).csv$/$1/;

	say STDERR "$file :: $name";

	my $test = SampleTests->new();
	$test->input_file($file);
	$test->output_file("dist/${name}_test_output.csv");
	$test->output_error_file("dist/${name}_failures.csv");
	$test->run_some_tests();
}

done_testing();

package SampleTests;

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

    my $env = $ENV{'DEPLOY_TO'} // 'preview';

    # should be a command line option 'host'
    $self->{'redirector'} = $env . "alphagov.co.uk";

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

sub output_redirects_file {
    my $self = shift;

    $self->{'output_redirects_file'} = shift;
}

sub run_some_tests {
    my $self = shift;

    my $csv = Text::CSV->new( { binary => 1 } )
        or die "Cannot use CSV: ".Text::CSV->error_diag();

    open( my $fh, "<", $self->{'input_file'} )
        or die $self->{'input_file'} . ": $!";

    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );

    open ( my $output_log, ">", $self->{'output_file'} )
        or die $self->{'output_file'} . ": $!";

    say $output_log "Old Url,New Url,Status,Test Result,"
                    . "Actual Status,Actual New Url,New Url Status"
                        unless defined $self->{'output_has_no_header'};

    my $error_count = 0;
    open ( my $output_error_log, '>', $self->{'output_error_file'} )
        or die $self->{'output_error_file'} . ": $!";

    say $output_error_log "Old Url,New Url,Expected Status,"
                          . "Actual Status,Actual New Url,New Url Status"
                              unless defined $self->{'output_has_no_header'};

    my $output_redirects_log;
    my $redirects_count = 0;
    if ( defined $self->{'output_redirects_file'} ) {
        open ( $output_redirects_log, ">", $self->{'output_redirects_file'} )
            or die $self->{'output_redirects_file'} . ": $!";
        say $output_redirects_log "Old Url,New Url,Expected Status,"
                            . "Actual Status,Actual New Url,New Url Status"
                                unless defined $self->{'output_has_no_header'};
    }

    while ( my $row = $csv->getline_hr( $fh ) ) {
        my( $passed, $response, $redirected_response, $chased_redirect )
            = $self->test($row);

        if ( $passed != -1 ) {
            my $response_status   = $response->code;
            my $location_header   = $response->header('location') // '';
            my $redirected_status = 'no redirect followed';

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
                    $passed,
                    $response_status,
                    $location_header,
                    $redirected_status;

            if ( $passed == 0 ) {
                $error_count++;
                say $output_error_log
                    join ',',
                        $row->{'Old Url'},
                        $row->{'New Url'} // '',
                        $row->{'Status'},
                        $response_status,
                        $location_header,
                        $redirected_status;
            }

            if ( $chased_redirect && defined $self->{'output_redirects_file'} ) {
                $redirects_count++;
                say $output_redirects_log
                    join ',',
                        $row->{'Old Url'},
                        $row->{'New Url'} // '',
                        $row->{'Status'},
                        $response_status,
                        $location_header,
                        $redirected_status;
            }
        }
    }

    # clean up error/redirect files if no actual errors or redirects occured
    close $output_error_log;
    unlink $self->{'output_error_file'}
        unless $error_count;
    if ( defined $self->{'output_redirects_file'} ) {
        close $output_redirects_log;
        unlink $self->{'output_redirects_file'}
            unless $redirects_count;
    }

}

sub run_tests {

    my $self = shift;
    $self->run_some_tests();
    done_testing();
}

sub get_response {
    my $self = shift;
    my $row  = shift;

    my $request;

    if ($self->{'redirector'}) {
        my $old_uri        = URI->new( $row->{'Old Url'} );
        my $redirector_url = $self->{redirector} . $old_uri->path_query;

        $request = HTTP::Request->new( 'GET', $redirector_url );
        $request->header( 'Host', $old_uri->host );
    } else {
        $request = HTTP::Request->new( 'GET', $row->{'Old Url'} );
    }

    return $self->{'ua'}->request($request);
}

sub is_redirect_to_a_200_or_410_eventually {
    my $self = shift;
    my $row  = shift;

    if ( 301 == $row->{'Status'} ) {
        my $old_url  = $row->{'Old Url'};
        my $new_url  = $row->{'New Url'};
        my $response = $self->get_response($row);
        my $location = $response->header('location');

        my $redirected_response_code = "wrong redirect location";
        my $redirected_response;

        my $max_redirects = 3;
        my $chased_redirect = 0;

        while ( $max_redirects && defined $location ) {
            $max_redirects--;

            $redirected_response      = $self->{'ua'}->get($location);
            $redirected_response_code = $redirected_response->code;
            $location                 = $redirected_response->header('location');

            $chased_redirect = 1
                 if defined $location;
        }

        if ( defined $location && $location eq $new_url ) {
            $redirected_response = $self->{'ua'}->get($new_url);
            $redirected_response_code = $redirected_response->code;
        }

        my $passed = is($redirected_response_code, 200, "$old_url redirects to $new_url, which is 200 line $.");

        return(
            $passed,
            $response,
            $redirected_response,
            $chased_redirect
        );
    }

    return -1;
}

sub test_closed_gones {
    my $self = shift;
    my $row  = shift;

    return $self->is_gone_response($row);
}

sub is_gone_response {
    my $self = shift;
    my $row  = shift;

    if ( 410 == $row->{'Status'} ) {
        my $response = $self->get_response($row);
        my $old_url  = $row->{'Old Url'};

        my $passed = is($response->code, 410, "$old_url returns 410 line $.");

        return($passed, $response, undef);
    }

    return -1;
}

sub is_ok_response {
    my $self = shift;
    my $row  = shift;

    if ( 200 == $row->{'Status'} ) {
        my $response = $self->get_response($row);
        my $old_url  = $row->{'Old Url'};

        my $passed = is($response->code, 200, "$old_url returns 200 line $.");

        return($passed, $response, undef);
    }

    return -1;
}

sub test {
    my $self = shift;

    my ( $passed, $response, $test_response ) = $self->is_redirect_to_a_200_or_410_eventually(@_);

    if ( -1 == $passed ) {
    	( $passed, $response, $test_response ) = $self->test_closed_gones(@_);
    	if ( -1 == $passed ) {
    		( $passed, $response, $test_response ) = $self->is_ok_response(@_);
    	}
    }

    return ($passed, $response, $test_response);
}

1;
