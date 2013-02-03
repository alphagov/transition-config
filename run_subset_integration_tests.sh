#!/bin/sh

set -e -x

: DEPLOY_TO=$DEPLOY_TO

for csv in data/tests/subsets/*.csv
do
	prove -l tools/test_csv.pl :: $csv
done
