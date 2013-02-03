#!/bin/sh

set -e

. tools/messages.sh

status DEPLOY_TO=$DEPLOY_TO

status "Testing CSV files from data/test/subsets ..."

for csv in data/tests/subsets/*.csv
do
	status "Testing $csv ..."
	prove -l tools/test_csv.pl :: $csv
done

report
