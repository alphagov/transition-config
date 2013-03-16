#!/bin/sh

set -e

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
