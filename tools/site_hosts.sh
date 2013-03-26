#!/bin/bash

#
#  check all domains mentioned in sites directory exist in a set of mappings files
#
cmd=$(basename $0)
sites="data/sites"
aka=""

usage() {
    echo "usage: $cmd [opts] [mappings.csv ...]" >&2
    echo "    [-a|--also-aka]         also generate aka hosts" >&2
    echo "    [-s|--sites $sites] sites directory" >&2
    echo "    [-?|--help]             print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -a|--also-aka) shift ; aka=y ; continue ;;
    -s|--sites) shift; sites="$1" ; shift ; continue ;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

cat $sites/*.yml |
    egrep -h '^(host:|  *-)' |
    sed -e 's/^host: //' -e 's/  *- *//' |
    grep -v ':' |
    sort -u |
    while read host
    do
        echo $host
        if [ -n "$aka" ] ; then
            aka=$(echo $host | sed -e 's/^/aka-/' -e 's/^aka-www/aka/')
            echo $aka
        fi
    done |
    sort -u

exit 0
