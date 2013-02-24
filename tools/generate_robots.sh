#!/bin/sh

#
#  generate robots.txt for a site
#
#  usage: tools/generate_robots.sh "$host"

set -e

host="$1"

#
#  robots.txt
#
cat <<EOF
User-agent: *
Disallow:
Sitemap: http://$host/sitemap.xml
EOF

exit
