#!/bin/sh

set -e
set -x

echo DEPLOY_TO=$DEPLOY_TO
prove -lj4 tests/integration/config_rules/
prove -lj4 tests/integration/sample/