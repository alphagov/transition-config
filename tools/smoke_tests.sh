#!/bin/sh

set -e

[ -z "$REDIRECTOR" ] && export REDIRECTOR="redirector.${DEPLOY_TO:=dev}.alphagov.co.uk"

echo REDIRECTOR=$REDIRECTOR

testdir=data/tests

echo "Checking test coverage ..."
tools/test_coverage.sh $testdir/*.csv

echo "Testing static assets ..."
tools/test_static_assets.sh

echo "Testing CSV files from $testdir ..."
tools/test_mappings.pl $@ $testdir/*.csv
