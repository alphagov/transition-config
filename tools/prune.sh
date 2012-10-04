#!/bin/bash

#
#  prune URLs which have an error status,  or are redirected to an error page
#

site=directgov

awk '$3 ~ /^3/ { print $1 }' "$site.txt" | while read url; do curl -f -s -o /dev/null -w '%{url_effective} %{http_code} %{redirect_url}\n' "$url"; done > "$site-redirects".txt

awk '$3 ~ /(sendHTTPError|404.html|500.html)/ { print }' < "$site-redirects.txt" | sort > $site-errors.txt

awk '$3 !~ /^[4-5]/ { print }' < $site.txt | sort > $site-nonerror.txt

join -v 1 $site-nonerror.txt $site-errors.txt > $site-good.txt
