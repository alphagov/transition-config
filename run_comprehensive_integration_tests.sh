#!/bin/sh

set -e
set -x

echo DEPLOY_TO=$DEPLOY_TO

prove -lr${CONCURRENT_TESTS:-}          \
    tests/integration/config_rules/     \
    tests/integration/ratified/         \
    tests/integration/regression/       \
    tests/integration/sample/           \
    tools/test-log.pl
