#!/bin/sh

test_document_mappings='cache/test_whitehall.csv'
test_fetch_list='/tmp/fetch.csv'
test_sites_directory='/tmp/sites'
output_dir='/tmp/output'
cache='./cache'
test_site='test'
other_source='googledoc'

output="${output_dir}/${test_site}.csv"
fetched_data="${cache}/${test_site}/${other_source}.csv"

run_munge () {
  ./munge/generate-redirects.sh -n -F $test_fetch_list -o $output_dir -s $test_sites_directory -W "$test_document_mappings" $test_site > /tmp/munge.out 2> /tmp/munge.err
  if [ $? -ne 0 ] ; then
      cat /tmp/munge.err
      echo "./munge/generate-redirects.sh failed: $?"
      fail
  fi
}

setup() {
mkdir -p $cache/$test_site
mkdir -p $output_dir

cat > $test_fetch_list <<!
Site,Name,Source
$test_site,$other_source,https://example.com
!

mkdir -p $test_sites_directory
cat > "$test_sites_directory/$test_site.yml" <<!
---
site: $test_site
host: www.example.com
redirection_date: 13th December 2012
tna_timestamp: 20120816224015
title: Test Website
homepage_furl: www.gov.uk/test
homepage: https://www.gov.uk/government/organisations/test-organisation
---
!

cat > $test_document_mappings <<!
Old Url,New Url,Status,Slug,Admin Url,State
"",https://www.gov.uk/government/policies/remapped-public-url,"",remapped-public-url,https://whitehall-admin.production.alphagov.co.uk/government/admin/policy_advisory_groups/88/edit,archived
!
}

teardown() {
  rm -f $test_document_mappings $test_fetch_list $fetched_data $output
  rm -fr $test_sites_directory
  rm -fr $output_dir
}

fail () {
    echo "$0: FAIL"
    teardown
    exit 1;
}

# test: ensure we take sources from fetch.csv and whitehall

setup

cat >> $test_document_mappings <<!
Old Url,New Url,Status,Slug,Admin Url,State
http://www.example.com/from-whitehall,https://www.gov.uk/from-whitehall,,,https://whitehall-admin.production.alphagov.co.uk/government/admin/organisations/1/edit,
!

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.example.com/from-googledoc,https://www.gov.uk/from-googledoc,,passed in string,1
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.example.com/from-googledoc,https://www.gov.uk/from-googledoc,301
http://www.example.com/from-whitehall,https://www.gov.uk/from-whitehall,301
!

[ $? -ne 0 ] && fail

teardown

# test: ensure admin urls are mapped to public and earlier urls trump later ones

setup

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.example.com/bar,https://whitehall-admin.production.alphagov.co.uk/government/admin/policy_advisory_groups/88/edit,,passed in string,1
http://www.example.com/bar,https://www.gov.uk/this-should-be-trumped-and-not-appear,,passed in string,2
http://www.example.com/foo,https://www.gov.uk/this-is-foo,,passed in string,3
http://www.example.com/foo?,https://www.gov.uk/this-should-not-appear-as-foo,,passed in string,3
http://www.example.com/foo#,https://www.gov.uk/this-should-not-appear-as-foo,,passed in string,3
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.example.com/bar,https://www.gov.uk/government/policies/remapped-public-url,301
http://www.example.com/foo,https://www.gov.uk/this-is-foo,301
!

[ $? -ne 0 ] && fail

teardown

# test: ensure that different cases are treated correctly with trumping

setup

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.example.com/foo,https://www.gov.uk/this-is-foo,,passed in string,3
http://www.example.com/FOO,https://www.gov.uk/this-should-not-appear-as-foo-as-capitalised,,passed in string,3
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.example.com/foo,https://www.gov.uk/this-is-foo,301
!

[ $? -ne 0 ] && fail

teardown

# test: ensure that we fold mappings correctly

setup

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.example.com/foo,http://www.example.com/bar,,passed in string,3
http://www.example.com/bar,http://www.example.com/quux,,passed in string,4
http://www.example.com/quux,https://www.gov.uk/this-is-the-end-target,,passed in string,5
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.example.com/bar,https://www.gov.uk/this-is-the-end-target,301
http://www.example.com/foo,https://www.gov.uk/this-is-the-end-target,301
http://www.example.com/quux,https://www.gov.uk/this-is-the-end-target,301
!

[ $? -ne 0 ] && fail

teardown

# test: ensure we capture the status correctly when it changes

setup

cat > $fetched_data <<!
old url,new url,status,source,row_number
http://www.example.com/foo,http://www.example.com/bar,,passed in string,3
http://www.example.com/bar,,410,passed in string,4
!

run_munge

diff $output - <<!
Old Url,New Url,Status
http://www.example.com/bar,,410
http://www.example.com/foo,,410
!

[ $? -ne 0 ] && fail

teardown

echo "$0: OK"
