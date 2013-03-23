#!/bin/sh

set -e

echo DEPLOY_TO=$DEPLOY_TO

testdir=data/tests

echo "Checking test coverage ..."
tools/test_coverage.sh $testdir/*.csv

echo "Testing static assets ..."
tools/test_static_assets.sh

echo "Testing CSV files from $testdir ..."
prove -l tools/test_mappings.pl :: $@ $testdir/*.csv
