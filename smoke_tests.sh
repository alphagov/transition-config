#!/bin/sh

set -e

. tools/messages.sh

status DEPLOY_TO=$DEPLOY_TO

status "Testing CSV files from data/test/subsets ..."

prove -l tools/test_mappings.pl :: data/tests/subsets/*.csv
