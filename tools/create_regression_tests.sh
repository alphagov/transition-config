#!/bin/sh

generate_template() {
	local package_name=$1
	local name=$1
	local path="$(pwd)/tests/redirects/${name}"
	mkdir -p $path
	cat > "${path}/gone.t" <<EOF
my \$test = ${package_name}::Ratified::Gone->new();
\$test->input_file("dist/${name}_mappings_source.csv");
\$test->output_file("dist/${name}_gone_output.csv");
\$test->output_error_file("dist/${name}_gone_errors.csv");
\$test->run_tests();
exit;


package ${package_name}::Ratified::Gone;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my \$self = shift;

    \$self->test_closed_gones(@_);
    
}

EOF

}