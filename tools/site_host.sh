#!/bin/sh
# return host for a given site
[ -z "$1" ] && { echo "usage $(basename $0): site" >&2 ; exit 2; }
grep "^host:" data/sites/"$1".yml | awk '{ print $2 }'
