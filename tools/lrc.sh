#!/bin/bash

echo "Old Url,New Url,Status,Count"

cat lrc-redirects-sorted.txt |
	sed -e '/ 404 /d' |
	awk '$1 == $3 { print "\"" $1 "\",,200," $4 }
		$1 != $3 { print "\"" $1 "\",\"" $3 "\",301," $4 }' |
	sed -e 's/"HTTP/"http/'

