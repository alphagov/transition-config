#!/bin/sh
set -e

# copy current workspace to redirector, to run the tests there
# (much faster because almost zero network latency)
ssh redirector.production.alphagov.co.uk mkdir -p /tmp/redirector
rsync -av . redirector.production.alphagov.co.uk:/tmp/redirector/.


# run tests on redirector
ssh redirector.production.alphagov.co.uk \
        'cd /tmp/redirector && sh run_integration_tests.sh'

# copy back any artifacts created
rsync -av redirector.production.alphagov.co.uk:/tmp/redirector/. .
