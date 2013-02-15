#!/bin/sh

# Must ensure that the csv columns remain in the same order,
# as ./munge/generate-redirects.sh relies on them. When this
# test breaks, be sure to update this test and that file.

header=`head -n1 data/sites.csv`

[ "$header" == 'Site,Host,Redirection Date,TNA Timestamp,Title,New Site,Aliases,Validate Options' ] || { echo "$0: FAIL: sites.csv has had its columns changed. Please update this test and generate-redirects.sh's use of sites.csv." ; exit 2; }

echo "$0: OK"
