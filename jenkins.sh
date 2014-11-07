#!/bin/sh

set -e -x

bundle install --deployment

bundle exec rake test whitehall:slug_check validate_hosts_unique_and_lowercase

exit $?
