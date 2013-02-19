#!/bin/sh

#
#  seed mappings from sites.csv
#
set -e

sites="data/sites.csv"

usage() {
    echo "usage: $cmd [opts] site" >&2
    echo "    [-s|--sites $sites] sites file" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -s|--sites) shift; sites="$1" ; shift ; continue;;
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done


cut -d , -f1,2,9 "$sites" |
    tail -n +2 | (
    IFS=,
    while read site host url
    do
        file="data/mappings/${site}.csv"
        if [ ! -f "$file" ] ; then
            echo "seeding $file"
            cat > $file <<!
Old Url,New Url,Status
http://$host,$url,301
!
        fi
done)


tools/site_hosts.sh |
    while read host
    do
        url=$(grep "\b$host\b" "$sites" | cut -d , -f 9)
        file="data/tests/subsets/${host}.csv"
        if [ ! -f "$file" ] ; then
            echo "seeding $file"
            cat > $file <<!
Old Url,New Url,Status
http://$host,$url,301
http://$host/,$url,301
!
        fi
    done

exit
