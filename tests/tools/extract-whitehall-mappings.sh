#!/bin/sh

whitehall_file='/tmp/test_extract_whitehall_mappings_input.csv'
output='/tmp/test_extract_whitehall_mappings_output.csv'

# test: ensure we only include domains from host, uses ssh, and we chop to three columns

cat > $whitehall_file <<!
Old Url,New Url,Status,Slug,Admin Url,State
http://example.com/foo,,,,,
https://example.com/uses-ssh,,,,,
http://notincluded.com/foo,,,,,
!

./tools/extract-whitehall-mappings.sh example.com < $whitehall_file > $output

diff $output - <<!
old url,new url,status,source,row_number
http://example.com/foo,,
https://example.com/uses-ssh,,
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

# test: remove empty quotes

cat > $whitehall_file <<!
Old Url,New Url,Status,Slug,Admin Url,State
http://example.com/foo,"",,,,
!

./tools/extract-whitehall-mappings.sh example.com < $whitehall_file > $output

diff $output - <<!
old url,new url,status,source,row_number
http://example.com/foo,,
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

echo "$0: OK"
