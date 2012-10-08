#!/bin/bash

#
#  prune URLs which have an error status,  or are redirected to an error page
#

site=directgov

# find the end point goal of all the redirects
awk '$3 ~ /^3/ { print $1 }' "${site}.txt" | while read url; do curl -f -s -o /dev/null -w '%{url_effective} %{http_code} %{redirect_url}\n' "$url"; done > "${site}-redirects".txt

# if it does not have a status code of 3xx, 4xx or 5xx we can assume it is not an error
awk '$3 !~ /^[3-5]/ { print }' < ${site}.txt | sort > ${site}-nonerrors.txt

# if the status code is 3xx it may redirect to an error
awk '$3 ~ /(sendHTTPError|404.html|500.html)/ { print }' < "${site}-redirects.txt" | sort > ${site}-errors.txt
awk '$3 !~ /(sendHTTPError|404.html|500.html)/ { print }' < "${site}-redirects.txt" | sort > ${site}-valid-redirects.txt

# print out everything in non-errors except that which is in errors.
join -v 1 ${site}-nonerrors.txt ${site}-errors.txt > ${site}-good.txt

# now concatenate non-errors and valid-redirects
cat ${site}-valid-redirects.txt ${site}-good.txt | sort | uniq > ${site}-testable-urls.txt

# format for testing that day's output
sort -k2 -nr "${site}-testable-urls.txt" | awk 'BEGIN { print "Old Url,Count,Status" }
 { print "\"" $1 "\"," $2 "," $3 }' > ${site}-testable.csv

# add the URLs only to the $site-all file
( awk '{ print $1 }' "${site}-testable-urls.txt"; cat ../${site}-all.txt ) | sort | uniq > new_${site}_all.txt
mv new_${site}_all.txt ../${site}-all.txt