#!/bin/sh

set -e
set -x

export PERL5LIB='lib'

echo DEPLOY_TO=$DEPLOY_TO

graphs=`perl tests/integration/count_all_sources.pl`

prove -lj4 tests/integration/config_rules/

perl tests_with_graphs.pl \
        --tests tests/integration/ratified \
        --graph-base 'govuk.app.redirector.ratified' \
        --report-template tests/integration/dashboard_template.html \
        --report-output dist/dashboard.html \
        --output-csv dist/integration_results.csv \
        --${DEPLOY_TO:-preview} \
        $graphs

# combine output files
CSV_HEADER="Old Url,New Url,Status,Whole Tag,Test Result,Actual Status,Actual New Url,New Url Status"
for site in businesslink directgov; do
    for type in redirects gone; do
        (
            echo $CSV_HEADER;
            cat dist/${site}_*_${type}_output.csv
        ) > dist/${site}_${type}_output.csv
        rm dist/${site}_*_${type}_output.csv
        
        (
            echo $CSV_HEADER;
            cat dist/${site}_*_${type}_errors.csv
        ) > dist/${site}_${type}_errors.csv
        rm dist/${site}_*_${type}_errors.csv
    done
done

if [ "$DEPLOY_TO" = 'production' ]; then
    perl tests/integration/graph_redirects_results.pl dist/integration_results.csv
    perl tests/integration/graph_open_sources.pl dist/integration_results.csv
fi

perl fail_build.pl
