#!/bin/sh

set -e

. tools/messages.sh

status "DEPLOY_TO=$DEPLOY_TO"

csv="dist/full_urls.csv"

status "Combining all known mappings into $csv ..."

# find all mappings and tests
cat data/mappings/*.csv data/tests/subsets/*.csv | sort | uniq | egrep -v '^Old Url' | {

	echo "Old Url,New Url,Status,Suggested Links,Archive Link"
	cat

} > $csv

status "Testing $csv ..."

prove -l tools/test_csv.pl :: $csv
