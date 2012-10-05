#!/bin/bash

#
#  takes the day's logs and puts them into the format required for 
#  testing 
#

site=directgov

sort -k2 -n "$site-good.txt" | awk 'BEGIN { print "Old Url,Count,Status" }
 { print "\"" $1 "\"," $2 "," $3 }' > $site-testable.csv