#!/bin/sh
#usage: sh munge/local-munge.sh targetname filetoadd.csv

set -e -x

if [ $1 == "-n" ]
then
	shift
	nofetch="-n"
else
	nofetch=""
fi

rm -rf cache/$1 &&
mkdir -p cache/$1 &&
sh ./munge/generate-redirects.sh $nofetch -s data/sites -u betademo:nottobes -w data/whitelist.txt -l "$2" "$1" &&
git diff --stat &&
mkdir -p cache/candidate/ &&
cp data/mappings/$1.csv cache/candidate/$1.csv &&
mv cache/$1/*.csv cache/candidate/
mv $2 cache/$1/
