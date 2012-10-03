#!/bin/bash

#
#  prune URLs which have an error status,  or are redirected to an error page
#
#  .. hack script, run in the process/2012... directory

site=directgov

awk '$3 ~ /^3/ { print $1 }' "$site.txt" | while read url; do curl -f -s -o /dev/null -w '%{url_effective} %{http_code} %{redirect_url}\n' "$url"; done > "$site-302".txt

awk '$3 !~ /^[4-5]/ { print }' < $site.txt | sort > $site-nonerror.txt

awk '$3 ~ /(sendHTTPError|404.html|500.html)/ { print }' < $site-302.txt | sort > $site-errors.txt

join -v 1 $site-nonerror.txt $site-errors.txt > $site-good.txt
