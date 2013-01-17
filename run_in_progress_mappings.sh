#!/bin/sh

set -e
set -x

echo DEPLOY_TO=$DEPLOY_TO

(
	IFS=,
    read titles
    while read site redirected rest
    do
    	if [ $redirected = N ]; then
            prove -l tests/unit/sources/${site}_valid_lines.t
			prove -l tests/in_progress/${site}/
        fi
    done
) < sites.csv

exit 0;