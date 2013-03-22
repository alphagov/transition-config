#!/bin/sh

#
#  generate nginx .conf file for a site
#

set -e

cmd=$(basename $0)
homepage="https://www.gov.uk"
site="site"

usage() {
    echo "usage: $cmd [opts] host [alias ...]" >&2
    echo "    [-h|--homepage url]         location for /" >&2
    echo "    [-s|--site site]            site name" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -h|--homepage) shift; homepage="$1" ; shift ; continue ;;
    -s|--site) shift; site="$1" ; shift ; continue ;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

[ $# -lt 1 ] && usage
host="$1" ; shift

cat <<!
server {
!

#
#  format hosts
#
sep="    server_name     "
tab="                    "
for alias in $host $*
do
    aka=$(echo $alias | sed -e 's/^/aka-/' -e 's/^aka-www/aka/')
    echo "$sep$alias"
    echo "$tab$aka\c"
    sep="\n$tab"
done

echo ";"
echo

cat <<!
    root            /var/apps/redirector/static/$site;
    include         /var/apps/redirector/common/settings.conf;
    include         /var/apps/redirector/common/status_pages.conf;
    include         /var/apps/redirector/maps/$site/location.conf;

    location = /    { return 301 ${homepage/&amp;/&}; }
}
!

exit 0
