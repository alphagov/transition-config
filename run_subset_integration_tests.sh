#!/bin/sh

set -e
set -x

echo DEPLOY_TO=$DEPLOY_TO

prove -l${CONCURRENT_TESTS:-j4}         \
    tests/integration/config_rules/     \
    tests/integration/sample/           \
    tests/integration/regression/
