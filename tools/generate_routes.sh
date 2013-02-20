#!/bin/sh

#
#  generate nginx routes from sites.csv
#
cmd=$(basename $0)
sites="data/sites.csv"
verbose=""

usage() {
    echo "usage: $cmd [opts] [mappings.csv ...]" >&2
    echo "    [-s|--sites $sites] sites file" >&2
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

#
#  sites.csv
#
#  1    2    3                4             5     6    7       8                9
#  Site,Host,Redirection Date,TNA Timestamp,Title,FURL,Aliases,Validate Options,New Url
#
IFS=,
cut -d , -f 6,9 $sites |
    tail -n +2 |
    while read furl url
    do
        path=$(echo "$url" | sed 's+^https://www.gov.uk++')
        case "$furl:$path" in
        /*:/*) printf "  %-27s => %s,\n" "'$furl'" "'$path'" ;;
        esac
    done |
    sort -u

exit 0
