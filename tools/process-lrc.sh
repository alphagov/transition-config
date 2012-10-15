#!/bin/bash

#
#  find and prune LRC URLs from the BT supplied logs
#
#  - raw log files are on the transition machine
#

mkdir -p lrc

find businesslink/ -name 'access*' | while read file
do

	# XXX.XXX.XXX.XXX - - [30/Apr/2012:08:28:09 +0100] "GET /status.html HTTP/1.1" 200 28 "-" "FirstFlowAgent" GET "HTTP/1.1" https-lrc
	awk '/^[^#]/ { print $7 " " $9 }' "$file" | sed -e '/^[^\/]/d' -e '/404$/d' | sed -e 's/&.dyn=[a-zA-Z0-9]*//' -e 's+^/+http://lrc.businesslink.gov.uk/+'

done | sort -T /mnt/tmp | uniq -c | awk '{ print $2 " " $1 " " $3 }'  > lrc/lrc.txt

site=lrc/lrc

echo $(date +"%H:%M:%S") "curling each redirect to find where it redirects to..." >&2
awk '$3 ~ /^3/ { print $1 " " $2 }' "${site}.txt" | while read url count; do echo -n $url " "; curl -m 10 -L -s -o /dev/null -w '%{http_code} %{url_effective}' "$url"; echo " " $count; done > "${site}-redirects".txt

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

exit 0
