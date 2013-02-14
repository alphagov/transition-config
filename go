#!/bin/sh

# .. development,test loop ..

set -e -x

host=redirector.dev.alphagov.co.uk

#
#  build
#
time jenkins.sh

#
#  copy dist/conf to /etc/nginx/sites-enabled
#  .. or ln -s /etc/nginx/sites-enabled ~/src/redirector/dist/configs

#
#  restart nginx
#
time ssh $host sudo /etc/init.d/nginx restart

#
#  smoke tests
#
time smoke_tests.sh --host $host --skip-assets
