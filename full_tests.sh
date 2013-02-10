#!/bin/sh

set -e

. tools/messages.sh

status "DEPLOY_TO=$DEPLOY_TO"

mappings="dist/full_tests_mappings.csv"

status "Combining all known mappings into $mappings ..."

# find all mappings and tests
mkdir -p dist
cat data/mappings/*.csv \
	data/tests/full/*.csv \
	data/tests/popular/*.csv \
	data/tests/subsets/*.csv \
	| sed 's/"//g' | sort | uniq | egrep -v '^Old Url' | (

	echo "Old Url,New Url,Status,Suggested Link,Archive Link"
	cat

) > $mappings

status "Testing $mappings ..."

prove -l tools/test_mappings.pl :: $mappings
