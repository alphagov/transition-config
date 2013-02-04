#!/usr/bin/env perl

use Test::More;

#
#  test the mappings cited in CSV files
#
foreach my $file (@ARGV) {

	my $name = $file;
	$name =~ s/^.*\/([\w\.]*).csv$/$1/;

	say STDERR "$file :: $name";

	my $test = SampleTests->new();
	$test->{'force_production_redirector'} = 1;
	$test->input_file($file);
	$test->output_file("dist/${name}_test_output.csv");
	$test->output_error_file("dist/${name}_failures.csv");
	$test->run_some_tests();
}

done_testing();

exit;

package SampleTests;
use base 'IntegrationTest';

sub test {
    my $self = shift;

    my ( $passed, $response, $test_response ) = $self->test_closed_redirects(@_);

    if ( -1 == $passed ) {
    	( $passed, $response, $test_response ) = $self->test_closed_gones(@_);
    	if ( -1 == $passed ) {
    		( $passed, $response, $test_response ) = $self->is_ok_response(@_);
    	}
    }

    return (
    	$passed,
    	$response,
    	$test_response
    );
}
