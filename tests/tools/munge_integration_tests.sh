#!/bin/sh

# tests that admin urls are mapped to public
# and that urls which appear first trump older urls

# Ensure sort behaviour is consistent
export LC_ALL=C

test_document_mappings='/tmp/munge_test_document_mappings.csv'
fetched_data='/tmp/munge_test_fetched_data.csv'
output='/tmp/munge_test.out'

run_munge () {
  cat $fetched_data |
  ./munge/munge.rb $test_document_mappings 2>/dev/null |
  ./tools/fold-mappings.rb |
  ./tools/choose-status.rb |
  ./munge/strip-empty-quotes-and-whitespace.rb |
  ./munge/reverse-csv.rb |
  ./tools/tidy_mappings.pl --trump > $output 2> /dev/null
}

cat > $test_document_mappings <<!
Old Url,New Url,Status,Whole Tag,Slug,Admin Url,State
"",https://www.gov.uk/government/policies/remapped-public-url,"",Open,remapped-public-url,https://whitehall-admin.production.alphagov.co.uk/government/admin/policy_advisory_groups/88/edit,archived
!

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk,https://whitehall-admin.production.alphagov.co.uk/government/admin/policy_advisory_groups/88/edit,,passed in string,1
http://www.decc.gov.uk,https://gov.uk/this-should-be-trumped-and-not-appear,,passed in string,2
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,,passed in string,3
http://www.decc.gov.uk/foo?,https://gov.uk/this-should-not-appear-as-foo,,passed in string,3
http://www.decc.gov.uk/foo#,https://gov.uk/this-should-not-appear-as-foo,,passed in string,3
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk,https://www.gov.uk/government/policies/remapped-public-url,301
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,301
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

# test: ensure that different cases are treated correctly with trumping

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,,passed in string,3
http://www.decc.gov.uk/FOO,https://gov.uk/this-should-not-appear-as-foo-as-capitalised,,passed in string,3
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,301
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

# test: ensure that we fold mappings correctly

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk/foo,http://www.decc.gov.uk/bar,,passed in string,3
http://www.decc.gov.uk/bar,http://www.decc.gov.uk/quux,,passed in string,4
http://www.decc.gov.uk/quux,https://gov.uk/this-is-the-end-target,,passed in string,5
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk/bar,https://gov.uk/this-is-the-end-target,301
http://www.decc.gov.uk/foo,https://gov.uk/this-is-the-end-target,301
http://www.decc.gov.uk/quux,https://gov.uk/this-is-the-end-target,301
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

# test: ensure we capture the status correctly when it changes

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk/foo,http://www.decc.gov.uk/bar,,passed in string,3
http://www.decc.gov.uk/bar,,410,passed in string,4
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk/bar,,410
http://www.decc.gov.uk/foo,,410
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

echo "$0: OK"
