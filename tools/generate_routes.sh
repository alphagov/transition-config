#!/bin/sh

#
#  generate GOV.UK nginx routes for sites
#
cmd=$(basename $0)
sites="data/sites"
verbose=""

usage() {
    echo "usage: $cmd [opts] [mappings.csv ...]" >&2
    echo "    [-s|--sites $sites] sites directory" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -s|--sites) shift; sites="$1" ; shift ; continue;;
    -v|--verbose) shift; verbose=y ; continue;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

ls -1 $sites/*.yml |
    while read file
    do
        site=$(basename $file .yml)
        furl=$(grep "^furl:" $file | sed 's/^.*: //')
        homepage=$(grep "^homepage:" $file | sed 's/^.*: //')

        fpath=$(echo "$furl" | sed 's+^www.gov.uk++')
        path=$(echo "$homepage" | sed 's+^https://www.gov.uk++')

        case "$fpath:$path" in
        /*:/*) printf "  %-27s => %s,\n" "'$fpath'" "'$path'" ;;
        esac
    done |
    sort -u

exit 0
