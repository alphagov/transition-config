#!/bin/sh

#
#  tidy all the mappings
#
set -e
cmd=$(basename $0)
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

if [ $# -le 0 ] ; then
    set data/sites/*.yml
fi

ls -1 "$@" |
    while read file
    do
        site=$(basename $(basename $file .yml) .csv)
        mappings=$dir/${site}.csv
        sitefile=data/sites/${site}.yml
        options=$(grep "^options:" $sitefile | sed 's/^options: //')

        echo
        echo ":: site: $site"
        echo ":: options: $options"
        echo ":: mappings: $mappings"
        tmpfile=tmp/$$.$site.csv

        set -e -x
        tools/tidy_mappings.pl $options < $mappings > $tmpfile
        set +x
        mv $tmpfile $mappings
    done

exit $?
