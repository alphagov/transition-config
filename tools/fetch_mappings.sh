#!/bin/sh

#
#  fetch files mentioned in data/fetch.csv
#
cmd=$(basename $0)
fetch="data/fetch.csv"
cache="./cache"

usage() {
    echo "usage: $cmd [opts] site [site ...]" >&2
    echo "    [-c|--cache-dir $cache]      directory to cache files into" >&2
    echo "    [-f|--fetch $fetch] fetch CSV file" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -c|--cache-dir) shift; cache="$1" ; shift ; continue;;
    -s|--fetch) shift; fetch="$1" ; shift ; continue;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

mkdir -p "$cache"

IFS=,
if [ $# -lt 1 ] ; then
   tail -n +2 "$fetch"
else
    for site in "$@"
    do
        IFS=,
        grep "\b$site\b" "$fetch"
    done
fi |

    #
    #  fetch.csv
    #
    #  1    2    3
    #  Site,Name,Source
    #
    cut -d , -f 1,2,3 |
    while read site name url
    do
            path="$cache/$site/$name.csv"
            mkdir -p $(dirname "$path")
            echo "$path"
            set -x
            curl -s "$url" > "$path"
            set +x
    done

exit 0
