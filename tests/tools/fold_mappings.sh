#!/bin/sh

fetched_data='/tmp/munge_test_fetched_data.csv'
output='/tmp/munge_test.out'

# test: ensure that we fold mappings correctly

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk/foo,http://www.decc.gov.uk/bar,301
http://www.decc.gov.uk/bar,http://www.decc.gov.uk/quux,301
http://www.decc.gov.uk/quux,https://gov.uk/this-is-the-end-target,301
!

./tools/fold-mappings.rb < $fetched_data > $output

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk/foo,https://gov.uk/this-is-the-end-target,301
http://www.decc.gov.uk/bar,https://gov.uk/this-is-the-end-target,301
http://www.decc.gov.uk/quux,https://gov.uk/this-is-the-end-target,301
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

echo "$0: OK"
