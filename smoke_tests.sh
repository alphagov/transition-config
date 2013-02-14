#!/bin/sh

set -e

. tools/messages.sh

status DEPLOY_TO=$DEPLOY_TO

dir="data/tests/subsets"

status "Checking test coverage ..."
tools/test_coverage.sh --name $dir --sites data/sites.csv $dir/*

status "Testing static assets ..."
tools/test_static_assets.sh --sites data/sites.csv

status "Testing CSV files from $dir ..."
prove -l tools/test_mappings.pl :: $@ $dir/*.csv
