#!/bin/sh

#
#  hack script to turn sites.csv into separate yaml files ..
#

set -e

sites="data/sites.csv"

mkdir -p data/sites

IFS=,
tail -n +2 $sites |
    while read site host redirection_date tna_timestamp title furl aliases options homepage rest
    do
{
cat <<EOF
---
site: $site
host: $host
redirect_date: $redirection_date
tna_timestamp: $tna_timestamp
title: $title
furl: $furl
homepage: $homepage
EOF
        if [ -n "$options" ] ; then
            echo "options: $options"
        fi

        if [ -n "$aliases" ] ; then
            echo "aliases:"
            IFS=" "
            for alias in $aliases
            do
                echo "  - $alias"
            done
            IFS=,
        fi
echo "---"
} > data/sites/$site.yml
    done

exit $?
