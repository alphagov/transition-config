#!/bin/sh

#
#  tidy all the mappings
#
set -e
cmd=$(basename $0)
sites="data/sites.csv"
dir="data/mappings"

usage() {
    echo "usage: $cmd [opts]" >&2
    echo "    [-d|--dir $dir]    mappings directory" >&2
    echo "    [-s|--sites $sites] sites file" >&2
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

IFS=,
tail -n +2 $sites |
    while read site host redirection_date tna_timestamp title furl aliases options homepage rest
    do
        mappings=$dir/${site}.csv

        echo
        echo ":: site: $site"
        echo ":: host: $host"
        echo ":: options: $options"
        echo ":: mappings: $mappings"
        tmpfile=tmp/$$.$site.csv

        set -e -x
        tools/tidy_mappings.pl $options < $mappings > $tmpfile
        set +
        mv $tmpfile $mappings
    done

exit $?
