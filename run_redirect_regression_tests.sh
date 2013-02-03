#!/bin/bash

set -e -x

csv=dist/full_urls.csv

# find all mappings and tests
# relies upon lines begining with Old Url are sorted ahead of those begining with http://
cat data/mappings/subsets/*.csv data/subsets/*.csv | sort | uniq > $csv

prove -l tools/test_csv.pl :: $csv
