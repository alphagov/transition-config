#!/bin/sh

set -e

. tools/messages.sh

status "DEPLOY_TO=$DEPLOY_TO"

mappings="dist/full_tests_mappings.csv"

status "Combining all known mappings into $mappings ..."
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

    # contains many issues so commented out, pending review ..
    # cat data/tests/full/*.csv

    cat data/tests/subsets/*.csv

} | egrep -v '^Old Url' | sort -u | (

    echo "Old Url,New Url,Status,Suggested Link,Archive Link"
    cat

) > $mappings

status "Checking test coverage ..."
tools/test_coverage.sh --name "$mappings" --sites data/sites.csv $mappings

status "Testing static assets ..."
tools/test_static_assets.sh --sites data/sites.csv

status "Testing $mappings ..."
prove -l tools/test_mappings.pl :: $@ $mappings
