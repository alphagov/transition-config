#!/bin/bash

#
#  check all domains mentioned in sites.csv file exist in a set of mappings files
#
cmd=$(basename $0)
name="mappings"
sites="data/sites.csv"
hosts='/tmp/coverage-hosts.txt'

usage() {
    echo "usage: $cmd [opts] [mappings.csv ...]" >&2
    echo "    [-n|--name name]            name of mappings" >&2
    echo "    [-s|--sites $sites] sites file" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -n|--name) shift; name="$1 " ; shift ; continue;;
    -s|--sites) shift; sites="$1" ; shift ; continue;;
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done

#
#  hosts from sites.csv
#
tools/site_hosts.sh --sites "$sites" > $hosts

#
#  hosts from mappings
#
missing=$(
cat "$@" |
    cut -d , -f 1 |
    sed -e 's/^http:\/\///' -e 's/\/.*$//' |
    sort -u |
    grep -v "Old Url" |
    comm -2 -3 $hosts - |
    sed -e 's/[ 	]//g' -e 's/^/> /'
)

if [ -n "$missing" ] ; then
    echo "$cmd: missing $name" >&2
    echo "$missing"
    exit 2
fi

exit 0
