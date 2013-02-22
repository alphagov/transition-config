#!/bin/sh

test_file_one='/tmp/test_csvcat_one.csv'
test_file_two='/tmp/test_csvcat_two.csv'
test_file_no_trailing_newline='/tmp/test_csvcat_file_no_trailing_newline.csv'
output='/tmp/test_csvcat_output.csv'

# test: ensure cat strips headers and adds trailing newline

cat > $test_file_one <<!
foo,bar
line1,
line2,
!

cat > $test_file_two <<!
baz,quux
line3,
line4,
!

printf "%s\n%s" "header" "line-without-newline" > $test_file_no_trailing_newline

./tools/csvcat.sh $test_file_one $test_file_no_trailing_newline $test_file_two > $output 2> /dev/null

diff $output - <<!
old url,new url,status,source,row_number
line1,
line2,
line-without-newline
line3,
line4,
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

echo "$0: OK"
