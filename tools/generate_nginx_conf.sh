#!/bin/sh

#
#  generate nginx .conf file for a site
#

set -e

# "$site" "$host" "$aliases"

site="$1" ; shift
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

cat <<!
    root            /var/apps/redirector/static/$site;
    include         /var/apps/redirector/common_nginx_settings.conf;
    include         /var/apps/redirector/common_status_pages.conf;
    include         /var/apps/redirector/$host.location.conf;
}
!

exit 0
