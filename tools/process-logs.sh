#!/bin/bash

#
#  finds Akamai logs in the directgov businesslink directories
#  generates a report of status codes and count for each URL
#  one for each day the processed directory for each day
#

for site in businesslink directgov
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

			# extract URL status from logfiles
			case $(basename "$filename" .gz) in

			# Business Link Akamai
			akamai_*)
				 gzip -d -c "$filename" | awk '/^[^#]/ { print $5 " " $6 }' | sed -e 's+^/wwwt+http://www+' -e 's+businesslink.gov.uk.akadns.net/+businesslink.gov.uk/+'
			;;

			# Business Link origin server
			webserver*)
				gzip -d -c "$filename" |
				awk 'BEGIN {
					a["https-prod"] = "http://www.businesslink.gov.uk"; 
					a["https-online"] = "https://online.businesslink.gov.uk";
					a["https-ukwelcomes"] = "http://www.ukwelcomes.businesslink.gov.uk";
					a["https-online-ukwelcomes"] = "https://online.ukwelcomes.businesslink.gov.uk";
					a["https-wales"] = "http://businesslink.gov.uk";
					a["https-bgateway"] = "http://www.businesslink.gov.uk";
					a["https-ini"] = "http://www.businesslink.gov.uk";
					a["https-301war"] = "http://www.businesslink.gov.uk";
					a["aol"] = "http://aol.businesslink.gov.uk";
					a["msn"] = "http://msn.businesslink.gov.uk";
					a["blackpoolunlimited"] = "http://blackpoolunlimited.businesslink.gov.uk";
					a["alliance-leicestercommercialbank"] = "http://alliance-leicestercommercialbank.businesslink.gov.uk";
					a["sage"] = "http://sagestartup.businesslink.gov.uk";
					a["simplybusiness"] = "http://simplybusiness.businesslink.gov.uk";
					a["%vsid%"] = "http://www.businesslink.gov.uk";
					a["https-elms"] = "https://elms.businesslink.gov.uk";
					a["https-elms-ssl"] = "https://elms.businesslink.gov.uk";
					a["https-services"] = "https://services.businesslink.gov.uk";

					a["BusinessLinkEastMidlands"] = "http://www.businesslink.gov.uk";
					a["BusinessLinkLondon"] = "http://www.businesslink.gov.uk";
					a["BusinessLinkNorthEast"] = "http://www.businesslink.gov.uk";
					a["BusinessLinkNorthWest"] = "http://www.businesslink.gov.uk";
					a["BusinessLinkSouthEast"] = "http://www.businesslink.gov.uk";
					a["BusinessLinkSouthWest"] = "http://www.businesslink.gov.uk";
					a["BusinessLinkWestMidlands"] = "http://www.businesslink.gov.uk";
					a["BusinessLinkYorkshire"] = "http://www.businesslink.gov.uk";

				}
				/^[^#]/ { print a[$(NF)] $7 " " $9 }'
			;;

			# LRC logs
			access*)
			;;

			# DirectGov Akamai
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
