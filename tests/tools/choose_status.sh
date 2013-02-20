#!/bin/sh

fetched_data='/tmp/munge_test_fetched_data.csv'
output='/tmp/munge_test.out'

# test: ensure that we fold mappings correctly

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk/foo,,301
http://www.decc.gov.uk/bar,http://www.gov.uk/bar,301
http://www.decc.gov.uk/baz,http://www.gov.uk/baz,418
!

./tools/choose-status.rb < $fetched_data > $output

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk/foo,,410
http://www.decc.gov.uk/bar,http://www.gov.uk/bar,301
http://www.decc.gov.uk/baz,http://www.gov.uk/baz,418
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

echo "$0: OK"
