#!/bin/bash

set -x

echo DEPLOY_TO=$DEPLOY_TO

prove -l tests/integration/config_rules/     \
    	tests/integration/regression/   	 \
	    tests/integration/sample/           \
		tools/test-log.pl					 \
		tests/regression/businesslink_piplinks.t

(
	IFS=,
    read titles
    while read site redirected rest
    do
    	if [ $redirected == Y ]; then
            prove -l tests/unit/sources/${site}_valid_lines.t
			prove -l tests/regression/${site}.t
        fi
    done
) < sites.csv
