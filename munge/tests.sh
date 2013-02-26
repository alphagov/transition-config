#!/bin/sh

set -e -x
rake -f munge/Rakefile test

for t in tests/munge/*.sh ; do set -x ; $t ; set +x ; done

exit 0
