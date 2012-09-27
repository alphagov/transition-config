#!/bin/sh
set -e

REDIRECTOR='deploy@redirector.production.alphagov.co.uk'

# copy current workspace to redirector, to run the tests there
# (much faster because almost zero network latency)
ssh ${REDIRECTOR} mkdir -p /tmp/redirector
rsync -av . ${REDIRECTOR}:/tmp/redirector/.


# run tests on redirector
ssh ${REDIRECTOR} \
        'cd /tmp/redirector && sh run_integration_tests.sh'

# copy back any artifacts created
rsync -av ${REDIRECTOR}:/tmp/redirector/. .
