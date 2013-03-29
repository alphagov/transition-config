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

echo "name,301,410,value"

for file in $dir/*.csv
do
    site=$(basename $file .csv)
    nr=$(awk -F, '$3 == 301 { print $3 }' $file | wc -l)
    ng=$(awk -F, '$3 == 410 { print $3 }' $file | wc -l)
    count=$(cat $file |wc -l)
    let "count=$count - 1"
    echo "$site,$nr,$ng,$count" | sed 's/ //g'
done
