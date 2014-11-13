#!/bin/sh

set -e -x

bundle install --deployment

bundle exec rake test whitehall:slug_check hosts:validate

exit $?
