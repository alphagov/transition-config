#!/bin/bash

set -e

if [ "$#" = "0" ]; then
    echo "Usage: $0 department-name http_user http_pass"
    exit 1
fi

if [ ! -f ./document_mappings.csv ]; then
    wget https://$2:$3@whitehall-admin.production.alphagov.co.uk/government/document_mappings.csv
fi

department=$1
make_mappings_file="./munge/fetch_${department}_mappings.rb"
mappings_out="./data/mappings/${department}.csv"
folded_mappings="./${department}-folded.csv"
if [ ! -f "$make_mappings_file" -o ! -f "$mappings_out" ]; then
    echo "Error: $department does not exist"
    exit 1
fi

echo "Generating mappings..."

# First let's extract the mappings by domain
domain=`cat data/sites.csv | grep "^$department" | cut -d ',' -f3`

set -e
echo "Fetching mappings for $domain..."
./munge/extract-mappings.rb $domain < ./document_mappings.csv | $make_mappings_file

echo "Folding mappings..."
./munge/fold-mappings.rb < $mappings_out > $folded_mappings

echo "Sorting and putting folded file in place..."
sort -u $folded_mappings > $mappings_out

rm $folded_mappings

echo "Done"
