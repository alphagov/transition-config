#!/bin/sh

set -e -x

: DEPLOY_TO=$DEPLOY_TO

prove -l tests/integration/config_rules/

for csv in data/subsets/*.csv
do
	prove -l tools/test_csv.pl :: $csv
done
