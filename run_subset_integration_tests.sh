#!/bin/sh

set -e
set -x

echo DEPLOY_TO=$DEPLOY_TO
prove -lj4 tests/integration/config_rules/ tests/integration/sample/ tests/integration/regressions/ tools/test-log.pl