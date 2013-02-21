#!/bin/sh

#
#  script to generate the popular url tests from Akamai logs
#
#set -e

. tools/env

totals="$1"
[ -z "$totals" ] && error "usage: $(basename $0) totals.csv [max-lines]" && exit 2

max="$2"
[ -z "$max" ] && max=250


# cat logs/redirector_*.gz | gzip -d -c | awk -F'   ' '{ print $5 " " $6 }' | sed 's/^/http:\//' | sort | uniq -c | awk '$1 > 2 { print $1 "," $2 "," $3 } ' | sort -rn  > tmp/totals.csv

mkdir -p data/tests/popular

cat $totals | sed -e 's/^[0-9 ]*,https*:\/\///' -e 's+/.*$++' -e '/^aka/d' | sort -u |

	while read domain
	do
		site=$(grep $domain data/sites.csv | awk -F, '{ print $1 }')
		cdomain=$(grep $domain data/sites.csv | awk -F, '{ print $2 }')

		if [ -z "$site" ] ; then
			error "unknown domain: $domain"
			continue
		fi

		status "$domain $site ($cdomain)"

		cat $totals | awk -F, '$3 ~ /^(200|301|410)$/ && $2 ~ /https*:\/\/'$domain'/ { print $2 " " $3 " " $1 }' | head -$max |
		{
			echo "Old Url,New Url,Status"
			while read url status count
			do
				case "$status" in
				200|410)
					echo "$url,,$status"
					;;

				301)
					mapping_url=$(echo "$url" | sed "s/$domain/$cdomain/")
					mapping=$(grep -F -h "$mapping_url," data/mappings/*)

					if [ -z "$mapping" ] ; then
						warning "unknown mapping: $url $mapping_url"
						continue
					fi

					mapping=$(echo "$mapping" | sed "s/$cdomain/$domain/")

					echo "$mapping"
					;;
				esac
			done
		} > data/tests/popular/$domain.csv
	done

report
exit 0
