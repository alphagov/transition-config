#!/bin/sh

set -e -x

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

bundle install --deployment

bundle exec rake test validate:all

exit $?
