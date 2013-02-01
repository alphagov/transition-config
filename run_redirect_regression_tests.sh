#!/bin/bash

set -x

: DEPLOY_TO=$DEPLOY_TO

prove -l tests/integration/config_rules/ \
	tests/integration/regression/ \
	tests/regression/businesslink_piplinks.t

for csv in data/subsets/*.csv
do
	prove -l tools/test_csv.pl :: $csv
done

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
) < data/sites.csv
