#!/bin/sh

set -e

#
#  depends upon mustache
#
bundle
export PATH=$PATH:vendor/bundle/ruby/1.9.1/bin

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
