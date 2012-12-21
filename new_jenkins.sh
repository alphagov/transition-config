#!/bin/bash
set -e
mkdir -p dist

source sites.sh

for site in ${REDIRECTED_SITES[@]}; do
	mkdir tests/redirects/$site

done

for site in ${IN_PROGRESS_SITES[@]}; do
    echo $site
done