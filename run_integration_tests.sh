#!/bin/sh

export PERL5LIB='lib'


graphs=`perl tests/integration/count_all_sources.pl`

perl tests_with_graphs.pl \
        --tests tests/integration/ratified \
        --graph-base 'govuk.app.redirector.ratified' \
        --report-template tests/integration/dashboard_template.html \
        --report-output dist/dashboard.html \
        --output-csv dist/integration_results.csv \
        --${DEPLOY_TO:-preview} \
        $graphs

if [ "$DEPLOY_TO" = 'production' ]; then
    perl tests/integration/graph_redirects_results.pl
    perl tests/integration/graph_open_sources.pl
fi