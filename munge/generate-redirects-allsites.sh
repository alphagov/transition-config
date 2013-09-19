#!/bin/sh -e

rm -f cache/whitehall.csv &&
rm -rf backup &&
mkdir -p cache/backup/ && 

for SITE in `ls data/sites/directgov* | sed 's/\.yml//g'`
do
	if [ -z "$SITE" ]
	then
		echo "Blank line in $all_sites"
	elif [ -z `grep $SITE data/ignore_sites.txt` ]; then
        echo "Ignored $SITE"
        
	else
		mkdir -p cache/$SITE
		sh ./munge/generate-redirects.sh -s data/sites -u betademo:nottobes -w data/whitelist.txt $SITE
  		cp data/mappings/$SITE.csv cache/backup/$SITE.csv &&
        mkdir -p cache/backup/$SITE
		mv cache/$SITE/*.csv cache/backup/$SITE
	fi
done &&

git diff --stat

