#!/bin/sh

errors() {
    sed -e '/^# *at tools\/validate_mappings.pl/d' -e '/^# *Looks/d' /tmp/validate.err > /tmp/validate.errors
}

#
#  simple
#
cat > /tmp/validate.in <<!
Old Url,New Url,Status,Stuff
http://example.com/ok-301,https://www.gov.uk,301
http://example.com/invalid-status,,404
http://example.com/missing-status-410,,410
http://example.com/missing-status-301,https://www.gov.uk,301,
http://example.com/not-in-whitelist,https://whatfettle.com,301,
http://example.com/ok-410,,410
http://EXAMPLE.COM/bad-capitals,,410
http://example.com/query-string?,,410
http://example.com/empty-query-string?,,410
http://example.com/fragid#OldUrlFragmentIdenfierMakesNoSense,,410
http://example.com/empty-fragid#,,410
http://example.com/empty-fragid-on-slash/#,,410
http://example.com/empty-fragid-on-query/?#,,410
http://example.com/empty-fragid-on-query-slash/?#,,410
http://example.com/418-without-a-new-url,,418
!
tools/validate_mappings.pl /tmp/validate.in > /tmp/validate.out 2> /tmp/validate.err

errors

diff /tmp/validate.errors - <<!
#   Failed test 'invalid Status [404] for Old Url [http://example.com/invalid-status] line 3'
#   Failed test 'New Url [https://whatfettle.com] host [whatfettle.com] not whitelist /tmp/validate.in line 6'
#   Failed test 'Old Url [http://EXAMPLE.COM/bad-capitals] is not canonical [http://example.com/bad-capitals] /tmp/validate.in line 8'
#          got: 'http://EXAMPLE.COM/bad-capitals'
#     expected: 'http://example.com/bad-capitals'
#   Failed test 'Old Url [http://example.com/query-string?] is not canonical [http://example.com/query-string] /tmp/validate.in line 9'
#          got: 'http://example.com/query-string?'
#     expected: 'http://example.com/query-string'
#   Failed test 'Old Url [http://example.com/empty-query-string?] is not canonical [http://example.com/empty-query-string] /tmp/validate.in line 10'
#          got: 'http://example.com/empty-query-string?'
#     expected: 'http://example.com/empty-query-string'
#   Failed test 'Old Url [http://example.com/fragid\#OldUrlFragmentIdenfierMakesNoSense] is not canonical [http://example.com/fragid] /tmp/validate.in line 11'
#          got: 'http://example.com/fragid#OldUrlFragmentIdenfierMakesNoSense'
#     expected: 'http://example.com/fragid'
#   Failed test 'Old Url [http://example.com/empty-fragid\#] is not canonical [http://example.com/empty-fragid] /tmp/validate.in line 12'
#          got: 'http://example.com/empty-fragid#'
#     expected: 'http://example.com/empty-fragid'
#   Failed test 'Old Url [http://example.com/empty-fragid-on-slash/\#] is not canonical [http://example.com/empty-fragid-on-slash] /tmp/validate.in line 13'
#          got: 'http://example.com/empty-fragid-on-slash/#'
#     expected: 'http://example.com/empty-fragid-on-slash'
#   Failed test 'Old Url [http://example.com/empty-fragid-on-query/?\#] is not canonical [http://example.com/empty-fragid-on-query] /tmp/validate.in line 14'
#          got: 'http://example.com/empty-fragid-on-query/?#'
#     expected: 'http://example.com/empty-fragid-on-query'
#   Failed test 'Old Url [http://example.com/empty-fragid-on-query-slash/?\#] is not canonical [http://example.com/empty-fragid-on-query-slash] /tmp/validate.in line 15'
#          got: 'http://example.com/empty-fragid-on-query-slash/?#'
#     expected: 'http://example.com/empty-fragid-on-query-slash'
#   Failed test '418 New Url [] should be a full URI /tmp/validate.in line 16'
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

#
#  wrong columns
#
cat > /tmp/validate.in <<!
Old Url,Status,New Url,Status,Stuff
!
tools/validate_mappings.pl /tmp/validate.in > /tmp/validate.out 2> /tmp/validate.err

errors

diff /tmp/validate.errors - <<!
#   Failed test 'incorrect column names [Old Url,Status,New Url,Status,Stuff]'
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

#
#  wrong columns
#
cat > /tmp/validate.in <<!
Old Url,New Url,Statuses
!
tools/validate_mappings.pl /tmp/validate.in > /tmp/validate.out 2> /tmp/validate.err

errors

diff /tmp/validate.errors - <<!
#   Failed test 'incorrect column names [Old Url,New Url,Statuses]'
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

echo "$0: OK"
