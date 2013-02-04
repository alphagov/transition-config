#!/bin/sh

generate_valid_lines_test() {
	local package_name=$1
	local site=$(echo "$package_name" | tr '[:upper:]' '[:lower:]')
	local source_path="$(pwd)/tests/unit/sources"
	mkdir -p $source_path
    cat > "${source_path}/${site}_valid_lines.t" <<EOF
my \$test = ${package_name}::Source->new('dist/${site}_mappings_source.csv');
\$test->run_tests();
exit;


package ${package_name}::Source;
use base 'SourcesTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my \$self = shift;
    \$self->test_source_line(@_);
}

EOF

}

generate_regression_test() {
	local package_name=$1
	local site=$(echo "$package_name" | tr [:upper:] [:lower:])
	local source_path="$(pwd)/tests/regression/"
	mkdir -p $source_path
	cat > "${source_path}/${site}.t" <<EOF
my \$test = ${package_name}::Finalised->new();
\$test->input_file("dist/${site}_mappings_source.csv");
\$test->output_file("dist/${site}_all_tested.csv");
\$test->output_error_file("dist/${site}_errors.csv");
\$test->output_redirects_file("dist/${site}_redirects_chased.csv");
\$test->run_tests();
exit;


package ${package_name}::Finalised;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my \$self = shift;

    my ( \$passed,
    	\$response,
    	\$redirected_response,
    	\$chased_redirects ) = \$self->test_closed_gones(@_);

    #i.e. it is not a 410
    if ( -1 == \$passed ) {
    	( \$passed,
    	\$response,
    	\$redirected_response,
    	\$chased_redirects ) = \$self->test_finalised_redirects(@_);
    }

    return ( \$passed,
    	\$response,
    	\$redirected_response,
    	\$chased_redirects );
}

EOF

}

generate_in_progress_gone_test(){
    local package_name=$1
    local site=$(echo "$package_name" | tr [:upper:] [:lower:])
    local source_path="$(pwd)/tests/integration/in_progress"
    mkdir -p $source_path/${site}
    cat > "${source_path}/${site}/gone.t" <<EOF
my \$test = $package_name::In_Progress::Gone->new();
\$test->input_file("dist/${site}_mappings_source.csv");
\$test->output_file("dist/${site}_gone_output.csv");
\$test->output_error_file("dist/${site}_gone_errors.csv");
\$test->run_tests();
exit;


package $package_name::In_Progress::Gone;
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

generate_in_progress_redirection_test(){
    local package_name=$1
    local site=$(echo "$package_name" | tr [:upper:] [:lower:])
    local source_path="$(pwd)/tests/integration/in_progress"
    mkdir -p $source_path/${site}
    cat > "${source_path}/${site}/redirects.t" <<EOF
my \$test = $package_name::In_Progress::Redirects->new();
\$test->input_file("dist/${site}_mappings_source.csv");
\$test->output_file("dist/${site}_redirects_output.csv");
\$test->output_error_file("dist/${site}_redirects_errors.csv");
\$test->run_tests();
exit;


package $package_name::In_Progress::Redirects;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my \$self = shift;

    \$self->test_closed_redirects(@_);
}

EOF

}
