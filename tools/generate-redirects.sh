#!/bin/bash

if [ "$#" = "0" ]; then
    echo "Usage: $0 department-name"
    exit 1
fi

department=$1
make_mappings_file="./tools/fetch_${department}_mappings.rb"
mappings_out="./data/mappings/${department}.csv"
folded_mappings="./${department}-folded.csv"
if [ ! -f "$make_mappings_file" -o ! -f "$mappings_out" ]; then
    echo "Error: $department does not exist"
    exit 1
fi

echo "Generating mappings..."

set -e
$make_mappings_file
./tools/fold-mappings.rb < $mappings_out > $folded_mappings
mv $folded_mappings $mappings_out
set +e

echo "Done"
