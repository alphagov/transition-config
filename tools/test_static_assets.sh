#!/bin/bash

#
#  test static assets served for each host mentioned in sites.csv
#
cmd=$(basename $0)
sites="data/sites.csv"
tmpfile="tmp/static_assets.csv"

set -e
usage() {
    echo "usage: $cmd) [opts] [-- test_mappings opts]" >&2
    echo "    [-s|--sites sites.csv]      sites file" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -s|--sites) shift; sites="$1" ; shift ; continue;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

mkdir -p $(dirname $tmpfile)

(
echo "Old Url,New Url,Status"
IFS=,
cut -d, -f 2,6,9 "$sites" |
    tail -n +2 |
    while read host furl new_url
    do
        # home page redirect
        echo "http://$host,$new_url,301"
        echo "http://$host/,$new_url,301"
        #echo "$furl,$new_url,301"

        # static assets
        echo "http://$host/robots.txt,,200"
        echo "http://$host/sitemap.xml,,200"
        echo "http://$host/favicon.ico,,200"
        echo "http://$host/gone.css,,200"

        #TBD: echo "http://$host/404,,404"
        #TBD: echo "http://$host/410,,410"
    done
) > $tmpfile

prove tools/test_mappings.pl :: "$@" $tmpfile

exit 0
