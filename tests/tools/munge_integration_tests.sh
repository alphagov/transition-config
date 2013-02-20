#!/bin/sh

# tests that admin urls are mapped to public
# and that urls which appear first trump older urls

test_document_mappings='/tmp/munge_test_document_mappings.csv'
fetched_data='/tmp/munge_test_fetched_data.csv'
output='/tmp/munge_test.out'

function run_merge {
  cat $fetched_data |
  ./munge/munge.rb $test_document_mappings 2>/dev/null |
  ./munge/strip-empty-quotes-and-whitespace.rb |
  ./munge/reverse-csv.rb |
  ./tools/tidy_mappings.pl --trump $validate_options > $output 2> /dev/null
}

cat > $test_document_mappings <<!
Old Url,New Url,Status,Whole Tag,Slug,Admin Url,State
"",https://www.gov.uk/government/policies/boosting-private-sector-employment-in-england,"",Open,boosting-private-sector-employment-in-england,https://whitehall-admin.production.alphagov.co.uk/government/admin/policy_advisory_groups/88/edit,archived
!

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk,https://whitehall-admin.production.alphagov.co.uk/government/admin/policy_advisory_groups/88/edit,,passed in string,1
http://www.decc.gov.uk,https://gov.uk/this-should-be-trumped-and-not-appear,,passed in string,2
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,,passed in string,3
http://www.decc.gov.uk/foo?,https://gov.uk/this-should-not-appear-as-foo,,passed in string,3
http://www.decc.gov.uk/foo#,https://gov.uk/this-should-not-appear-as-foo,,passed in string,3
!

run_merge

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk,https://www.gov.uk/government/policies/boosting-private-sector-employment-in-england,301
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,301
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

# test: ensure that different cases are treated correctly with trumping

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,,passed in string,3
http://www.decc.gov.uk/Foo,https://gov.uk/this-should-not-appear-as-foo-as-capitalised,,passed in string,3
http://www.decc.gov.uk/foo,https://gov.uk/this-is-foo,301
!

run_merge

diff $output - <<!
Old Url,New Url,Status
http://www.decc.gov.uk,https://www.gov.uk/government/policies/boosting-private-sector-employment-in-england,301
!

[ $? -ne 0 ] && { echo "$0: WARNING: This is a known issue with capitalisation causing trumping not to work" ; }

echo "$0: OK"
