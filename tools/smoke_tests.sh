#!/bin/sh

set -e

. tools/env

status DEPLOY_TO=$DEPLOY_TO

testdir=data/tests

status "Checking test coverage ..."
tools/test_coverage.sh --name "test data $testdir" --sites data/sites.csv $testdir/*

status "Testing static assets ..."
tools/test_static_assets.sh --sites data/sites.csv

status "Testing CSV files from $testdir ..."
prove -l tools/test_mappings.pl :: $@ $testdir/*.csv
