#!/bin/bash

#
#  finds Akamai logs in the directgov businesslink directories
#  generates a report of status codes and count for each URL
#  one for each day the processed directory for each day
#

for site in directgov # businesslink directgov
do
	find $site -name '*\.2012*.gz' | sed -e 's/^.*\(2012[0-1][0-9][0-9][0-9]\).*$/\1/' | sort -u |

	while read day
	do
		sitefile="processed/$day/$site.txt"
		[ -f "$sitefile" ] && continue

		echo $(date +"%H:%M:%S") "creating $sitefile .." >&2

		mkdir -p "processed/$day"

		ls $site/*\.*$day*.gz | while read filename
		do
			echo $(date +"%H:%M:%S") "  $filename" >&2
			case $(basename "$filename" .gz) in
			akamai_*)
				 gzip -d -c "$filename" | awk '/^[^#]/ { print $5 " " $6 }' | sed -e 's+^/wwwt+http://www+' -e 's+businesslink.gov.uk.akadns.net/+businesslink.gov.uk/+'
			;;
			webserver*)
				# a mixture of devolved sites
				# https-prod http://www.businesslink.gov.uk / http://online.businesslink.gov.uk

				# https-online https://online.businesslink.gov.uk

				# https-ukwelcomes http://www.ukwelcomes.businesslink.gov.uk /
				# http://online.ukwelcomes.businesslink.gov.uk

				# https-online-ukwelcomes https://online.ukwelcomes.businesslink.gov.uk

				# https-wales http://business.wales.gov.uk / https://business.wales.gov.uk

				# https-bgateway http://www.business.scotland.gov.uk /
				# https://www.business.scotland.gov.uk

				# https-ini http://www.nibusinessinfo.co.uk / https://www.nibusinessinfo.co.uk

				# https-301war This is used to add the routing onto received base
				# domains. i.e. http://www.businesslink.gov.uk becomes
				# http://www.businesslink.gov.uk/bdotg/action/home.

			 	# e.g. GET /bdotg/action/openpopup?flag=e&itemId=1075331868&r.i=1081676012&r.t=RESOURCES&site=202&type=ONEOFFPAGE HTTP/1.1" 200 4184 "-" "Mozilla/5.0 (comp
				# atible; AhrefsBot/3.1; +http://ahrefs.com/robot/)" GET "HTTP/1.1" https-bgateway

				#gzip -d -c "$filename" | awk '/^[^#]/ { print $7 " " $9 }' | sed -e 's+^+http://www.businesslink.gov.uk+'
			;;
			prod_*) 
				 gzip -d -c "$filename" | awk '/^[^#]/ { print $5 " " $6 }' | sed -e 's+^/theclubprod.download.akamai.com+http://www.direct.gov.uk+' -e 's+^/+http://+'
			;;
			*)
			;;
			esac
		done | sort -T /mnt/tmp | uniq -c | awk '{ print $2 " " $1 " " $3 }'  > $sitefile

		ln -f -s $day processed/latest
	done
done
exit 0
