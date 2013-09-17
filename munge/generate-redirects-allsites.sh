#!/bin/sh

set -e -x 
rm -f cache/whitehall.csv &&
rm -rf backup &&
mkdir -p cache/backup/ && 

all_sites="./data/all_sites.txt" &&

while read SITE;
do
	if [ -z "$SITE" ] 
	then
		echo "Blank line in $all_sites"
	else
		mkdir -p cache/$SITE
		sh ./munge/generate-redirects.sh -s data/sites -u betademo:nottobes -w data/whitelist.txt $SITE
  		cp data/mappings/$SITE.csv cache/backup/$SITE.csv && 
        mkdir -p cache/backup/$SITE
		mv cache/$SITE/*.csv cache/backup/$SITE
	fi
done < $all_sites

git diff --stat 
