#!/bin/sh

# extract-whitehall-mappings.sh

# Filters the given input to only include lines which start with
# the host we are interested in.

set -e

usage() {
    echo "usage: $0 [opts] host" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done

host=$1 ; [ -z "$host" ] && usage

echo "old url,new url,status,source,row_number"
grep -E "^\"*https*://$host[/,]" |
  sed 's/""//g' |
  cut -d , -f 1,2,3
