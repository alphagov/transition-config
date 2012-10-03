#!/bin/bash

#
#  finds Akamai logs in the directgov businesslink directories
#  generates a report of status codes and count for each URL
#  one for each day the processed directory for each day
#

for site in directgov #businesslink
do
	find $site -name '*20120930*.gz' | sed -e 's/^.*\(2012[0-1][0-9][0-9][0-9]\).*$/\1/' | sort -u |

	while read day
	do
		sitefile="processed/$day/$site.txt"
		[ -f "$sitefile" ] && continue

		echo $(date +"%H:%M:%S") "creating $sitefile .."

		mkdir -p "processed/$day"

		ls $site/*\.*$day*.gz | while read filename
		do
			case $(basename "$filename" .gz) in
			akamai_*)
				 gzip -d -c "$filename" | awk '/^[^#]/ { print $5 " " $6 }' | sed -e 's+^/wwwt+http://www+' -e 's+businesslink.gov.uk.akadns.net/+businesslink.gov.uk/+'
			;;
			webserver*)
				 # a mixture of devolved sites
				 #gzip -d -c "$filename" | awk '/^[^#]/ { print $7 " " $9 }' | sed -e 's+^+http://www.businesslink.gov.uk+'
			;;
			prod_*) 
				 gzip -d -c "$filename" | awk '/^[^#]/ { print $5 " " $6 }' | sed -e 's+^/theclubprod.download.akamai.com+http://www.direct.gov.uk+' -e 's+^/+http:/+'
			;;
			*)
			;;
			esac
		done | sort -T /mnt/tmp | uniq -c | awk '{ print $2 " " $1 " " $3 }'  > $sitefile

		ln -f -s $day processed/latest
	done
done
exit 0
