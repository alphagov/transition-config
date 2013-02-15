#!/bin/bash

set -e

if [ "$#" = "0" ]; then
    echo "Usage: $0 department-name http_user http_pass"
    exit 1
fi

if [ ! -f ./document_mappings.csv ]; then
    echo "Fetching document_mappings.csv from production whitehall servers..."
    wget -O ./document_mappings.csv https://$2:$3@whitehall-admin.production.alphagov.co.uk/government/all_document_attachment_and_non_document_mappings.csv
fi

department=$1
make_mappings_file="./munge/fetch_${department}_mappings.rb"
mappings_out="./data/mappings/${department}.csv"
if [ ! -f "$make_mappings_file" -o ! -f "$mappings_out" ]; then
    echo "Error: $department does not exist"
    exit 1
fi

echo "Generating mappings..."

# First let's extract the mappings by domain
# This assumes domain (host) is second column in sites.csv - brittle
domain=`cat data/sites.csv | grep "^$department" | cut -d ',' -f2`
# This assumes validate options is 8th column in sites.csv - brittle
validate_options=`cat data/sites.csv | grep "^$department" | cut -d ',' -f8`

set -e
echo "Fetching mappings for $domain..."
./munge/extract-mappings.rb $domain < ./document_mappings.csv | $make_mappings_file

echo "Folding, tidying, sorting mappings... (with options: $validate_options)"
cat $mappings_out | ./munge/fold-mappings.rb | ./tools/tidy_mappings.pl $validate_options | sort -u > $mappings_out.tmp

mv $mappings_out{.tmp,}

echo "Validating mappings..."
prove tools/validate_mappings.pl :: --host $domain --whitelist data/whitelist.txt $validate_options $mappings_out

echo "Done"
