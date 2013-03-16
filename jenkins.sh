#!/bin/sh

set -e

bundle

#
#  bootstrap makefiles ..
#
make data/sites
make init

#
#  test, validate and build project ..
#
make ci

exit $?
