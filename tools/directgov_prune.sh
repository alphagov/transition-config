#!/bin/bash

#
#  prune URLs which have an error status,  or are redirected to an error page
#

site=directgov

echo $(date +"%H:%M:%S") "curling each redirect to find where it redirects to..." >&2
awk '$3 ~ /^3/ { print $1 " " $2 }' "${site}.txt" | while read url count; do echo -n $url " "; curl -L -s -o /dev/null -w '%{http_code} %{url_effective}' "$url"; echo " " $count; done > "${site}-redirects".txt

echo $(date +"%H:%M:%S") "moving those we can assume aren't errors (those without status of 3xx, 4xx, or 5xx) to ${site}-nonerrors.txt..." >&2
awk '$3 !~ /^[3-5]/ { print }' < ${site}.txt | sort > ${site}-nonerrors.txt

echo $(date +"%H:%M:%S") "sorting 3xxs into those that redirect to errors and those that do not..." >&2
awk '$3 ~ /(sendHTTPError|404.html|500.html)/ { print }' < "${site}-redirects.txt" | sort > ${site}-errors.txt
awk '$3 !~ /(sendHTTPError|404.html|500.html)/ { print }' < "${site}-redirects.txt" | awk '{ print $1 " " $4 }' | sort > ${site}-valid-redirects.txt

echo $(date +"%H:%M:%S") "concatenate non-errors and valid-redirects..." >&2
cat ${site}-valid-redirects.txt ${site}-nonerrors.txt | awk '{ print $1 " " $2 }' | sort | uniq > ${site}-testable-urls.txt

echo $(date +"%H:%M:%S") "formatting to csv for testing that day's output..." >&2
sort -k2 -nr "${site}-testable-urls.txt" | awk 'BEGIN { print "Old Url,Count,Status" }
 { print "\"" $1 "\"," $2 "," $3 }' > ${site}-testable.csv

echo $(date +"%H:%M:%S") "adding URLs only to site-all.txt..." >&2
( awk '{ print $1 }' "${site}-testable-urls.txt"; cat ../${site}-all.txt ) | sort | uniq > new_${site}_all.txt
mv new_${site}_all.txt ../${site}-all.txt