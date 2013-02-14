#!/bin/sh

set -e

. tools/messages.sh

status "DEPLOY_TO=$DEPLOY_TO"

mappings="dist/full_tests_mappings.csv"

status "Combining all known mappings into $mappings ..."

# find all mappings and tests
mkdir -p dist

{
    {
        IFS=,
        read titles
        while read site rest
        do
            cat data/mappings/$site.csv
        done
    } < data/sites.csv

    cat data/tests/full/*.csv \
        data/tests/subsets/*.csv

} | egrep -v '^Old Url' | sort -u | (

    echo "Old Url,New Url,Status,Suggested Link,Archive Link"
    cat

) > $mappings

status "Testing $mappings ..."

status "Checking test coverage ..."
tools/test_coverage.sh --name "$mappings" --sites data/sites.csv $mappings

prove -l tools/test_mappings.pl :: $@ $mappings
