#!/bin/sh

# .. development,test loop ..

set -e -x

host=redirector.dev.alphagov.co.uk

#
#  build
#
time make makefiles
time make

#
#  copy dist/conf to /etc/nginx/sites-enabled
#  .. or ln -s /etc/nginx/sites-enabled ~/src/redirector/dist/configs

#
#  restart nginx
#
ssh $host sudo /etc/init.d/nginx stop
time ssh $host sudo /etc/init.d/nginx start

#
#  smoke tests
#
time tools/smoke_tests.sh --host $host --skip-assets --no-follow
