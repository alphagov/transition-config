#!/bin/sh

set -e -x

#
#  depends upon mustache
#
bundle install --deployment

#
#  clean dist
#
rm -rf dist makefiles

#
#  bootstrap makefiles ..
#
make makefiles

#
#  test, validate and build project ..
#
make ci

exit $?
