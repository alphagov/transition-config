#!/bin/bash

#
#  generate a set of mappings from furls mentioned in sites
#
cmd=$(basename $0)
sites="data/sites"
aka=""

usage() {
    echo "usage: $cmd [opts] [mappings.csv ...]" >&2
    echo "    [-s|--sites $sites] sites directory" >&2
    echo "    [-?|--help]             print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -s|--sites) shift; sites="$1" ; shift ; continue ;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

echo "Old Url,New Url,Status"
ls -1 $sites/*.yml |
    while read file
    do
        site=$(basename $file .yml)
        host=$(grep "^host:" $file | sed 's/^.*: //')
        furl=$(grep "^furl:" $file | sed 's/^.*: //')
        homepage=$(grep "^homepage:" $file | sed 's/^.*: //')

        echo "http://$host,$homepage,301"
        [ -n "$furl" ] && echo "http://$furl,$homepage,301"
    done |
    sort -u -t, -k1,1

exit 0
