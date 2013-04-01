#!/bin/bash

#
#  count mappings, output as csv
#
sites="data/sites"
dir="data/mappings"

usage() {
    echo "usage: $cmd [opts]" >&2
    echo "    [-d|--dir $dir]    mappings directory" >&2
    echo "    [-s|--sites $sites] sites directory" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -d|--dir) shift; dir="$1" ; shift ; continue ;;
    -s|--sites) shift; sites="$1" ; shift ; continue ;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

echo "name,_301,_410,_418,total"

ls data/mappings/*.csv |
    sed -e 's/^.*\///' -e 's/_.*$//' -e 's/\.csv$//' |
    sort -u |
    while read site
    do
        tmpfile=/tmp/count.$$
        cat $dir/$site.csv $dir/${site}_*.csv 2> /dev/null | grep -v "^Old Url" > $tmpfile

        nr=$(cat $tmpfile | awk -F, '$3 == 301 { print $3 }' | wc -l)
        ng=$(cat $tmpfile | awk -F, '$3 == 410 { print $3 }' | wc -l)
        np=$(cat $tmpfile | awk -F, '$3 == 418 { print $3 }' | wc -l)
        count=$(cat $tmpfile |wc -l)

        echo "$site,$nr,$ng,$np,$count" | sed 's/ //g'

        rm -f $tmpfile
    done
