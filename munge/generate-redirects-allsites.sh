#!/bin/sh -e

rm -f cache/whitehall.csv &&
rm -rf backup &&
mkdir -p cache/backup/ && 

for SITE in `ls data/sites | sed 's/\.yml//g'`
do
	IGNORE=`grep -x $SITE data/ignore_sites.txt`
	if [ -z $SITE ]
	then
		echo "Blank line in checklist"
	elif [ "$SITE" = "$IGNORE" ]
	then
		echo "Excluded - ignoring: $SITE"
	else
		echo "Included - munging: $SITE"
		mkdir -p cache/$SITE
		sh ./munge/generate-redirects.sh -s data/sites -u betademo:nottobes -w data/whitelist.txt $SITE
  		cp data/mappings/$SITE.csv cache/backup/$SITE.csv &&
        mkdir -p cache/backup/$SITE
		mv cache/$SITE/*.csv cache/backup/$SITE
		
	fi
done &&

git diff --stat

